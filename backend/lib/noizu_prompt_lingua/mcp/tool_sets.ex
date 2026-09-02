defmodule NoizuPromptLingua.MCP.ToolSets do
  @moduledoc """
  Context for durable MCP tool sets (`Schema.MCPToolSet`, PRD-N2 §4.1): CRUD +
  deactivate + clone, request-path lookup, and the `to_overrides/1` pure
  translator from the closed-vocabulary `config` jsonb to normalized override
  ops.

  N3 flip (PRD-N3 FR-3-4): `assemble_custom/2` returns the REAL
  `%Noizu.MCP.Toolset.Custom{}` — base = `NoizuPromptLingua.MCP.UniverseToolset`
  (plane ∪ every customizable group's tools — no single server module covers a
  set's potential universe), `include` = the expanded allowlist universe
  (plane ∪ enabled config groups, R2), `tools` = `to_overrides/1` wrapped into
  `%Noizu.MCP.Toolset.Override{}` with targets flattened to base canonical
  names (tool ops) / field atoms (arg ops, mapped through the target spec's
  cast plan). Unknown tool/field targets degrade per D5: dropped with a
  warning, never a 500. N2b still flips `to_overrides/1` elements to
  `%Override{}` structs and layers in grants (weight 200).

  N4b adds the admin-side companions: `assemble_config_custom/2` (scratch
  assembly from a raw config), `validate_config/1` (pure Validator.compile/3
  dry-run against the live catalog — unknown targets are NAMED, not dropped)
  and `arg_enum_values/2` (enum-picker seeds for the overrides editor).

  Every write fires `MCP.Server.notify_toolset_changed/0` (best-effort, N1
  wiring) so live connections re-list before serving a stale set.
  """

  import Ecto.Query, only: [from: 2]
  require Logger

  alias NoizuPromptLingua.MCP.Server
  alias NoizuPromptLingua.MCP.ToolNames
  alias NoizuPromptLingua.MCP.Toolsets.Profiles
  alias NoizuPromptLingua.MCPServers
  alias NoizuPromptLingua.Organizations.SlugBackfill
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.MCPToolSet

  @doc """
  Create a set. `opts[:actor_id]` is stamped into `settings.updated_by`
  (in-row audit, mirroring the carry_audit precedent — no new audit table).
  """
  def create(attrs, opts \\ []) do
    %MCPToolSet{}
    |> MCPToolSet.changeset(stamp_actor(attrs, opts))
    |> Repo.insert()
    |> notify_on_ok(fn set -> "tool_set.created slug=#{set.slug} org=#{set.organization_id}" end)
  end

  @doc """
  Partial update: config/settings/display_name/description/expires_at/is_active
  only — identity fields (slug/org/project/group/source) are create-only (see
  `Schema.MCPToolSet.changeset/3`).
  """
  def update(set_or_id, attrs, opts \\ [])

  def update(%MCPToolSet{} = tool_set, attrs, opts) do
    tool_set
    |> MCPToolSet.changeset(stamp_actor(attrs, opts), :update)
    |> Repo.update()
    |> notify_on_ok(fn set -> "tool_set.updated slug=#{set.slug} org=#{set.organization_id}" end)
  end

  def update(id, attrs, opts) when is_binary(id) do
    case get(id) do
      nil -> {:error, :not_found}
      tool_set -> update(tool_set, attrs, opts)
    end
  end

  @doc "Soft-kill (R8): `is_active: false`. Deactivated sets vanish from the request path."
  def deactivate(set_or_id, opts \\ [])

  def deactivate(%MCPToolSet{} = tool_set, opts) do
    tool_set
    |> MCPToolSet.changeset(stamp_actor(%{"is_active" => false}, opts), :update)
    |> Repo.update()
    |> notify_on_ok(fn set ->
      "tool_set.deactivated slug=#{set.slug} org=#{set.organization_id}"
    end)
  end

  def deactivate(id, opts) when is_binary(id) do
    case get(id) do
      nil -> {:error, :not_found}
      tool_set -> deactivate(tool_set, opts)
    end
  end

  @doc """
  Clone a profile slug or an existing set into a new, fully editable row.

    * from a profile — `source: "clone"`, `source_profile` = the slug, and a
      deep-copied allowlist config `%{"groups" => %{g => %{"enabled" => true}}}`
      over the profile's expanded groups (FR-2A-7).
    * from a set — `source: "clone"` with the set's config deep-copied and
      provenance in `settings.cloned_from` (open question 4; `source_profile`
      stays nil).

  The clone's slug auto-suggests `<source-slug>-copy`, suffixing `-2`, `-3`, …
  on collision within the org. Required attrs: `organization_id` (plus optional
  `project_id`/`group_id`/`display_name`/`description`/`expires_at`).
  """
  def clone(source, attrs, opts \\ [])

  def clone(source, attrs, opts) when is_binary(source) do
    case Profiles.get(source) do
      nil ->
        {:error, :unknown_profile}

      profile ->
        config = %{"groups" => Map.new(profile.groups, fn g -> {g, %{"enabled" => true}} end)}

        source
        |> clone_attrs(attrs, config)
        |> Map.merge(%{
          "source" => "clone",
          "source_profile" => source,
          "settings" => Map.merge(caller_settings(attrs), %{})
        })
        |> create_from_clone(opts, source)
    end
  end

  def clone(%MCPToolSet{} = source, attrs, opts) do
    source.slug
    |> clone_attrs(attrs, deep_copy(source.config))
    |> Map.merge(%{
      "source" => "clone",
      "source_profile" => nil,
      "settings" => Map.merge(caller_settings(attrs), %{"cloned_from" => source.slug})
    })
    |> create_from_clone(opts, source.slug)
  end

  def clone(_, _, _), do: {:error, :invalid_source}

  defp create_from_clone(attrs, opts, source_slug) do
    attrs =
      attrs
      |> Map.put("slug", suggest_slug(attrs["organization_id"], attrs["slug"]))
      |> stamp_actor(opts)

    %MCPToolSet{}
    |> MCPToolSet.changeset(attrs)
    |> Repo.insert()
    |> notify_on_ok(fn set ->
      "tool_set.cloned slug=#{set.slug} from=#{source_slug} org=#{set.organization_id}"
    end)
  end

  # Merge caller attrs over clone defaults; caller-provided display fields and
  # audience shape win, the derived "<slug>-copy" naming is a fallback only.
  defp clone_attrs(source_slug, attrs, config) do
    attrs = Map.new(attrs, fn {k, v} -> {to_string(k), v} end)

    %{
      "organization_id" => Map.get(attrs, "organization_id"),
      "project_id" => Map.get(attrs, "project_id"),
      "group_id" => Map.get(attrs, "group_id"),
      "slug" => "#{source_slug}-copy",
      "display_name" => Map.get(attrs, "display_name") || "#{source_slug} copy",
      "description" => Map.get(attrs, "description"),
      "config" => config,
      "expires_at" => Map.get(attrs, "expires_at")
    }
  end

  # Caller-supplied settings (N4a in-row audit seeds `_audit`) merged UNDER the
  # clone-provenance keys, which always win.
  defp caller_settings(attrs) do
    attrs
    |> Map.new(fn {k, v} -> {to_string(k), v} end)
    |> Map.get("settings")
    |> Kernel.||(%{})
    |> stringify_map()
  end

  # First free "<base>-copy" / "<base>-copy-N" slug within the org.
  defp suggest_slug(nil, _base), do: nil

  defp suggest_slug(org_id, base) do
    candidate = SlugBackfill.slugify(base) || "set-copy"
    taken = org_slugs(org_id)
    suggest(candidate, taken, 1)
  end

  defp suggest(candidate, taken, 1) do
    if MapSet.member?(taken, candidate), do: suggest(candidate, taken, 2), else: candidate
  end

  defp suggest(base, taken, n) do
    candidate = "#{base}-#{n}"

    if MapSet.member?(taken, candidate) do
      suggest(base, taken, n + 1)
    else
      candidate
    end
  end

  # Every slug in the org (all shapes, active or not — the namespace is
  # org-wide per R4).
  defp org_slugs(org_id) do
    Repo.all(
      from(s in MCPToolSet,
        where: s.organization_id == ^org_id,
        select: s.slug
      )
    )
    |> MapSet.new()
  end

  @doc """
  Sets for an org, every audience shape, oldest first. Active-only by default
  (the request path's universe); `opts[:include_inactive]` adds deactivated
  rows — the admin index needs those (FR-4-3: deactivated sets remain listable).
  """
  def list_for_org(org_id, opts \\ [])

  def list_for_org(org_id, opts) when is_binary(org_id) do
    query =
      if Keyword.get(opts, :include_inactive, false) do
        from(s in MCPToolSet,
          where: s.organization_id == ^org_id,
          order_by: [asc: s.inserted_at, asc: s.slug]
        )
      else
        from(s in MCPToolSet,
          where: s.organization_id == ^org_id and s.is_active == true,
          order_by: [asc: s.inserted_at, asc: s.slug]
        )
      end

    Repo.all(query)
  end

  def list_for_org(_, _), do: []

  def get(id) when is_binary(id), do: Repo.get(MCPToolSet, id)
  def get(_), do: nil

  @doc """
  Resolve by (organization_id, slug) — the org-addressed URL form. Slug
  matching is normalized case-insensitively, mirroring
  `MCPCustomScopes.get_by_org_and_slug/2`; a slug can never resolve outside its
  org. Not active-filtered (admin path — the request path uses
  `get_for_request/2`).
  """
  def get_by_org_and_slug(org_id, slug) when is_binary(slug) do
    Repo.get_by(MCPToolSet, organization_id: org_id, slug: normalize_slug(slug))
  end

  def get_by_org_and_slug(_, _), do: nil

  @doc """
  Request-path lookup (active-only + unexpired): nil for inactive sets, expired
  sets, and sets of other orgs (AC-2A-8). THIN in N2a — returns
  `%MCPToolSet{} | nil`; the return type flips to the assembled lib toolset at
  PRD-3 time.
  """
  def get_for_request(org_id, slug) when is_binary(slug) do
    case get_by_org_and_slug(org_id, slug) do
      %MCPToolSet{is_active: true, expires_at: nil} = tool_set ->
        tool_set

      %MCPToolSet{is_active: true, expires_at: expires_at} = tool_set ->
        if DateTime.compare(expires_at, DateTime.utc_now()) == :gt do
          tool_set
        else
          nil
        end

      _ ->
        nil
    end
  end

  def get_for_request(_, _), do: nil

  @doc """
  Effective view for serving — N3 REAL form (PRD-N3 FR-3-4, FR-2B-4 shape):
  a `%Noizu.MCP.Toolset.Custom{}` the lib composes through the toolset
  protocol. `ctx` is unused today and kept for the signature seam.
  """
  def assemble_custom(%MCPToolSet{} = tool_set, _ctx \\ nil) do
    settings = tool_set.settings || %{}

    assemble_config_custom(tool_set.config,
      slug: "set:" <> tool_set.slug,
      title: tool_set.display_name || tool_set.slug,
      description: tool_set.description || Map.get(settings, "instructions"),
      settings: settings,
      metadata: %{
        mcp_tool_set_id: tool_set.id,
        source: tool_set.source,
        source_profile: tool_set.source_profile,
        allow_api_keys: Map.get(settings, "allow_api_keys", true),
        shape: shape(tool_set)
      }
    )
  end

  @doc """
  N4b scratch assembly (PRD-N4 §4.1): the same core as `assemble_custom/2`,
  from a raw config map — the validate dry-run's candidate toolset and the
  show-preview's D1-correct effective view both compose from this shape
  (UniverseToolset base, expanded allowlist universe, closed-vocabulary ops).
  """
  def assemble_config_custom(config, opts \\ []) do
    settings = Keyword.get(opts, :settings) || %{}
    universe = universe_for_groups(enabled_groups(config))

    %Noizu.MCP.Toolset.Custom{
      slug: Keyword.get(opts, :slug, "candidate"),
      base: NoizuPromptLingua.MCP.UniverseToolset,
      title: Keyword.get(opts, :title),
      description: Keyword.get(opts, :description) || Map.get(settings, "instructions"),
      immutable: false,
      include: universe.include,
      exclude: [],
      tools: override_map(config, universe.specs),
      metadata: Keyword.get(opts, :metadata) || %{}
    }
  end

  @doc """
  N4b dry-run (FR-4-6): pure catalog compile of a config map against the LIVE
  base catalog (UniverseToolset, expanded + unfiltered — no DB, no serving
  state). `{:ok, warnings}` | `{:error, [%Noizu.MCP.Toolset.Validator.Issue{}]}`.

  Unlike `assemble_custom/2` the D5 drop does NOT run here: unknown tool/field
  targets keep their as-written spelling so the Validator can NAME them
  (:unknown_tool / :unknown_field). Resolvable targets map to base canonical
  names / cast-plan field atoms exactly as the serving assembly does, so a
  passing config is serving-shaped by construction.
  """
  def validate_config(config) when is_map(config) do
    universe = universe_for_groups(enabled_groups(config))

    base_entries =
      NoizuPromptLingua.MCP.UniverseToolset.__toolset_specs__(nil, nil, [])
      |> Enum.map(&Noizu.MCP.Toolset.Behaviour.entry_for/1)

    candidate = %Noizu.MCP.Toolset.Custom{
      slug: "validate:candidate",
      base: NoizuPromptLingua.MCP.UniverseToolset,
      include: universe.include,
      exclude: [],
      tools: validation_map(config, universe.specs)
    }

    Noizu.MCP.Toolset.Validator.compile(candidate, base_entries)
  end

  def validate_config(_), do: {:ok, []}

  @doc """
  N4b enum-picker helper: the base enum values of `tool_key`'s `arg_key` field
  from the LIVE universe catalog (plane ∪ every customizable group) — the
  prune candidates the admin UI offers. `{:ok, [String.t()]}` for enum fields
  (stringified, the config jsonb's spelling); `{:error, :unknown_tool |
  :unknown_field | :not_enum}` otherwise.
  """
  def arg_enum_values(tool_key, arg_key)
      when is_binary(tool_key) and is_binary(arg_key) do
    specs = universe_for_groups(Enum.map(MCPServers.customizable(), & &1.id)).specs

    case spec_for(%{tool: tool_key}, specs) do
      nil ->
        {:error, :unknown_tool}

      spec ->
        case field_atom(spec, arg_key) do
          nil ->
            {:error, :unknown_field}

          atom ->
            # Values live on the DSL field (input_fields — the same shape the
            # Validator reads), not on the cast-plan projection.
            field =
              spec.definition.input_fields
              |> List.wrap()
              |> Enum.find(&match?(%{name: ^atom}, &1))

            case field_values(field) do
              values when is_list(values) -> {:ok, Enum.map(values, &to_string/1)}
              _ -> {:error, :not_enum}
            end
        end
    end
  end

  def arg_enum_values(_, _), do: {:error, :unknown_tool}

  defp field_values(%{opts: opts}), do: opts_values(opts)
  defp field_values(_), do: nil

  defp opts_values(opts) when is_list(opts), do: Keyword.get(opts, :values)
  defp opts_values(opts) when is_map(opts), do: Map.get(opts, :values)
  defp opts_values(_), do: nil

  # Validation twin of override_map/2: same target resolution (aliases fold to
  # base canonical names, args to cast-plan atoms) but unresolvable targets
  # keep their as-written spelling — the Validator reports them, the serving
  # assembly would silently drop them (D5).
  defp validation_map(config, specs_index) do
    config
    |> to_overrides()
    |> Enum.flat_map(&validation_op(&1, specs_index))
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
  end

  defp validation_op(
         %{op: op, target: %{tool: tool_key, arg: arg_key} = target, value: value},
         specs_index
       )
       when op in [:prune_enum, :hide_field, :rename_field, :pin_default, :set_arg_description] do
    case spec_for(target, specs_index) do
      nil ->
        [{tool_key, struct(Noizu.MCP.Toolset.Override, op: op, target: arg_key, value: value)}]

      spec ->
        field = field_atom(spec, arg_key) || arg_key

        [
          {spec.definition.name,
           struct(Noizu.MCP.Toolset.Override, op: op, target: field, value: value)}
        ]
    end
  end

  defp validation_op(%{op: op, target: %{tool: tool_key} = target, value: value}, specs_index)
       when op in [:set_visible, :set_callable, :set_name, :set_description, :set_title] do
    case spec_for(target, specs_index) do
      nil ->
        [{tool_key, struct(Noizu.MCP.Toolset.Override, op: op, target: tool_key, value: value)}]

      spec ->
        {spec.definition.name,
         struct(Noizu.MCP.Toolset.Override, op: op, target: spec.definition.name, value: value)}
        |> List.wrap()
    end
  end

  defp validation_op(_op_map, _specs_index), do: []

  @doc """
  Audience shape of a set (FR-2A-6): `:org` | `:project` | `:group`.
  """
  def shape(%MCPToolSet{project_id: project_id, group_id: group_id}) do
    cond do
      project_id -> :project
      group_id -> :group
      true -> :org
    end
  end

  @doc """
  The plane tools + expanded group tools universe for a set/profile allowlist
  (FR-2B-4, R2): the root aggregate's tools MINUS every customizable-group
  tool = the always-served Discovery/NPL/overview plane; group tools come from
  each group's server module registry. Returns
  `%{include: [canonical_name], specs: %{canonical_name => %Spec{}}}`.
  """
  def universe_for_groups(group_ids) when is_list(group_ids) do
    root_specs = expand_specs(NoizuPromptLingua.MCP)

    group_specs =
      group_ids
      |> Enum.flat_map(fn group_id ->
        case MCPServers.server_module(group_id) do
          nil -> []
          module -> expand_specs(module)
        end
      end)
      |> Enum.uniq_by(& &1.definition.name)

    group_names = MapSet.new(group_specs, & &1.definition.name)

    plane_specs =
      root_specs
      |> Enum.reject(&MapSet.member?(group_names, &1.definition.name))
      |> Enum.uniq_by(& &1.definition.name)

    specs = plane_specs ++ group_specs

    %{
      include: Enum.map(specs, & &1.definition.name),
      specs: Map.new(specs, &{&1.definition.name, &1})
    }
  end

  def universe_for_groups(_), do: %{include: [], specs: %{}}

  @doc "Include list only (`universe_for_groups/1` convenience for profiles)."
  def universe_include(group_ids), do: universe_for_groups(group_ids).include

  @doc """
  The serving flip (PRD-N3, AC-N3-9): the resolved
  `:noizu_prompt_lingua, :tool_sets_enabled` application env. Non-test envs
  get it from config/runtime.exs (`TOOL_SETS_ENABLED`, default true —
  "false"/"0"/"no" is the kill switch); tests pin it via `Application.put_env`.
  false ⇒ the set gateways 404 (one shared body, no oracle) and save-time
  config validation downgrades to the N2a structural-only changeset. The B1
  fix routes every flag check through THIS reader so the resolved value (env
  default included) is the single source of truth.
  """
  def enabled?, do: Application.get_env(:noizu_prompt_lingua, :tool_sets_enabled, false)

  @doc "Config group ids participating in the allowlist (explicit `enabled: false` excludes)."
  def enabled_groups(config) when is_map(config) do
    config
    |> Map.get("groups", %{})
    |> Enum.reject(fn {_group_id, group_cfg} ->
      is_map(group_cfg) and Map.get(group_cfg, "enabled") == false
    end)
    |> Enum.map(&elem(&1, 0))
  end

  def enabled_groups(_), do: []

  # Expand a server module's registered tools into %Spec{} structs.
  defp expand_specs(module) do
    module.__mcp__(:tools)
    |> Noizu.MCP.Server.Features.Tools.expand()
  rescue
    e ->
      Logger.warning(
        "[ToolSets] spec expansion failed for #{inspect(module)}: #{Exception.message(e)}"
      )

      []
  end

  # N2a map ops → lib %Override{} structs keyed by base canonical name.
  # Unknown tool targets (and arg fields) are dropped with a warning (D5).
  defp override_map(config, specs_index) do
    config
    |> to_overrides()
    |> Enum.flat_map(fn op_map ->
      case flatten_op(op_map, specs_index) do
        {name, %Noizu.MCP.Toolset.Override{} = override} -> [{name, override}]
        nil -> []
      end
    end)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
  end

  defp flatten_op(%{op: op, target: target, value: value}, specs_index)
       when op in [:prune_enum, :hide_field, :rename_field, :pin_default, :set_arg_description] do
    with %Noizu.MCP.Server.Tool.Spec{} = spec <- spec_for(target, specs_index),
         field when is_atom(field) <- field_atom(spec, target.arg) do
      {spec.definition.name,
       struct(Noizu.MCP.Toolset.Override, op: op, target: field, value: value)}
    else
      _ ->
        Logger.warning(
          "[ToolSets] dropping arg op #{inspect(op)} for #{inspect(target.tool)}.#{inspect(target.arg)} — unknown field (D5)"
        )

        nil
    end
  end

  defp flatten_op(%{op: op, target: target, value: value}, specs_index)
       when op in [:set_visible, :set_callable, :set_name, :set_description, :set_title] do
    case spec_for(target, specs_index) do
      %Noizu.MCP.Server.Tool.Spec{} = spec ->
        {spec.definition.name,
         struct(Noizu.MCP.Toolset.Override, op: op, target: spec.definition.name, value: value)}

      nil ->
        Logger.warning(
          "[ToolSets] dropping op #{inspect(op)} for unknown tool #{inspect(target.tool)} (D5)"
        )

        nil
    end
  end

  defp flatten_op(_op, _specs_index), do: nil

  defp spec_for(%{tool: tool_key}, specs_index) do
    canonical = ToolNames.canonical(tool_key)

    Map.get(specs_index, tool_key) ||
      Enum.find(specs_index, fn {name, _spec} -> ToolNames.canonical(name) == canonical end)
      |> case do
        {_name, spec} -> spec
        nil -> nil
      end
  end

  defp spec_for(_, _), do: nil

  # Map a config arg key (string) onto the spec's cast-plan field atom. The
  # cast plan is Fields-shaped — entries may be %Field{} structs or plain
  # %{name: atom, wire_key: ...} maps; a miss degrades per D5. Public: the
  # admin effective-preview resolves base schema keys against the same cast
  # plan the serving assembly used (rename-aware pruned-arg diffing).
  def field_atom(%Noizu.MCP.Server.Tool.Spec{cast_plan: cast_plan}, arg_key)
      when is_binary(arg_key) do
    cast_plan
    |> List.wrap()
    |> Enum.find_value(fn
      %{name: name} = field when is_atom(name) ->
        cond do
          Atom.to_string(name) == arg_key -> name
          wire_key_of(field) == arg_key -> name
          true -> nil
        end

      _ ->
        nil
    end)
  end

  def field_atom(_, _), do: nil

  defp wire_key_of(field) do
    case Map.get(field, :wire_key) do
      nil ->
        case Map.get(field, :opts) do
          opts when is_list(opts) -> Keyword.get(opts, :wire_key)
          opts when is_map(opts) -> Map.get(opts, :wire_key)
          _ -> nil
        end

      wire_key ->
        wire_key
    end
  end

  @doc """
  Pure translator (FR-2A-4): valid config map → normalized override ops, one
  per configured change, stable order (groups sorted → tools sorted → args
  sorted; within a tool: enabled ops, name, description; within an arg, PRD-1
  §4.5 vocabulary order: prune_enum, hide_field, rename_field, pin_default,
  set_arg_description).

    * tool `enabled: false` ⇒ `:set_visible false` + `:set_callable false`
      (explicit `enabled: true` is the default state — no ops)
    * tool `name` / `description` ⇒ `:set_name` / `:set_description`
    * arg `enum_remove` / `hide` / `rename` / `default` / `description` ⇒
      `:prune_enum` / `:hide_field` / `:rename_field` / `:pin_default` /
      `:set_arg_description`

  Group-level `enabled` is include-metadata (the N2b allowlist), not an
  override op. Purity: no DB/ETS/env access; same input ⇒ same output. N2b
  wraps each element into `%Noizu.MCP.Toolset.Override{}`.
  """
  def to_overrides(config) when is_map(config) do
    config
    |> Map.get("groups", %{})
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.flat_map(fn {group_id, group_cfg} ->
      tools = group_cfg |> Map.get("tools", %{}) |> Enum.sort_by(&elem(&1, 0))

      Enum.flat_map(tools, fn {tool_name, tool_cfg} ->
        tool_ops(group_id, tool_name, tool_cfg) ++ arg_ops(group_id, tool_name, tool_cfg)
      end)
    end)
  end

  def to_overrides(_), do: []

  defp tool_ops(group_id, tool_name, tool_cfg) do
    target = %{group: group_id, tool: tool_name}

    enabled_ops =
      case Map.get(tool_cfg, "enabled") do
        false ->
          [
            %{op: :set_visible, target: target, value: false},
            %{op: :set_callable, target: target, value: false}
          ]

        _ ->
          []
      end

    name_ops =
      case Map.get(tool_cfg, "name") do
        nil -> []
        name -> [%{op: :set_name, target: target, value: name}]
      end

    description_ops =
      case Map.get(tool_cfg, "description") do
        nil -> []
        description -> [%{op: :set_description, target: target, value: description}]
      end

    enabled_ops ++ name_ops ++ description_ops
  end

  defp arg_ops(group_id, tool_name, tool_cfg) do
    args = tool_cfg |> Map.get("args", %{}) |> Enum.sort_by(&elem(&1, 0))

    Enum.flat_map(args, fn {arg_name, arg_cfg} ->
      target = %{group: group_id, tool: tool_name, arg: arg_name}

      []
      |> append_op(Map.get(arg_cfg, "enum_remove"), :prune_enum, target)
      |> append_op(Map.get(arg_cfg, "hide"), :hide_field, target)
      |> append_op(Map.get(arg_cfg, "rename"), :rename_field, target)
      |> append_op(Map.get(arg_cfg, "default"), :pin_default, target)
      |> append_op(Map.get(arg_cfg, "description"), :set_arg_description, target)
    end)
  end

  defp append_op(ops, nil, _op, _target), do: ops
  defp append_op(ops, value, op, target), do: ops ++ [%{op: op, target: target, value: value}]

  # ---- helpers ----

  defp get_attr(attrs, key) when is_map(attrs) do
    Map.get(attrs, key, Map.get(attrs, Atom.to_string(key)))
  end

  defp deep_copy(map) when is_map(map) do
    Map.new(map, fn
      {k, v} when is_atom(k) -> {Atom.to_string(k), deep_copy(v)}
      {k, v} -> {k, deep_copy(v)}
    end)
  end

  defp deep_copy(other), do: other

  defp normalize_slug(slug) when is_binary(slug) do
    slug |> String.trim() |> String.downcase()
  end

  # In-row audit stamp (carry_audit precedent): record the acting user in the
  # row's settings jsonb. No new audit table (PRD open question, out of scope).
  defp stamp_actor(attrs, opts) do
    case Keyword.get(opts, :actor_id) do
      nil ->
        attrs

      actor_id when is_binary(actor_id) ->
        settings =
          attrs
          |> get_attr(:settings)
          |> Kernel.||(%{})
          |> stringify_map()
          |> Map.put("updated_by", actor_id)

        Map.new(attrs, fn {k, v} -> {to_string(k), v} end)
        |> Map.put("settings", settings)
    end
  end

  defp stringify_map(map) when is_map(map) do
    Map.new(map, fn {k, v} -> {to_string(k), v} end)
  end

  # Best-effort write-path propagation (N1 wiring): bump ToolsetCache +
  # broadcast tools/list_changed on every NPL MCP server. A failure here must
  # never fail the write (mirror of MCPCustomScopes.bump_cache_on_ok).
  defp notify_on_ok({:ok, tool_set} = ok, event_fun) do
    Logger.info("[ToolSets] #{event_fun.(tool_set)}")
    Server.notify_toolset_changed()
    ok
  end

  defp notify_on_ok(other, _event_fun), do: other
end
