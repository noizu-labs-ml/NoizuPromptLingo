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

  @doc "The typed-confirmation phrase for disabling required core groups."
  def confirm_phrase, do: @confirm_phrase

  @doc "Slug of the global default package every account is offered."
  def default_package_slug, do: @default_package_slug

  @doc "Display name of the per-account default custom endpoint."
  def account_default_name, do: @account_default_name

  @doc "Group ids seeded into the default `tobor` all-in-one package."
  def default_package_groups, do: @default_package_groups

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
  Get-or-create the global `tobor` all-in-one scope. Idempotent. Used as the
  unauthenticated setup fallback; signed-in accounts get `ensure_account_default/1`.
  """
  def get_default_package(_opts \\ []) do
    case get_by_slug(@default_package_slug) do
      nil ->
        groups = Map.new(@default_package_groups, fn id -> {id, %{"tools" => %{}}} end)

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
            Map.put(acc, id, %{"tools" => %{}})

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
  # time, e.g. a `sessions` group that never made it in). Additive only — a
  # group the owner deliberately disabled stays disabled, and hand-built scopes
  # (empty source_template_slug) are left alone. Other top-level config keys
  # (e.g. `segment`) are preserved.
  defp maybe_put_groups_refresh(attrs, %{
         source_template_slug: @default_package_slug,
         config: config
       }) do
    groups = normalize_groups(config || %{})

    missing =
      Enum.reject(@default_package_groups, fn id -> Map.has_key?(groups, id) end)

    if missing == [] do
      attrs
    else
      merged = Map.merge(groups, Map.new(missing, fn id -> {id, %{"tools" => %{}}} end))
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
      Map.new(@default_package_groups, fn id -> {id, %{"tools" => %{}}} end)
    end
  end

  defp groups_from(_), do: Map.new(@default_package_groups, fn id -> {id, %{"tools" => %{}}} end)

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
        groups = Map.new(@core_variant_groups, fn id -> {id, %{"tools" => %{}}} end)

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

  def delete(%MCPCustomScope{} = scope) do
    cond do
      scope.slug == @default_package_slug -> {:error, :protected}
      scope.slug == @core_variant_slug -> {:error, :protected}
      scope.is_default == true and not is_nil(scope.user_id) -> {:error, :protected}
      scope.is_default == true and not is_nil(scope.organization_id) and is_nil(scope.user_id) ->
        {:error, :protected}

      true ->
        Repo.delete(scope)
    end
  end

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
  """
  def normalize_config(config, kind \\ "custom", opts \\ [])

  def normalize_config(config, kind, opts) when is_map(config) do
    groups = normalize_groups(config)

    %{"groups" => enforce_required(groups, kind, opts)}
    |> put_segment(config)
  end

  def normalize_config(_, kind, opts), do: %{"groups" => enforce_required(%{}, kind, opts)}

  # Preserve the top-level `segment` flag (task one-off marker) across normalization;
  # only emitted when present, so plain configs are unchanged.
  defp put_segment(normalized, config) do
    case get_key(config, "segment") do
      seg when is_boolean(seg) -> Map.put(normalized, "segment", seg)
      _ -> normalized
    end
  end

  # Non-server groups kept by the normalizer (W7): per-key gating of the Lit
  # component registry uses group id "components" (see
  # NoizuPromptLinguaWeb.ComponentController) even though no MCP server maps
  # to it.
  @non_server_groups ["components"]

  defp normalize_groups(config) do
    groups = Map.get(config, "groups") || Map.get(config, :groups) || %{}

    Enum.reduce(groups, %{}, fn {group_id, group_cfg}, acc ->
      group_id = to_string(group_id)

      if not is_nil(MCPServers.server_module(group_id)) or group_id in @non_server_groups do
        Map.put(acc, group_id, normalize_group_config(group_cfg || %{}))
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

    attrs =
      attrs
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

    case Map.fetch(attrs, "config") do
      {:ok, config} ->
        Map.put(
          attrs,
          "config",
          normalize_config(config, kind,
            confirm: Keyword.get(opts, :confirm),
            actor_id: Keyword.get(opts, :actor_id),
            prior: Keyword.get(opts, :prior)
          )
        )

      :error ->
        attrs
    end
  end

  defp normalize_attrs(_, _), do: %{}

  defp stringify_keys(map) do
    Map.new(map, fn {key, value} -> {to_string(key), value} end)
  end

  defp normalize_group_config(config) when is_map(config) do
    tools = Map.get(config, "tools") || Map.get(config, :tools) || %{}

    base =
      %{}
      |> put_bool("disabled", Map.get(config, "disabled", Map.get(config, :disabled)))
      |> put_bool("hidden", Map.get(config, "hidden", Map.get(config, :hidden)))
      |> carry_audit(config)

    Map.put(base, "tools", normalize_tools_config(tools))
  end

  defp normalize_group_config(_), do: %{"tools" => %{}}

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

  defp normalize_tools_config(tools) when is_map(tools) do
    Map.new(tools, fn {tool_name, cfg} ->
      {to_string(tool_name), normalize_tool_config(cfg || %{})}
    end)
  end

  defp normalize_tools_config(_), do: %{}

  defp normalize_tool_config(config) when is_map(config) do
    %{}
    |> put_bool("disabled", Map.get(config, "disabled", Map.get(config, :disabled)))
    |> put_bool("hidden", Map.get(config, "hidden", Map.get(config, :hidden)))
  end

  defp normalize_tool_config(_), do: %{}

  defp put_bool(map, _key, nil), do: map
  defp put_bool(map, key, value) when is_boolean(value), do: Map.put(map, key, value)
  defp put_bool(map, _key, _value), do: map

  defp normalize_slug(slug) do
    slug
    |> String.trim()
    |> String.downcase()
  end
end
