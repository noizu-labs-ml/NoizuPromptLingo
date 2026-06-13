defmodule Codefresh.Accounts.InviteToken do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @roles Codefresh.Accounts.Membership.roles()
  @raw_token_bytes 32

  schema "invite_tokens" do
    field :email, :string
    field :role, :string
    field :token_hash, :binary
    field :key_prefix, :string
    field :expires_at, :utc_datetime
    field :max_uses, :integer, default: 1
    field :use_count, :integer, default: 0
    field :last_redeemed_at, :utc_datetime
    field :revoked_at, :utc_datetime
    field :metadata, :map, default: %{}

    # Virtual — holds the raw token only in the `{:ok, invite, raw_token}` creation response;
    # never persisted.
    field :raw_token, :string, virtual: true, redact: true

    belongs_to :organization, Codefresh.Organizations.Organization
    belongs_to :invited_by, Codefresh.Accounts.User, foreign_key: :invited_by_user_id

    timestamps(type: :utc_datetime)
  end

  @doc """
  Generates a URL-safe raw token string suitable for emailing to invitees.
  """
  def generate_raw_token do
    :crypto.strong_rand_bytes(@raw_token_bytes)
    |> Base.url_encode64(padding: false)
  end

  @doc """
  Computes the Bcrypt hash for a raw token; stored as `token_hash`.
  """
  def hash_token(raw_token) when is_binary(raw_token) do
    Bcrypt.hash_pwd_salt(raw_token)
  end

  @doc """
  Verifies a raw token against a stored bcrypt hash (constant-time).
  """
  def verify_token(raw_token, hash) when is_binary(raw_token) and is_binary(hash) do
    Bcrypt.verify_pass(raw_token, hash)
  end

  @doc """
  Derives the key_prefix (first 8 chars of the raw token) for support lookup.
  """
  def derive_key_prefix(raw_token) when is_binary(raw_token) do
    String.slice(raw_token, 0, 8)
  end

  @doc """
  Changeset for creating a new invite token.

  Accepts: `:organization_id` (optional), `:email` (optional), `:role` (required),
  `:invited_by_user_id` (optional), `:expires_at`, `:max_uses`, `:metadata`.

  Automatically fills `:token_hash` and `:key_prefix` from the provided raw token.
  """
  def create_changeset(invite, attrs) do
    invite
    |> cast(attrs, [
      :organization_id,
      :email,
      :role,
      :invited_by_user_id,
      :expires_at,
      :max_uses,
      :metadata,
      :raw_token
    ])
    |> validate_required([:role, :raw_token])
    |> validate_inclusion(:role, @roles)
    |> validate_number(:max_uses, greater_than_or_equal_to: 1)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email")
    |> normalize_email()
    |> apply_token_fields()
  end

  @doc """
  Atomic increment after a successful redemption.
  """
  def redeem_changeset(invite) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    invite
    |> change(
      use_count: invite.use_count + 1,
      last_redeemed_at: now
    )
  end

  @doc """
  Mark an invite as revoked. Irreversible; no further redemptions.
  """
  def revoke_changeset(invite) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    change(invite, revoked_at: now)
  end

  @doc """
  Runtime predicate: is this invite still redeemable right now?
  """
  def active?(%__MODULE__{} = invite) do
    cond do
      invite.revoked_at != nil ->
        false

      invite.use_count >= invite.max_uses ->
        false

      invite.expires_at != nil and DateTime.compare(invite.expires_at, DateTime.utc_now()) != :gt ->
        false

      true ->
        true
    end
  end

  defp normalize_email(changeset) do
    case get_change(changeset, :email) do
      nil -> changeset
      email -> put_change(changeset, :email, String.downcase(email))
    end
  end

  defp apply_token_fields(changeset) do
    case get_change(changeset, :raw_token) do
      nil ->
        changeset

      raw_token ->
        changeset
        |> put_change(:token_hash, hash_token(raw_token))
        |> put_change(:key_prefix, derive_key_prefix(raw_token))
    end
  end
end
