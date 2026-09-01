defmodule NoizuPromptLingua.MCP.ToolSets do
  @moduledoc """
  Context for durable MCP tool sets (`Schema.MCPToolSet`, PRD-N2 §4.1): CRUD +
  deactivate + clone, request-path lookup, and the `to_overrides/1` pure
  translator from the closed-vocabulary `config` jsonb to normalized override
  ops.

  N2a seams (deliberately thin — both FLIP at N2b, one-line wraps):

    * `get_for_request/2` returns `%MCPToolSet{} | nil`; at PRD-3 time it
      returns the assembled lib toolset.
    * `assemble_custom/2` returns a plain effective-view map; at N2b it builds
      `%Noizu.MCP.Toolset.Custom{}` via `to_overrides/1`.
    * `to_overrides/1` elements are `%{op | target | value}` maps; at N2b they
      wrap into `%Noizu.MCP.Toolset.Override{}`.

  Every write fires `MCP.Server.notify_toolset_changed/0` (best-effort, N1
  wiring) so live connections re-list before serving a stale set.
  """

  import Ecto.Query, only: [from: 2]
  require Logger

  alias NoizuPromptLingua.MCP.Server
  alias NoizuPromptLingua.MCP.Toolsets.Profiles
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
  Effective view for serving — THIN in N2a (normalized config + overrides +
  defaulted settings); at N2b this returns `%Noizu.MCP.Toolset.Custom{}` built
  via `to_overrides/1` (FR-2B-4). `ctx` is unused in N2a and kept for the
  signature seam.
  """
  def assemble_custom(%MCPToolSet{} = tool_set, _ctx \\ nil) do
    settings = tool_set.settings || %{}

    %{
      slug: tool_set.slug,
      display_name: tool_set.display_name || tool_set.slug,
      source: tool_set.source,
      source_profile: tool_set.source_profile,
      is_active: tool_set.is_active,
      config: tool_set.config,
      overrides: to_overrides(tool_set.config),
      settings: %{
        "allow_api_keys" => Map.get(settings, "allow_api_keys", true),
        "description_verbosity" => Map.get(settings, "description_verbosity"),
        "instructions" => Map.get(settings, "instructions")
      }
    }
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
