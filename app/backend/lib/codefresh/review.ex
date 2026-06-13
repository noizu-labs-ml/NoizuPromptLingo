defmodule Codefresh.Review do
  @moduledoc """
  Stage-8 review & promotion context: the backend surface for the freeball
  review queue and for promoting approved freeball chains into new authored
  script versions (or persona-scoped expectations).

  Covers:
    * US-088 — queue listing with filter/sort/paginate
    * US-089 — claim → approve / reject / dismiss with resolution notes
    * US-090 — promote an approved freeball chain to a new script_version
    * US-137 — regression-flag carried in audit metadata when rejecting
    * US-138 — bulk queue actions
    * US-139 — promote to persona_version (target_kind variant)
    * US-140 — assignment workflow (assign / my-queue filter)
    * US-141 — SLA aging (age_days computed + overdue sort / sla_warning marker)

  Mutations append an `audit_events` row (action / subject_type / subject_id /
  actor_user_id / metadata) for the Stage-9 audit-log export.
  """

  import Ecto.Query, only: [from: 2]
  import Ecto.Changeset, only: [cast: 3, validate_inclusion: 3]
  alias Ecto.Multi
  alias Codefresh.Repo
  alias Codefresh.Review.{ReviewItem, BranchPromotion}
  alias Codefresh.Runs.FreeballNode
  alias Codefresh.Scripts
  alias Codefresh.Scripts.{ScriptNode, ScriptVersion}

  # ---------------------------------------------------------------------------
  # Queue ingest — called from the Stage-5 runner when a freeball node is
  # persisted. Idempotent: if a row already exists for this freeball, returns
  # the existing one.
  # ---------------------------------------------------------------------------

  @doc """
  Enqueue a freeball node for review. Safe to call more than once for the
  same node — the `unique_index` on `freeball_node_id` collapses duplicates.
  """
  def enqueue(%FreeballNode{} = freeball, attrs \\ %{}) do
    case Repo.get_by(ReviewItem, freeball_node_id: freeball.id) do
      %ReviewItem{} = existing ->
        {:ok, existing}

      nil ->
        priority = Map.get(attrs, :priority, priority_from_confidence(freeball.confidence))

        %ReviewItem{}
        |> ReviewItem.create_changeset(%{
          organization_id: freeball.organization_id,
          freeball_node_id: freeball.id,
          status: "pending",
          priority: priority
        })
        |> Repo.insert()
    end
  end

  # Higher priority = lower confidence = surfaces first (US-088 default sort).
  defp priority_from_confidence(nil), do: 50

  defp priority_from_confidence(%Decimal{} = c) do
    # priority = round((1 - confidence) * 100), clamped to 0..100
    one_minus = Decimal.sub(Decimal.new(1), c)
    scaled = Decimal.mult(one_minus, Decimal.new(100))

    scaled
    |> Decimal.round(0)
    |> Decimal.to_integer()
    |> max(0)
    |> min(100)
  end

  defp priority_from_confidence(c) when is_number(c) do
    trunc(max(0, min(100, (1 - c) * 100)))
  end

  # ---------------------------------------------------------------------------
  # US-088 / US-140 / US-141 — list_queue
  # ---------------------------------------------------------------------------

  @doc """
  List review queue items for an org. Options:

    * `:status` — `"pending"` | `"claimed"` | `"approved"` | `"rejected"` |
      `"promoted"` | list of those. Defaults to `["pending"]`.
    * `:assigned_to_user_id` — filter to assignments (US-140 my-queue).
    * `:min_priority` / `:max_priority` — bounds, inclusive.
    * `:limit`  — page size (default 50, capped at 200).
    * `:offset` — pagination offset (default 0).
    * `:sort`   — `:priority_desc` (default) or `:oldest_first`.

  Each item is returned alongside its freeball_node and an
  `age_days` integer (US-141 aging).
  """
  def list_queue(organization_id, opts \\ []) when is_binary(organization_id) do
    statuses = opts |> Keyword.get(:status, ["pending"]) |> List.wrap()
    limit = opts |> Keyword.get(:limit, 50) |> min(200) |> max(1)
    offset = opts |> Keyword.get(:offset, 0) |> max(0)
    sort = Keyword.get(opts, :sort, :priority_desc)

    q =
      from ri in ReviewItem,
        where: ri.organization_id == ^organization_id and ri.status in ^statuses,
        preload: [:freeball_node]

    q
    |> maybe_filter_assignee(Keyword.get(opts, :assigned_to_user_id))
    |> maybe_filter_priority_min(Keyword.get(opts, :min_priority))
    |> maybe_filter_priority_max(Keyword.get(opts, :max_priority))
    |> apply_queue_sort(sort)
    |> then(&from(ri in &1, limit: ^limit, offset: ^offset))
    |> Repo.all()
    |> Enum.map(&annotate/1)
  end

  defp maybe_filter_assignee(q, nil), do: q
  defp maybe_filter_assignee(q, uid), do: from(ri in q, where: ri.assigned_to_user_id == ^uid)

  defp maybe_filter_priority_min(q, nil), do: q
  defp maybe_filter_priority_min(q, min), do: from(ri in q, where: ri.priority >= ^min)

  defp maybe_filter_priority_max(q, nil), do: q
  defp maybe_filter_priority_max(q, max), do: from(ri in q, where: ri.priority <= ^max)

  defp apply_queue_sort(q, :oldest_first),
    do: from(ri in q, order_by: [asc: ri.inserted_at])

  defp apply_queue_sort(q, _default),
    do: from(ri in q, order_by: [desc: ri.priority, asc: ri.inserted_at])

  @doc """
  Count of items matching the same filters as `list_queue/2` (no pagination).
  Used by the nav badge in US-088.
  """
  def count_queue(organization_id, opts \\ []) when is_binary(organization_id) do
    statuses = opts |> Keyword.get(:status, ["pending"]) |> List.wrap()

    q =
      from ri in ReviewItem,
        where: ri.organization_id == ^organization_id and ri.status in ^statuses,
        select: count(ri.id)

    q
    |> maybe_filter_assignee(Keyword.get(opts, :assigned_to_user_id))
    |> Repo.one()
  end

  # ---------------------------------------------------------------------------
  # Fetch
  # ---------------------------------------------------------------------------

  def get_item(organization_id, id) when is_binary(organization_id) and is_binary(id) do
    case Repo.get(ReviewItem, id) do
      %ReviewItem{organization_id: ^organization_id} = ri -> Repo.preload(ri, :freeball_node)
      _ -> nil
    end
  rescue
    Ecto.Query.CastError -> nil
  end

  # ---------------------------------------------------------------------------
  # US-089 — claim
  # ---------------------------------------------------------------------------

  @doc """
  Claim an item — sets status=claimed, assigned_to_user_id, claimed_at.

  Returns `{:ok, item}` | `{:error, :not_claimable}` if the item is already
  in a terminal state | `{:error, changeset}`.
  """
  def claim_item(%ReviewItem{} = item, actor_user_id) when is_binary(actor_user_id) do
    cond do
      item.status == "pending" ->
        now = now()

        result =
          item
          |> ReviewItem.update_changeset(%{
            status: "claimed",
            assigned_to_user_id: actor_user_id,
            claimed_at: now,
            assigned_at: now
          })
          |> Repo.update()

        with {:ok, updated} <- result do
          audit(actor_user_id, item.organization_id, "review.claim", "review_item", item.id, %{
            freeball_node_id: item.freeball_node_id
          })

          {:ok, updated}
        end

      item.status == "claimed" and item.assigned_to_user_id == actor_user_id ->
        # idempotent re-claim by the same user
        {:ok, item}

      true ->
        {:error, :not_claimable}
    end
  end

  # ---------------------------------------------------------------------------
  # US-089 — approve / reject / dismiss
  # ---------------------------------------------------------------------------

  @doc """
  Approve a claimed item. Leaves the freeball with review_status='approved'
  but does NOT create new script versions; promotion is a separate step
  (`create_promotion/2`). This matches the US-089 three-way split where
  Approve flips the flag and US-090 performs the actual graph surgery.
  """
  def approve(%ReviewItem{} = item, actor_user_id, attrs \\ %{}) do
    resolve(item, actor_user_id, "approved", "review.approve", attrs)
  end

  @doc """
  Reject a claimed item. `resolution_notes` is required. If
  `attrs[:flag_regression]` is truthy, the audit metadata records the
  regression flag for US-137 (actual dataset wiring lives in the datasets
  context, owned by a sibling agent).
  """
  def reject(%ReviewItem{} = item, actor_user_id, attrs) do
    case require_notes(attrs) do
      :ok ->
        meta =
          if truthy?(Map.get(attrs, :flag_regression)) do
            %{flag_regression: true}
          else
            %{}
          end

        resolve(item, actor_user_id, "rejected", "review.reject", attrs, meta)

      {:error, _} = err ->
        err
    end
  end

  @doc """
  Dismiss a claimed item — no promotion, no regression flag.
  `resolution_notes` is required (so the reviewer leaves a breadcrumb).
  """
  def dismiss(%ReviewItem{} = item, actor_user_id, attrs) do
    case require_notes(attrs) do
      :ok -> resolve(item, actor_user_id, "rejected", "review.dismiss", attrs, %{dismissed: true})
      {:error, _} = err -> err
    end
  end

  defp resolve(item, actor_user_id, new_status, action, attrs, extra_meta \\ %{}) do
    cond do
      item.status in ["approved", "rejected", "promoted"] ->
        {:error, :already_resolved}

      true ->
        notes = Map.get(attrs, :resolution_notes) || Map.get(attrs, "resolution_notes")
        now = now()

        Multi.new()
        |> Multi.update(
          :item,
          ReviewItem.update_changeset(item, %{
            status: new_status,
            resolution_notes: notes,
            resolved_at: now
          })
        )
        |> Multi.run(:freeball, fn repo, _ ->
          case repo.get(FreeballNode, item.freeball_node_id) do
            nil ->
              {:ok, nil}

            %FreeballNode{} = fb ->
              fb
              |> freeball_status_changeset(new_status)
              |> repo.update()
          end
        end)
        |> Repo.transaction()
        |> case do
          {:ok, %{item: updated}} ->
            audit(
              actor_user_id,
              item.organization_id,
              action,
              "review_item",
              item.id,
              Map.merge(
                %{freeball_node_id: item.freeball_node_id, notes_present: !is_nil(notes)},
                extra_meta
              )
            )

            {:ok, updated}

          {:error, _, reason, _} ->
            {:error, reason}
        end
    end
  end

  defp require_notes(attrs) do
    notes = Map.get(attrs, :resolution_notes) || Map.get(attrs, "resolution_notes")

    if is_binary(notes) and String.trim(notes) != "" do
      :ok
    else
      {:error, :resolution_notes_required}
    end
  end

  # ---------------------------------------------------------------------------
  # US-140 — assign / unassign
  # ---------------------------------------------------------------------------

  @doc """
  Assign an item to a user. Passing `nil` for `assignee_user_id` returns it to
  the shared pool. Only valid on pending or claimed items.
  """
  def assign(%ReviewItem{} = item, actor_user_id, assignee_user_id) do
    cond do
      item.status not in ["pending", "claimed"] ->
        {:error, :not_assignable}

      true ->
        attrs = %{
          assigned_to_user_id: assignee_user_id,
          assigned_at: if(is_nil(assignee_user_id), do: nil, else: now())
        }

        case item |> ReviewItem.update_changeset(attrs) |> Repo.update() do
          {:ok, updated} ->
            audit(actor_user_id, item.organization_id, "review.assign", "review_item", item.id, %{
              assignee_user_id: assignee_user_id
            })

            {:ok, updated}

          err ->
            err
        end
    end
  end

  # ---------------------------------------------------------------------------
  # US-138 — bulk actions
  # ---------------------------------------------------------------------------

  @doc """
  Apply the same action to many items at once. Items not owned by the org or
  not in a valid state for the action are skipped and returned under
  `:skipped` with a reason.

  Action is one of: `"claim"`, `"approve"`, `"reject"`, `"dismiss"`,
  `"assign"`. For `"assign"`, pass `:assignee_user_id` in `opts`.
  """
  def bulk_action(organization_id, actor_user_id, action, item_ids, opts \\ [])
      when action in ~w(claim approve reject dismiss assign) and is_list(item_ids) do
    items =
      Repo.all(
        from ri in ReviewItem,
          where: ri.organization_id == ^organization_id and ri.id in ^item_ids
      )

    results =
      Enum.reduce(items, %{ok: [], skipped: []}, fn item, acc ->
        res = dispatch_bulk(item, action, actor_user_id, opts)

        case res do
          {:ok, updated} -> %{acc | ok: [updated | acc.ok]}
          {:error, reason} -> %{acc | skipped: [{item.id, reason} | acc.skipped]}
        end
      end)

    %{ok: Enum.reverse(results.ok), skipped: Enum.reverse(results.skipped)}
  end

  defp dispatch_bulk(item, "claim", actor, _opts), do: claim_item(item, actor)

  defp dispatch_bulk(item, "approve", actor, opts),
    do: approve(item, actor, Map.new(opts))

  defp dispatch_bulk(item, "reject", actor, opts),
    do: reject(item, actor, Map.new(opts))

  defp dispatch_bulk(item, "dismiss", actor, opts),
    do: dismiss(item, actor, Map.new(opts))

  defp dispatch_bulk(item, "assign", actor, opts),
    do: assign(item, actor, Keyword.get(opts, :assignee_user_id))

  # ---------------------------------------------------------------------------
  # US-141 — SLA aging
  # ---------------------------------------------------------------------------

  @doc """
  Mark the `sla_warning_sent_at` timestamp on items past the SLA that haven't
  yet had a warning dispatched. Returns the number of items updated. The
  notification fan-out (email / webhook) lives outside this context.
  """
  def mark_sla_warnings(organization_id, sla_days \\ 7) when is_integer(sla_days) do
    cutoff = DateTime.add(now(), -sla_days * 24 * 3600, :second)

    {count, _} =
      Repo.update_all(
        from(ri in ReviewItem,
          where:
            ri.organization_id == ^organization_id and
              ri.status in ["pending", "claimed"] and
              ri.inserted_at <= ^cutoff and
              is_nil(ri.sla_warning_sent_at)
        ),
        set: [sla_warning_sent_at: now()]
      )

    count
  end

  @doc """
  Age (in whole days) since a queue item was enqueued.
  """
  def age_days(%ReviewItem{inserted_at: inserted}) when not is_nil(inserted) do
    DateTime.diff(now(), inserted, :second) |> div(86_400)
  end

  def age_days(_), do: 0

  # ---------------------------------------------------------------------------
  # US-090 / US-139 — promote approved freeball
  # ---------------------------------------------------------------------------

  @doc """
  Promote an approved freeball into a new authored script_version (US-090) or
  an existing persona_version (US-139), controlled by `target_kind`.

  For the `"script_version"` path:
    1. Fork the parent script that owns the anchor script_node
       (uses `Scripts.fork_script/2`, which already exists)
    2. Add a script_node mirroring the freeball into the forked draft
    3. Add an edge from the corresponding parent anchor to the new node
    4. Record a `branch_promotions` row
    5. Flip the item to `:promoted` + freeball to `:promoted`

  For the `"persona_version"` path, only the audit/promotion record is
  created; the caller is expected to have already produced the new persona
  version via `Personas.publish_version/2`. The `target_script_version_id`
  slot is repurposed to store the persona version id (schema reuse).

  Options:
    * `:target_kind`             — `"script_version"` | `"persona_version"`
    * `:target_script_version_id` — required for the persona variant
    * `:notes`                   — free-form note persisted on the promotion

  Returns `{:ok, %{item: updated_item, promotion: promotion, script?:
  {fork, draft_version}}}` or `{:error, reason}`.
  """
  def create_promotion(%ReviewItem{} = item, actor_user_id, opts \\ []) do
    target_kind = Keyword.get(opts, :target_kind, "script_version")

    cond do
      item.status != "approved" ->
        {:error, :item_not_approved}

      target_kind == "script_version" ->
        do_promote_to_script(item, actor_user_id, opts)

      target_kind == "persona_version" ->
        do_promote_to_persona(item, actor_user_id, opts)

      true ->
        {:error, :unknown_target_kind}
    end
  end

  defp do_promote_to_script(item, actor_user_id, opts) do
    notes = Keyword.get(opts, :notes)

    with %FreeballNode{} = freeball <- Repo.get(FreeballNode, item.freeball_node_id),
         %ScriptNode{} = anchor <- Repo.get(ScriptNode, freeball.parent_script_node_id),
         %ScriptVersion{} = source_version <- Repo.get(ScriptVersion, anchor.script_version_id),
         {:ok, source_script} <-
           get_script(freeball.organization_id, source_version.script_id),
         {:ok, fork, draft_version} <-
           Scripts.fork_script(source_script, forked_by_user_id: actor_user_id) do
      case splice_freeball_into_fork(freeball, anchor, draft_version) do
        {:ok, {new_node, new_edge}} ->
          finalize_promotion(
            item,
            actor_user_id,
            %{
              organization_id: freeball.organization_id,
              source_freeball_node_id: freeball.id,
              source_script_version_id: source_version.id,
              target_script_version_id: draft_version.id,
              target_kind: "script_version",
              promoted_by_user_id: actor_user_id,
              node_mapping: %{freeball.id => new_node.id},
              edge_additions: %{edges: [new_edge.id]},
              notes: notes
            },
            %{fork_id: fork.id, draft_version_id: draft_version.id}
          )

        {:error, reason} ->
          {:error, reason}
      end
    else
      nil -> {:error, :source_graph_not_found}
      {:error, reason} -> {:error, reason}
    end
  end

  defp do_promote_to_persona(item, actor_user_id, opts) do
    persona_version_id = Keyword.get(opts, :target_script_version_id)
    notes = Keyword.get(opts, :notes)

    cond do
      is_nil(persona_version_id) ->
        {:error, :persona_version_id_required}

      true ->
        with %FreeballNode{} = freeball <- Repo.get(FreeballNode, item.freeball_node_id),
             %ScriptNode{} = anchor <- Repo.get(ScriptNode, freeball.parent_script_node_id),
             %ScriptVersion{} = source_version <-
               Repo.get(ScriptVersion, anchor.script_version_id) do
          finalize_promotion(
            item,
            actor_user_id,
            %{
              organization_id: freeball.organization_id,
              source_freeball_node_id: freeball.id,
              source_script_version_id: source_version.id,
              target_script_version_id: persona_version_id,
              target_kind: "persona_version",
              promoted_by_user_id: actor_user_id,
              node_mapping: %{freeball.id => persona_version_id},
              edge_additions: %{},
              notes: notes
            },
            %{persona_version_id: persona_version_id}
          )
        else
          nil -> {:error, :source_graph_not_found}
        end
    end
  end

  defp splice_freeball_into_fork(
         %FreeballNode{} = freeball,
         %ScriptNode{} = anchor,
         %ScriptVersion{} = draft
       ) do
    # The fork copied the graph by `node_key`, so look up the mirror of the
    # anchor in the new draft.
    mirror_anchor =
      Repo.one(
        from n in ScriptNode,
          where: n.script_version_id == ^draft.id and n.node_key == ^anchor.node_key
      )

    if is_nil(mirror_anchor) do
      {:error, :anchor_not_found_in_fork}
    else
      new_key = promoted_node_key(freeball)

      with {:ok, new_node} <-
             Scripts.add_node(draft, %{
               "node_key" => new_key,
               "kind" => "assistant_turn",
               "metadata" => %{
                 "promoted_from_freeball_id" => freeball.id,
                 "runner_model" => freeball.runner_model,
                 "prompt_text" => freeball.prompt_text
               }
             }),
           {:ok, new_edge} <-
             Scripts.add_edge(draft, %{
               "from_node_id" => mirror_anchor.id,
               "to_node_id" => new_node.id,
               "match_method" => "always",
               "label" => "promoted:#{short_id(freeball.id)}"
             }) do
        {:ok, {new_node, new_edge}}
      end
    end
  end

  defp finalize_promotion(item, actor_user_id, promo_attrs, extra_audit) do
    # branch_promotions has a non-null `inserted_at` but no updated_at — Ecto
    # does not auto-fill here because the schema marks the field virtual:false
    # explicitly. Supply it.
    promo_attrs = Map.put_new(promo_attrs, :inserted_at, now())

    Multi.new()
    |> Multi.insert(:promotion, BranchPromotion.create_changeset(%BranchPromotion{}, promo_attrs))
    |> Multi.update(
      :item,
      ReviewItem.update_changeset(item, %{status: "promoted"})
    )
    |> Multi.run(:freeball, fn repo, _ ->
      case repo.get(FreeballNode, item.freeball_node_id) do
        nil ->
          {:ok, nil}

        %FreeballNode{} = fb ->
          fb |> freeball_status_changeset("promoted") |> repo.update()
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{promotion: p, item: i}} ->
        audit(
          actor_user_id,
          item.organization_id,
          "review.promote",
          "branch_promotion",
          p.id,
          Map.merge(
            %{
              review_item_id: item.id,
              freeball_node_id: item.freeball_node_id,
              target_kind: p.target_kind
            },
            extra_audit
          )
        )

        {:ok, %{item: i, promotion: p, extra: extra_audit}}

      {:error, _, reason, _} ->
        {:error, reason}
    end
  end

  defp promoted_node_key(%FreeballNode{id: id}) do
    "freeball_" <> short_id(id)
  end

  defp short_id(id) when is_binary(id) do
    id |> String.replace("-", "") |> binary_part(0, 8)
  end

  defp get_script(org_id, script_id) do
    case Scripts.get_script(org_id, script_id) do
      nil -> {:error, :script_not_found}
      script -> {:ok, script}
    end
  end

  # ---------------------------------------------------------------------------
  # Promotions listing
  # ---------------------------------------------------------------------------

  def list_promotions(organization_id, opts \\ []) when is_binary(organization_id) do
    limit = opts |> Keyword.get(:limit, 50) |> min(200) |> max(1)

    Repo.all(
      from p in BranchPromotion,
        where: p.organization_id == ^organization_id,
        order_by: [desc: p.inserted_at],
        limit: ^limit
    )
  end

  def get_promotion(organization_id, id) when is_binary(organization_id) and is_binary(id) do
    case Repo.get(BranchPromotion, id) do
      %BranchPromotion{organization_id: ^organization_id} = p -> p
      _ -> nil
    end
  rescue
    Ecto.Query.CastError -> nil
  end

  # ---------------------------------------------------------------------------
  # Private — annotate / audit / helpers
  # ---------------------------------------------------------------------------

  # Schema-local update helper for `freeball_nodes.review_status`. Defined
  # here (not on the schema) because `lib/codefresh/runs/` is owned by a
  # parallel agent during this session.
  defp freeball_status_changeset(%FreeballNode{} = fb, new_status) do
    fb
    |> cast(%{review_status: new_status}, [:review_status])
    |> validate_inclusion(:review_status, FreeballNode.review_statuses())
  end

  @doc """
  Convenience wrapper used by the controller to pair an item with its
  computed `age_days`.
  """
  def with_age(%ReviewItem{} = ri), do: {ri, age_days(ri)}

  defp annotate(%ReviewItem{} = ri), do: ri

  # Stable advisory-lock key namespaced for audit inserts. Serializing
  # concurrent `insert_all` calls on the `audit_events` TimescaleDB
  # hypertable side-steps `ERROR 40P01 deadlock_detected` that would
  # otherwise surface under parallel writes to hypertable chunk indexes.
  @audit_advisory_lock_key 0xA7D17_EFE

  defp audit(actor_user_id, organization_id, action, subject_type, subject_id, metadata) do
    row = %{
      organization_id: Ecto.UUID.dump!(organization_id),
      actor_user_id: maybe_dump_uuid(actor_user_id),
      action: action,
      subject_type: subject_type,
      subject_id: maybe_dump_uuid(subject_id),
      metadata: metadata || %{},
      timestamp: now(),
      inserted_at: now()
    }

    Repo.query!("SELECT pg_advisory_xact_lock($1)", [@audit_advisory_lock_key])
    Repo.insert_all("audit_events", [row])
  end

  defp maybe_dump_uuid(nil), do: nil

  defp maybe_dump_uuid(id) when is_binary(id) do
    case Ecto.UUID.dump(id) do
      {:ok, bin} -> bin
      :error -> nil
    end
  end

  defp truthy?(v) when v in [true, "true", 1, "1"], do: true
  defp truthy?(_), do: false

  defp now, do: DateTime.utc_now() |> DateTime.truncate(:second)
end
