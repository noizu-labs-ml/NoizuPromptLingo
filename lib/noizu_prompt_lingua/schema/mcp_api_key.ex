defmodule NoizuPromptLingua.Schema.McpApiKey do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime_usec]

  schema "mcp_api_keys" do
    belongs_to :user, NoizuPromptLingua.Schema.User
    field :label, :string, default: "default"
    field :key_prefix, :string
    field :key_hash, :string
    field :status, :string, default: "active"
    field :last_used_at, :utc_datetime_usec
    field :expires_at, :utc_datetime_usec
    timestamps(inserted_at: :inserted_at, updated_at: :updated_at)
  end

  def create_changeset(api_key, attrs) do
    api_key
    |> cast(attrs, [:user_id, :label, :key_prefix, :key_hash, :expires_at])
    |> validate_required([:user_id, :key_prefix, :key_hash])
    |> foreign_key_constraint(:user_id)
  end
end
