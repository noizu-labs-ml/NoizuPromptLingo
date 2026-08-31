defmodule ExLiteLLM.Core.ProviderTest do
  use ExUnit.Case, async: true

  alias ExLiteLLM.Core.Provider

  describe "resolve/2 — explicit prefix" do
    test "anthropic/claude-… → anthropic + bare model" do
      assert {:ok, :anthropic, "claude-3-5-sonnet", ExLiteLLM.Providers.Anthropic} =
               Provider.resolve("anthropic/claude-3-5-sonnet")
    end

    test "openai/gpt-4o → openai + bare model" do
      assert {:ok, :openai, "gpt-4o", ExLiteLLM.Providers.OpenAI} =
               Provider.resolve("openai/gpt-4o")
    end

    test "groq/llama-3 → groq" do
      assert {:ok, :groq, "llama-3", ExLiteLLM.Providers.Groq} =
               Provider.resolve("groq/llama-3")
    end
  end

  describe "resolve/2 — bare-model pattern" do
    test "claude-3-5-sonnet-20241022 → anthropic" do
      assert {:ok, :anthropic, "claude-3-5-sonnet-20241022", _} =
               Provider.resolve("claude-3-5-sonnet-20241022")
    end

    test "gpt-4o → openai" do
      assert {:ok, :openai, "gpt-4o", _} = Provider.resolve("gpt-4o")
    end

    test "o3-mini → openai" do
      assert {:ok, :openai, "o3-mini", _} = Provider.resolve("o3-mini")
    end
  end

  describe "resolve/2 — api_base endpoint match" do
    test "groq api_base pins provider even for a bare model name" do
      assert {:ok, :groq, "some-model", _} =
               Provider.resolve("some-model", %{"api_base" => "https://api.groq.com/openai/v1"})
    end
  end

  describe "resolve/2 — default" do
    test "unknown bare model falls back to openai_compatible" do
      assert {:ok, :openai_compatible, "mystery-model", ExLiteLLM.Providers.OpenAI} =
               Provider.resolve("mystery-model")
    end
  end
end
