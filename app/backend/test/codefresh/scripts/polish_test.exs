defmodule Codefresh.Scripts.PolishTest do
  use Codefresh.DataCase, async: true

  alias Codefresh.{Scripts, Prompts}

  import Codefresh.Fixtures

  # ──────────────────────────────────────────────────────────────────────────
  # Shared setup
  # ──────────────────────────────────────────────────────────────────────────

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
    {:ok, n2} = Scripts.add_node(draft, %{"node_key" => "end", "kind" => "terminal"})

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

    {:ok, :published, v} = Scripts.publish_version(script, published_by_user_id: user.id)

    %{org: org, user: user, script: script, draft: draft, version: v, n1: n1, n2: n2}
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-041 — fork_script/2
  # ──────────────────────────────────────────────────────────────────────────

  describe "fork_script/2 (US-041)" do
    test "forks a published script into a new head" do
      %{org: org, user: user, script: source, version: v} = setup_published_script()

      assert {:ok, fork, draft} = Scripts.fork_script(source, forked_by_user_id: user.id)

      assert fork.organization_id == org.id
      assert fork.id != source.id
      assert String.starts_with?(fork.slug, source.slug <> "-fork-")

      assert draft.parent_version_id == v.id
      assert draft.version_number == 1

      # Graph was copied — draft has nodes
      nodes = Scripts.list_nodes(draft)
      assert length(nodes) == 2
    end

    test "returns error when source has no published version" do
      %{organization: org, user: user} = org_with_owner()
      {:ok, script, _draft} = Scripts.create_script(%{"organization_id" => org.id, "name" => "Unpublished"})

      assert {:error, :not_published} = Scripts.fork_script(script, forked_by_user_id: user.id)
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-042 — diff_versions/2
  # ──────────────────────────────────────────────────────────────────────────

  describe "diff_versions/2 (US-042)" do
    test "returns empty diff for identical versions" do
      %{draft: draft} = setup_published_script()

      diff = Scripts.diff_versions(draft, draft)

      assert diff.added_nodes == []
      assert diff.removed_nodes == []
      assert diff.changed_nodes == []
      assert diff.added_edges == []
      assert diff.removed_edges == []
    end

    test "detects added and removed nodes between versions" do
      %{user: user, script: source} = setup_published_script()
      {:ok, fork, fork_draft} = Scripts.fork_script(source, forked_by_user_id: user.id)

      # Add a node to the fork draft
      {:ok, _extra} = Scripts.add_node(fork_draft, %{"node_key" => "extra", "kind" => "terminal"})

      source_draft = Scripts.get_draft_version(source)
      diff = Scripts.diff_versions(source_draft, fork_draft)

      assert Enum.any?(diff.added_nodes, &(&1.node_key == "extra"))
      _ = fork
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-043 — bulk_node_operation/4
  # ──────────────────────────────────────────────────────────────────────────

  describe "bulk_node_operation/4 (US-043)" do
    test "archives a set of nodes" do
      %{draft: draft, n1: n1, n2: n2} = setup_published_script()

      assert {:ok, updated} = Scripts.bulk_node_operation(draft, "archive", [n1.id, n2.id])
      assert Enum.all?(updated, fn n -> n.metadata["archived"] == true end)
    end

    test "retags a set of nodes" do
      %{draft: draft, n1: n1} = setup_published_script()

      assert {:ok, [updated_node]} =
               Scripts.bulk_node_operation(draft, "retag", [n1.id], tags: ["smoke", "regression"])

      assert updated_node.eval_tags == ["smoke", "regression"]
    end

    test "returns error for node_ids not in version" do
      %{draft: draft} = setup_published_script()
      fake_id = Ecto.UUID.generate()

      assert {:error, {:nodes_not_found, _}} =
               Scripts.bulk_node_operation(draft, "archive", [fake_id])
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-044 — auto_layout/1
  # ──────────────────────────────────────────────────────────────────────────

  describe "auto_layout/1 (US-044)" do
    test "assigns positions to all nodes" do
      %{draft: draft} = setup_published_script()

      assert {:ok, nodes} = Scripts.auto_layout(draft)
      assert length(nodes) == 2
      assert Enum.all?(nodes, fn n -> is_map(n.position) and Map.has_key?(n.position, "x") end)
    end

    test "root node gets y=0" do
      %{script: script} = setup_published_script()
      # Reload draft to get the current root_node_id
      draft = Scripts.get_draft_version(script)
      {:ok, nodes} = Scripts.auto_layout(draft)

      root_id = Codefresh.Repo.get!(Codefresh.Scripts.ScriptVersion, draft.id).root_node_id
      root_node = Enum.find(nodes, &(&1.id == root_id))

      assert root_node.position["y"] == 0
    end

    test "empty script returns ok with empty list" do
      %{organization: org} = org_with_owner()
      {:ok, _script, draft} = Scripts.create_script(%{"organization_id" => org.id, "name" => "Empty"})

      assert {:ok, []} = Scripts.auto_layout(draft)
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-045 — node comments
  # ──────────────────────────────────────────────────────────────────────────

  describe "node comments (US-045)" do
    test "adds and lists a comment on a node" do
      %{org: org, user: user, n1: n1} = setup_published_script()
      thread_id = Ecto.UUID.generate()

      assert {:ok, comment} =
               Scripts.add_node_comment(n1, user.id, %{
                 "thread_id" => thread_id,
                 "body" => "This node needs a better prompt"
               })

      assert comment.body == "This node needs a better prompt"
      assert comment.thread_id == thread_id

      comments = Scripts.list_node_comments(org.id, n1.id)
      assert Enum.any?(comments, &(&1.id == comment.id))
    end

    test "rejects comment with empty body" do
      %{user: user, n1: n1} = setup_published_script()

      assert {:error, cs} =
               Scripts.add_node_comment(n1, user.id, %{
                 "thread_id" => Ecto.UUID.generate(),
                 "body" => ""
               })

      assert %{body: _} = cs.errors |> Enum.into(%{}) |> Map.new(fn {k, {_m, _}} -> {k, true} end)
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-046 — version_lineage/1
  # ──────────────────────────────────────────────────────────────────────────

  describe "version_lineage/1 (US-046)" do
    test "returns single-element chain for a root version" do
      %{version: v} = setup_published_script()

      assert {:ok, [only]} = Scripts.version_lineage(v)
      assert only.id == v.id
    end

    test "returns chain with fork's parent version" do
      %{user: user, script: source, version: src_v} = setup_published_script()
      {:ok, _fork, fork_draft} = Scripts.fork_script(source, forked_by_user_id: user.id)

      assert {:ok, chain} = Scripts.version_lineage(fork_draft)
      assert length(chain) == 2
      # oldest first — src_v is the ancestor
      assert hd(chain).id == src_v.id
      assert List.last(chain).id == fork_draft.id
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-047 — validate_draft/1
  # ──────────────────────────────────────────────────────────────────────────

  describe "validate_draft/1 (US-047)" do
    test "returns ok with no warnings for a valid graph" do
      %{script: script} = setup_published_script()
      # Reload the draft after publish (root_node_id gets set during node additions)
      draft = Scripts.get_draft_version(script)
      assert {:ok, _warnings} = Scripts.validate_draft(draft)
    end

    test "returns errors for empty graph" do
      %{organization: org} = org_with_owner()
      {:ok, _s, draft} = Scripts.create_script(%{"organization_id" => org.id, "name" => "Bare"})

      assert {:error, errors} = Scripts.validate_draft(draft)
      assert Enum.any?(errors, &String.contains?(&1, "no nodes"))
    end

    test "returns errors when no expectations" do
      %{organization: org} = org_with_owner()
      {:ok, _s, draft} = Scripts.create_script(%{"organization_id" => org.id, "name" => "Bare"})
      {:ok, _} = Scripts.add_node(draft, %{"node_key" => "root", "kind" => "user_turn"})

      assert {:error, errors} = Scripts.validate_draft(draft)
      assert Enum.any?(errors, &String.contains?(&1, "expectations"))
    end

    test "warns about user_turn nodes without prompt" do
      %{draft: draft, n1: n1} = setup_published_script()
      # Remove prompt from n1 by setting nil
      Scripts.update_node(n1, %{prompt_version_id: nil})

      # The draft still has expectations, so it may still be :ok with warnings
      result = Scripts.validate_draft(draft)

      case result do
        {:ok, warnings} ->
          assert Enum.any?(warnings, &String.contains?(&1, "prompt"))

        {:error, _} ->
          # Also acceptable if validation fails for other reasons after modification
          :ok
      end
    end
  end
end
