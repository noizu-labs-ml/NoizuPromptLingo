defmodule NoizuPromptLinguaWeb.ToolSetProfilesController do
  @moduledoc """
  Org-admin management for MCP tool sets (PRD-N4 §4.1): list the 5 built-in
  profiles (read-only DATA, R1) next to the org's own sets, and create /
  update / deactivate / clone sets through `MCP.ToolSets`.

  N4b (PRD-3 gate): `validate/2` dry-runs a candidate config through
  `Noizu.MCP.Toolset.Validator.compile/3` against the LIVE catalog (pure —
  never persists), `show/2` carries the D1-correct `effective` preview (the
  serving pipeline's `compose_full` over `ToolSets.assemble_custom/2`), and
  create/update REJECT configs that cannot compile once the serving flip is
  on (`:tool_sets_enabled` — R8 save-time guarantee). `group_options/2` and
  `arg_enum/2` back the frontend's group selector and enum-prune picker.

  Every mutation records in-row provenance under `settings["_audit"]`
  (bounded, last 20 — the `MCPCustomScopes.carry_audit` precedent; NPL has no
  dedicated audit table) plus a structured Logger event. Audit failure NEVER
  fails the mutation (log-only path, FR-4-5).
  """
  use NoizuPromptLinguaWeb, :controller

  require Logger

  alias Noizu.MCP.Ctx
  alias Noizu.MCP.Toolset.Custom
  alias Noizu.MCP.Toolset.Validator
  alias NoizuPromptLingua.Authz.Groups
  alias NoizuPromptLingua.Guardian
  alias NoizuPromptLingua.MCP.ToolSetEndpoint
  alias NoizuPromptLingua.MCP.ToolSets
  alias NoizuPromptLingua.MCP.Toolsets.Profiles
  alias NoizuPromptLingua.MCPServers
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Authz.Group
  alias NoizuPromptLingua.Schema.MCPToolSet
  alias NoizuPromptLingua.Tools.Catalog
  alias NoizuPromptLingua.Authz.ScopedMemberships

  # Reserved settings keys preserved across updates (never client-writable).
  @system_keys ~w(cloned_from updated_by _audit)

  # In-row audit trail bound (PRD-N4 §4.1: last 20).
  @audit_max 20

  @doc """
  GET /api/v1/organizations/:org_id/tool-sets — built-in profiles (from DATA,
  never rows) + the org's sets (active AND deactivated, FR-4-3) with shape,
  digest and group-set member counts.
  """
  def index(conn, %{"org_id" => org_id}) do
    counts = group_tool_counts()

    json(conn, %{
      profiles: Enum.map(Profiles.all(), &profile_view(&1, counts)),
      sets:
        org_id
        |> ToolSets.list_for_org(include_inactive: true)
        |> Enum.map(&set_view/1)
    })
  end

  @doc """
  GET .../tool-sets/:slug — resolves built-in profile slugs to their read-only
  view and anything else to the org's row (404 for foreign slugs — no
  cross-org read, FR-4-1). Both carry `effective`: the D1-correct preview —
  the serving pipeline's own compose (`Custom.compose_full/3` over the
  assembled `%Toolset.Custom{}`), per-tool effective name / visibility /
  pruned-arg summaries / provenance layer ids (FR-4-7). The admin sees exactly
  what a caller gets, never a parallel renderer.
  """
  def show(conn, %{"org_id" => org_id, "slug" => slug}) do
    cond do
      profile = Profiles.get(slug) ->
        profile_config = %{"groups" => Map.new(profile.groups, &{&1, %{"enabled" => true}})}

        view =
          profile
          |> profile_view(group_tool_counts())
          |> Map.put(:preview, profile_preview(profile, group_tool_counts()))
          |> Map.put(:effective, effective_preview(Profiles.custom(profile), profile_config))

        json(conn, %{profile: view})

      tool_set = ToolSets.get_by_org_and_slug(org_id, slug) ->
        view =
          tool_set
          |> set_view(with_audit: true)
          |> Map.put(
            :effective,
            effective_preview(ToolSets.assemble_custom(tool_set), tool_set.config)
          )
          # The edit form needs the full config; the list view carries only the
          # digest.
          |> Map.put(:config, tool_set.config)

        json(conn, %{tool_set: view})

      true ->
        not_found(conn)
    end
  end

  @doc """
  POST .../tool-sets — create a custom set. Organization, source and
  provenance are controller-owned (`source: "custom"`; cloning is the clone
  route's job). Identity fields (project/group audience) ride the create
  changeset. 201 + set_view, or 422 + changeset field errors.
  """
  def create(conn, %{"org_id" => org_id} = params) do
    actor_id = current_user_id(conn)
    body = set_params(params)

    attrs =
      body
      |> Map.put("organization_id", org_id)
      |> Map.drop(["source", "source_profile", "settings"])

    settings = audit_settings(%{}, Map.get(body, "settings"), "create", actor_id)

    case reject_invalid_config(conn, attrs["config"]) do
      :ok ->
        case ToolSets.create(Map.put(attrs, "settings", settings), actor_id: actor_id) do
          {:ok, tool_set} ->
            audit_log("create", tool_set.slug, actor_id, "ok")

            conn
            |> put_status(:created)
            |> json(%{tool_set: set_view(tool_set, with_audit: true)})

          {:error, %Ecto.Changeset{} = cs} ->
            audit_log("create", attrs["slug"] || attrs["display_name"], actor_id, "error")
            changeset_error(conn, cs)
        end

      {:error, conn} ->
        audit_log("create", attrs["slug"] || attrs["display_name"], actor_id, "error")
        conn
    end
  end

  @doc """
  PATCH .../tool-sets/:slug — partial update of config/settings/display_name/
  description/expires_at/is_active. Profile slugs are rejected controller-side
  (FR-4-4). Deactivated sets reactivate via `is_active: true`.
  """
  def update(conn, %{"org_id" => org_id, "slug" => slug} = params) do
    with {:ok, actor_id} <- require_actor(conn),
         :ok <- reject_profile_slug(slug),
         {:ok, tool_set} <- load_set(org_id, slug) do
      submitted =
        params
        |> set_params()
        |> Map.take([
          "display_name",
          "description",
          "config",
          "settings",
          "expires_at",
          "is_active"
        ])

      if submitted == %{} do
        json(conn, %{tool_set: set_view(tool_set)})
      else
        case reject_invalid_config(conn, Map.get(submitted, "config")) do
          :ok ->
            attrs = Map.delete(submitted, "settings")

            settings =
              audit_settings(
                tool_set.settings,
                Map.get(submitted, "settings"),
                "update",
                actor_id
              )

            case ToolSets.update(tool_set, Map.put(attrs, "settings", settings),
                   actor_id: actor_id
                 ) do
              {:ok, updated} ->
                audit_log("update", updated.slug, actor_id, "ok")
                json(conn, %{tool_set: set_view(updated, with_audit: true)})

              {:error, %Ecto.Changeset{} = cs} ->
                audit_log("update", slug, actor_id, "error")
                changeset_error(conn, cs)
            end

          {:error, conn} ->
            audit_log("update", slug, actor_id, "error")
            conn
        end
      end
    else
      {:error, :read_only_profile} -> read_only(conn)
      {:error, :not_found} -> not_found(conn)
    end
  end

  @doc """
  POST .../tool-sets/:slug/deactivate — soft-kill (R8), idempotent. The set
  drops out of the request path (`get_for_request/2`, AC-2A-8) but stays
  listable in the index with `is_active: false`.
  """
  def deactivate(conn, %{"org_id" => org_id, "slug" => slug}) do
    with {:ok, actor_id} <- require_actor(conn),
         :ok <- reject_profile_slug(slug),
         {:ok, tool_set} <- load_set(org_id, slug) do
      settings = audit_settings(tool_set.settings, nil, "deactivate", actor_id)

      # Routed through update/3 (the context deactivate/2 wrapper cannot carry
      # the audited settings) — same changeset, same notify-on-ok path.
      case ToolSets.update(tool_set, %{"is_active" => false, "settings" => settings},
             actor_id: actor_id
           ) do
        {:ok, updated} ->
          audit_log("deactivate", updated.slug, actor_id, "ok")
          json(conn, %{tool_set: set_view(updated, with_audit: true)})

        {:error, %Ecto.Changeset{} = cs} ->
          audit_log("deactivate", slug, actor_id, "error")
          changeset_error(conn, cs)
      end
    else
      {:error, :read_only_profile} -> read_only(conn)
      {:error, :not_found} -> not_found(conn)
    end
  end

  @doc """
  POST .../tool-sets/clone — `{source: profile_slug | set_slug, ...attrs}` →
  201 + new editable set (FR-2A-7 semantics: allowlist config deep-copied from
  the profile, provenance recorded, slug auto-suggested `<source>-copy`).
  Validation of the copied config is N4b machinery.
  """
  def clone(conn, %{"org_id" => org_id} = params) do
    with {:ok, actor_id} <- require_actor(conn),
         {:ok, source, source_slug} <- resolve_source(org_id, params) do
      # `source` rides at the top level (PRD §4.1) while the create attrs may
      # sit under the `tool_set` wrapper — merge both views. Organization is
      # controller-owned (path-resolved UUID).
      body =
        params
        |> set_params()
        |> Map.put("source", params["source"] || set_params(params)["source"])
        |> Map.put("organization_id", org_id)
        |> Map.delete("settings")

      settings = audit_settings(%{}, Map.get(set_params(params), "settings"), "clone", actor_id)

      case ToolSets.clone(source, Map.put(body, "settings", settings), actor_id: actor_id) do
        {:ok, tool_set} ->
          audit_log("clone", tool_set.slug, actor_id, "ok")

          conn
          |> put_status(:created)
          |> json(%{tool_set: set_view(tool_set, with_audit: true)})

        {:error, %Ecto.Changeset{} = cs} ->
          audit_log("clone", source_slug, actor_id, "error")
          changeset_error(conn, cs)

        {:error, other} ->
          audit_log("clone", source_slug, actor_id, "error")
          conn |> put_status(:unprocessable_entity) |> json(%{error: inspect(other)})
      end
    else
      {:error, :not_found} -> not_found(conn, "source tool set not found")
    end
  end

  @doc """
  POST .../tool-sets/validate — N4b dry-run (FR-4-6): compile the candidate
  config through `Noizu.MCP.Toolset.Validator.compile/3` against the live
  catalog. Pure — NEVER persists. 200 `%{ok: true, warnings}` (non-fatal
  notes) or 422 `%{ok: false, issues}` with structured lib-code issues.
  Accepts the create/update body shape (inline config) so the editor can
  validate before saving.
  """
  def validate(conn, params) do
    config = set_params(params)["config"]

    case ToolSets.validate_config(config) do
      {:ok, warnings} ->
        json(conn, %{ok: true, warnings: warnings})

      {:error, issues} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{ok: false, issues: Enum.map(issues, &issue_view/1)})
    end
  end

  @doc """
  GET .../tool-sets/group-options — N4b group-selector completeness: REAL
  authz groups (`groups` via `Authz.Groups`) alongside the 5 ladder roles they
  currently are, each labeled by `kind` and carrying an expires_at-aware
  member count (`list_for_resource/2` already excludes expired rows). R3
  group-pinning targets custom groups; the ladder roles are named
  distinctly so the UI can separate them.
  """
  def group_options(conn, %{"org_id" => org_id}) do
    ladder = Group.role_names()

    counts =
      "organization"
      |> ScopedMemberships.list_for_resource(org_id)
      |> Enum.frequencies_by(& &1.role)

    json(conn, %{
      groups:
        Enum.map(Groups.list_all(), fn group ->
          %{
            id: group.id,
            name: group.name,
            display_name: group.display_name,
            is_system: group.is_system,
            kind: if(group.name in ladder, do: "ladder_role", else: "custom"),
            member_count: Map.get(counts, group.name, 0)
          }
        end)
    })
  end

  @doc """
  GET .../tool-sets/arg-enum?tool=&arg= — N4b enum-picker seeds: the base enum
  values of one arg from the live catalog (the prune candidates).
  """
  def arg_enum(conn, %{"tool" => tool, "arg" => arg})
      when is_binary(tool) and is_binary(arg) do
    case ToolSets.arg_enum_values(tool, arg) do
      {:ok, values} ->
        json(conn, %{tool: tool, arg: arg, values: values})

      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "no enum for #{inspect(tool)}.#{inspect(arg)}", code: to_string(reason)})
    end
  end

  def arg_enum(conn, _params),
    do: conn |> put_status(:unprocessable_entity) |> json(%{error: "tool and arg are required"})

  # ---- N4b: catalog validation (FR-4-6/7) ----

  # R8 save-time guarantee: once the serving flip is on, a config that cannot
  # compile against the live catalog is rejected at write instead of being
  # stored to D5-disable at serve time. Pre-flip (flag off) keeps the N4a
  # structural-only changeset contract. B1: same resolved-flag reader as the
  # gateway gate.
  defp reject_invalid_config(conn, config) do
    if ToolSets.enabled?() do
      case ToolSets.validate_config(config) do
        {:ok, _warnings} ->
          :ok

        {:error, issues} ->
          {:error,
           conn
           |> put_status(:unprocessable_entity)
           |> json(%{
             ok: false,
             error: "config failed catalog validation",
             issues: Enum.map(issues, &issue_view/1)
           })}
      end
    else
      :ok
    end
  end

  # ---- params ----

  # Accept a `tool_set` (or `set`) wrapper or a flat body, string-keyed.
  defp set_params(%{"tool_set" => attrs}) when is_map(attrs), do: stringify(attrs)
  defp set_params(%{"set" => attrs}) when is_map(attrs), do: stringify(attrs)
  defp set_params(attrs) when is_map(attrs), do: stringify(attrs)

  defp stringify(map) do
    Map.new(map, fn
      {k, v} when is_atom(k) -> {Atom.to_string(k), v}
      {k, v} -> {k, v}
    end)
  end

  defp resolve_source(org_id, params) do
    source = params["source"] || set_params(params)["source"]

    cond do
      not is_binary(source) or source == "" ->
        {:error, :not_found}

      is_binary(source) and not is_nil(Profiles.get(source)) ->
        {:ok, source, source}

      tool_set = ToolSets.get_by_org_and_slug(org_id, source) ->
        {:ok, tool_set, source}

      true ->
        {:error, :not_found}
    end
  end

  defp load_set(org_id, slug) do
    case ToolSets.get_by_org_and_slug(org_id, slug) do
      nil -> {:error, :not_found}
      tool_set -> {:ok, tool_set}
    end
  end

  defp reject_profile_slug(slug) do
    if slug in Profiles.slugs() or slug in MCPToolSet.reserved_slugs() do
      {:error, :read_only_profile}
    else
      :ok
    end
  end

  # ---- audit (FR-4-5) ----

  # Final settings for a mutation: when the client submits `settings` it
  # replaces the editable keys (system keys survive from the row), when it
  # does not the row's settings ride along unchanged — either way the audit
  # entry is appended (bounded trail). System keys are never client-writable.
  defp audit_settings(current, provided, action, actor_id) do
    trail =
      case Map.get(current || %{}, "_audit") do
        entries when is_list(entries) -> Enum.take(entries, -(@audit_max - 1))
        _ -> []
      end

    entry = %{
      "at" => DateTime.utc_now() |> DateTime.to_iso8601(),
      "actor" => actor_id,
      "action" => action
    }

    base =
      if is_map(provided) do
        (current || %{})
        |> Map.take(@system_keys)
        |> Map.merge(stringify(provided))
      else
        stringify(current || %{})
      end

    Map.put(base, "_audit", trail ++ [entry])
  rescue
    _ ->
      %{
        "_audit" => [
          %{
            "at" => DateTime.utc_now() |> DateTime.to_iso8601(),
            "actor" => actor_id,
            "action" => action
          }
        ]
      }
  end

  # Structured Logger event with the same fields as the in-row provenance.
  # Best-effort: a logging failure must never fail the mutation (FR-4-5).
  defp audit_log(action, target, actor_id, result) do
    Logger.info("mcp_tool_set #{action} slug=#{target}",
      event: [:mcp_tool_set, :mutation],
      action: action,
      target: target,
      actor: actor_id,
      result: result
    )
  rescue
    _ -> :ok
  end

  # ---- views ----

  defp profile_view(profile, counts) do
    %{
      slug: profile.slug,
      display_name: profile.label,
      description: profile.description,
      groups: profile.groups,
      group_count: length(profile.groups),
      tool_count: profile.groups |> Enum.map(&Map.get(counts, &1, 0)) |> Enum.sum(),
      cloneable: true,
      editable: false,
      is_profile: true,
      is_active: true
    }
  end

  # Structural preview over the registry for a profile: what a clone would
  # start from. NOT an effective-catalog preview — that is N4b (D1).
  defp profile_preview(profile, counts) do
    %{
      groups:
        Map.new(profile.groups, fn group_id ->
          {group_id,
           %{
             enabled: true,
             tool_count: Map.get(counts, group_id, 0),
             overridden_tools: 0,
             override_ops: 0
           }}
        end),
      total_override_ops: 0
    }
  end

  defp set_view(tool_set, opts \\ []) do
    settings = tool_set.settings || %{}

    view = %{
      id: tool_set.id,
      slug: tool_set.slug,
      display_name: tool_set.display_name || tool_set.slug,
      description: tool_set.description,
      shape: shape_of(tool_set),
      project_id: tool_set.project_id,
      group_id: tool_set.group_id,
      source: tool_set.source,
      source_profile: tool_set.source_profile,
      is_active: tool_set.is_active,
      expires_at: to_iso8601(tool_set.expires_at),
      config_digest: digest(tool_set.config),
      # Live count for group sets (org members carrying the group's role);
      # nil otherwise. Computed per request — fine at admin scale (PRD §10.3).
      member_count: member_count(tool_set),
      settings: Map.take(settings, ~w(allow_api_keys description_verbosity instructions)),
      updated_by: Map.get(settings, "updated_by"),
      updated_at: to_iso8601(tool_set.updated_at),
      # N3 seam: the gateway/set URL builders land with PRD-N3.
      urls: %{mcp: nil, admin: nil}
    }

    if Keyword.get(opts, :with_audit, false) do
      Map.put(view, :audit, Map.get(settings, "_audit", []))
    else
      view
    end
  end

  # ── N4b effective preview (FR-4-7, D1) ──────────────────────────────────────

  # The D1-correct view: the serving pipeline's own compose_full/3 over the
  # assembled (or profile) toolset, with an unauthenticated ctx — no ACL pass
  # (NPL's provider answers :allow for subjectless principals) and no grant
  # layers, so what the admin sees is the SET's static surface; per-caller
  # ACL/grants remain the serving path's business.
  defp effective_preview(%Custom{} = custom, config) do
    base_index =
      config
      |> ToolSets.enabled_groups()
      |> ToolSets.universe_for_groups()
      |> Map.get(:specs)

    ctx = %Ctx{server: ToolSetEndpoint, auth: nil}

    case Custom.compose_full(custom, ctx, []) do
      {:ok, %{entries: entries, version: version, provenance: provenance}} ->
        renames = rename_map(custom)

        %{
          version: version,
          tools:
            Enum.map(entries, &effective_tool_view(&1, custom, renames, base_index, provenance))
        }

      {:error, %Noizu.MCP.Error{data: %{issues: issues}}} ->
        # Invalid config serving D5-degraded — surface the lib's own issues.
        %{version: nil, tools: [], issues: Enum.map(issues, &issue_view/1)}

      {:error, %Noizu.MCP.Error{}} ->
        %{version: nil, tools: [], issues: []}
    end
  end

  defp effective_tool_view(entry, custom, renames, base_index, provenance) do
    name = entry.definition.name
    base_name = Map.get(renames, name, name)
    base_spec = Map.get(base_index, base_name)
    field_renames = field_rename_map(custom, base_name, base_spec)
    eff_props = schema_props(entry.input_schema)

    provenance_rows =
      provenance
      |> Map.get(name, %{})
      |> Enum.map(fn {{_tool, op, field}, {layer, weight}} ->
        %{op: safe(op), field: safe(field), layer: safe(layer), weight: weight}
      end)
      |> Enum.sort_by(& &1.weight)

    %{
      name: name,
      base_name: base_name,
      renamed: name != base_name,
      visible: entry.visible,
      callable: entry.callable,
      reason: safe(entry.reason),
      pruned_args: pruned_args(base_spec, eff_props, field_renames),
      arg_renames: field_renames,
      hidden_args: hidden_args(base_spec, eff_props, field_renames),
      provenance: provenance_rows
    }
  end

  # base wire name → original base name, from the assembled static ops.
  defp rename_map(%Custom{tools: tools}) do
    tools
    |> Enum.flat_map(fn {base, ops} ->
      case Enum.find(ops, &(&1.op == :set_name)) do
        %{value: value} when is_binary(value) and value != base -> [{value, base}]
        _ -> []
      end
    end)
    |> Map.new()
  end

  # Config `rename` ops on the tool's args → %{base_schema_key => effective
  # wire key}. Ops carry cast-plan atoms (the serving assembly resolved them
  # through ToolSets.field_atom/2); base schema keys resolve through the same
  # path so the rename composes with the schema-keyed diff below. Direct
  # key-string targets match too.
  defp field_rename_map(_custom, _base_name, nil), do: %{}

  defp field_rename_map(%Custom{tools: tools}, base_name, base_spec) do
    key_atoms =
      base_spec
      |> schema_props()
      |> Map.new(fn {key, _} -> {key, ToolSets.field_atom(base_spec, key)} end)

    tools
    |> Map.get(base_name, [])
    |> Enum.flat_map(fn
      %Noizu.MCP.Toolset.Override{op: :rename_field, target: target, value: value} ->
        for {key, atom} <- key_atoms,
            atom == target or to_string(atom) == to_string(target) or to_string(target) == key do
          {key, to_string(value)}
        end

      _ ->
        []
    end)
    |> Map.new()
  end

  # Args whose enum the set pruned: base enum minus the effective enum, read
  # off the compose_full materialization (the entry schema — the same surface
  # the wire serves). Rename-aware: rename_field MOVES the property key, so
  # each base field diffs against its effective (renamed) key; the pre-fix
  # renderer looked the base key up verbatim, missed, and reported the FULL
  # base enum for every renamed arg. Fields GONE from the wire (hide_field)
  # are `hidden_args/3` business — an absent arg is not an enum prune.
  defp pruned_args(nil, _eff_props, _field_renames), do: %{}

  defp pruned_args(base_spec, eff_props, field_renames) do
    base_spec
    |> schema_props()
    |> Enum.flat_map(fn {field, prop} ->
      with base when is_list(base) <- Map.get(prop, "enum"),
           eff_key = Map.get(field_renames, field, field),
           {:ok, eff_prop} <- Map.fetch(eff_props, eff_key),
           eff when is_list(eff) <- Map.get(eff_prop, "enum") || [],
           removed = Enum.reject(base, &(&1 in eff)),
           true <- removed != [] do
        [{field, removed}]
      else
        _ -> []
      end
    end)
    |> Map.new()
  end

  # Base fields GONE from the effective wire schema (hide_field): their value
  # space left the wire, so the admin sees them listed here instead of as a
  # misleading full-enum prune.
  defp hidden_args(nil, _eff_props, _field_renames), do: []

  defp hidden_args(base_spec, eff_props, field_renames) do
    base_spec
    |> schema_props()
    |> Enum.filter(fn {field, _prop} ->
      eff_key = Map.get(field_renames, field, field)
      not Map.has_key?(eff_props, eff_key)
    end)
    |> Enum.map(&elem(&1, 0))
  end

  # %Spec{} → its wire schema; a raw schema map passes through.
  defp schema_props(%Noizu.MCP.Server.Tool.Spec{definition: definition}),
    do: schema_props(definition.input_schema)

  defp schema_props(schema) when is_map(schema), do: Map.get(schema, "properties") || %{}
  defp schema_props(_), do: %{}

  # %Validator.Issue{} → the §4.1 JSON contract row, Jason-safe throughout.
  defp issue_view(%Validator.Issue{} = issue) do
    %{
      code: safe(issue.code),
      message: issue.message,
      tool: safe(issue.tool),
      field: safe(issue.field),
      op: safe(issue.op),
      meta: safe(issue.meta)
    }
  end

  defp issue_view(other),
    do: %{code: "unknown", message: safe(other), tool: nil, field: nil, op: nil, meta: nil}

  # Atoms/tuples → Jason-encodable strings/lists (issues carry :atom codes and
  # {:acl, provider}-style layer ids).
  defp safe(v) when is_atom(v) and not is_boolean(v) and not is_nil(v), do: Atom.to_string(v)
  defp safe(v) when is_map(v), do: Map.new(v, fn {k, x} -> {safe(k), safe(x)} end)
  defp safe(v) when is_list(v), do: Enum.map(v, &safe/1)
  defp safe(v) when is_tuple(v), do: Enum.map(Tuple.to_list(v), &safe/1)
  defp safe(other), do: other

  defp shape_of(%MCPToolSet{group_id: gid}) when is_binary(gid), do: "group"
  defp shape_of(%MCPToolSet{project_id: pid}) when is_binary(pid), do: "project"
  defp shape_of(%MCPToolSet{}), do: "org"

  # Group-set audience size: org members whose membership row carries the
  # set's group (role). via ScopedMemberships.list_for_resource/3 (PRD §10.3).
  defp member_count(%MCPToolSet{group_id: gid, organization_id: org_id})
       when is_binary(gid) and is_binary(org_id) do
    case Repo.get(Group, gid) do
      nil ->
        nil

      group ->
        org_members = ScopedMemberships.list_for_resource("organization", org_id)
        Enum.count(org_members, &(&1.role == group.name))
    end
  end

  defp member_count(_), do: nil

  # Per-group tool counts, enumerated from each group's MCP server module
  # (MCPServers.server_module/1 — the root server catalog only carries core
  # groups). Computed once per index/show call; admin scale (PRD §10.3).
  defp group_tool_counts do
    Map.new(MCPServers.customizable(), fn group ->
      case MCPServers.server_module(group.id) do
        nil ->
          {group.id, 0}

        module ->
          {group.id, length(Catalog.specs(module))}
      end
    end)
  end

  defp digest(config) when is_map(config) do
    :crypto.hash(:sha256, Jason.encode!(config))
    |> Base.encode16(case: :lower)
    |> binary_part(0, 12)
  end

  defp digest(_), do: nil

  defp to_iso8601(nil), do: nil
  defp to_iso8601(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  defp to_iso8601(_), do: nil

  # ---- auth helpers (mcp_endpoints_controller pattern) ----

  defp require_actor(conn) do
    case current_user_id(conn) do
      nil -> {:error, :not_found}
      id -> {:ok, id}
    end
  end

  defp current_user_id(conn) do
    case Guardian.Plug.current_resource(conn) do
      %{user: {:ref, _, id}} when is_binary(id) -> id
      %{user: %{id: id}} when is_binary(id) -> id
      _ -> nil
    end
  end

  defp not_found(conn, msg \\ "tool set not found"),
    do: conn |> put_status(:not_found) |> json(%{error: msg})

  defp read_only(conn),
    do:
      conn
      |> put_status(:unprocessable_entity)
      |> json(%{
        error: "built-in profiles are read-only; clone one to customize",
        code: "profile_read_only"
      })

  defp changeset_error(conn, cs) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{errors: Ecto.Changeset.traverse_errors(cs, fn {msg, _} -> msg end)})
  end
end
