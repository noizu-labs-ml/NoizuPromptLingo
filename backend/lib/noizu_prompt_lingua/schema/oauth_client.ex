defmodule NoizuPromptLingua.Schema.OAuthClient do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "oauth_clients" do
    field :client_id, :string
    field :client_secret_hash, :string
    field :client_name, :string, default: "unnamed"
    field :redirect_uris, {:array, :string}, default: []
    field :grant_types, {:array, :string}, default: ["authorization_code", "refresh_token"]
    field :token_endpoint_auth_method, :string, default: "none"
    field :scope, :string, default: "openid mcp"
    field :is_first_party, :boolean, default: false
    field :status, :string, default: "active"
    field :metadata, :map, default: %{}

    # W8: per-client MCP toolset narrowing captured at consent time.
    # Shape-identical to `mcp_api_keys.toolset_config` (see
    # `NoizuPromptLingua.MCP.KeyToolsets`): only BLOCKED entries are stored
    # (`disabled`/`hidden` flags; absent = allowed). `%{}` (column default)
    # = no narrowing = legacy behavior (everything allowed).
    field :toolset_config, :map, default: %{}
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(client, attrs) do
    client
    |> cast(attrs, [
      :client_id,
      :client_secret_hash,
      :client_name,
      :redirect_uris,
      :grant_types,
      :token_endpoint_auth_method,
      :scope,
      :is_first_party,
      :status,
      :metadata,
      :toolset_config
    ])
    |> validate_required([:client_id, :client_name, :redirect_uris])
    |> validate_inclusion(:status, ["active", "revoked"])
    |> unique_constraint(:client_id)
  end
end
