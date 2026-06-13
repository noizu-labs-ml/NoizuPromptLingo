defmodule Codefresh.ApiTokens do
  @moduledoc """
  Context for org-scoped API tokens (SDK / CLI auth).

  Token values are shown exactly once at creation; subsequent reads return only
  metadata (name, role, key_prefix, expires_at, last_used_at, revoked_at).
  """

  import Ecto.Query, only: [from: 2]
  alias Ecto.Multi
  alias Codefresh.Repo
  alias Codefresh.Accounts.ApiToken

  @default_expiry_days 90

  def list_tokens(organization_id) do
    Repo.all(
      from t in ApiToken,
        where: t.organization_id == ^organization_id,
        order_by: [desc: t.inserted_at]
    )
  end

  def get_token!(id), do: Repo.get!(ApiToken, id)

  def get_org_token!(organization_id, id) do
    Repo.one!(
      from t in ApiToken,
        where: t.organization_id == ^organization_id and t.id == ^id
    )
  end

  @doc """
  Create a new API token. Returns `{:ok, token, raw_token}` on success.

  `attrs` supports: `:name` (required), `:role` (required), `:expires_at` (optional;
  defaults to now + 90 days), `:organization_id` (required), `:created_by_user_id` (optional).
  """
  def create_token(attrs) when is_map(attrs) do
    raw = ApiToken.generate_raw_token()

    attrs_norm =
      attrs
      |> normalize_keys()
      |> Map.put_new_lazy(:expires_at, fn ->
        DateTime.utc_now()
        |> DateTime.add(@default_expiry_days * 24 * 3600, :second)
        |> DateTime.truncate(:second)
      end)
      |> Map.put(:raw_token, raw)

    result =
      %ApiToken{}
      |> ApiToken.create_changeset(attrs_norm)
      |> Repo.insert()

    case result do
      {:ok, token} -> {:ok, token, raw}
      {:error, cs} -> {:error, cs}
    end
  end

  def revoke_token(%ApiToken{} = token) do
    token
    |> ApiToken.revoke_changeset()
    |> Repo.update()
  end

  @doc """
  Rotate a token: revoke the old (renaming it out of the unique slot) and issue
  a new token with the same original name + role. Returns `{:ok, new_token, raw_token}`.
  """
  def rotate_token(%ApiToken{} = old) do
    original_name = old.name
    role = old.role
    expires_at = old.expires_at
    created_by = old.created_by_user_id

    Multi.new()
    |> Multi.update(:revoke_old, ApiToken.revoke_and_rename_changeset(old))
    |> Multi.run(:new_token, fn _repo, _ ->
      create_token(%{
        organization_id: old.organization_id,
        name: original_name,
        role: role,
        expires_at: expires_at,
        created_by_user_id: created_by
      })
      |> case do
        {:ok, token, raw} -> {:ok, {token, raw}}
        {:error, cs} -> {:error, cs}
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{new_token: {token, raw}}} -> {:ok, token, raw}
      {:error, _step, reason, _} -> {:error, reason}
    end
  end

  @doc """
  Authenticate a raw token. Uses indexed key_prefix to narrow candidates then
  constant-time bcrypt verify. On success, touches `last_used_at`.
  """
  def authenticate(raw) when is_binary(raw) and raw != "" do
    prefix = ApiToken.derive_key_prefix(raw)

    candidates =
      Repo.all(
        from t in ApiToken,
          where: t.key_prefix == ^prefix and is_nil(t.revoked_at)
      )

    matched = Enum.find(candidates, fn t -> ApiToken.verify_token(raw, t.token_hash) end)

    cond do
      matched == nil -> {:error, :invalid_token}
      not ApiToken.active?(matched) -> {:error, :token_inactive}
      true -> touch_and_return(matched)
    end
  end

  def authenticate(_), do: {:error, :invalid_token}

  defp touch_and_return(token) do
    case token |> ApiToken.touch_last_used_changeset() |> Repo.update() do
      {:ok, updated} -> {:ok, updated}
      {:error, _} -> {:ok, token}
    end
  end

  defp normalize_keys(attrs) do
    for {k, v} <- attrs, into: %{} do
      key =
        cond do
          is_atom(k) -> k
          is_binary(k) -> safe_atom(k)
        end

      {key, v}
    end
  end

  defp safe_atom(str) do
    String.to_existing_atom(str)
  rescue
    ArgumentError -> String.to_atom(str)
  end
end
