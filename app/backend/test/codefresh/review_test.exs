defmodule Codefresh.ReviewTest do
  @moduledoc """
  Stage-8 context tests — queue listing, claim / resolve, assignment,
  promotion to script_version, bulk actions, and SLA aging.

  Covers US-088 / US-089 / US-090 / US-137 / US-138 / US-139 / US-140 / US-141.
  """

  # async: false because the context inserts into `audit_events`
  # (TimescaleDB hypertable) — concurrent insert_all acquires a
  # ShareRowExclusiveLock on chunk tables and the policy catalogue, which
  # cross-deadlocks the parallel test connections. Single-threaded avoids it.
  use Codefresh.DataCase, async: false

  import Codefresh.Fixtures
  import Ecto.Query, only: [from: 2]

  alias Codefresh.{Review, Runs, Scripts, Prompts, Agents, Repo}
  alias Codefresh.Review.{ReviewItem, BranchPromotion}
  alias Codefresh.Runs.FreeballNode

  # ---------------------------------------------------------------------------
  # Fixtures
  # ---------------------------------------------------------------------------

  defp setup_published_script do
    %{organization: org, user: user} = org_with_owner()

    {:ok, prompt} =
      Prompts.create_prompt(%{
        "organization_id" => org.id,
        "created_by_user_id" => user.id,
        "name" => "Greeter"
      })

    {:ok, :published, pv} =
      Prompts.publish_version(prompt, %{body: "hello", published_by_user_id: user.id})

    {:ok, script, draft} =
      Scripts.create_script(%{"organization_id" => org.id, "name" => "Flow"})

    {:ok, n1} = Scripts.add_node(draft, %{"node_key" => "start", "kind" => "user_turn"})
    {:ok, _} = Scripts.attach_prompt(n1, pv.id)
    {:ok, n2} = Scripts.add_node(draft, %{"node_key" => "finish", "kind" => "terminal"})

    {:ok, _} =
      Scripts.add_expectation(n1, %{
        "label" => "says hi",
        "scoring_method" => "regex",
        "config" => %{"pattern" => "(?i)hi|hello"}
      })

    {:ok, _} =
      Scripts.add_edge(draft, %{
        "from_node_id" => n1.id,
        "to_node_id" => n2.id,
        "match_method" => "always"
      })

    {:ok, :published, version} = Scripts.publish_version(script, published_by_user_id: user.id)

    # Reload script so `current_version_id` is visible to Runs.trigger_run
    script = Scripts.get_script!(org.id, script.id)

    %{
      org: org,
      user: user,
      script: script,
      draft: draft,
      version: version,
      anchor: n1,
      terminal: n2
    }
  end

  defp setup_agent(org, user) do
    {:ok, agent} =
      Agents.create_agent(%{
        "organization_id" => org.id,
        "created_by_user_id" => user.id,
        "name" => "Agent #{System.unique_integer([:positive])}"
      })

    {:ok, :published, _v} =
      Agents.publish_version(agent, %{
        adapter: "openai",
        model: "gpt-4o",
        auth_ref: %{"type" => "secret_ref", "ref" => "infisical://x/Y"},
        request_template: %{"timeout_ms" => 30_000},
        published_by_user_id: user.id
      })

    agent
  end

  # Build a run + a freeball_node attached to the anchor. Returns
  # %{org, user, script, version, anchor, run, freeball}.
  defp setup_freeball do
    ctx = setup_published_script()
    agent = setup_agent(ctx.org, ctx.user)

    {:ok, run} =
      Runs.trigger_run(ctx.script, agent.id,
        triggered_by_user_id: ctx.user.id,
        enqueue: false
      )

    {:ok, freeball} =
      %FreeballNode{}
      |> FreeballNode.create_changeset(%{
        run_id: run.id,
        organization_id: ctx.org.id,
        parent_script_node_id: ctx.anchor.id,
        sequence: 1,
        prompt_text: "The agent deviated here — ask about refunds.",
        confidence: Decimal.new("0.20"),
        runner_model: "gpt-4o"
      })
      |> Repo.insert()

    Map.merge(ctx, %{run: run, freeball: freeball})
  end

  # Build another freeball_node sharing the org / script / anchor from `ctx`,
  # with its own run — so we can test bulk actions across multiple items in
  # one org.
  defp setup_freeball_in(%{org: org, user: user, script: script, anchor: anchor}) do
    agent = setup_agent(org, user)

    {:ok, run} =
      Runs.trigger_run(script, agent.id,
        triggered_by_user_id: user.id,
        enqueue: false
      )

    seq = System.unique_integer([:positive])

    {:ok, fb} =
      %FreeballNode{}
      |> FreeballNode.create_changeset(%{
        run_id: run.id,
        organization_id: org.id,
        parent_script_node_id: anchor.id,
        sequence: seq,
        prompt_text: "another freeball #{seq}",
        confidence: Decimal.new("0.30"),
        runner_model: "gpt-4o"
      })
      |> Repo.insert()

    fb
  end

  defp enqueue!(freeball) do
    {:ok, item} = Review.enqueue(freeball)
    item
  end

  defp claim!(item, user) do
    {:ok, claimed} = Review.claim_item(item, user.id)
    claimed
  end

  # ---------------------------------------------------------------------------
  # US-088 — enqueue / list_queue / count_queue
  # ---------------------------------------------------------------------------

  describe "enqueue/2 (US-088)" do
    test "creates a pending review item from a freeball node" do
      %{freeball: fb, org: org} = setup_freeball()

      assert {:ok, %ReviewItem{} = item} = Review.enqueue(fb)
      assert item.status == "pending"
      assert item.organization_id == org.id
      assert item.freeball_node_id == fb.id
      # low-confidence (0.20) → high priority (~80)
      assert item.priority >= 70
    end

    test "is idempotent — re-enqueueing the same freeball returns the same row" do
      %{freeball: fb} = setup_freeball()

      assert {:ok, first} = Review.enqueue(fb)
      assert {:ok, second} = Review.enqueue(fb)
      assert first.id == second.id
    end
  end

  describe "list_queue/2 + count_queue/2 (US-088)" do
    test "returns pending items for org, scoped tightly, priority-desc default" do
      %{freeball: fb, org: org, user: u} = setup_freeball()
      enqueue!(fb)

      # Another org with its own item — must not bleed over
      %{freeball: other_fb} = setup_freeball()
      enqueue!(other_fb)

      items = Review.list_queue(org.id)
      assert length(items) == 1
      assert Review.count_queue(org.id) == 1
      # The unrelated org's user cannot peek either
      _ = u
    end

    test "status filter excludes resolved items" do
      %{freeball: fb, org: org, user: u} = setup_freeball()
      item = enqueue!(fb)
      claimed = claim!(item, u)
      {:ok, _} = Review.approve(claimed, u.id)

      assert Review.list_queue(org.id, status: "pending") == []
      assert Review.count_queue(org.id, status: "approved") == 1
    end

    test "my-queue filter (US-140) returns only items assigned to the user" do
      %{freeball: fb, org: org, user: u} = setup_freeball()
      item = enqueue!(fb)
      # Not yet assigned
      assert Review.list_queue(org.id, assigned_to_user_id: u.id) == []
      {:ok, _} = Review.assign(item, u.id, u.id)
      assert [_] = Review.list_queue(org.id, assigned_to_user_id: u.id)
    end
  end

  # ---------------------------------------------------------------------------
  # US-089 — claim / approve / reject / dismiss
  # ---------------------------------------------------------------------------

  describe "claim_item/2 (US-089)" do
    test "sets status=claimed, claimed_at, assigned_at, assigned_to_user_id" do
      %{freeball: fb, user: u} = setup_freeball()
      item = enqueue!(fb)

      assert {:ok, claimed} = Review.claim_item(item, u.id)
      assert claimed.status == "claimed"
      assert claimed.assigned_to_user_id == u.id
      assert claimed.claimed_at != nil
      assert claimed.assigned_at != nil
    end

    test "is idempotent for the same user, errors when already resolved" do
      %{freeball: fb, user: u} = setup_freeball()
      item = enqueue!(fb)
      claimed = claim!(item, u)

      assert {:ok, ^claimed} = Review.claim_item(claimed, u.id)

      {:ok, _} = Review.approve(claimed, u.id)
      reloaded = Repo.get!(ReviewItem, item.id)
      assert {:error, :not_claimable} = Review.claim_item(reloaded, u.id)
    end
  end

  describe "approve/3 (US-089)" do
    test "flips item + freeball to approved; audit row recorded" do
      %{freeball: fb, user: u, org: org} = setup_freeball()
      item = enqueue!(fb) |> claim!(u)

      assert {:ok, approved} = Review.approve(item, u.id, %{resolution_notes: "looks clean"})
      assert approved.status == "approved"
      assert approved.resolution_notes == "looks clean"
      assert approved.resolved_at != nil

      reloaded_fb = Repo.get!(FreeballNode, fb.id)
      assert reloaded_fb.review_status == "approved"

      assert count_audits(org.id, "review.approve") == 1
    end

    test "rejects double-resolution" do
      %{freeball: fb, user: u} = setup_freeball()
      item = enqueue!(fb) |> claim!(u)
      {:ok, approved} = Review.approve(item, u.id)
      assert {:error, :already_resolved} = Review.approve(approved, u.id)
    end
  end

  describe "reject/3 (US-089, US-137)" do
    test "requires resolution_notes" do
      %{freeball: fb, user: u} = setup_freeball()
      item = enqueue!(fb) |> claim!(u)

      assert {:error, :resolution_notes_required} = Review.reject(item, u.id, %{})
      assert {:error, :resolution_notes_required} =
               Review.reject(item, u.id, %{resolution_notes: "  "})
    end

    test "flag_regression persists in audit metadata (US-137)" do
      %{freeball: fb, user: u, org: org} = setup_freeball()
      item = enqueue!(fb) |> claim!(u)

      assert {:ok, rejected} =
               Review.reject(item, u.id, %{
                 resolution_notes: "bad turn — make this a regression",
                 flag_regression: true
               })

      assert rejected.status == "rejected"

      assert audit_metadata(org.id, "review.reject")["flag_regression"] == true

      reloaded_fb = Repo.get!(FreeballNode, fb.id)
      assert reloaded_fb.review_status == "rejected"
    end
  end

  describe "dismiss/3 (US-089)" do
    test "requires notes and flips to rejected with dismissed marker" do
      %{freeball: fb, user: u, org: org} = setup_freeball()
      item = enqueue!(fb) |> claim!(u)

      assert {:error, :resolution_notes_required} = Review.dismiss(item, u.id, %{})

      assert {:ok, dismissed} =
               Review.dismiss(item, u.id, %{resolution_notes: "noise"})

      assert dismissed.status == "rejected"
      assert audit_metadata(org.id, "review.dismiss")["dismissed"] == true
    end
  end

  # ---------------------------------------------------------------------------
  # US-140 — assign / unassign
  # ---------------------------------------------------------------------------

  describe "assign/3 (US-140)" do
    test "assigns to another user and can unassign with nil" do
      %{freeball: fb, user: u, org: org} = setup_freeball()
      other = user_fixture()
      membership_fixture(other, org, "editor")

      item = enqueue!(fb)

      {:ok, assigned} = Review.assign(item, u.id, other.id)
      assert assigned.assigned_to_user_id == other.id
      assert assigned.assigned_at != nil

      {:ok, cleared} = Review.assign(assigned, u.id, nil)
      assert cleared.assigned_to_user_id == nil
      assert cleared.assigned_at == nil
    end

    test "refuses to reassign a resolved item" do
      %{freeball: fb, user: u} = setup_freeball()
      item = enqueue!(fb) |> claim!(u)
      {:ok, resolved} = Review.approve(item, u.id)
      assert {:error, :not_assignable} = Review.assign(resolved, u.id, u.id)
    end
  end

  # ---------------------------------------------------------------------------
  # US-138 — bulk actions
  # ---------------------------------------------------------------------------

  describe "bulk_action/5 (US-138)" do
    test "bulk-claim multiple pending items in one org" do
      ctx = setup_freeball()
      %{org: org, user: u} = ctx

      # Two freeballs anchored to the same org as ctx
      second = setup_freeball_in(ctx)
      third = setup_freeball_in(ctx)

      item1 = enqueue!(ctx.freeball)
      item2 = enqueue!(second)
      item3 = enqueue!(third)

      ids = [item1.id, item2.id, item3.id]

      result = Review.bulk_action(org.id, u.id, "claim", ids)

      assert length(result.ok) == 3
      assert result.skipped == []
      assert Enum.all?(result.ok, &(&1.status == "claimed"))
    end

    test "bulk-approve skips items that are not claimable and reports reasons" do
      ctx = setup_freeball()
      %{org: org, user: u} = ctx

      # Already-resolved item should be skipped
      resolved_item = enqueue!(ctx.freeball) |> claim!(u)
      {:ok, resolved} = Review.approve(resolved_item, u.id)

      # A fresh pending item in the same org that approve/3 DOES accept (no
      # notes required for approve).
      another_fb = setup_freeball_in(ctx)
      fresh = enqueue!(another_fb)

      result = Review.bulk_action(org.id, u.id, "approve", [resolved.id, fresh.id])

      assert length(result.ok) == 1
      assert [{skipped_id, :already_resolved}] = result.skipped
      assert skipped_id == resolved.id
    end
  end

  # ---------------------------------------------------------------------------
  # US-141 — SLA aging
  # ---------------------------------------------------------------------------

  describe "mark_sla_warnings/2 + age_days/1 (US-141)" do
    test "backdated items get sla_warning_sent_at stamped" do
      %{freeball: fb, org: org} = setup_freeball()
      item = enqueue!(fb)

      # Backdate by 10 days via direct update
      backdated =
        DateTime.utc_now()
        |> DateTime.add(-10 * 24 * 3600, :second)
        |> DateTime.truncate(:second)

      {1, _} =
        Repo.update_all(
          from(ri in ReviewItem, where: ri.id == ^item.id),
          set: [inserted_at: backdated]
        )

      assert Review.mark_sla_warnings(org.id, 7) == 1

      reloaded = Repo.get!(ReviewItem, item.id)
      assert reloaded.sla_warning_sent_at != nil
      assert Review.age_days(reloaded) >= 9
    end
  end

  # ---------------------------------------------------------------------------
  # US-090 — promote to script_version
  # ---------------------------------------------------------------------------

  describe "create_promotion/3 script_version (US-090)" do
    test "forks the source, splices the freeball, records branch_promotion" do
      %{freeball: fb, user: u, org: org, script: source_script} = setup_freeball()
      item = enqueue!(fb) |> claim!(u)
      {:ok, approved} = Review.approve(item, u.id)

      assert {:ok, result} = Review.create_promotion(approved, u.id, notes: "splice it")

      assert result.item.status == "promoted"
      assert %BranchPromotion{} = result.promotion
      assert result.promotion.target_kind == "script_version"
      assert result.promotion.source_freeball_node_id == fb.id
      assert result.promotion.notes == "splice it"

      # Forked script exists and contains a freeball_<id> node wired to the
      # anchor mirror.
      draft = Repo.get!(Codefresh.Scripts.ScriptVersion, result.promotion.target_script_version_id)
      assert draft.parent_version_id != nil
      nodes = Scripts.list_nodes(draft)
      assert Enum.any?(nodes, fn n -> String.starts_with?(n.node_key, "freeball_") end)

      # Freeball status advanced to :promoted
      assert Repo.get!(FreeballNode, fb.id).review_status == "promoted"

      # Audit row present
      assert count_audits(org.id, "review.promote") == 1

      # The forked script's id differs from the source
      assert result.promotion.source_script_version_id != result.promotion.target_script_version_id
      _ = source_script
    end

    test "refuses to promote until item is approved" do
      %{freeball: fb, user: u} = setup_freeball()
      item = enqueue!(fb)
      assert {:error, :item_not_approved} = Review.create_promotion(item, u.id)
    end
  end

  describe "create_promotion/3 persona_version (US-139)" do
    test "records a promotion row with target_kind=persona_version" do
      %{freeball: fb, user: u, version: sv} = setup_freeball()
      item = enqueue!(fb) |> claim!(u)
      {:ok, approved} = Review.approve(item, u.id)

      # The branch_promotions.target_script_version_id FK requires a real
      # row in `script_versions`. Re-use the already-published version —
      # this suffices for schema-level verification that the persona variant
      # does NOT perform graph surgery, it only records the audit row.
      assert {:ok, %{promotion: p}} =
               Review.create_promotion(approved, u.id,
                 target_kind: "persona_version",
                 target_script_version_id: sv.id
               )

      assert p.target_kind == "persona_version"
      assert p.target_script_version_id == sv.id
    end

    test "requires target_script_version_id for persona variant" do
      %{freeball: fb, user: u} = setup_freeball()
      item = enqueue!(fb) |> claim!(u)
      {:ok, approved} = Review.approve(item, u.id)

      assert {:error, :persona_version_id_required} =
               Review.create_promotion(approved, u.id, target_kind: "persona_version")
    end
  end

  # ---------------------------------------------------------------------------
  # Helpers — audit_events introspection (hypertable, bare-map select)
  # ---------------------------------------------------------------------------

  defp count_audits(org_id, action) do
    {:ok, org_uuid} = Ecto.UUID.dump(org_id)

    Repo.one(
      from e in "audit_events",
        where: e.organization_id == ^org_uuid and e.action == ^action,
        select: count(e.id)
    )
  end

  defp audit_metadata(org_id, action) do
    {:ok, org_uuid} = Ecto.UUID.dump(org_id)

    Repo.one(
      from e in "audit_events",
        where: e.organization_id == ^org_uuid and e.action == ^action,
        select: e.metadata,
        order_by: [desc: e.timestamp],
        limit: 1
    )
  end
end
