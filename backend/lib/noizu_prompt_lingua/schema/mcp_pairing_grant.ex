defmodule NoizuPromptLingua.Schema.McpPairingGrant do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "mcp_pairing_grants" do
    field :grant_id, :string
    belongs_to :user, NoizuPromptLingua.Schema.Users.User, type: Ecto.UUID
    field :client_id, :string
    field :resource, :string
    field :scope, :string, default: "mcp"
    field :authorization_details, {:array, :map}, default: []
    field :status, :string, default: "active"
    field :expires_at, :utc_datetime_usec
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(grant, attrs) do
    grant
    |> cast(attrs, [
      :grant_id,
      :user_id,
      :client_id,
      :resource,
      :scope,
      :authorization_details,
      :status,
      :expires_at
    ])
    |> validate_required([:grant_id, :user_id, :client_id, :resource])
    |> validate_inclusion(:status, ["active", "revoked"])
    |> unique_constraint(:grant_id)
  end
end
