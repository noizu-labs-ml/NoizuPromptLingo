defmodule Codefresh.Accounts.ApiToken do
  @moduledoc """
  Named, org-scoped API tokens for SDK / CLI authentication.

  Raw token shown once at creation (via `:raw_token` virtual field); server
  stores only the bcrypt hash plus an 8-char `key_prefix` for support lookup
  and indexed candidate narrowing during verification.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  # Roles usable by tokens — excludes :owner (never grant owner to a non-human)
  @token_roles ~w(admin editor viewer ci)
  @raw_token_bytes 32

  schema "api_tokens" do
    field :name, :string
    field :token_hash, :binary
    field :key_prefix, :string
    field :role, :string
    field :expires_at, :utc_datetime
    field :last_used_at, :utc_datetime
    field :revoked_at, :utc_datetime

    field :raw_token, :string, virtual: true, redact: true

    belongs_to :organization, Codefresh.Organizations.Organization
    belongs_to :created_by, Codefresh.Accounts.User, foreign_key: :created_by_user_id

    timestamps(type: :utc_datetime)
  end

  def roles, do: @token_roles

  def generate_raw_token do
    :crypto.strong_rand_bytes(@raw_token_bytes) |> Base.url_encode64(padding: false)
  end

  def hash_token(raw) when is_binary(raw), do: Bcrypt.hash_pwd_salt(raw)

  def verify_token(raw, hash) when is_binary(raw) and is_binary(hash),
    do: Bcrypt.verify_pass(raw, hash)

  def derive_key_prefix(raw) when is_binary(raw), do: String.slice(raw, 0, 8)

  def create_changeset(token, attrs) do
    token
    |> cast(attrs, [
      :organization_id,
      :name,
      :role,
      :expires_at,
      :created_by_user_id,
      :raw_token
    ])
    |> validate_required([:organization_id, :name, :role, :raw_token])
    |> validate_inclusion(:role, @token_roles)
    |> validate_length(:name, min: 1, max: 120)
    |> apply_token_fields()
    |> unique_constraint([:organization_id, :name])
    |> foreign_key_constraint(:organization_id)
  end

  def revoke_changeset(token) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    change(token, revoked_at: now)
  end

  @doc """
  Rename the token to a revoked-marker name so the original name frees up
  for a rotation replacement. Paired with revoke in a single tx.
  """
  def revoke_and_rename_changeset(token) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    suffix = "[revoked #{DateTime.to_iso8601(now)}]"

    token
    |> change(revoked_at: now, name: truncate_name("#{token.name} #{suffix}"))
  end

  def touch_last_used_changeset(token) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    change(token, last_used_at: now)
  end

  def active?(%__MODULE__{} = t) do
    cond do
      t.revoked_at != nil -> false
      t.expires_at != nil and DateTime.compare(t.expires_at, DateTime.utc_now()) != :gt -> false
      true -> true
    end
  end

  defp apply_token_fields(changeset) do
    case get_change(changeset, :raw_token) do
      nil ->
        changeset

      raw ->
        changeset
        |> put_change(:token_hash, hash_token(raw))
        |> put_change(:key_prefix, derive_key_prefix(raw))
    end
  end

  defp truncate_name(n) when byte_size(n) <= 120, do: n
  defp truncate_name(n), do: binary_part(n, 0, 120)
end
