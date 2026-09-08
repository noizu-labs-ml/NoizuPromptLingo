defmodule NoizuPromptLingua.PromptBuilder.ShowcaseTest do
  @moduledoc """
  Showcase pipeline against the Stub generator: rewrite → dual execute → judge
  (scripted JSON verdict), budget isolation (system key), once-only
  processing, and failure recording.
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.PromptBuilder.Showcase
  alias NoizuPromptLingua.PromptBuilder
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{PromptLog, PromptBuilderConfig}

  @npl_rewrite "⌜NPL@1.0⌝\n:persona: \"Reviewer\"\n:syntax\n@directive: review code\n⌞NPL@1.0⌟"
  @verdict ~s({"original": {"structure": 12, "clarity": 14, "completeness": 15, "conventions": 10, "fitness": 14, "total": 65}, "npl": {"structure": 22, "clarity": 20, "completeness": 21, "conventions": 24, "fitness": 19, "total": 106}, "winner": "npl", "analysis": "The NPL rewrite added explicit structure and directives; it won on structure and conventions."})

  setup do
    on_exit(fn -> Process.delete(:pb_stub_replies) end)

    # The Stub's fallback reply (echo) IS a valid NPL prompt, so the rewrite
    # arm works unscripted; execute arms need plain text replies scripted.
    :ok
  end

  defp seed_log(attrs \\ %{}) do
    %PromptLog{}
    |> PromptLog.changeset(Map.merge(%{key_hash: "k" <> Ecto.UUID.generate(), description: "A prompt for a code reviewer agent", prompt: "⌜NPL@1.0⌝ built ⌞NPL@1.0⌟"}, attrs))
    |> Repo.insert!()
  end

  test "process_log runs the full pipeline and records an entry" do
    log = seed_log()
    # Call order: rewrite, exec-original, exec-npl, judge.
    queue([{:text, @npl_rewrite}, {:text, "I can help you get started — let's begin with your goals."}, {:text, "I am a code reviewer; send code and I will review it."}, {:text, @verdict}])

    assert :processed = Showcase.process_log(log)

    [entry] = Repo.all(NoizuPromptLingua.Schema.ShowcaseEntry)
    assert entry.log_id == log.id
    assert entry.original_prompt == log.description
    assert entry.npl_prompt =~ "⌜NPL@1.0⌝"
    assert entry.score_original == 65
    assert entry.score_npl == 106
    assert entry.winner == "npl"
    assert entry.ctx_original_chars == String.length(log.description)
    assert entry.ctx_npl_tokens > 0
    assert entry.rubric["original"]["total"] == 65
    assert entry.difference_analysis =~ "NPL rewrite"
    assert is_nil(entry.error)

    # processed once — log no longer pending
    assert Showcase.pending_count() == 0
  end

  test "process_batch claims pending logs and skips already-claimed ones" do
    seed_log()
    queue([{:text, @npl_rewrite}, {:text, "out-o"}, {:text, "out-n"}, {:text, @verdict}])

    assert {:ok, %{processed: 1, failed: 0}} = Showcase.process_batch(5)
    # Second batch: nothing pending.
    assert {:ok, %{processed: 0, failed: 0}} = Showcase.process_batch(5)
  end

  test "failures are recorded with the error and the log is marked failed" do
    log = seed_log()
    # rewrite fails (transport error) — pipeline records the failure entry.
    queue([{:error, :timeout}])

    assert :failed = Showcase.process_log(log)

    [entry] = Repo.all(NoizuPromptLingua.Schema.ShowcaseEntry)
    assert entry.error =~ "timeout"
    assert entry.original_prompt == log.description
    assert Repo.reload!(log).showcase_status == "failed"

    # Gallery hides failed entries.
    assert Showcase.list_entries() == []
  end

  test "showcase runs bill the SYSTEM key, not the user's key" do
    user_key = PromptBuilder.key_hash("1.2.3.4", "user-sess")
    log = seed_log(%{key_hash: user_key})
    queue([{:text, @npl_rewrite}, {:text, "out-o"}, {:text, "out-n"}, {:text, @verdict}])

    :processed = Showcase.process_log(log)

    # Showcase billed ONLY the system key — the user key has no usage row.
    assert {:ok, _} = PromptBuilder.today_usage("system_showcase")
    assert {:error, :not_found} = PromptBuilder.today_usage(user_key)
  end

  test "system budget cap stops the batch (skipped, not failed)" do
    seed_log()
    :ok = PromptBuilder.record("system_showcase", cost: Decimal.new("5.00"))

    Repo.get!(PromptBuilderConfig, "default")
    |> Ecto.Changeset.change(showcase_daily_cost_cap_usd: Decimal.new("5.00"))
    |> Repo.update!()

    # Cap reached before any model call — no stub replies queued on purpose.
    assert {:ok, %{processed: 0, failed: 0, skipped: 1}} = Showcase.process_batch(1)
    assert Showcase.pending_count() == 1
  end

  test "list_entries returns successful entries newest-first" do
    log = seed_log()
    queue([{:text, @npl_rewrite}, {:text, "out-o"}, {:text, "out-n"}, {:text, @verdict}])
    :processed = Showcase.process_log(log)

    assert [%NoizuPromptLingua.Schema.ShowcaseEntry{}] = Showcase.list_entries()
  end

  test "empty rewrite (reasoning-model quirk) retries once, then succeeds" do
    log = seed_log()
    # 1st rewrite empty → retry rewrite OK → exec-o → exec-n → judge.
    queue([{:text, ""}, {:text, @npl_rewrite}, {:text, "out-o"}, {:text, "out-n"}, {:text, @verdict}])

    assert :processed = Showcase.process_log(log)
    [entry] = Repo.all(NoizuPromptLingua.Schema.ShowcaseEntry)
    assert is_nil(entry.error)
    assert entry.npl_prompt =~ "⌜NPL@1.0⌝"
  end

  defp queue(replies), do: Process.put(:pb_stub_replies, replies)
end
