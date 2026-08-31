defmodule NoizuPromptLingua.Schema.McpApiKey do
  @moduledoc """
  An MCP API key (PAT-style credential used to mint short-lived MCP JWTs).

  `toolset_config` carries this key's own MCP toolset overrides, shape-identical
  to `MCPCustomScopes` configs:

      %{"groups" => %{"<group_id>" => %{
           "disabled" => boolean, "hidden" => boolean,
           "tools" => %{"<Tool.Name>" => %{"disabled" => boolean, "hidden" => boolean}}}}}

  Resolution cascade (most specific wins; absent field = inherit):

    1. global `tobor` template (via the custom-scope clone chain)
    2. custom-scope config (per-user/org default endpoint or named preset)
    3. **this key's `toolset_config`** — `disabled` blocks execution,
       `hidden` blocks listing/discovery.

  See `NoizuPromptLingua.MCP.KeyToolsets`.
  """

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
    field :toolset_config, :map, default: %{}
    timestamps(type: :utc_datetime_usec)
  end

  # Stores the key_prefix + key_hash only; the raw key is returned to the caller
  # once at creation time and never persisted.
  def create_changeset(api_key, attrs) do
    api_key
    |> cast(attrs, [:user_id, :label, :key_prefix, :key_hash, :expires_at, :toolset_config])
    |> validate_required([:user_id, :key_prefix, :key_hash])
    |> validate_inclusion(:status, ["active", "revoked"])
    |> foreign_key_constraint(:user_id)
  end

  def status_changeset(api_key, attrs) do
    api_key
    |> cast(attrs, [:status, :last_used_at])
    |> validate_inclusion(:status, ["active", "revoked"])
  end

  def toolset_changeset(api_key, attrs) do
    api_key
    |> cast(attrs, [:label, :status, :toolset_config])
    |> validate_inclusion(:status, ["active", "revoked"])
  end
end

