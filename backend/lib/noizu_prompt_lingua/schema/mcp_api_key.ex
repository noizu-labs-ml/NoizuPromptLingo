defmodule NoizuPromptLingua.Schema.McpApiKey do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "mcp_api_keys" do
    belongs_to :user, NoizuPromptLingua.Schema.Users.User, type: Ecto.UUID
    field :label, :string, default: "default"
    field :key_prefix, :string
    field :key_hash, :string
    field :status, :string, default: "active"
    field :last_used_at, :utc_datetime_usec
    field :expires_at, :utc_datetime_usec
    timestamps(type: :utc_datetime_usec)
  end

  # Stores the key_prefix + key_hash only; the raw key is returned to the caller
  # once at creation time and never persisted.
  def create_changeset(api_key, attrs) do
    api_key
    |> cast(attrs, [:user_id, :label, :key_prefix, :key_hash, :expires_at])
    |> validate_required([:user_id, :key_prefix, :key_hash])
    |> validate_inclusion(:status, ["active", "revoked"])
    |> foreign_key_constraint(:user_id)
  end

  def status_changeset(api_key, attrs) do
    api_key
    |> cast(attrs, [:status, :last_used_at])
    |> validate_inclusion(:status, ["active", "revoked"])
  end
end
