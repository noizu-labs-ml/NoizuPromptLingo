defmodule NoizuPromptLingua.Schema.MCPCustomScope do
  @moduledoc """
  Preset that exposes a selected set of MCP domain tool groups as one custom MCP
  endpoint. A scope has a `kind`:

    * `"custom"`       — free-form group selection (default; original behavior)
    * `"all_in_one"`   — an everything-included package; the required core groups
      are auto-included and protected from casual removal (see
      `NoizuPromptLingua.MCPCustomScopes`)
    * `"core_variant"` — a named core package (sessions/projects/organizations)

  A scope may be a global (org-less) preset or attached to an organization and/or
  a project.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias NoizuPromptLingua.MCP.Window

  @kinds ~w(custom all_in_one core_variant)

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "mcp_custom_scopes" do
    field :slug, :string
    field :name, :string
    field :description, :string
    field :kind, :string, default: "custom"
    field :organization_id, :binary_id
    field :project_id, :binary_id
    field :user_id, :binary_id
    field :is_default, :boolean, default: false
    field :source_template_slug, :string
    field :config, :map, default: %{}

    timestamps(type: :utc_datetime)
  end

  @doc "Valid `kind` values."
  def kinds, do: @kinds

  def changeset(scope, attrs) do
    scope
    |> cast(attrs, [
      :slug,
      :name,
      :description,
      :kind,
      :organization_id,
      :project_id,
      :user_id,
      :is_default,
      :source_template_slug,
      :config
    ])
    |> update_change(:slug, &normalize_slug/1)
    |> validate_required([:slug, :name, :kind])
    |> validate_inclusion(:kind, @kinds)
    |> validate_format(:slug, ~r/^[a-z0-9][a-z0-9-]{0,62}$/)
    |> validate_change(:config, &validate_config/2)
    |> unique_constraint(:slug, name: :uq_mcp_custom_scopes_slug)
    |> unique_constraint(:user_id, name: :uq_mcp_custom_scopes_user_default)
    |> unique_constraint(:organization_id, name: :uq_mcp_custom_scopes_org_default)
  end

  defp normalize_slug(nil), do: nil

  defp normalize_slug(slug) when is_binary(slug) do
    slug
    |> String.trim()
    |> String.downcase()
  end

  defp validate_config(:config, value) when is_map(value) do
    validate_window_entries(value)
  end

  defp validate_config(:config, _), do: [config: "must be an object"]

  # F3 temporal windows: every tool entry in the config jsonb is validated via
  # `NoizuPromptLingua.MCP.Window.validate_entry/1` (mutual exclusion of
  # hide_until/enable_for_hours, datetime + positive-integer shape). Errors are
  # keyed to the offending entry path.
  defp validate_window_entries(config) do
    groups = Map.get(config, "groups") || Map.get(config, :groups) || %{}

    if is_map(groups) do
      Enum.flat_map(groups, fn {group_id, group_cfg} ->
        tools = group_tools(group_cfg)

        Enum.flat_map(tools, fn {tool_name, tool_cfg} ->
          tool_cfg
          |> Kernel.||(%{})
          |> Window.validate_entry()
          |> Enum.map(&{:config, "groups.#{group_id}.tools.#{tool_name}: #{&1}"})
        end)
      end)
    else
      []
    end
  end

  defp group_tools(group_cfg) when is_map(group_cfg),
    do: Map.get(group_cfg, "tools") || Map.get(group_cfg, :tools) || %{}

  defp group_tools(_), do: %{}
end
