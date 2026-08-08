defmodule NoizuPromptLingua.Schema.OAuthAuthorizationCode do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "oauth_authorization_codes" do
    field :code_hash, :string
    field :client_id, :string
    belongs_to :user, NoizuPromptLingua.Schema.Users.User, type: Ecto.UUID
    field :redirect_uri, :string
    field :resource, :string
    field :scope, :string, default: "mcp"
    field :code_challenge, :string
    field :code_challenge_method, :string, default: "S256"
    field :grant_id, :string
    field :expires_at, :utc_datetime_usec
    field :consumed_at, :utc_datetime_usec
    field :inserted_at, :utc_datetime_usec
  end

  def changeset(code, attrs) do
    code
    |> cast(attrs, [
      :code_hash,
      :client_id,
      :user_id,
      :redirect_uri,
      :resource,
      :scope,
      :code_challenge,
      :code_challenge_method,
      :grant_id,
      :expires_at,
      :consumed_at,
      :inserted_at
    ])
    |> validate_required([
      :code_hash,
      :client_id,
      :user_id,
      :redirect_uri,
      :code_challenge,
      :expires_at
    ])
    |> validate_inclusion(:code_challenge_method, ["S256"])
    |> unique_constraint(:code_hash)
  end
end
