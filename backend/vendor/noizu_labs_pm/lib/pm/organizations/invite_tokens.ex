defmodule Noizu.PM.Organizations.InviteTokens do
  @moduledoc """
  Shared invite-token store on `Noizu.PM.Repo` (pm_core). Invites are org-scoped
  and must be visible to whichever host app (TRP, NPL) created or redeems them,
  so the whole flow — issue, list, revoke, redeem — lives here rather than on
  an app-local DB.
  """
  alias Noizu.PM.Organizations.InviteToken, as: Entity
  alias Noizu.PM.Schema.Organizations.InviteToken, as: Schema
  alias Noizu.PM.Schema.Organizations.InviteTokenRedemption, as: RedemptionSchema

  use Noizu.Repo
  def_repo(entity: Entity)

  import Ecto.Query

  @doc "Roles an inviter may attach to an invite token (never `owner`)."
  def invite_roles, do: ~w(admin member viewer)

  @doc """
  Invites for an organization, newest first.

  Deliberately never selects `token_hash` — the raw token is shown exactly
  once, at creation, and the hash has no business leaving the database.
  """
  def list_for_organization(organization_id) do
    from(t in Schema,
      where: t.organization_id == ^organization_id,
      order_by: [desc: t.inserted_at],
      select: %{
        id: t.id,
        email: t.email,
        role: t.role,
        key_prefix: t.key_prefix,
        status: t.status,
        revoked: t.revoked,
        uses: t.uses,
        max_uses: t.max_uses,
        starts_at: t.starts_at,
        expires_at: t.expires_at,
        accepted_at: t.accepted_at,
        inserted_at: t.inserted_at
      }
    )
    |> Noizu.PM.Repo.all()
  end

  @doc """
  Creates an invite token, returning `{:ok, invite, raw_token}`. The raw
  token is generated here (rather than accepted as an attr) because it must
  never be persisted anywhere but `token_hash`.
  """
  def create(attrs) do
    raw_token = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
    key_prefix = String.slice(raw_token, 0, 8)
    token_hash = Bcrypt.hash_pwd_salt(raw_token)

    result =
      %Schema{}
      |> Schema.changeset(Map.merge(attrs, %{token_hash: token_hash, key_prefix: key_prefix}))
      |> Noizu.PM.Repo.insert()

    case result do
      {:ok, invite} -> {:ok, invite, raw_token}
      error -> error
    end
  end

  @doc """
  Revokes an invite by id, scoped to its organization so one org cannot
  revoke another's token by guessing an id.
  """
  def revoke(organization_id, invite_id) do
    now = DateTime.utc_now()

    {count, _} =
      from(t in Schema,
        where: t.id == ^invite_id and t.organization_id == ^organization_id,
        where: t.revoked == false
      )
      |> Noizu.PM.Repo.update_all(set: [revoked: true, status: "revoked", updated_at: now])

    case count do
      0 -> {:error, :not_found}
      _ -> :ok
    end
  end

  @doc """
  Looks up a live (unrevoked, in-window, not-exhausted) invite matching
  `raw_token`, optionally scoped to `email` when the invite was addressed to
  one. `key_prefix` narrows the candidate set; `Bcrypt.verify_pass/2` does
  the real comparison since `token_hash` is salted per-row.
  """
  def find_active_by_raw_token(raw_token, email \\ nil) when is_binary(raw_token) do
    key_prefix = String.slice(raw_token, 0, 8)
    now = DateTime.utc_now()
    email = email && normalize_email(email)

    from(t in Schema,
      where: t.key_prefix == ^key_prefix and t.revoked == false,
      where: is_nil(t.starts_at) or t.starts_at <= ^now,
      where: is_nil(t.expires_at) or t.expires_at > ^now,
      where: is_nil(t.max_uses) or t.uses < t.max_uses
    )
    |> Noizu.PM.Repo.all()
    |> Enum.find(fn token ->
      email_matches? =
        is_nil(token.email) || is_nil(email) || normalize_email(token.email) == email

      email_matches? && Bcrypt.verify_pass(raw_token, token.token_hash)
    end)
    |> case do
      nil -> {:error, :invalid_token}
      token -> {:ok, token}
    end
  end

  @doc """
  Atomically consumes one use of `invite_token` for `user_id` and records a
  redemption row. The max_uses check lives in the UPDATE's WHERE clause
  rather than a read-then-write check, so two concurrent redemptions of a
  single-use token cannot both pass: the loser matches zero rows.

  Does NOT grant the org membership — callers compose that (and should wrap
  both in one `Noizu.PM.Repo.transaction/1`) since the membership call is
  app-specific (`add_scoped_member` raises on already-member, which the
  caller typically guards against beforehand).

  Returns `{:ok, redemption}` or `{:error, :invite_exhausted | Ecto.Changeset.t()}`.
  """
  def redeem(invite_token, user_id, redemption_attrs \\ %{}) do
    now = DateTime.utc_now()

    consumed =
      from(t in Schema,
        where: t.id == ^invite_token.id,
        where: t.revoked == false,
        where: is_nil(t.max_uses) or t.uses < t.max_uses
      )
      |> Noizu.PM.Repo.update_all(
        inc: [uses: 1, redemption_count: 1],
        set: [
          accepted_by: user_id,
          accepted_at: invite_token.accepted_at || now,
          status: "accepted",
          updated_at: now
        ]
      )

    attrs =
      Map.merge(
        %{invite_token_id: invite_token.id, user_id: user_id, redeemed_at: now},
        redemption_attrs
      )

    with {1, _} <- consumed,
         {:ok, redemption} <-
           %RedemptionSchema{} |> RedemptionSchema.changeset(attrs) |> Noizu.PM.Repo.insert() do
      {:ok, redemption}
    else
      {0, _} -> {:error, :invite_exhausted}
      {:error, reason} -> {:error, reason}
    end
  end

  defp normalize_email(email), do: email |> String.trim() |> String.downcase()
end
