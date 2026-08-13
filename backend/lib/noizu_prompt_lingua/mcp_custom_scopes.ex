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

  # Global all-in-one package every account gets. NPL load/spec tools are
  # attached by MCP.Custom for all_in_one scopes (not a selectable group).
  @default_package_slug "tobor"
  @default_package_groups ~w(
    sessions organizations projects tickets chat artifacts wiki
    personas instructions memory review assets github notifications
  )

  @doc "The typed-confirmation phrase for disabling required core groups."
  def confirm_phrase, do: @confirm_phrase

  @doc "Slug of the global default package every account is offered."
  def default_package_slug, do: @default_package_slug

  @doc "Group ids seeded into the default `tobor` all-in-one package."
  def default_package_groups, do: @default_package_groups

  @doc """
  List scopes. Optional `filters`:

    * `{:kind, kind | [kind]}` — restrict by kind
    * `{:organization_id, uuid | nil}` — exact match (`nil` = global/org-less)
    * `{:project_id, uuid | nil}` — exact match (`nil` = project-less)
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
      _, q -> q
    end)
  end

  def get_by_slug(slug) when is_binary(slug) do
    Repo.get_by(MCPCustomScope, slug: normalize_slug(slug))
  end

  @doc """
  Get-or-create the global `tobor` all-in-one scope. Idempotent. This is the
  single MCP endpoint the setup UI offers by default.
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
        scope
    end
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

  def delete(%MCPCustomScope{slug: slug} = scope) do
    if slug == @default_package_slug do
      {:error, :protected}
    else
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

  defp normalize_groups(config) do
    groups = Map.get(config, "groups") || Map.get(config, :groups) || %{}

    Enum.reduce(groups, %{}, fn {group_id, group_cfg}, acc ->
      group_id = to_string(group_id)

      if MCPServers.server_module(group_id) do
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
        "config",
        :slug,
        :name,
        :description,
        :kind,
        :organization_id,
        :project_id,
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
