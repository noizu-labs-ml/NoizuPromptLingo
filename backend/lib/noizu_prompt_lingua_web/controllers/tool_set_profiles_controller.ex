defmodule NoizuPromptLinguaWeb.ToolSetProfilesController do
  @moduledoc """
  Org-admin management for MCP tool sets (PRD-N4 §4.1, N4a scope): list the 5
  built-in profiles (read-only DATA, R1) next to the org's own sets, and
  create / update / deactivate / clone sets through `MCP.ToolSets`.

  Contract-first on pinned hex noizu_mcp 0.1.5 — no lib calls. Structural
  validation only (the N2a changeset is the single authority, FR-4-3); the
  validate dry-run + effective-catalog preview are N4b (gated on lib PRD-3).

    # N4b: dry-run Validator.compile/3 seam — `POST .../tool-sets/validate`
    # (candidate config → issues) lands with the PRD-3 gate.

  Every mutation records in-row provenance under `settings["_audit"]`
  (bounded, last 20 — the `MCPCustomScopes.carry_audit` precedent; NPL has no
  dedicated audit table) plus a structured Logger event. Audit failure NEVER
  fails the mutation (log-only path, FR-4-5).
  """
  use NoizuPromptLinguaWeb, :controller

  require Logger

  alias NoizuPromptLingua.Guardian
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
  view (with a structural preview over the registry) and anything else to the
  org's row (404 for foreign slugs — no cross-org read, FR-4-1).
  """
  def show(conn, %{"org_id" => org_id, "slug" => slug}) do
    counts = group_tool_counts()

    cond do
      profile = Profiles.get(slug) ->
        view =
          profile
          |> profile_view(counts)
          |> Map.put(:preview, profile_preview(profile, counts))

        json(conn, %{profile: view})

      tool_set = ToolSets.get_by_org_and_slug(org_id, slug) ->
        view =
          tool_set
          |> set_view(with_audit: true)
          |> Map.put(:preview, structural_preview(tool_set, counts))
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
        attrs = Map.delete(submitted, "settings")

        settings =
          audit_settings(tool_set.settings, Map.get(submitted, "settings"), "update", actor_id)

        case ToolSets.update(tool_set, Map.put(attrs, "settings", settings), actor_id: actor_id) do
          {:ok, updated} ->
            audit_log("update", updated.slug, actor_id, "ok")
            json(conn, %{tool_set: set_view(updated, with_audit: true)})

          {:error, %Ecto.Changeset{} = cs} ->
            audit_log("update", slug, actor_id, "error")
            changeset_error(conn, cs)
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

  # Structural preview for a stored set: per-group registry tool counts +
  # override-op census computed from the row's config. No lib, no catalog
  # compile (N4b's D1-correct preview replaces this at the flip).
  defp structural_preview(tool_set, counts) do
    groups = Map.get(tool_set.config || %{}, "groups", %{})

    group_previews =
      Map.new(groups, fn {group_id, group_cfg} ->
        tools = Map.get(group_cfg || %{}, "tools", %{})

        {group_id,
         %{
           enabled: Map.get(group_cfg || %{}, "enabled", true),
           tool_count: Map.get(counts, group_id, 0),
           overridden_tools: map_size(tools),
           override_ops: length(ToolSets.to_overrides(%{"groups" => %{group_id => group_cfg}}))
         }}
      end)

    %{groups: group_previews, total_override_ops: length(ToolSets.to_overrides(tool_set.config))}
  end

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
