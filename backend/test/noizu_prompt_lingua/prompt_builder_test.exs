defmodule NoizuPromptLingua.PromptBuilderTest do
  @moduledoc """
  PromptBuilder context: key derivation, usage accumulation/budget math, and
  env-override config resolution. Not async — Hammer's shared ETS + the
  process-dict stub queue leak across async tests.
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.PromptBuilder
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.PromptBuilderConfig

  describe "key_hash/2" do
    test "deterministic, session-sensitive, truncated" do
      a = PromptBuilder.key_hash("1.2.3.4", "sess-1")
      assert a == PromptBuilder.key_hash("1.2.3.4", "sess-1")
      refute a == PromptBuilder.key_hash("1.2.3.4", "sess-2")
      refute a == PromptBuilder.key_hash("1.2.3.5", "sess-1")
      assert String.length(a) == 32
      assert PromptBuilder.key_hash("1.2.3.4", nil) == PromptBuilder.key_hash("1.2.3.4", nil)
    end
  end

  describe "usage + budget math" do
    test "today_usage/not_found then record accumulates cost + counters" do
      key = PromptBuilder.key_hash("10.0.0.1", "s")
      assert {:error, :not_found} = PromptBuilder.today_usage(key)

      :ok = PromptBuilder.record(key, tokens_in: 1000, tokens_out: 2000, cost: Decimal.new("0.20"))
      :ok = PromptBuilder.record(key, tokens_in: 500, tokens_out: 0, cost: Decimal.new("0.05"))

      assert {:ok, usage} = PromptBuilder.today_usage(key)
      assert usage.request_count == 2
      assert usage.tokens_in == 1500
      assert usage.tokens_out == 2000
      assert Decimal.eq?(usage.est_cost_usd, Decimal.new("0.25"))
      assert Decimal.eq?(PromptBuilder.today_cost(key), Decimal.new("0.25"))

      # Rejections count but add no tokens.
      :ok = PromptBuilder.record(key, rejected: true)
      assert {:ok, usage} = PromptBuilder.today_usage(key)
      assert usage.rejected_count == 1
      assert usage.request_count == 3
      assert Decimal.eq?(usage.est_cost_usd, Decimal.new("0.25"))
    end

    test "usage rows are per-key/per-day isolated" do
      k1 = PromptBuilder.key_hash("10.0.0.2", "a")
      k2 = PromptBuilder.key_hash("10.0.0.2", "b")

      :ok = PromptBuilder.record(k1, cost: Decimal.new("0.50"))
      assert Decimal.eq?(PromptBuilder.today_cost(k1), Decimal.new("0.50"))
      assert Decimal.eq?(PromptBuilder.today_cost(k2), Decimal.new(0))
    end
  end

  describe "config" do
    test "get_config returns the seeded defaults" do
      config = PromptBuilder.get_config()
      assert config.id == "default"
      assert config.enabled
      assert config.provider == "groq"
      assert config.model == "openai/gpt-oss-120b"
      assert config.requests_per_minute == 6
      assert config.tokens_per_hour == 40_000
      assert Decimal.eq?(config.daily_cost_cap_usd, Decimal.new("1.00"))
    end

    test "update_config validates thresholds" do
      assert {:ok, config} = PromptBuilder.update_config(%{"requests_per_minute" => 12})
      assert config.requests_per_minute == 12

      assert {:error, _changeset} = PromptBuilder.update_config(%{"requests_per_minute" => 0})
      assert {:error, _changeset} = PromptBuilder.update_config(%{"daily_cost_cap_usd" => "-1"})

      # The rejected updates never applied.
      assert Repo.get!(PromptBuilderConfig, "default").requests_per_minute == 12
    end
  end

  describe "budget_resets_at/0 + estimate_tokens/1" do
    test "resets at next UTC midnight" do
      resets = PromptBuilder.budget_resets_at()
      now = DateTime.utc_now()
      assert DateTime.compare(resets, now) == :gt
      assert resets.hour == 0 and resets.minute == 0
    end

    test "estimate_tokens is chars/4, min 1" do
      assert PromptBuilder.estimate_tokens("") == 1
      assert PromptBuilder.estimate_tokens("abcd") == 1
      assert PromptBuilder.estimate_tokens(String.duplicate("a", 400)) == 100
    end
  end
end
