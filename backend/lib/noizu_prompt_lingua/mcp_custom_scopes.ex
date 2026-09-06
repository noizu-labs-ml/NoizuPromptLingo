defmodule NoizuPromptLingua.MCPCustomScopes do
  @moduledoc """
  CRUD and config helpers for custom MCP include scopes.

  Scopes carry a `kind` (`custom` | `all_in_one` | `core_variant`) and may be
  attached to an organization and/or project (or remain global presets):

    * `custom` — free-form group selection (original behavior).
    * `all_in_one` — an everything-included package. The **required core** groups
      (those flagged `required` in `NoizuPromptLingua.MCPServers`) are auto-included
      and enabled. Disabling one requires a typed confirmation (see `update/3`).
    * `core_variant` — a named core package. `get_core_variant/1` lazily seeds the
      default `"core"` variant.
  """
  # Scoped import: a bare `import Ecto.Query` would pull in `Ecto.Query.update/3`,
  # colliding with this module's `update/3`.
  import Ecto.Query, only: [from: 2, where: 3, order_by: 3]

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.MCPCustomScope
  alias NoizuPromptLingua.MCP.Window
  alias NoizuPromptLingua.MCP.ToolsetConfig
  alias NoizuPromptLingua.MCPServers
  alias NoizuPromptLingua.Tools.Catalog

  # Typed-confirmation phrase required to disable a required core group on an
  # all_in_one scope. Overridable via config; the design spec proposes this wording.
  @confirm_phrase Application.compile_env(
                    :noizu_prompt_lingua,
                    :required_group_confirm_phrase,
                    "YES I KNOW WHAT I AM DOING"
                  )

  @core_variant_slug "core"
  # Group ids the default "core" variant ships with. Verified against
  # `MCPServers` @servers: sessions/projects/organizations all exist. There is no
  # standalone "npl" group — the NPL loader lives on the root endpoint — so it is
  # intentionally omitted here (see report follow-ups).
  @core_variant_groups ~w(sessions projects organizations)

  # W2 scope sharing. Canonical storage is the config jsonb key `"visibility"`;
  # the schema surfaces it via `MCPCustomScope.visibility/1` (virtual field).
  @visibilities ~w(org account shared)

  # W2 named presets, selectable at scope creation via attrs["preset"].
  # `:crud_entity` names the primary entity per group: within preset groups,
  # only `<Entity>_Overview` + `<Entity>_(Create|Get|List|Update|Delete)` stay
  # enabled — everything else in the group is seeded disabled. Groups without a
  # `:crud_entity` keep current behavior (all tools enabled).
  @presets %{
    "basic_crud" => %{
      name: "Basic CRUD",
      description: "Sessions, organizations, projects & tickets — basic CRUD tools only.",
      groups: ~w(sessions organizations projects tickets),
      crud_entity: %{
        "sessions" => "Session",
        "organizations" => "Organization",
        "projects" => "Project",
        "tickets" => "Ticket"
      }
    }
  }

  # Global all-in-one package every account/org is cloned from. NPL load/spec
  # tools are attached by MCP.Custom for all_in_one scopes and tobor clones
  # (not a selectable group).
  @default_package_slug "tobor"
  @account_default_name "Tobor Locker"
  @legacy_account_default_name "default-mcp"
  @default_package_groups ~w(
    sessions organizations projects tickets chat artifacts wiki
    personas instructions memory review assets github notifications
    pubsub
  )

  # W5: the session manifest tool is enabled by default everywhere the tobor
  # template applies — seeded (unrestricted, i.e. enabled + visible per the
  # toolset layer's inverted semantics) into the template's sessions group and
  # union-healed into template-derived scopes. jsonb only; no Liquibase.
  @manifest_tool "Session_Manifest"

  @doc "The manifest tool seeded by default into the `tobor` template's sessions group."
  def manifest_tool, do: @manifest_tool

  # Fresh group config for a default-package group; the sessions group carries
  # the manifest tool entry explicitly.
  defp group_seed("sessions"), do: %{"tools" => %{@manifest_tool => %{}}}
  defp group_seed(_), do: %{"tools" => %{}}

  @doc "The typed-confirmation phrase for disabling required core groups."
  def confirm_phrase, do: @confirm_phrase

  @doc "Slug of the global default package every account is offered."
  def default_package_slug, do: @default_package_slug

  @doc "Display name of the per-account default custom endpoint."
  def account_default_name, do: @account_default_name

  @doc "Group ids seeded into the default `tobor` all-in-one package."
  def default_package_groups, do: @default_package_groups

  @doc "Named presets selectable at scope creation (attrs[\"preset\"])."
  def presets, do: @presets

  @doc """
  Config seed for a named preset, or `nil` when unknown. For CRUD-preset groups
  the seed disables every non-CRUD tool (keys follow the live catalog's emitted
  tool-name form, so downstream disabled lookups match whatever the server
  currently emits); unknown groups seed plain group configs.
  """
  def preset_config(slug) when is_binary(slug) do
    case Map.fetch(@presets, slug) do
      :error ->
        nil

      {:ok, preset} ->
        crud = Map.get(preset, :crud_entity) || %{}

        groups =
          Map.new(preset.groups, fn id ->
            {id, %{"tools" => preset_tools_config(id, crud)}}
          end)

        %{"groups" => groups}
    end
  end

  def preset_config(_), do: nil

  defp preset_tools_config(group_id, crud) do
    case Map.fetch(crud, group_id) do
      :error ->
        %{}

      {:ok, entity} ->
        group_id
        |> MCPServers.server_module()
        |> case do
          nil ->
            %{}

          module ->
            module.__mcp__(:tools)
            |> Noizu.MCP.Server.Features.Tools.expand()
            |> Enum.reject(&discovery_spec?/1)
            # W5: Session_Manifest is enabled by default everywhere (it is the
            # client's own state report, not a mutating tool) — the preset never
            # disables it (contract §5; integration decision).
            |> Enum.reject(&manifest_spec?/1)
            |> Enum.flat_map(fn spec ->
              if basic_crud_tool?(entity, spec.definition.name),
                do: [],
                else: [{spec.definition.name, %{"disabled" => true}}]
            end)
            |> Map.new()
        end
    end
  end

  defp basic_crud_tool?(entity, name) do
    normalized = String.replace(name, ".", "_")

    normalized == "#{entity}_Overview" or
      Regex.match?(~r/^#{entity}_(Create|Get|List|Update|Delete)$/, normalized)
  end

  defp discovery_spec?(spec) do
    ((spec.definition.meta && spec.definition.meta["category"]) || "Uncategorized") == "Discovery"
  end

  defp manifest_spec?(spec) do
    NoizuPromptLingua.MCP.ToolNames.canonical(spec.definition.name) == "Session_Manifest"
  end

  @doc """
  List scopes. Optional `filters`:

    * `{:kind, kind | [kind]}` — restrict by kind
    * `{:organization_id, uuid | nil}` — exact match (`nil` = global/org-less)
    * `{:project_id, uuid | nil}` — exact match (`nil` = project-less)
    * `{:user_id, uuid}` — scopes owned by this user
    * `{:is_default, boolean}`
  """
  def list(filters \\ []) do
    MCPCustomScope
    |> apply_filters(filters)
    |> order_by([s], asc: s.name)
    |> Repo.all()
  end

  @doc """
  Scopes eligible for a packaging endpoint set: rows of the given `kinds` that are
  either global (org-less) OR match the supplied `:organization_id` / `:project_id`.
  Keeps global presets visible regardless of the requesting org/project.
  """
  def scopes_for(kinds, opts \\ []) do
    kinds = List.wrap(kinds)
    org = Keyword.get(opts, :organization_id)
    proj = Keyword.get(opts, :project_id)

    query =
      from(s in MCPCustomScope, where: s.kind in ^kinds, order_by: [asc: s.name])

    query =
      cond do
        org && proj ->
          where(
            query,
            [s],
            is_nil(s.organization_id) or s.organization_id == ^org or s.project_id == ^proj
          )

        org ->
          where(query, [s], is_nil(s.organization_id) or s.organization_id == ^org)

        true ->
          where(query, [s], is_nil(s.organization_id))
      end

    Repo.all(query)
  end

  defp apply_filters(query, filters) do
    Enum.reduce(filters, query, fn
      {:kind, kind}, q when is_binary(kind) -> where(q, [s], s.kind == ^kind)
      {:kind, kinds}, q when is_list(kinds) -> where(q, [s], s.kind in ^kinds)
      {:organization_id, nil}, q -> where(q, [s], is_nil(s.organization_id))
      {:organization_id, org}, q -> where(q, [s], s.organization_id == ^org)
      {:project_id, nil}, q -> where(q, [s], is_nil(s.project_id))
      {:project_id, pid}, q -> where(q, [s], s.project_id == ^pid)
      {:user_id, uid}, q when is_binary(uid) -> where(q, [s], s.user_id == ^uid)
      {:is_default, flag}, q when is_boolean(flag) -> where(q, [s], s.is_default == ^flag)
      _, q -> q
    end)
  end

  def get(id) when is_binary(id), do: Repo.get(MCPCustomScope, id)
  def get(_), do: nil

  def get_by_slug(slug) when is_binary(slug) do
    Repo.get_by(MCPCustomScope, slug: normalize_slug(slug))
  end

  @doc """
  Resolve a scope by (organization_id, slug) — the org-addressed URL form
  `/org/:org_slug/custom/:slug/mcp`. Slug matching is normalized case-insensitively,
  as in `get_by_slug/1`. Returns nil when the slug exists but belongs to a
  different org (or no org), so a slug can never be served outside its owner.
  """
  def get_by_org_and_slug(org_id, slug) when is_binary(slug) do
    Repo.get_by(MCPCustomScope, organization_id: org_id, slug: normalize_slug(slug))
  end

  @doc """
  Get-or-create the global `tobor` all-in-one scope. Idempotent. Used as the
  unauthenticated setup fallback; signed-in accounts get `ensure_account_default/1`.
  """
  def get_default_package(_opts \\ []) do
    case get_by_slug(@default_package_slug) do
      nil ->
        groups = Map.new(@default_package_groups, fn id -> {id, group_seed(id)} end)

        attrs = %{
          "slug" => @default_package_slug,
          "name" => "Tobor Locker",
          "description" =>
            "Default MCP package for every account — sessions, organizations, projects, " <>
              "tickets, chat, artifacts, wiki, personas, instructions, memory, review, " <>
              "assets, GitHub, notifications, plus NPL load/spec.",
          "kind" => "all_in_one",
          "config" => %{"groups" => groups}
        }

        case create(attrs) do
          {:ok, scope} -> scope
          {:error, _} -> get_by_slug(@default_package_slug)
        end

      scope ->
        heal_default_package(scope)
    end
  end

  # Repair drift on the stored global template: union-merge any missing
  # @default_package_groups (enabled) and re-enable required core groups whose
  # disable was never confirmation-stamped. Additive only — never removes a
  # group or clobbers audit fields, so concurrent heals converge and an admin's
  # deliberate non-required choices survive. Persists only when something
  # actually changed; on update failure the healed config is still returned so
  # the caller sees the intended tool set.
  defp heal_default_package(%MCPCustomScope{} = scope) do
    groups = normalize_groups(scope.config || %{})
    required = MCPServers.required_ids()

    healed =
      Enum.reduce(@default_package_groups, groups, fn id, acc ->
        case Map.get(acc, id) do
          nil ->
            Map.put(acc, id, group_seed(id))

          %{"disabled" => true} = gc ->
            if id in required and not already_confirmed_disabled?(gc) do
              Map.put(acc, id, clear_disable(gc))
            else
              acc
            end

          _enabled_or_absent_flag ->
            acc
        end
      end)
      |> ensure_manifest_tool()

    if healed == groups do
      scope
    else
      config = Map.put(scope.config || %{}, "groups", healed)

      case update(scope, %{"config" => config}) do
        {:ok, updated} -> updated
        _ -> %{scope | config: config}
      end
    end
  end

  @doc "The per-account default custom endpoint for `user_id`, or nil."
  def get_account_default(user_id) when is_binary(user_id) do
    Repo.one(
      from(s in MCPCustomScope,
        where: s.user_id == ^user_id and s.is_default == true,
        limit: 1
      )
    )
  end

  def get_account_default(_), do: nil

  @doc """
  Get-or-create this user's standard custom endpoint, cloned from the global
  `tobor` (Tobor Locker) template. Slug is a short uuid handle
  (`/custom/<handle>/mcp`). Idempotent per user.
  """
  def ensure_account_default(user_id) when is_binary(user_id) do
    _ = get_default_package()
    _ = get_core_variant()

    case get_account_default(user_id) do
      %MCPCustomScope{} = scope ->
        maybe_refresh_account_default(scope)

      nil ->
        case insert_account_default(user_id) do
          {:ok, scope} ->
            scope

          {:error, _} ->
            get_account_default(user_id) || get_default_package()
        end
    end
  end

  def ensure_account_default(_), do: get_default_package()

  defp maybe_refresh_account_default(%MCPCustomScope{} = scope) do
    attrs =
      %{}
      |> maybe_put_name_refresh(scope)
      |> maybe_put_template_refresh(scope)
      |> maybe_put_groups_refresh(scope)

    if attrs == %{} do
      scope
    else
      case update(scope, attrs) do
        {:ok, updated} -> updated
        _ -> scope
      end
    end
  end

  defp maybe_put_name_refresh(attrs, %{name: name})
       when name in [@legacy_account_default_name, "default-mcp"] do
    Map.put(attrs, "name", @account_default_name)
  end

  defp maybe_put_name_refresh(attrs, _), do: attrs

  defp maybe_put_template_refresh(attrs, %{source_template_slug: slug})
       when is_binary(slug) and slug != "" do
    attrs
  end

  defp maybe_put_template_refresh(attrs, _) do
    Map.put(attrs, "source_template_slug", @default_package_slug)
  end

  # Lazily repair defaults cloned from the tobor template: add any
  # default-package groups missing from their config (template drift at clone
  # time, e.g. a `sessions` group that never made it in), and additively seed
  # the `Session_Manifest` tool into the sessions group when absent. Additive
  # only — a group (or tool) the owner deliberately disabled stays disabled,
  # and hand-built scopes (empty source_template_slug) are left alone. Other
  # top-level config keys (e.g. `segment`) are preserved.
  defp maybe_put_groups_refresh(attrs, %{
         source_template_slug: @default_package_slug,
         config: config
       }) do
    groups = normalize_groups(config || %{})

    missing =
      Enum.reject(@default_package_groups, fn id -> Map.has_key?(groups, id) end)

    merged =
      groups
      |> Map.merge(Map.new(missing, fn id -> {id, group_seed(id)} end))
      |> ensure_manifest_tool()

    if merged == groups do
      attrs
    else
      Map.put(attrs, "config", Map.put(config || %{}, "groups", merged))
    end
  end

  defp maybe_put_groups_refresh(attrs, _), do: attrs

  defp insert_account_default(user_id, attempt \\ 0)

  defp insert_account_default(_user_id, attempt) when attempt > 4 do
    {:error, :handle_collision}
  end

  defp insert_account_default(user_id, attempt) do
    template = get_default_package()

    attrs = %{
      "slug" => short_handle(),
      "name" => @account_default_name,
      "description" =>
        "Your standard Tobor Locker MCP package — cloned from the #{template.name} template.",
      "kind" => "custom",
      "user_id" => user_id,
      "is_default" => true,
      "source_template_slug" => template.slug,
      "config" => %{"groups" => groups_from(template)}
    }

    case create(attrs) do
      {:ok, scope} ->
        {:ok, scope}

      {:error, %Ecto.Changeset{} = cs} ->
        cond do
          slug_taken?(cs) ->
            insert_account_default(user_id, attempt + 1)

          default_taken?(cs) ->
            case get_account_default(user_id) do
              %MCPCustomScope{} = existing -> {:ok, existing}
              _ -> {:error, cs}
            end

          true ->
            {:error, cs}
        end
    end
  end

  @doc "The per-org default custom endpoint, or nil."
  def get_org_default(organization_id) when is_binary(organization_id) do
    Repo.one(
      from(s in MCPCustomScope,
        where:
          s.organization_id == ^organization_id and is_nil(s.user_id) and s.is_default == true,
        limit: 1
      )
    )
  end

  def get_org_default(_), do: nil

  @doc """
  Get-or-create this organization's standard custom endpoint, cloned from the
  global `tobor` template. Idempotent per org.
  """
  def ensure_org_default(organization_id, org_name \\ nil)

  def ensure_org_default(organization_id, org_name) when is_binary(organization_id) do
    _ = get_default_package()
    _ = get_core_variant()

    case get_org_default(organization_id) do
      %MCPCustomScope{} = scope ->
        maybe_refresh_account_default(scope)

      nil ->
        case insert_org_default(organization_id, org_name) do
          {:ok, scope} ->
            scope

          {:error, _} ->
            get_org_default(organization_id) || get_default_package()
        end
    end
  end

  def ensure_org_default(_, _), do: get_default_package()

  defp insert_org_default(organization_id, org_name, attempt \\ 0)

  defp insert_org_default(_organization_id, _org_name, attempt) when attempt > 4 do
    {:error, :handle_collision}
  end

  defp insert_org_default(organization_id, org_name, attempt) do
    template = get_default_package()
    label = if is_binary(org_name) and org_name != "", do: org_name, else: "this organization"

    attrs = %{
      "slug" => short_handle(),
      "name" => @account_default_name,
      "description" =>
        "Standard Tobor Locker MCP package for #{label} — cloned from the #{template.name} template.",
      "kind" => "custom",
      "organization_id" => organization_id,
      "is_default" => true,
      "source_template_slug" => template.slug,
      "config" => %{"groups" => groups_from(template)}
    }

    case create(attrs) do
      {:ok, scope} ->
        {:ok, scope}

      {:error, %Ecto.Changeset{} = cs} ->
        cond do
          slug_taken?(cs) ->
            insert_org_default(organization_id, org_name, attempt + 1)

          default_taken?(cs) ->
            case get_org_default(organization_id) do
              %MCPCustomScope{} = existing -> {:ok, existing}
              _ -> {:error, cs}
            end

          true ->
            {:error, cs}
        end
    end
  end

  @doc "Global (user-less, org-less) presets, including seeded `tobor` and `core`."
  def list_templates do
    _ = get_default_package()
    _ = get_core_variant()

    from(s in MCPCustomScope,
      where: is_nil(s.user_id) and is_nil(s.organization_id),
      order_by: [asc: s.name]
    )
    |> Repo.all()
  end

  @doc "Every custom endpoint owned by `user_id` (default first)."
  def list_for_user(user_id) when is_binary(user_id) do
    from(s in MCPCustomScope,
      where: s.user_id == ^user_id,
      order_by: [desc: s.is_default, asc: s.name]
    )
    |> Repo.all()
  end

  def list_for_user(_), do: []

  @doc "Org-owned endpoints (no user_id) for the given organization ids."
  def list_for_organizations(org_ids) when is_list(org_ids) do
    org_ids = Enum.filter(org_ids, &is_binary/1)

    if org_ids == [] do
      []
    else
      from(s in MCPCustomScope,
        where: s.organization_id in ^org_ids and is_nil(s.user_id),
        order_by: [desc: s.is_default, asc: s.name]
      )
      |> Repo.all()
    end
  end

  def list_for_organizations(_), do: []

  @doc """
  Duplicate `source` into a new endpoint. `attrs` may set `name`, `slug`,
  `description`, `kind`, `user_id`, `organization_id`, `is_default`.
  """
  def copy(source, attrs \\ %{})

  def copy(%MCPCustomScope{} = source, attrs) do
    attrs = stringify_keys(attrs || %{})
    is_default = truthy?(Map.get(attrs, "is_default"))

    create(%{
      "slug" => Map.get(attrs, "slug") || short_handle(),
      "name" => Map.get(attrs, "name") || "#{source.name} copy",
      "description" => Map.get(attrs, "description") || source.description,
      "kind" => Map.get(attrs, "kind") || "custom",
      "user_id" => Map.get(attrs, "user_id"),
      "organization_id" => Map.get(attrs, "organization_id"),
      "project_id" => Map.get(attrs, "project_id"),
      "is_default" => is_default,
      "source_template_slug" =>
        Map.get(attrs, "source_template_slug") || source.source_template_slug || source.slug,
      "config" => %{"groups" => groups_from(source)}
    })
  end

  def copy(slug, attrs) when is_binary(slug) do
    case get_by_slug(slug) do
      nil -> {:error, :not_found}
      scope -> copy(scope, attrs)
    end
  end

  @doc """
  Mark `scope` as this user's account default. Other personal defaults are
  cleared. `scope` must be owned by `user_id`.
  """
  def set_account_default(user_id, %MCPCustomScope{} = scope) when is_binary(user_id) do
    cond do
      scope.user_id != user_id ->
        {:error, :forbidden}

      scope.is_default == true ->
        {:ok, scope}

      true ->
        Repo.transaction(fn ->
          now = DateTime.utc_now() |> DateTime.truncate(:second)

          from(s in MCPCustomScope,
            where: s.user_id == ^user_id and s.is_default == true
          )
          |> Repo.update_all(set: [is_default: false, updated_at: now])

          case scope
               |> MCPCustomScope.changeset(%{"is_default" => true})
               |> Repo.update() do
            {:ok, updated} -> updated
            {:error, cs} -> Repo.rollback(cs)
          end
        end)
    end
  end

  def set_account_default(_, _), do: {:error, :not_found}

  defp groups_from(%{config: config}) do
    groups = (config || %{}) |> Map.get("groups") || Map.get(config || %{}, :groups)

    if is_map(groups) and map_size(groups) > 0 do
      groups
    else
      Map.new(@default_package_groups, fn id -> {id, group_seed(id)} end)
    end
  end

  defp groups_from(_), do: Map.new(@default_package_groups, fn id -> {id, group_seed(id)} end)

  # Additive-only: the sessions group always carries the (unrestricted)
  # manifest tool entry. An explicit owner override for `Session_Manifest`
  # (disabled/hidden) is already present in the tools map and never clobbered.
  defp ensure_manifest_tool(groups) when is_map(groups) do
    case Map.get(groups, "sessions") do
      %{"tools" => tools} = gc when is_map(tools) ->
        if Map.has_key?(tools, @manifest_tool) do
          groups
        else
          Map.put(groups, "sessions", Map.put(gc, "tools", Map.put(tools, @manifest_tool, %{})))
        end

      gc when is_map(gc) ->
        Map.put(groups, "sessions", Map.put(gc, "tools", %{@manifest_tool => %{}}))

      _ ->
        groups
    end
  end

  defp ensure_manifest_tool(groups), do: groups

  defp truthy?(true), do: true
  defp truthy?("true"), do: true
  defp truthy?(_), do: false

  defp short_handle do
    Ecto.UUID.generate()
    |> String.replace("-", "")
    |> String.slice(0, 12)
  end

  defp slug_taken?(%Ecto.Changeset{errors: errors}) do
    Keyword.has_key?(errors, :slug)
  end

  defp default_taken?(%Ecto.Changeset{errors: errors}) do
    Keyword.has_key?(errors, :user_id) or Keyword.has_key?(errors, :organization_id)
  end

  @doc """
  Get-or-create the default `"core"` core-variant scope (global/org-less). Idempotent.
  Included in `core+custom` packaging output.
  """
  def get_core_variant(_opts \\ []) do
    case get_by_slug(@core_variant_slug) do
      nil ->
        groups = Map.new(@core_variant_groups, fn id -> {id, group_seed(id)} end)

        attrs = %{
          "slug" => @core_variant_slug,
          "name" => "Core",
          "description" => "Core MCP package — sessions, projects, organizations.",
          "kind" => "core_variant",
          "config" => %{"groups" => groups}
        }

        case create(attrs) do
          {:ok, scope} -> scope
          # Lost a create race, or another validation issue — fall back to a read.
          {:error, _} -> get_by_slug(@core_variant_slug)
        end

      scope ->
        scope
    end
  end

  def create(attrs) do
    %MCPCustomScope{}
    |> MCPCustomScope.changeset(normalize_attrs(attrs))
    |> Repo.insert()
    |> bump_cache_on_ok()
  end

  @doc """
  Update a scope.

  For `all_in_one` scopes, disabling a **required core** group is rejected with
  `{:error, :confirmation_required, [group_id, ...]}` unless `attrs["confirm"]`
  equals `confirm_phrase/0`. On confirmed disable, the group's config records
  `disabled_confirmed_at` (UTC ISO8601) and, when an actor is threaded via
  `opts[:actor_id]`, `disabled_confirmed_by`; otherwise `confirmed: true`.

  `opts`:
    * `:actor_id` — id of the acting user, recorded on confirmed disables.
  """
  def update(scope_or_slug, attrs, opts \\ [])

  def update(%MCPCustomScope{} = scope, attrs, opts) do
    kind = effective_kind(scope, attrs)
    confirm = confirm_value(attrs)
    actor_id = Keyword.get(opts, :actor_id)
    incoming_config = fetch_config(attrs)

    # A visibility-only edit must not clobber the stored group config: seed the
    # normalization input from the stored config when the caller didn't send one.
    attrs = seed_config_for_reserved_attrs(scope, attrs)

    case check_required_core(scope, incoming_config, kind, confirm) do
      :ok ->
        scope
        |> MCPCustomScope.changeset(
          normalize_attrs(attrs,
            kind: kind,
            confirm: confirm,
            actor_id: actor_id,
            prior: scope.config
          )
        )
        |> Repo.update()
        |> bump_cache_on_ok()

      {:error, :confirmation_required, groups} ->
        {:error, :confirmation_required, groups}
    end
  end

  def update(slug, attrs, opts) when is_binary(slug) do
    case get_by_slug(slug) do
      nil -> {:error, :not_found}
      scope -> update(scope, attrs, opts)
    end
  end

  # Reserved top-level attrs (`visibility`, `preset`) can arrive without a
  # `config`; seed the stored config so normalization merges into it instead of
  # starting from an empty map (which would drop existing groups).
  defp seed_config_for_reserved_attrs(%MCPCustomScope{} = scope, attrs)
       when is_map(attrs) do
    reserved_sent? =
      (Map.has_key?(attrs, "visibility") or Map.has_key?(attrs, :visibility) or
         Map.has_key?(attrs, "preset") or Map.has_key?(attrs, :preset)) and
        not (Map.has_key?(attrs, "config") or Map.has_key?(attrs, :config))

    if reserved_sent? do
      Map.put(attrs, "config", scope.config || %{})
    else
      attrs
    end
  end

  defp seed_config_for_reserved_attrs(_, attrs), do: attrs

  def delete(%MCPCustomScope{} = scope) do
    cond do
      scope.slug == @default_package_slug ->
        {:error, :protected}

      scope.slug == @core_variant_slug ->
        {:error, :protected}

      scope.is_default == true and not is_nil(scope.user_id) ->
        {:error, :protected}

      scope.is_default == true and not is_nil(scope.organization_id) and is_nil(scope.user_id) ->
        {:error, :protected}

      true ->
        Repo.delete(scope)
        |> bump_cache_on_ok()
    end
  end

  # Scope rows feed the EffectiveToolset cascade (template / scope configs) via
  # the ToolsetCache — drop the cache whenever a scope write lands. The cache
  # bump + tools/list_changed broadcast are ONE best-effort step: connected
  # clients re-list before serving a stale include set (N1 manifest parity).
  defp bump_cache_on_ok({:ok, _} = ok) do
    NoizuPromptLingua.MCP.Server.notify_toolset_changed()
    ok
  end

  defp bump_cache_on_ok(other), do: other

  def delete(slug) when is_binary(slug) do
    case get_by_slug(slug) do
      nil -> {:error, :not_found}
      scope -> delete(scope)
    end
  end

  @doc """
  Normalize a scope config. For `kind == "all_in_one"` the required core groups
  are enforced (auto-included + enabled); a required group left `disabled` is
  force-enabled unless it carries a confirmation (stamped on write) or `opts`
  supplies the confirm phrase.

  `opts`: `:confirm` (phrase), `:actor_id`.
    * `:preserve_anchors` — READ-path mode (see `MCP.Window`): temporal-window
      anchors (`set_at` / legacy `enabled_at`) are carried verbatim instead of
      re-stamped, and no anchor is minted that the stored entry lacked. Without
      it (write semantics) every normalization stamps a fresh `set_at`.
  """
  def normalize_config(config, kind \\ "custom", opts \\ [])

  def normalize_config(config, kind, opts) when is_map(config) do
    groups = normalize_groups(config, opts)

    %{"groups" => enforce_required(groups, kind, opts)}
    |> put_reserved_keys(config, Keyword.get(opts, :prior) || %{})
  end

  def normalize_config(_, kind, opts), do: %{"groups" => enforce_required(%{}, kind, opts)}

  # Preserve reserved top-level config flags across normalization; only emitted
  # when present, so plain configs are unchanged.
  #   * `segment` — task one-off marker (W7 packaging); boolean-filtered.
  #   * `visibility` — scope sharing mode (W2): "org" | "account" | "shared".
  #     Carried verbatim (from the incoming config, falling back to `prior` so a
  #     group-only edit keeps the stored mode); invalid values are carried too so
  #     the schema's config validation rejects them rather than silently dropping.
  defp put_reserved_keys(normalized, config, prior) do
    normalized
    |> maybe_put_reserved("segment", config, prior, &is_boolean/1)
    |> maybe_put_reserved("visibility", config, prior, fn _ -> true end)
  end

  defp maybe_put_reserved(map, key, config, prior, valid?) do
    value =
      case get_key(config, key) do
        nil -> get_key(prior, key)
        value -> value
      end

    if value != nil and valid?.(value), do: Map.put(map, key, value), else: map
  end

  # Non-server groups kept by the normalizer (W7): per-key gating of the Lit
  # component registry uses group id "components" (see
  # NoizuPromptLinguaWeb.ComponentController) even though no MCP server maps
  # to it. W4 adds "prompts"/"resources" — DB-backed MCP prompt/resource
  # capability groups gated by NoizuPromptLingua.MCP.Custom's prompts/* and
  # resources/* handlers (no MCP server module maps to them).
  @non_server_groups ["components", "prompts", "resources"]

  defp normalize_groups(config, opts \\ []) do
    groups = Map.get(config, "groups") || Map.get(config, :groups) || %{}

    Enum.reduce(groups, %{}, fn {group_id, group_cfg}, acc ->
      group_id = to_string(group_id)

      if not is_nil(MCPServers.server_module(group_id)) or group_id in @non_server_groups do
        Map.put(acc, group_id, normalize_group_config(group_cfg || %{}, opts))
      else
        acc
      end
    end)
  end

  # For all_in_one: guarantee every required core group is present + enabled,
  # honoring (and stamping) confirmed disables. `opts[:prior]` (the stored config)
  # lets a previously-confirmed disable survive an edit whose incoming config omits
  # the audit fields.
  defp enforce_required(groups, "all_in_one", opts) do
    confirm = Keyword.get(opts, :confirm)
    actor_id = Keyword.get(opts, :actor_id)
    prior = normalize_groups(Keyword.get(opts, :prior) || %{})

    Enum.reduce(MCPServers.required_ids(), groups, fn id, acc ->
      case Map.get(acc, id) do
        nil ->
          Map.put(acc, id, %{"tools" => %{}})

        %{"disabled" => true} = gc ->
          prior_gc = Map.get(prior, id) || %{}

          cond do
            confirmed_phrase?(confirm) -> Map.put(acc, id, stamp_confirmed_disable(gc, actor_id))
            already_confirmed_disabled?(gc) -> acc
            already_confirmed_disabled?(prior_gc) -> Map.put(acc, id, carry_audit(gc, prior_gc))
            true -> Map.put(acc, id, clear_disable(gc))
          end

        _enabled_or_absent_flag ->
          acc
      end
    end)
  end

  defp enforce_required(groups, _kind, _opts), do: groups

  defp stamp_confirmed_disable(gc, actor_id) do
    gc =
      Map.put(gc, "disabled_confirmed_at", DateTime.utc_now() |> DateTime.to_iso8601())

    if actor_id do
      gc |> Map.put("disabled_confirmed_by", to_string(actor_id)) |> Map.delete("confirmed")
    else
      Map.put(gc, "confirmed", true)
    end
  end

  defp clear_disable(gc) do
    gc
    |> Map.delete("disabled")
    |> Map.delete("disabled_confirmed_at")
    |> Map.delete("disabled_confirmed_by")
    |> Map.delete("confirmed")
  end

  # Guard: reject disabling a required core group on an all_in_one scope unless the
  # confirm phrase is supplied (or the group was already confirmed-disabled).
  defp check_required_core(_scope, _config, kind, _confirm) when kind != "all_in_one", do: :ok

  defp check_required_core(scope, config, "all_in_one", confirm) do
    if confirmed_phrase?(confirm) do
      :ok
    else
      incoming = normalize_groups(config || %{})
      stored = normalize_groups(scope.config || %{})

      offending =
        MCPServers.required_ids()
        |> Enum.filter(fn id ->
          Map.get(incoming[id] || %{}, "disabled") == true and
            not already_confirmed_disabled?(stored[id] || %{})
        end)

      if offending == [], do: :ok, else: {:error, :confirmation_required, offending}
    end
  end

  defp already_confirmed_disabled?(gc) do
    Map.get(gc, "disabled") == true and
      (not is_nil(Map.get(gc, "disabled_confirmed_at")) or
         not is_nil(Map.get(gc, "disabled_confirmed_by")) or
         Map.get(gc, "confirmed") == true)
  end

  defp confirmed_phrase?(confirm), do: is_binary(confirm) and confirm == @confirm_phrase

  defp effective_kind(scope, attrs) do
    attrs_kind(attrs) || scope.kind || "custom"
  end

  defp attrs_kind(attrs) do
    case Map.get(attrs, "kind") || Map.get(attrs, :kind) do
      k when is_binary(k) -> k
      _ -> nil
    end
  end

  defp confirm_value(attrs), do: Map.get(attrs, "confirm") || Map.get(attrs, :confirm)

  # String/atom dual-key read for the fixed reserved attr names ("preset",
  # "visibility") — fixed internal keys only, never user input.
  defp attrs_key(attrs, key), do: Map.get(attrs, key) || Map.get(attrs, String.to_atom(key))

  defp fetch_config(attrs) do
    Map.get(attrs, "config") || Map.get(attrs, :config)
  end

  def catalog do
    MCPServers.customizable()
    |> Enum.map(fn server ->
      module = MCPServers.server_module(server.id)

      %{
        id: server.id,
        label: server.label,
        desc: server.desc,
        required: server.required,
        tools: Catalog.build(module) |> Enum.reject(&(&1.category == "Discovery"))
      }
    end)
  end

  def scope_json(%MCPCustomScope{} = scope, host \\ nil) do
    %{
      id: scope.id,
      slug: scope.slug,
      name: scope.name,
      kind: scope.kind,
      organization_id: scope.organization_id,
      project_id: scope.project_id,
      user_id: scope.user_id,
      is_default: scope.is_default == true,
      source_template_slug: scope.source_template_slug,
      visibility: MCPCustomScope.visibility(scope),
      description: scope.description,
      config: normalize_config(scope.config || %{}, scope.kind),
      url: host && MCPServers.custom_url(scope.slug, host),
      inserted_at: scope.inserted_at,
      updated_at: scope.updated_at
    }
  end

  defp normalize_attrs(attrs, opts \\ [])

  defp normalize_attrs(attrs, opts) when is_map(attrs) do
    kind = Keyword.get(opts, :kind) || attrs_kind(attrs) || "custom"
    visibility = attrs_key(attrs, "visibility")

    attrs =
      attrs
      |> apply_preset()
      |> Map.take([
        "slug",
        "name",
        "description",
        "kind",
        "organization_id",
        "project_id",
        "user_id",
        "is_default",
        "source_template_slug",
        "config",
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
      |> stringify_keys()
      |> Map.put("kind", kind)

    # W2: top-level `visibility` attr overrides the config jsonb value. Applied
    # after group normalization, verbatim — invalid values reach the schema's
    # config validation and reject the changeset.
    case Map.fetch(attrs, "config") do
      {:ok, config} ->
        normalized =
          config
          |> normalize_config(kind,
            confirm: Keyword.get(opts, :confirm),
            actor_id: Keyword.get(opts, :actor_id),
            prior: Keyword.get(opts, :prior)
          )
          |> maybe_put_visibility(visibility)

        Map.put(attrs, "config", normalized)

      :error ->
        if visibility do
          Map.put(attrs, "config", normalize_config(%{"visibility" => visibility}, kind))
        else
          attrs
        end
    end
  end

  defp normalize_attrs(_, _), do: %{}

  defp maybe_put_visibility(config, nil), do: config
  defp maybe_put_visibility(config, visibility), do: Map.put(config, "visibility", visibility)

  # W2: named preset ("basic_crud", ...) provides the base config at scope
  # creation. Caller-supplied `config.groups` win per group id; preset groups
  # fill the rest. Unknown preset slugs are ignored (forward-compatible).
  defp apply_preset(attrs) when is_map(attrs) do
    case attrs_key(attrs, "preset") do
      nil ->
        attrs

      preset_slug ->
        case preset_config(preset_slug) do
          nil ->
            attrs

          seed ->
            attrs
            |> Map.delete("preset")
            |> Map.delete(:preset)
            |> Map.update("config", seed, fn config ->
              config = stringify_keys(config)
              user_groups = Map.get(config, "groups") || %{}
              Map.put(config, "groups", Map.merge(Map.get(seed, "groups"), user_groups))
            end)
        end
    end
  end

  defp apply_preset(_), do: %{}

  defp stringify_keys(map) do
    Map.new(map, fn {key, value} -> {to_string(key), value} end)
  end

  defp normalize_group_config(config, opts) when is_map(config) do
    tools = Map.get(config, "tools") || Map.get(config, :tools) || %{}
    entries = Map.get(config, "entries") || Map.get(config, :entries) || %{}

    base =
      %{}
      |> put_bool("disabled", Map.get(config, "disabled", Map.get(config, :disabled)))
      |> put_bool("hidden", Map.get(config, "hidden", Map.get(config, :hidden)))
      |> carry_audit(config)

    base = Map.put(base, "tools", normalize_tools_config(tools, opts))

    # W4: per-entry gating for the DB-backed prompts/resources groups
    # (keyed by prompt slug / resource URI). Same flags as tools; omitted
    # when empty so normalize output for existing configs is unchanged.
    case normalize_tools_config(entries, opts) do
      empty when empty == %{} -> base
      entries -> Map.put(base, "entries", entries)
    end
  end

  defp normalize_group_config(_, _), do: %{"tools" => %{}}

  # Preserve confirmed-disable audit fields across re-normalization so a stored
  # confirmation survives later edits. Only added when present (no effect on plain
  # configs, so existing normalize output is unchanged).
  defp carry_audit(map, config) do
    map
    |> maybe_put("disabled_confirmed_at", get_key(config, "disabled_confirmed_at"))
    |> maybe_put("disabled_confirmed_by", get_key(config, "disabled_confirmed_by"))
    |> maybe_put_bool("confirmed", get_key(config, "confirmed"))
  end

  defp get_key(config, key), do: Map.get(config, key, Map.get(config, String.to_atom(key)))

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  defp maybe_put_bool(map, key, value) when is_boolean(value), do: Map.put(map, key, value)
  defp maybe_put_bool(map, _key, _value), do: map

  defp normalize_tools_config(tools, opts) when is_map(tools) do
    Map.new(tools, fn {tool_name, cfg} ->
      {to_string(tool_name), normalize_tool_config(cfg || %{}, opts)}
    end)
  end

  defp normalize_tools_config(_, _), do: %{}

  defp normalize_tool_config(config, opts) when is_map(config) do
    # W9/F3/F2 fields ride the same tool entry as disabled/hidden — carried
    # through verbatim when present so persistence never strips them.
    %{}
    |> put_bool("disabled", Map.get(config, "disabled", Map.get(config, :disabled)))
    |> put_bool("hidden", Map.get(config, "hidden", Map.get(config, :hidden)))
    |> carry_entry_keys(config)
    # F3 temporal windows (hide_until / enable_for_hours); invalid values are
    # dropped here — strict rejection lives on the scope changeset. Window
    # owns these keys (see @entry_extra_keys) so carry never duplicates them.
    # :preserve_anchors (read path) rides through to Window.normalize_entry.
    |> Window.normalize_entry(config, Keyword.take(opts, [:preserve_anchors]))
  end

  defp normalize_tool_config(_, _), do: %{}

  @entry_extra_keys [
    "name_override",
    "description_override",
    "arg_overrides"
    # window keys (hide_until / enable_for_hours / set_at) are owned and
    # normalized by MCP.Window.normalize_entry — not carried verbatim.
  ]

  defp carry_entry_keys(map, config) do
    Enum.reduce(@entry_extra_keys, map, fn key, acc ->
      case get_key(config, key) do
        nil -> acc
        value -> maybe_carry_entry(acc, key, value)
      end
    end)
  end

  # F2 §2.7: name/description overrides are string-only, empty string = absent,
  # capped (name ≤ 128, description ≤ 1024) — the shared policy lives in
  # NoizuPromptLingua.MCP.ToolsetConfig (single source of truth; the read-path
  # overlay in EffectiveToolset applies the same rule). Other extra keys
  # carried verbatim.
  defp maybe_carry_entry(acc, key, value)

  defp maybe_carry_entry(acc, key, value) when key in ["name_override", "description_override"],
    do: ToolsetConfig.carry_override(acc, key, value)

  defp maybe_carry_entry(acc, key, value), do: Map.put(acc, key, value)

  defp put_bool(map, _key, nil), do: map
  defp put_bool(map, key, value) when is_boolean(value), do: Map.put(map, key, value)
  defp put_bool(map, _key, _value), do: map

  defp normalize_slug(slug) do
    slug
    |> String.trim()
    |> String.downcase()
  end
end
