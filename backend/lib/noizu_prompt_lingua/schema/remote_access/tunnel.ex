defmodule NoizuPromptLingua.Schema.RemoteAccess.Tunnel do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "remote_access_tunnels" do
    field :organization_id, :binary_id
    field :user_id, :binary_id
    field :name, :string
    field :tunnel_token_hash, :string
    field :proxy_type, :string, default: "http"
    field :status, :string, default: "active"
    field :last_connected_at, :utc_datetime
    field :expires_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @name_format ~r/^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$/

  def changeset(tunnel, attrs) do
    tunnel
    |> cast(attrs, [
      :organization_id,
      :user_id,
      :name,
      :tunnel_token_hash,
      :proxy_type,
      :status,
      :last_connected_at,
      :expires_at
    ])
    |> validate_required([:organization_id, :user_id, :name, :tunnel_token_hash])
    |> validate_format(:name, @name_format,
      message: "must be a valid DNS label (lowercase letters, digits, hyphens)"
    )
    |> validate_inclusion(:proxy_type, ["http", "https", "tcp"])
    |> validate_inclusion(:status, ["active", "revoked"])
    |> unique_constraint(:name, name: :idx_remote_access_tunnels_active_name)
    |> foreign_key_constraint(:organization_id)
  end
end
