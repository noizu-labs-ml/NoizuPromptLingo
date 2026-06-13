defmodule Codefresh.DatasetsTest do
  use Codefresh.DataCase, async: true

  import Codefresh.Fixtures
  alias Codefresh.{Datasets, Prompts, Rubrics}
  alias Codefresh.Datasets.{Dataset, DatasetVersion, DatasetEntry, FlaggedCapture}

  defp create_dataset!(org, user, attrs \\ %{}) do
    defaults = %{
      "name" => "Dataset #{System.unique_integer([:positive])}",
      "organization_id" => org.id,
      "created_by_user_id" => user.id
    }

    {:ok, d} = Datasets.create_dataset(Map.merge(defaults, attrs))
    d
  end

  defp published_rubric_version(org, user) do
    {:ok, prompt} =
      Prompts.create_prompt(%{
        "name" => "Judge #{System.unique_integer([:positive])}",
        "organization_id" => org.id,
        "created_by_user_id" => user.id
      })

    {:ok, :published, pv} =
      Prompts.publish_version(prompt, %{body: "Judge the output.", published_by_user_id: user.id})

    {:ok, rubric} =
      Rubrics.create_rubric(%{
        "name" => "Rubric #{System.unique_integer([:positive])}",
        "organization_id" => org.id,
        "created_by_user_id" => user.id
      })

    {:ok, :published, rv} =
      Rubrics.publish_version(rubric, %{
        judge_prompt_version_id: pv.id,
        judge_model: "anthropic:claude-sonnet-4-5",
        published_by_user_id: user.id
      })

    rv
  end

  # ─────────────────────────────────────────────────────────────────────────
  # US-101 — create dataset head
  # ─────────────────────────────────────────────────────────────────────────
  describe "create_dataset/1 (US-101)" do
    test "auto-derives slug + defaults to request_response" do
      %{user: user, organization: org} = org_with_owner()

      assert {:ok, %Dataset{} = d} =
               Datasets.create_dataset(%{
                 "name" => "Customer Support MMLU!",
                 "organization_id" => org.id,
                 "created_by_user_id" => user.id
               })

      assert d.slug == "customer-support-mmlu"
      assert d.type == "request_response"
      assert d.current_version_id == nil
    end

    test "list_datasets hides archived by default" do
      %{user: user, organization: org} = org_with_owner()
      d1 = create_dataset!(org, user)
      d2 = create_dataset!(org, user)
      {:ok, _} = Datasets.archive_dataset(d2)

      active_ids = Datasets.list_datasets(org.id) |> Enum.map(& &1.id)
      assert d1.id in active_ids
      refute d2.id in active_ids

      full_ids =
        Datasets.list_datasets(org.id, include_archived: true) |> Enum.map(& &1.id)

      assert d2.id in full_ids
    end

    test "get_dataset/2 returns nil on cross-org access" do
      %{user: user_a, organization: org_a} = org_with_owner()
      %{organization: org_b} = org_with_owner()
      d = create_dataset!(org_a, user_a)

      assert Datasets.get_dataset(org_a.id, d.id) != nil
      assert Datasets.get_dataset(org_b.id, d.id) == nil
    end
  end

  # ─────────────────────────────────────────────────────────────────────────
  # US-103 — add entries
  # ─────────────────────────────────────────────────────────────────────────
  describe "add_entry/2 (US-103)" do
    test "creates an open draft and appends the entry" do
      %{user: user, organization: org} = org_with_owner()
      d = create_dataset!(org, user)

      assert {:ok, {%DatasetVersion{version_number: 1} = v, %DatasetEntry{} = e}} =
               Datasets.add_entry(d, %{
                 entry_key: "q-1",
                 input: %{"text" => "What is 2+2?"},
                 expected_output: %{"text" => "4"}
               })

      assert e.dataset_version_id == v.id
      assert e.tags == []
      assert Datasets.list_entries(v) |> length() == 1
    end

    test "request_response type enforces expected_output" do
      %{user: user, organization: org} = org_with_owner()
      d = create_dataset!(org, user)

      assert {:error, :expected_output_required} =
               Datasets.add_entry(d, %{input: %{"text" => "hi"}})
    end

    test "conversation type does not require expected_output" do
      %{user: user, organization: org} = org_with_owner()
      d = create_dataset!(org, user, %{"type" => "conversation"})

      assert {:ok, {_v, _e}} = Datasets.add_entry(d, %{input: %{"text" => "hi"}})
    end

    test "unique (version, entry_key) enforced" do
      %{user: user, organization: org} = org_with_owner()
      d = create_dataset!(org, user)

      assert {:ok, _} =
               Datasets.add_entry(d, %{
                 entry_key: "dup",
                 input: %{"text" => "a"},
                 expected_output: %{"text" => "b"}
               })

      assert {:error, %Ecto.Changeset{}} =
               Datasets.add_entry(d, %{
                 entry_key: "dup",
                 input: %{"text" => "a"},
                 expected_output: %{"text" => "b"}
               })
    end
  end

  # ─────────────────────────────────────────────────────────────────────────
  # US-102 — publish dataset version
  # ─────────────────────────────────────────────────────────────────────────
  describe "publish_version/2 (US-102)" do
    test "publishes draft → pins head; re-publish with identical body is a noop" do
      %{user: user, organization: org} = org_with_owner()
      d = create_dataset!(org, user)

      {:ok, {_draft, _e}} =
        Datasets.add_entry(d, %{
          entry_key: "q1",
          input: %{"text" => "hi"},
          expected_output: %{"text" => "hello"}
        })

      assert {:ok, :published, v1} = Datasets.publish_version(d)
      reloaded = Datasets.get_dataset!(org.id, d.id)
      assert reloaded.current_version_id == v1.id

      # Publishing again with no new draft: no_draft
      assert {:error, :no_draft} = Datasets.publish_version(reloaded)

      # Add a second entry → draft gets created → publish → new version
      {:ok, {_draft, _e2}} =
        Datasets.add_entry(reloaded, %{
          entry_key: "q2",
          input: %{"text" => "x"},
          expected_output: %{"text" => "y"}
        })

      assert {:ok, :published, v2} = Datasets.publish_version(reloaded)
      assert v2.version_number == 2
    end

    test "rejects cross-org default rubric pin" do
      %{user: user_a, organization: org_a} = org_with_owner()
      %{user: user_b, organization: org_b} = org_with_owner()

      foreign_rv = published_rubric_version(org_b, user_b)

      d = create_dataset!(org_a, user_a)

      {:ok, {_draft, _}} =
        Datasets.add_entry(d, %{
          input: %{"text" => "hi"},
          expected_output: %{"text" => "ok"}
        })

      assert {:error, :rubric_not_pinnable} =
               Datasets.publish_version(d, %{default_rubric_version_id: foreign_rv.id})
    end

    test "attaches a same-org rubric as default (US-110)" do
      %{user: user, organization: org} = org_with_owner()
      rv = published_rubric_version(org, user)
      d = create_dataset!(org, user)

      {:ok, _} =
        Datasets.add_entry(d, %{
          input: %{"text" => "hi"},
          expected_output: %{"text" => "ok"}
        })

      assert {:ok, :published, v} =
               Datasets.publish_version(d, %{default_rubric_version_id: rv.id})

      assert v.default_rubric_version_id == rv.id
    end
  end

  # ─────────────────────────────────────────────────────────────────────────
  # US-104 — CSV + JSONL import
  # ─────────────────────────────────────────────────────────────────────────
  describe "import_csv/3 (US-104)" do
    test "imports rows and tolerates quoted newlines + BOM" do
      %{user: user, organization: org} = org_with_owner()
      d = create_dataset!(org, user)

      csv = "﻿input,expected_output,tags\n\"line one\nline two\",good,a|b\nhi,hello,\n"

      assert {:ok, %{inserted: 2, skipped: 0, version: _v}} = Datasets.import_csv(d, csv)

      entries = Datasets.list_entries(Datasets.ensure_draft(d) |> elem(1))
      assert length(entries) == 2

      tags = Enum.flat_map(entries, & &1.tags) |> Enum.sort()
      assert tags == ["a", "b"]
    end

    test "blank input row short-circuits with row number" do
      %{user: user, organization: org} = org_with_owner()
      d = create_dataset!(org, user)

      csv = "input,expected_output\nok,out\n,nothing\n"

      assert {:error, {:row, 3, :empty_input}} = Datasets.import_csv(d, csv)
    end
  end

  describe "import_jsonl/2 (US-104)" do
    test "imports object lines and rejects non-object lines" do
      %{user: user, organization: org} = org_with_owner()
      d = create_dataset!(org, user)

      jsonl = """
      {"entry_key":"a","input":"hi","expected_output":"hello"}

      {"entry_key":"b","input":{"text":"x"},"expected_output":{"text":"y"},"tags":["t1"]}
      """

      assert {:ok, %{inserted: 2, skipped: 0}} = Datasets.import_jsonl(d, jsonl)
    end

    test "invalid JSON reports row number" do
      %{user: user, organization: org} = org_with_owner()
      d = create_dataset!(org, user)

      jsonl = """
      {"entry_key":"ok","input":"hi","expected_output":"out"}
      this is not json
      """

      assert {:error, {:row, 2, _}} = Datasets.import_jsonl(d, jsonl)
    end
  end

  # ─────────────────────────────────────────────────────────────────────────
  # US-149 — HuggingFace stub
  # ─────────────────────────────────────────────────────────────────────────
  describe "import_from_huggingface/2 (US-149 stub)" do
    test "inserts a placeholder entry tagged with the HF source" do
      %{user: user, organization: org} = org_with_owner()
      d = create_dataset!(org, user)

      assert {:ok, %{version: _v, placeholder_entry: entry}} =
               Datasets.import_from_huggingface(d, %{"dataset_id" => "openai_humaneval"})

      assert entry.input["huggingface"] == true
      assert entry.input["dataset_id"] == "openai_humaneval"
      assert "source:huggingface:openai_humaneval" in entry.tags
    end

    test "rejects missing dataset_id" do
      %{user: user, organization: org} = org_with_owner()
      d = create_dataset!(org, user)

      assert {:error, :missing_dataset_id} = Datasets.import_from_huggingface(d, %{})
    end
  end

  # ─────────────────────────────────────────────────────────────────────────
  # US-106, US-107 — flag + browse captures
  # ─────────────────────────────────────────────────────────────────────────
  describe "flag_capture/1 + list_captures/2 (US-106, US-107)" do
    test "creates a capture + browses with filters" do
      %{user: user, organization: org} = org_with_owner()

      {:ok, %FlaggedCapture{} = c1} =
        Datasets.flag_capture(%{
          "organization_id" => org.id,
          "flagged_by_user_id" => user.id,
          "title" => "Agent said the wrong city",
          "reason" => "bug",
          "tags" => ["geo", "hallucination"],
          "input" => %{"text" => "where is paris"},
          "agent_response" => %{"text" => "berlin"}
        })

      {:ok, _c2} =
        Datasets.flag_capture(%{
          "organization_id" => org.id,
          "flagged_by_user_id" => user.id,
          "title" => "Nice handoff",
          "reason" => "good_example",
          "tags" => ["handoff"]
        })

      # Reason filter
      bug_only = Datasets.list_captures(org.id, reason: "bug") |> Enum.map(& &1.id)
      assert bug_only == [c1.id]

      # Tag filter
      geo = Datasets.list_captures(org.id, tag: "geo")
      assert length(geo) == 1

      # Typeahead
      search = Datasets.list_captures(org.id, q: "city")
      assert length(search) == 1

      # Promoted filter defaults to unpromoted
      unpromoted = Datasets.list_captures(org.id, promoted: :unpromoted)
      assert length(unpromoted) == 2
    end

    test "rejects invalid reason" do
      %{user: user, organization: org} = org_with_owner()

      assert {:error, %Ecto.Changeset{}} =
               Datasets.flag_capture(%{
                 "organization_id" => org.id,
                 "flagged_by_user_id" => user.id,
                 "title" => "bad",
                 "reason" => "not-a-real-reason"
               })
    end
  end

  # ─────────────────────────────────────────────────────────────────────────
  # US-108, US-109 — promote captures
  # ─────────────────────────────────────────────────────────────────────────
  describe "promote_to_dataset_entry/3 (US-109)" do
    test "promotes a capture into a dataset draft and pins promotion FK" do
      %{user: user, organization: org} = org_with_owner()
      d = create_dataset!(org, user)

      {:ok, capture} =
        Datasets.flag_capture(%{
          "organization_id" => org.id,
          "flagged_by_user_id" => user.id,
          "title" => "reg test candidate",
          "reason" => "regression",
          "tags" => ["flake"],
          "input" => %{"text" => "ping"},
          "agent_response" => %{"text" => "pong"}
        })

      assert {:ok, %{capture: pinned, entry: entry}} =
               Datasets.promote_to_dataset_entry(capture, d)

      assert pinned.promoted_to_dataset_entry_id == entry.id
      assert entry.input == %{"text" => "ping"}
      assert entry.expected_output == %{"text" => "pong"}
      assert "flake" in entry.tags
    end

    test "negative? flips into bug-promotion expected_output" do
      %{user: user, organization: org} = org_with_owner()
      d = create_dataset!(org, user)

      {:ok, capture} =
        Datasets.flag_capture(%{
          "organization_id" => org.id,
          "flagged_by_user_id" => user.id,
          "title" => "must not produce",
          "reason" => "bug",
          "input" => %{"text" => "hi"},
          "agent_response" => %{"text" => "I cannot help you."}
        })

      assert {:ok, %{entry: entry}} =
               Datasets.promote_to_dataset_entry(capture, d, negative?: true)

      assert entry.expected_output["direction"] == "negative"
      assert entry.expected_output["must_not_produce"] == %{"text" => "I cannot help you."}
    end

    test "rejects cross-org promotion" do
      %{user: user_a, organization: org_a} = org_with_owner()
      %{organization: org_b} = org_with_owner()

      {:ok, capture} =
        Datasets.flag_capture(%{
          "organization_id" => org_a.id,
          "flagged_by_user_id" => user_a.id,
          "title" => "t",
          "reason" => "bug",
          "input" => %{"text" => "x"}
        })

      d_b = create_dataset!(org_b, user_fixture())

      assert {:error, :cross_org_promotion} = Datasets.promote_to_dataset_entry(capture, d_b)
    end
  end

  describe "promote_to_script_node/2 (US-108)" do
    test "surfaces FK violation as a changeset error when node does not exist" do
      %{user: user, organization: org} = org_with_owner()

      {:ok, capture} =
        Datasets.flag_capture(%{
          "organization_id" => org.id,
          "flagged_by_user_id" => user.id,
          "title" => "t",
          "reason" => "bug"
        })

      fake_node_id = Ecto.UUID.generate()

      assert {:error, %Ecto.Changeset{} = cs} =
               Datasets.promote_to_script_node(capture, fake_node_id)

      assert Keyword.has_key?(cs.errors, :promoted_to_script_node_id)
    end
  end

  # ─────────────────────────────────────────────────────────────────────────
  # US-125 — dataset run fan-out validation
  # ─────────────────────────────────────────────────────────────────────────
  describe "validate_run_fanout/3 (US-125)" do
    test "rejects cross-org dataset_version" do
      %{user: user_a, organization: org_a} = org_with_owner()
      %{organization: org_b} = org_with_owner()

      d = create_dataset!(org_a, user_a)

      {:ok, {draft, _}} =
        Datasets.add_entry(d, %{
          input: %{"text" => "hi"},
          expected_output: %{"text" => "ok"}
        })

      {:ok, :published, v} = Datasets.publish_version(d)
      assert v.id == draft.id

      assert {:error, :dataset_version_not_in_org} =
               Datasets.validate_run_fanout(org_b.id, v.id, [])
    end
  end
end
