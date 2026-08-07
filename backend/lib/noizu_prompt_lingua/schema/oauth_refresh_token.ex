defmodule NoizuPromptLingua.Schema.OAuthRefreshToken do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "oauth_refresh_tokens" do
    field :token_hash, :string
    field :client_id, :string
    belongs_to :user, NoizuPromptLingua.Schema.Users.User, type: Ecto.UUID
    field :grant_id, :string
    field :resource, :string
    field :scope, :string, default: "mcp"
    field :expires_at, :utc_datetime_usec
    field :revoked_at, :utc_datetime_usec
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(token, attrs) do
    token
    |> cast(attrs, [
      :token_hash,
      :client_id,
      :user_id,
      :grant_id,
      :resource,
      :scope,
      :expires_at,
      :revoked_at
    ])
    |> validate_required([:token_hash, :client_id, :user_id, :expires_at])
    |> unique_constraint(:token_hash)
  end
end
