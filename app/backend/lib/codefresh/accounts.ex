defmodule Codefresh.Accounts do
  @moduledoc """
  Authentication, user registration, invite tokens, and memberships.

  Signup is invite-gated: `register_user_with_invite/2` is the only supported
  path for new users. A valid, active invite token is required.

  Bootstrap flow: create an invite with `organization_id: nil` — the redeemer
  will create a fresh org and become its owner. Team flow: create an invite
  with an `organization_id`; the redeemer joins that org with the invite's role.
  """

  import Ecto.Query, only: [from: 2]
  alias Ecto.Multi
  alias Codefresh.Repo
  alias Codefresh.Accounts.{User, Membership, InviteToken}
  alias Codefresh.Organizations

  # ──────────────────────────────────────────────────────────────────────────
  # Users
  # ──────────────────────────────────────────────────────────────────────────

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: String.downcase(email))
  end

  @doc """
  Low-level user creation. Does NOT check invite tokens. Used by seeds and by
  the invite-gated multi. External callers should use `register_user_with_invite/2`.
  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def authenticate_user(email, password) do
    user = get_user_by_email(email)

    cond do
      user && Bcrypt.verify_pass(password, user.hashed_password) ->
        {:ok, user}

      user ->
        {:error, :invalid_credentials}

      true ->
        # Timing-attack resistance
        Bcrypt.no_user_verify()
        {:error, :invalid_credentials}
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Memberships
  # ──────────────────────────────────────────────────────────────────────────

  def create_membership(attrs) do
    %Membership{}
    |> Membership.changeset(attrs)
    |> Repo.insert()
  end

  def list_memberships_for_user(user_id) do
    Repo.all(from m in Membership, where: m.user_id == ^user_id)
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Invite tokens
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Create an invite token. Returns `{:ok, invite, raw_token}` on success.

  The raw token is shown ONCE — it is never persisted in cleartext. Store it
  out-of-band (email, deployment logs) immediately; recovery is impossible.

  ## Attrs

    * `:organization_id` (optional) — nil for bootstrap invites
    * `:email` (optional) — bind to a specific email
    * `:role` (required) — one of `Membership.roles()`
    * `:invited_by_user_id` (optional) — audit trail
    * `:expires_at` (optional) — nil for non-expiring
    * `:max_uses` (default 1)
    * `:metadata` (default %{})
  """
  def create_invite_token(attrs) when is_map(attrs) do
    raw_token = InviteToken.generate_raw_token()
    attrs_with_raw = attrs |> stringify_then_atomize() |> Map.put(:raw_token, raw_token)

    result =
      %InviteToken{}
      |> InviteToken.create_changeset(attrs_with_raw)
      |> Repo.insert()

    case result do
      {:ok, invite} -> {:ok, invite, raw_token}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_invite_token!(id), do: Repo.get!(InviteToken, id)

  def list_active_invites_for_org(organization_id) do
    Repo.all(
      from i in InviteToken,
        where: i.organization_id == ^organization_id,
        where: is_nil(i.revoked_at),
        where: i.use_count < i.max_uses,
        order_by: [desc: i.inserted_at]
    )
  end

  def revoke_invite_token(%InviteToken{} = invite) do
    invite
    |> InviteToken.revoke_changeset()
    |> Repo.update()
  end

  @doc """
  Finds an active invite by its raw token. Uses the indexed key_prefix to narrow
  candidates, then constant-time-compares via bcrypt.
  """
  def find_active_invite_by_raw_token(raw_token) when is_binary(raw_token) and raw_token != "" do
    prefix = InviteToken.derive_key_prefix(raw_token)

    candidates =
      Repo.all(
        from i in InviteToken,
          where: i.key_prefix == ^prefix,
          where: is_nil(i.revoked_at),
          where: i.use_count < i.max_uses
      )

    matched =
      Enum.find(candidates, fn invite ->
        InviteToken.verify_token(raw_token, invite.token_hash)
      end)

    cond do
      matched == nil -> {:error, :invalid_invite_token}
      not InviteToken.active?(matched) -> {:error, :invite_inactive}
      true -> {:ok, matched}
    end
  end

  def find_active_invite_by_raw_token(_), do: {:error, :invalid_invite_token}

  # ──────────────────────────────────────────────────────────────────────────
  # Invite-gated registration (the only supported signup path)
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Register a new user using a valid invite token.

  The full transaction:
    1. Validate the raw invite token (hash match, not revoked, not expired, not exhausted)
    2. Check invite's email restriction (if any) matches submitted email
    3. Insert the user
    4. Resolve or create the target organization
    5. Create the membership (user joins org with invite's role)
    6. Increment invite's use_count + set last_redeemed_at

  Returns `{:ok, %{user: user, organization: org, membership: membership, invite: invite}}`
  on success, or `{:error, reason}` where reason is one of:

    * `:invalid_invite_token` — token doesn't match any row
    * `:invite_inactive` — revoked, expired, or exhausted
    * `:invite_email_mismatch` — invite bound to a different email
    * `:email_required` — submitted email missing (only when invite is email-bound)
    * `:org_not_found` — invite references an org that no longer exists
    * `%Ecto.Changeset{}` — user creation validation failed
  """
  def register_user_with_invite(user_attrs, raw_token) when is_binary(raw_token) do
    Multi.new()
    |> Multi.run(:invite, fn _repo, _changes ->
      find_active_invite_by_raw_token(raw_token)
    end)
    |> Multi.run(:invite_email_check, fn _repo, %{invite: invite} ->
      validate_invite_email(invite, fetch_email(user_attrs))
    end)
    |> Multi.insert(:user, fn _changes ->
      User.registration_changeset(%User{}, user_attrs)
    end)
    |> Multi.run(:organization, fn _repo, %{invite: invite, user: user} ->
      resolve_or_create_org(invite, user)
    end)
    |> Multi.insert(:membership, fn %{invite: invite, user: user, organization: org} ->
      Membership.changeset(%Membership{}, %{
        organization_id: org.id,
        user_id: user.id,
        role: invite.role
      })
    end)
    |> Multi.update(:redeem_invite, fn %{invite: invite} ->
      InviteToken.redeem_changeset(invite)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user, organization: org, membership: membership, invite: invite}} ->
        {:ok, %{user: user, organization: org, membership: membership, invite: invite}}

      {:error, :invite, reason, _} ->
        {:error, reason}

      {:error, :invite_email_check, reason, _} ->
        {:error, reason}

      {:error, :user, %Ecto.Changeset{} = cs, _} ->
        {:error, cs}

      {:error, :organization, reason, _} ->
        {:error, reason}

      {:error, :membership, %Ecto.Changeset{} = cs, _} ->
        {:error, cs}

      {:error, _step, reason, _} ->
        {:error, reason}
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Internal helpers
  # ──────────────────────────────────────────────────────────────────────────

  defp fetch_email(%{} = attrs) do
    attrs["email"] || attrs[:email]
  end

  defp validate_invite_email(%InviteToken{email: nil}, _submitted),
    do: {:ok, :no_email_restriction}

  defp validate_invite_email(%InviteToken{email: _bound}, nil), do: {:error, :email_required}

  defp validate_invite_email(%InviteToken{email: bound}, submitted) when is_binary(submitted) do
    if String.downcase(bound) == String.downcase(submitted) do
      {:ok, :email_match}
    else
      {:error, :invite_email_mismatch}
    end
  end

  # Invite has no org → bootstrap: create a fresh org, redeemer becomes owner
  defp resolve_or_create_org(%InviteToken{organization_id: nil}, %User{} = user) do
    base = user.email |> String.split("@") |> List.first() |> String.replace(~r/[^a-z0-9]/, "-")
    slug = "#{base}-#{short_id()}"

    Organizations.create_organization(%{
      "slug" => slug,
      "name" => "#{base}'s org"
    })
  end

  defp resolve_or_create_org(%InviteToken{organization_id: org_id}, _user) do
    case Repo.get(Codefresh.Organizations.Organization, org_id) do
      nil -> {:error, :org_not_found}
      org -> {:ok, org}
    end
  end

  defp short_id do
    :crypto.strong_rand_bytes(4) |> Base.url_encode64(padding: false) |> String.downcase()
  end

  # Accept either atom- or string-keyed attrs; normalize to atoms for InviteToken changeset
  defp stringify_then_atomize(attrs) do
    for {k, v} <- attrs, into: %{} do
      key = if is_atom(k), do: k, else: String.to_existing_atom(to_string(k))
      {key, v}
    end
  rescue
    ArgumentError -> attrs
  end
end
