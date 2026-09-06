defmodule NoizuPromptLingua.Schema.MCPToolSet do
  @moduledoc """
  A named, durable MCP tool set (`mcp_tool_sets`, Liquibase 083) — the N2a
  sibling of `MCPCustomScope` with a CLOSED operation vocabulary `config` jsonb
  (1:1 with the lib PRD-1 §4.5 override ops) and a whitelisted `settings` jsonb.

  Audience shapes (FR-2A-6, exactly one per row):

    * org-set     — `project_id` nil, `group_id` nil
    * project-set — `project_id` set, `group_id` nil
    * group-set   — `group_id` set (an authz `groups` row id), `project_id` nil

  `(organization_id, slug)` is one org-wide namespace across all shapes (R4).
  The 5 profile slugs (`Toolsets.Profiles.slugs/0`) plus `"root"` are reserved —
  profiles are virtual and must never be shadowable by a row (FR-2A-9).

  `config` is validated STRUCTURALLY in N2a: unknown keys anywhere in the tree
  are rejected, but tool/arg NAMES are not checked against the live catalog —
  full compile-validation arrives at N4b (`Validator.compile/3`), and the read
  side degrades per D5 (unknown tool/field dropped + warned, never a 500).
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias NoizuPromptLingua.MCP.Toolsets.Profiles
  alias NoizuPromptLingua.Organizations.SlugBackfill
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Authz.Group

  @sources ~w(custom clone)

  # Closed vocabulary (FR-2A-3). Group level: enabled/tools. Tool level:
  # enabled/name/description/args. Arg level: enum_remove/hide/rename/default/
  # description. 1:1 with the lib PRD-1 §4.5 ops — see
  # `NoizuPromptLingua.MCP.ToolSets.to_overrides/1` for the op mapping.
  @group_keys ~w(enabled tools)
  @tool_keys ~w(enabled name description args)
  @arg_keys ~w(enum_remove hide rename default description)

  # Settings whitelist (FR-2A-5) governs CLIENT-supplied keys. `cloned_from`
  # (clone provenance, open question 4), `updated_by` (in-row audit stamp) and
  # `_audit` (bounded mutation trail, PRD-N4 §4.1) are RESERVED SYSTEM keys —
  # written only by the MCP.ToolSets context / admin controller, not validated.
  @settings_system_keys ~w(cloned_from updated_by _audit)
  @settings_keys ~w(allow_api_keys description_verbosity instructions)
  @verbosity ~w(full concise minimal)

  @slug_format ~r/^[a-z0-9][a-z0-9-]{0,63}$/

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "mcp_tool_sets" do
    field :organization_id, :binary_id
    field :project_id, :binary_id
    field :group_id, :binary_id
    field :slug, :string
    field :display_name, :string
    field :description, :string
    field :source, :string, default: "custom"
    field :source_profile, :string
    field :config, :map, default: %{}
    field :settings, :map, default: %{}
    field :expires_at, :utc_datetime_usec
    field :is_active, :boolean, default: true

    timestamps(type: :utc_datetime)
  end

  @doc "Valid `source` values."
  def sources, do: @sources

  @doc "Reserved set slugs: the 5 profile slugs + \"root\" (FR-2A-2 / FR-2A-9)."
  def reserved_slugs, do: Profiles.slugs() ++ ["root"]

  @doc """
  Builds a changeset. `action` (:create default) controls which fields are
  writable: identity fields (`organization_id`, `project_id`, `group_id`,
  `slug`, `source`, `source_profile`) are create-only — updates may change
  config/settings/display_name/description/expires_at/is_active only.
  """
  def changeset(tool_set, attrs, action \\ :create)

  def changeset(tool_set, attrs, :create) do
    tool_set
    |> cast(attrs, [
      :organization_id,
      :project_id,
      :group_id,
      :slug,
      :display_name,
      :description,
      :source,
      :source_profile,
      :config,
      :settings,
      :expires_at,
      :is_active
    ])
    |> update_change(:slug, &derive_slug/1)
    |> fallback_slug_from_display_name()
    |> common_validation()
    |> validate_clone_invariant()
  end

  def changeset(tool_set, attrs, :update) do
    tool_set
    |> cast(attrs, [
      :display_name,
      :description,
      :config,
      :settings,
      :expires_at,
      :is_active
    ])
    |> common_validation()
  end

  # Slug: slugify the incoming value; when absent, fall back to slugifying the
  # display name (AC-2A-2 "unsluggable display name ⇒ slugified"). Still
  # required — neither source yielding a slug is an error.
  defp derive_slug(nil), do: nil
  defp derive_slug(slug) when is_binary(slug), do: SlugBackfill.slugify(slug)
  defp derive_slug(_), do: nil

  defp fallback_slug_from_display_name(changeset) do
    if is_nil(get_field(changeset, :slug)) do
      case SlugBackfill.slugify(get_field(changeset, :display_name)) do
        nil -> changeset
        slug -> put_change(changeset, :slug, slug)
      end
    else
      changeset
    end
  end

  defp common_validation(changeset) do
    changeset
    |> validate_required([:organization_id, :slug])
    |> validate_format(:slug, @slug_format)
    |> validate_length(:slug, max: 64)
    |> validate_length(:display_name, max: 200)
    |> validate_inclusion(:source, @sources)
    |> validate_exclusion(:slug, reserved_slugs())
    |> validate_change(:config, &validate_config/2)
    |> validate_change(:settings, &validate_settings/2)
    |> validate_shape()
    # Friendly duplicate error lands on :slug (the field an admin edits);
    # field order decides attribution. The named constraint backstops races.
    |> unsafe_validate_unique([:slug, :organization_id], Repo)
    |> unique_constraint(:slug, name: :mcp_tool_sets_org_slug_key)
  end

  # source == "clone" must carry provenance: source_profile (cloned from a
  # profile) or settings["cloned_from"] (cloned from a set — open question 4).
  defp validate_clone_invariant(changeset) do
    if get_field(changeset, :source) == "clone" do
      cloned_from = get_in(get_field(changeset, :settings) || %{}, ["cloned_from"])

      if is_nil(get_field(changeset, :source_profile)) and blank?(cloned_from) do
        add_error(changeset, :source, "clone sets require source_profile or settings.cloned_from")
      else
        changeset
      end
    else
      changeset
    end
  end

  defp blank?(nil), do: true
  defp blank?(""), do: true
  defp blank?(_), do: false

  # Exactly one audience shape per row (FR-2A-6): org / project / group.
  # Group-sets additionally require the group_id to reference an existing authz
  # `groups` row (the N3 group gate resolves membership against it).
  defp validate_shape(changeset) do
    project_id = get_field(changeset, :project_id)
    group_id = get_field(changeset, :group_id)

    changeset
    |> reject_both_shapes(project_id, group_id)
    |> validate_group_exists(group_id)
  end

  defp reject_both_shapes(changeset, project_id, group_id)
       when not is_nil(project_id) and not is_nil(group_id) do
    add_error(changeset, :project_id, "project and group audiences are mutually exclusive")
  end

  defp reject_both_shapes(changeset, _project_id, _group_id), do: changeset

  defp validate_group_exists(changeset, group_id) when not is_nil(group_id) do
    if Repo.get(Group, group_id) do
      changeset
    else
      add_error(changeset, :group_id, "does not exist")
    end
  end

  defp validate_group_exists(changeset, _), do: changeset

  # ---- config: closed-vocabulary structural validation (FR-2A-3) ----

  defp validate_config(:config, value) when is_map(value),
    do: do_validate_config(stringify(value))

  defp validate_config(:config, _), do: [config: "must be an object"]

  defp do_validate_config(config) do
    unknown_keys_errors(:config, "config", config, ["groups"]) ++
      case Map.get(config, "groups") do
        nil ->
          []

        groups when is_map(groups) ->
          Enum.flat_map(groups, fn {group_id, group_cfg} ->
            validate_group(group_id, group_cfg)
          end)

        _ ->
          [config: "groups: must be an object"]
      end
  end

  defp validate_group(group_id, group_cfg) when is_map(group_cfg) do
    prefix = "groups.#{group_id}"

    unknown_keys_errors(:config, prefix, group_cfg, @group_keys) ++
      validate_group_enabled(prefix, group_cfg) ++
      validate_tools(prefix, Map.get(group_cfg, "tools"))
  end

  defp validate_group(group_id, _), do: [config: "groups.#{group_id}: must be an object"]

  defp validate_group_enabled(prefix, group_cfg) do
    case Map.get(group_cfg, "enabled") do
      nil -> []
      value when is_boolean(value) -> []
      _ -> [config: "#{prefix}.enabled: must be a boolean"]
    end
  end

  defp validate_tools(_prefix, nil), do: []

  defp validate_tools(prefix, tools) when is_map(tools) do
    Enum.flat_map(tools, fn {tool_name, tool_cfg} ->
      validate_tool(prefix, tool_name, tool_cfg)
    end)
  end

  defp validate_tools(prefix, _), do: [config: "#{prefix}.tools: must be an object"]

  defp validate_tool(prefix, tool_name, tool_cfg) when is_map(tool_cfg) do
    tool_path = "#{prefix}.tools.#{tool_name}"

    unknown_keys_errors(:config, tool_path, tool_cfg, @tool_keys) ++
      validate_tool_scalars(tool_path, tool_cfg) ++
      validate_args(tool_path, Map.get(tool_cfg, "args"))
  end

  defp validate_tool(_prefix, tool_name, _), do: [config: "tools.#{tool_name}: must be an object"]

  defp validate_tool_scalars(tool_path, tool_cfg) do
    boolean_errors(tool_path, "enabled", Map.get(tool_cfg, "enabled")) ++
      string_errors(tool_path, "name", Map.get(tool_cfg, "name")) ++
      string_errors(tool_path, "description", Map.get(tool_cfg, "description"))
  end

  defp validate_args(_tool_path, nil), do: []

  defp validate_args(tool_path, args) when is_map(args) do
    renames = arg_renames(args)

    Enum.flat_map(args, fn {arg_name, arg_cfg} ->
      validate_arg("#{tool_path}.args", arg_name, arg_cfg, args)
    end) ++ duplicate_rename_errors(tool_path, renames)
  end

  defp validate_args(tool_path, _), do: [config: "#{tool_path}.args: must be an object"]

  defp validate_arg(args_path, arg_name, arg_cfg, args) when is_map(arg_cfg) do
    arg_path = "#{args_path}.#{arg_name}"

    unknown_keys_errors(:config, arg_path, arg_cfg, @arg_keys) ++
      validate_enum_remove(arg_path, Map.get(arg_cfg, "enum_remove")) ++
      boolean_errors(arg_path, "hide", Map.get(arg_cfg, "hide")) ++
      validate_rename(arg_path, arg_name, Map.get(arg_cfg, "rename"), args) ++
      validate_default(arg_path, Map.get(arg_cfg, "default")) ++
      string_errors(arg_path, "description", Map.get(arg_cfg, "description"))
  end

  defp validate_arg(args_path, arg_name, _, _),
    do: [config: "#{args_path}.#{arg_name}: must be an object"]

  defp validate_enum_remove(_arg_path, nil), do: []

  defp validate_enum_remove(arg_path, values) do
    if is_list(values) and Enum.all?(values, &scalar?/1) do
      []
    else
      [config: "#{arg_path}.enum_remove: must be a list of scalars"]
    end
  end

  defp validate_rename(arg_path, arg_name, rename, args)

  defp validate_rename(_arg_path, _arg_name, nil, _args), do: []

  defp validate_rename(arg_path, arg_name, rename, args) when is_binary(rename) do
    cond do
      rename == "" ->
        [config: "#{arg_path}.rename: must be a non-empty string"]

      # The rename target collides with another arg of the SAME tool (the
      # renamed arg itself is fine; a rename onto an existing sibling is not).
      Map.has_key?(args, rename) and rename != arg_name ->
        [config: "#{arg_path}.rename: collides with existing arg #{inspect(rename)}"]

      true ->
        []
    end
  end

  defp validate_rename(arg_path, _arg_name, _, _args),
    do: [config: "#{arg_path}.rename: must be a non-empty string"]

  defp validate_default(_arg_path, nil), do: []

  defp validate_default(arg_path, value) do
    if scalar?(value) do
      []
    else
      [config: "#{arg_path}.default: must be a scalar"]
    end
  end

  # Two args renamed onto the same target also collide.
  defp duplicate_rename_errors(tool_path, renames) do
    {_, dupes} =
      Enum.reduce(renames, {MapSet.new(), []}, fn {_arg, target}, {seen, dupes} ->
        if MapSet.member?(seen, target) do
          {seen, [target | dupes]}
        else
          {MapSet.put(seen, target), dupes}
        end
      end)

    Enum.map(dupes, fn target ->
      {:config, "#{tool_path}.args: multiple renames collide on #{inspect(target)}"}
    end)
  end

  defp arg_renames(args) do
    args
    |> Enum.flat_map(fn {arg_name, arg_cfg} ->
      rename = if is_map(arg_cfg), do: Map.get(arg_cfg, "rename")
      if is_binary(rename) and rename != "", do: [{arg_name, rename}], else: []
    end)
  end

  defp unknown_keys_errors(field, path, cfg, allowed) do
    cfg
    |> Map.keys()
    |> Enum.reject(&(&1 in allowed))
    |> Enum.map(fn key -> {field, "#{path}: unknown key #{inspect(key)}"} end)
  end

  defp boolean_errors(_path, _key, nil), do: []

  defp boolean_errors(path, key, value) do
    if is_boolean(value), do: [], else: [config: "#{path}.#{key}: must be a boolean"]
  end

  defp string_errors(_path, _key, nil), do: []

  defp string_errors(path, key, value) do
    if is_binary(value), do: [], else: [config: "#{path}.#{key}: must be a string"]
  end

  defp scalar?(value) when is_binary(value) or is_number(value) or is_boolean(value), do: true
  defp scalar?(_), do: false

  # ---- settings whitelist (FR-2A-5) ----

  defp validate_settings(:settings, value) when is_map(value),
    do: do_validate_settings(stringify(value))

  defp validate_settings(:settings, _), do: [settings: "must be an object"]

  defp do_validate_settings(settings) do
    settings = Map.drop(settings, @settings_system_keys)

    unknown_keys_errors(:settings, "settings", settings, @settings_keys) ++
      validate_allow_api_keys(Map.get(settings, "allow_api_keys")) ++
      validate_verbosity(Map.get(settings, "description_verbosity")) ++
      validate_instructions(Map.get(settings, "instructions"))
  end

  defp validate_allow_api_keys(nil), do: []

  defp validate_allow_api_keys(value) do
    if is_boolean(value), do: [], else: [settings: "settings.allow_api_keys: must be a boolean"]
  end

  defp validate_verbosity(nil), do: []

  defp validate_verbosity(value) when is_binary(value) do
    if value in @verbosity,
      do: [],
      else: [
        settings: "settings.description_verbosity: must be one of: #{Enum.join(@verbosity, ", ")}"
      ]
  end

  defp validate_verbosity(_), do: [settings: "settings.description_verbosity: must be a string"]

  defp validate_instructions(nil), do: []

  defp validate_instructions(value) do
    if is_binary(value), do: [], else: [settings: "settings.instructions: must be a string"]
  end

  # jsonb maps arrive from clients in either key spelling; canonical storage is
  # string-keyed (mirrors MCPCustomScopes normalize behavior).
  defp stringify(map) when is_map(map) do
    Map.new(map, fn
      {key, value} when is_atom(key) -> {Atom.to_string(key), stringify(value)}
      {key, value} when is_binary(key) -> {key, stringify(value)}
      pair -> pair
    end)
  end

  defp stringify(other), do: other
end
