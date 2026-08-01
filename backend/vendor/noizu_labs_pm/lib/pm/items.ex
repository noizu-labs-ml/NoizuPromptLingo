defmodule Noizu.PM.Items do
  @moduledoc """
  The universal work primitive: items (todo/task/bug/epic/etc.). Items are
  org-required, project-optional. Each gets an immutable human key (PREFIX-NNN)
  assigned race-safe on insert, with per-scope gap-free numbering.

  This is the consolidated shared domain lifted from npl's `Domains.Tickets` /
  trp's `Domains.Items` (npl `ticket_*` → `item_*`), centralizing on ONE
  `item_number_counters` table. The key-generation primitives (`next_number/2`,
  `ensure_prefix/2`, `claim_prefix/4`) are public so a host app's own item
  domain can call into the same atomic generator rather than reimplement it.
  """

  import Ecto.Query, except: [update: 2]

  alias Noizu.PM.Repo
  alias Noizu.PM.Schema.Items.{Item, ItemLink}
  alias Noizu.PM.Schema.Projects.Project
  alias Noizu.PM.Schema.Organizations.Organization
  alias Noizu.PM.Items.ItemKey

  @max_prefix_attempts 50

  @doc """
  Create an item, assigning an immutable human key (PREFIX-NNN) race-safe on
  insert. Per-scope gap-free numbering via an atomic counter upsert in the item's
  txn: project items number per (org, project); org-level (project_id NULL) items
  number per org. A rolled-back insert rolls back its counter increment.
  """
  def create(attrs) do
    org_id = fetch(attrs, :organization_id)

    if is_nil(org_id) do
      # No org -> can't key it; let the changeset surface the required-error.
      %Item{} |> Item.changeset(attrs) |> Repo.insert()
    else
      project_id = fetch(attrs, :project_id)

      Repo.transaction(fn ->
        prefix = ensure_prefix(org_id, project_id)
        number = next_number(org_id, project_id)
        key = ItemKey.format_key(prefix, number)

        cs =
          %Item{}
          |> Item.changeset(attrs)
          |> Ecto.Changeset.put_change(:number, number)
          |> Ecto.Changeset.put_change(:key, key)

        case Repo.insert(cs) do
          {:ok, item} -> item
          {:error, changeset} -> Repo.rollback(changeset)
        end
      end)
    end
  end

  def get(id) do
    Item
    |> preload([:queue, :parent])
    |> Repo.get(id)
  end

  @doc "Fetch an item by its human key within an organization."
  def get_by_key(org_id, key) do
    Item |> preload([:queue, :parent]) |> Repo.get_by(organization_id: org_id, key: key)
  end

  @doc """
  Backfill human keys for pre-existing keyless items. Idempotent: only NULL-key
  items, oldest-first so per-scope numbers follow inserted_at; reuses the SAME
  atomic counter + prefix logic as create (one generator). Re-runnable.
  """
  def backfill_keys(batch_size \\ 500) do
    items =
      Item
      |> where([t], is_nil(t.key))
      |> order_by([t], asc: t.inserted_at, asc: t.id)
      |> limit(^batch_size)
      |> Repo.all()

    case items do
      [] ->
        0

      _ ->
        filled =
          Enum.reduce(items, 0, fn t, acc ->
            case assign_key(t) do
              {:ok, _} -> acc + 1
              _ -> acc
            end
          end)

        filled + backfill_keys(batch_size)
    end
  end

  defp assign_key(item) do
    Repo.transaction(fn ->
      prefix = ensure_prefix(item.organization_id, item.project_id)
      number = next_number(item.organization_id, item.project_id)
      key = ItemKey.format_key(prefix, number)

      cs =
        item
        |> Ecto.Changeset.change(%{number: number, key: key})
        |> Ecto.Changeset.unique_constraint(:number, name: :idx_items_proj_number)
        |> Ecto.Changeset.unique_constraint(:number, name: :idx_items_org_number)
        |> Ecto.Changeset.unique_constraint(:key, name: :idx_items_org_key)

      case Repo.update(cs) do
        {:ok, t} -> t
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)
  end

  # ── human-key internals (public: shared with host-app item domains) ───────

  defp fetch(attrs, k), do: attrs[k] || attrs[Atom.to_string(k)]

  @doc """
  Per-scope gap-free counter via atomic upsert. The ON CONFLICT predicate
  selects the matching partial unique index (idx_inc_org for the NULL-project
  org bucket, idx_inc_proj for project buckets), so the org bucket collapses to
  ONE counter per org. Returns the newly-claimed number.
  """
  @spec next_number(binary(), binary() | nil) :: integer()
  def next_number(org_id, nil) do
    %{rows: [[n]]} =
      Repo.query!(
        """
        INSERT INTO item_number_counters (organization_id, project_id, last_number)
        VALUES ($1, NULL, 1)
        ON CONFLICT (organization_id) WHERE project_id IS NULL
        DO UPDATE SET last_number = item_number_counters.last_number + 1, updated_at = now()
        RETURNING last_number
        """,
        [uuid_bin(org_id)]
      )

    n
  end

  def next_number(org_id, project_id) do
    %{rows: [[n]]} =
      Repo.query!(
        """
        INSERT INTO item_number_counters (organization_id, project_id, last_number)
        VALUES ($1, $2, 1)
        ON CONFLICT (organization_id, project_id) WHERE project_id IS NOT NULL
        DO UPDATE SET last_number = item_number_counters.last_number + 1, updated_at = now()
        RETURNING last_number
        """,
        [uuid_bin(org_id), uuid_bin(project_id)]
      )

    n
  end

  # Raw SQL params for uuid columns want the 16-byte binary; ids flow through as
  # string uuids (binary_id). Tolerate an already-dumped binary too.
  defp uuid_bin(<<_::128>> = bin), do: bin
  defp uuid_bin(uuid) when is_binary(uuid), do: Ecto.UUID.dump!(uuid)

  @doc """
  Resolve the scope's key prefix, auto-deriving + claiming it on first use if
  unset. `org_id` scopes the cross-table uniqueness check (org + project
  prefixes within the org).
  """
  @spec ensure_prefix(binary(), binary() | nil) :: binary()
  def ensure_prefix(org_id, nil) do
    org = Repo.get!(Organization, org_id)
    org.key_prefix || claim_prefix(org, Organization, org_id, ItemKey.derive_prefix(org.slug), 0)
  end

  def ensure_prefix(org_id, project_id) do
    project = Repo.get!(Project, project_id)

    project.key_prefix ||
      claim_prefix(project, Project, org_id, ItemKey.derive_prefix(project.slug), 0)
  end

  @doc """
  Claim a unique key prefix for a scope row, collision-suffixing the derived
  base until one is free per-org (across both the org's own prefix and every
  project prefix in the org). Rolls back after `#{@max_prefix_attempts}` tries.
  """
  @spec claim_prefix(Ecto.Schema.t(), module(), binary(), binary(), non_neg_integer()) ::
          binary()
  def claim_prefix(_row, _mod, _org_id, _base, n) when n >= @max_prefix_attempts do
    Repo.rollback(:key_prefix_exhausted)
  end

  def claim_prefix(row, mod, org_id, base, n) do
    candidate = ItemKey.prefix_variant(base, n + 1)

    # A key is unique per ORG across BOTH scopes (the org's own prefix AND every
    # project prefix in the org) — otherwise an org-level and a project key could
    # collide on the (org,key) unique. The per-table uniques don't cross-check,
    # so guard it here; they remain the backstop for the rare simultaneous-first-
    # item race.
    cond do
      prefix_taken?(org_id, candidate) ->
        claim_prefix(row, mod, org_id, base, n + 1)

      true ->
        case row |> mod.changeset(%{key_prefix: candidate}) |> Repo.update() do
          {:ok, updated} ->
            updated.key_prefix

          {:error, %Ecto.Changeset{errors: errors} = cs} ->
            if Keyword.has_key?(errors, :key_prefix),
              do: claim_prefix(row, mod, org_id, base, n + 1),
              else: Repo.rollback(cs)
        end
    end
  end

  defp prefix_taken?(org_id, candidate) do
    org_use =
      Repo.one(
        from o in Organization, where: o.id == ^org_id and o.key_prefix == ^candidate, select: 1
      )

    proj_use =
      Repo.one(
        from p in Project,
          where: p.organization_id == ^org_id and p.key_prefix == ^candidate,
          select: 1
      )

    org_use != nil or proj_use != nil
  end

  @doc """
  Update an item. Custom-fields are merged (not replaced). Notification /
  audit-trail fan-out is the host application's concern (it layers on top of
  this shared write), so this function performs the core write only.
  """
  def update(id, attrs) do
    case Repo.get(Item, id) do
      nil ->
        {:error, :not_found}

      item ->
        merged_custom =
          case attrs[:custom_fields] || attrs["custom_fields"] do
            nil -> item.custom_fields
            new -> Map.merge(item.custom_fields || %{}, new)
          end

        item
        |> Item.update_changeset(Map.put(attrs, :custom_fields, merged_custom))
        |> Repo.update()
    end
  end

  def list(opts \\ []) do
    Item
    |> maybe_filter(:organization_id, opts[:organization_id])
    |> maybe_filter(:status, opts[:status])
    |> maybe_filter(:item_type, opts[:item_type])
    |> maybe_filter(:priority, opts[:priority])
    |> maybe_filter(:assignee, opts[:assignee])
    |> maybe_filter(:queue_id, opts[:queue_id])
    |> maybe_filter_parent(opts[:parent_id])
    |> maybe_filter(:project_id, opts[:project_id])
    |> maybe_filter(:stage_id, opts[:stage_id])
    |> maybe_filter(:iteration_id, opts[:iteration_id])
    |> order_by([t], desc: t.inserted_at)
    |> limit(^(opts[:limit] || 50))
    |> offset(^(opts[:offset] || 0))
    |> Repo.all()
  end

  def count_by_status do
    Item
    |> group_by([t], t.status)
    |> select([t], {t.status, count(t.id)})
    |> Repo.all()
    |> Map.new()
  end

  # ── Links (item ↔ item) ────────────────────────────────────────

  def link(source_id, target_id, link_type) do
    %ItemLink{}
    |> ItemLink.changeset(%{
      source_item_id: source_id,
      target_item_id: target_id,
      link_type: link_type
    })
    |> Repo.insert()
  end

  def unlink(source_id, target_id, link_type) do
    case Repo.get_by(ItemLink,
           source_item_id: source_id,
           target_item_id: target_id,
           link_type: link_type
         ) do
      nil -> {:error, :not_found}
      link -> Repo.delete(link)
    end
  end

  def get_links(item_id) do
    outgoing =
      ItemLink
      |> where([l], l.source_item_id == ^item_id)
      |> preload(:target_item)
      |> Repo.all()

    incoming =
      ItemLink
      |> where([l], l.target_item_id == ^item_id)
      |> preload(:source_item)
      |> Repo.all()

    %{outgoing: outgoing, incoming: incoming}
  end

  # ── Comments (polymorphic pm_comments, entity_type "item") ─────

  @doc "List comments for an item from the shared polymorphic pm_comments table."
  def list_comments(item_id, opts \\ []) do
    alias Noizu.PM.Schema.Polymorphic.PmComment

    PmComment
    |> where([c], c.entity_type == "item" and c.entity_id == ^item_id)
    |> order_by([c], asc: c.inserted_at)
    |> limit(^(opts[:limit] || 200))
    |> Repo.all()
  end

  def add_comment(item_id, attrs) do
    alias Noizu.PM.Schema.Polymorphic.PmComment

    %PmComment{}
    |> PmComment.changeset(Map.merge(attrs, %{entity_type: "item", entity_id: item_id}))
    |> Repo.insert()
  end

  # Scalar OR list value per field (multi-select). A list filters with `in`;
  # a scalar keeps `==`. nil/[] are no-ops.
  defp maybe_filter(query, _field, nil), do: query
  defp maybe_filter(query, _field, []), do: query

  defp maybe_filter(query, field, vals) when is_list(vals),
    do: where(query, [t], field(t, ^field) in ^vals)

  defp maybe_filter(query, field, val), do: where(query, [t], field(t, ^field) == ^val)

  # parent_id special-case: "root" sentinel selects top-level (parent_id IS NULL)
  # items — epics/parents without a parent of their own. nil is a no-op.
  defp maybe_filter_parent(query, nil), do: query
  defp maybe_filter_parent(query, "root"), do: where(query, [t], is_nil(t.parent_id))

  defp maybe_filter_parent(query, parent_id),
    do: where(query, [t], t.parent_id == ^parent_id)
end
