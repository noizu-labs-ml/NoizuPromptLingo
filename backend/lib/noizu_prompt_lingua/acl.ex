defmodule NoizuPromptLingua.Acl do
  @moduledoc """
  ACL/group library (Liquibase 081) — reusable permission primitives built on
  Noizu ERP references (`{:ref, Type, id}` records, JSONB persisted via
  `NoizuPromptLingua.Acl.ERPRef`), so grants attach to ANY arbitrary entity
  (users, personas, api keys, orgs, projects, wikis…) without schema changes.

  Layout:

    * `acl_groups` — named groups, optionally bound to an entity via `ref`.
    * `acl_group_members` — entity refs in groups (incl. nested groups).
    * `acl_rules` — subject_ref grant/deny `action` on resource_ref, optional
      `scope` tag + `priority`.

  Resolution: `resolve/4` expands the subject's groups transitively
  (cycle-guarded), fetches applicable rules, and delegates the decision to the
  pure `NoizuPromptLingua.Acl.Resolver` (deny-wins, no-match default deny).

      Acl.allowed?({:ref, User, uid}, "wiki.read", {:ref, Wiki, wid})
  """

  # Scoped import: a bare `import Ecto.Query` would pull in `Ecto.Query.update/3`,
  # whose macro expansion shadows this module's `update/3` (see MCPCustomScopes).
  import Ecto.Query, only: [from: 2, dynamic: 1, dynamic: 2]

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Acl.Group
  alias NoizuPromptLingua.Schema.Acl.GroupMember
  alias NoizuPromptLingua.Schema.Acl.Rule
  alias NoizuPromptLingua.Acl.ERPRef
  alias NoizuPromptLingua.Acl.Resolver

  require Noizu.EntityReference.Records
  alias Noizu.EntityReference.Records, as: R

  @action_wildcard Rule.action_wildcard()
  @max_group_depth 16

  @doc "Group-expansion depth cap — exposed so callers/tests can derive limits."
  def max_group_depth, do: @max_group_depth

  # ──────────────────────────────────────────────────────────────────
  # Resolution
  # ──────────────────────────────────────────────────────────────────

  @doc """
  Effective permission verdict for `subject_ref` performing `action` on
  `resource_ref`.

  Options: `scope` (nil = global rules only apply… see Resolver), `at`
  (DateTime for membership expiry, default now), `default` (`:deny`/`:allow`,
  default `:deny`).

  Returns `{:allow, rule | :default}` / `{:deny, rule | :default}`.
  """
  # Resource is normalized once here (the public boundary); the helpers below
  # expect canonical refs and never re-normalize.
  def resolve(subject_ref, action, resource_ref, opts \\ []) do
    subjects = subject_candidates(subject_ref, opts)
    resource = normalize(resource_ref)
    rules = applicable_rules(subjects, action, resource, Keyword.get(opts, :scope))
    Resolver.evaluate(rules, subjects, action, resource, opts)
  end

  @doc "Boolean convenience over `resolve/4`."
  def allowed?(subject_ref, action, resource_ref, opts \\ []) do
    case resolve(subject_ref, action, resource_ref, opts) do
      {:allow, _} -> true
      {:deny, _} -> false
    end
  end

  @doc "Detailed verdict — see `NoizuPromptLingua.Acl.Resolver.explain/5`."
  def explain(subject_ref, action, resource_ref, opts \\ []) do
    subjects = subject_candidates(subject_ref, opts)
    resource = normalize(resource_ref)
    rules = applicable_rules(subjects, action, resource, Keyword.get(opts, :scope))
    Resolver.explain(rules, subjects, action, resource, opts)
  end
  @doc """
  Normalize any accepted reference form into a canonical `{:ref, Type, id}`
  record (or `nil` when unparseable). Thin wrapper over `ERPRef.cast/1`, which
  is the system-wide normalization boundary (resolver + changesets share it):

    * `{:ref, Type, id}` records / bare tuples (incl. `:any` wildcards)
    * entity structs / wrapped refs (via the ERP protocol)
    * JSONB maps `%{"type" => "Some.Entity", "id" => "…"}` (atom keys too)
    * sref strings — `"ref.<Type>.<id>"` or `"<Type>.<id>"`, where the type is
      the longest dot-joined prefix naming a loaded module (or the `"any"`
      wildcard) and the id is the remaining dot-joined segments (ids may
      contain dots)

  All Acl entry points accept refs in any supported shape without hitting
  Ecto dump errors on raw strings/maps.
  """
  def normalize(nil), do: nil

  def normalize(value) do
    case ERPRef.cast(value) do
      {:ok, R.ref() = canonical} -> canonical
      _ -> nil
    end
  end

  @doc """
  The subject itself plus every group ref it reaches through
  `acl_group_members` — nested groups expanded transitively (BFS, cycle
  guard, capped). Non-expired memberships of active groups only. When the
  expansion exceeds the cap, the oldest frontier discoveries are dropped and
  expansion continues with the newest ones (the frontier is trimmed, not
  discarded wholesale).
  """
  def subject_candidates(subject_ref, opts \\ []) do
    at = Keyword.get(opts, :at, DateTime.utc_now())

    case normalize(subject_ref) do
      nil -> []
      subject -> do_expand([subject], MapSet.new([subject]), at, [subject])
    end
  end

  defp do_expand([], _visited, _at, acc), do: acc

  # `direct_group_refs/2` returns canonical `g.ref` records (loaded through
  # ERPRef), so no re-normalization is needed here.
  defp do_expand(frontier, visited, at, acc) do
    next =
      frontier
      |> Enum.flat_map(&direct_group_refs(&1, at))
      |> Enum.uniq()
      |> Enum.reject(&MapSet.member?(visited, &1))

    # Runaway-graph guard — cap mid-frontier: keep the newest discoveries up
    # to the remaining budget, drop the oldest overflow, keep expanding.
    budget = max(@max_group_depth - MapSet.size(visited), 0)
    next = if length(next) > budget, do: Enum.slice(next, length(next) - budget, budget), else: next

    visited = MapSet.union(visited, MapSet.new(next))

    do_expand(next, visited, at, acc ++ next)
  end

  defp direct_group_refs(candidate_ref, at) do
    from(g in Group,
      join: m in GroupMember,
      on: m.group_id == g.id,
      where: g.status == "active",
      where: m.member_ref == ^candidate_ref,
      where: is_nil(m.expires_at) or m.expires_at > ^at,
      select: g.ref
    )
    |> Repo.all()
    |> Enum.reject(&is_nil/1)
  end

  # `resource_ref` arrives canonical (normalized at the resolve/explain
  # boundary) — no re-normalization here.
  defp applicable_rules(subjects, action, resource_ref, scope) do
    subject_dyn = subject_dyn(subjects)
    resource_dyn = resource_dyn(resource_ref)

    scope_dyn =
      if scope do
        dynamic([r], is_nil(r.scope) or r.scope == ^scope)
      else
        dynamic([r], is_nil(r.scope))
      end

    from(r in Rule,
      where: r.status == "active",
      where: r.action in ^[action, @action_wildcard],
      where: ^subject_dyn,
      where: ^resource_dyn,
      where: ^scope_dyn
    )
    |> Repo.all()
  end

  # A nil-resource request is resource-agnostic: it matches rules stored with
  # a NULL resource_ref plus global `{"any","any"}` wildcards. (SQL `== NULL`
  # is never true, so the NULL case must be its own is_nil branch.)
  defp resource_dyn(nil) do
    dynamic(
      [r],
      is_nil(r.resource_ref) or
        fragment("?->>'type' = 'any' and ?->>'id' = 'any'", r.resource_ref, r.resource_ref)
    )
  end

  defp resource_dyn(resource) do
    dynamic(
      [r],
      r.resource_ref == ^resource or
        fragment("?->>'type' = ? and ?->>'id' = 'any'", r.resource_ref, ^kind_str(resource), r.resource_ref) or
        fragment("?->>'type' = 'any' and ?->>'id' = 'any'", r.resource_ref, r.resource_ref)
    )
  end

  defp subject_dyn([]), do: dynamic(false)

  defp subject_dyn(subjects) do
    Enum.reduce(subjects, dynamic(false), fn subject, acc ->
      dynamic([r], ^acc or r.subject_ref == ^subject)
    end)
  end

  # Canonical refs only — callers normalize before reaching here.
  defp kind_str(R.ref(module: :any)), do: "any"
  defp kind_str(R.ref(module: m, id: _)), do: ERPRef.kind_to_string(m)
  defp kind_str(_), do: "any"

  # ──────────────────────────────────────────────────────────────────
  # Groups
  # ──────────────────────────────────────────────────────────────────

  @doc "Create an ACL group. `:ref` binds it to an arbitrary entity (optional)."
  def create_group(attrs), do: %Group{} |> Group.changeset(attrs) |> Repo.insert()

  def update_group(%Group{} = group, attrs),
    do: group |> Group.changeset(attrs) |> Repo.update()

  def update_group(id, attrs) when is_binary(id) do
    case get_group(id) do
      nil -> {:error, :not_found}
      group -> update_group(group, attrs)
    end
  end

  @doc "Archive (soft-disable) a group — archived groups stop resolving."
  def archive_group(%Group{} = group), do: update_group(group, %{status: "archived"})
  def archive_group(id) when is_binary(id), do: update_group(id, %{status: "archived"})

  def get_group(id) when is_binary(id), do: Repo.get(Group, id)
  def get_group(_), do: nil

  def get_group_by_name(name) when is_binary(name),
    do: Repo.one(from(g in Group, where: g.name == ^name))

  # ──────────────────────────────────────────────────────────────────
  # Membership
  # ──────────────────────────────────────────────────────────────────

  @doc """
  Add a member (any ERP ref — record, sref string, or JSONB map) to a group.
  Opts: `:expires_at` (DateTime — membership stops resolving after it).

  Groups may be identified by struct, uuid, or name.
  """
  def add_member(group, member_ref, opts \\ []) do
    case resolve_group(group) do
      nil ->
        {:error, :not_found}

      group ->
        case normalize(member_ref) do
          nil ->
            {:error, :invalid_member_ref}

          member ->
            attrs =
              %{group_id: group.id, member_ref: member}
              |> maybe_put(:expires_at, Keyword.get(opts, :expires_at))

            %GroupMember{} |> GroupMember.changeset(attrs) |> Repo.insert()
        end
    end
  end

  @doc "Remove a member from a group."
  def remove_member(group, member_ref) do
    case resolve_group(group) do
      nil ->
        {:error, :not_found}

      group ->
        case normalize(member_ref) do
          nil ->
            {:error, :not_found}

          member ->
            {count, _} =
              from(m in GroupMember, where: m.group_id == ^group.id and m.member_ref == ^member)
              |> Repo.delete_all()

            {:ok, count}
        end
    end
  end

  @doc "All membership rows of a group."
  def members(group) do
    case resolve_group(group) do
      nil ->
        []

      group ->
        from(m in GroupMember, where: m.group_id == ^group.id, order_by: m.inserted_at)
        |> Repo.all()
    end
  end

  @doc "Active groups a member (any ERP ref) belongs to directly."
  def groups_for(member_ref, opts \\ []) do
    at = Keyword.get(opts, :at, DateTime.utc_now())

    case normalize(member_ref) do
      nil ->
        []

      member ->
        from(g in Group,
          join: m in GroupMember,
          on: m.group_id == g.id,
          where: g.status == "active",
          where: m.member_ref == ^member,
          where: is_nil(m.expires_at) or m.expires_at > ^at
        )
        |> Repo.all()
    end
  end

  defp resolve_group(%Group{} = group), do: group
  defp resolve_group(id_or_name) when is_binary(id_or_name),
    do: get_group(id_or_name) || get_group_by_name(id_or_name)

  defp resolve_group(_), do: nil

  # ──────────────────────────────────────────────────────────────────
  # Rules
  # ──────────────────────────────────────────────────────────────────

  @doc """
  Create a rule. Required: `subject_ref`, `resource_ref`, `action`, `effect`
  (`allow`/`deny`). Optional: `scope`, `priority`, `metadata`.
  """
  def create_rule(attrs), do: %Rule{} |> Rule.changeset(attrs) |> Repo.insert()

  def update_rule(%Rule{} = rule, attrs),
    do: rule |> Rule.changeset(attrs) |> Repo.update()

  def update_rule(id, attrs) when is_binary(id) do
    case get_rule(id) do
      nil -> {:error, :not_found}
      rule -> update_rule(rule, attrs)
    end
  end

  @doc "Archive (soft-disable) a rule."
  def archive_rule(%Rule{} = rule), do: update_rule(rule, %{status: "archived"})
  def archive_rule(id) when is_binary(id), do: update_rule(id, %{status: "archived"})

  def get_rule(id) when is_binary(id), do: Repo.get(Rule, id)
  def get_rule(_), do: nil

  # ──────────────────────────────────────────────────────────────────

  defp maybe_put(attrs, _key, nil), do: attrs
  defp maybe_put(attrs, key, value), do: Map.put(attrs, key, value)
end
