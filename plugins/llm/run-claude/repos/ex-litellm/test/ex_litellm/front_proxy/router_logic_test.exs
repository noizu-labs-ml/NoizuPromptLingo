defmodule ExLiteLLM.FrontProxy.RouterLogicTest do
  # Not async: reads the shared Rules persistent_term.
  use ExUnit.Case, async: false

  alias ExLiteLLM.FrontProxy.{RouterLogic, Rules}

  setup do
    Rules.set_mode(:passthrough)
    :ok
  end

  describe "passthrough mode routing" do
    test "OpenAI paths → litellm with master-key swap" do
      assert {url, :master_key} = RouterLogic.route("/v1/chat/completions", %{})
      # Points at the gateway's own port (LiteLLM surface is in-process).
      assert String.contains?(url, Integer.to_string(ExLiteLLM.Runtime.get().port))
    end

    test "/v1/embeddings → litellm" do
      assert {_url, :master_key} = RouterLogic.route("/v1/embeddings", %{})
    end

    test "/v1/messages with claude-* → anthropic passthrough (OAuth preserved)" do
      assert {"https://api.anthropic.com", :passthrough} =
               RouterLogic.route("/v1/messages", %{"model" => "claude-haiku-4-5"})
    end

    test "/v1/messages with a non-claude model → litellm with master-key swap" do
      assert {url, :master_key} = RouterLogic.route("/v1/messages", %{"model" => "gpt-4o"})
      refute url == "https://api.anthropic.com"
    end

    test "/v1/messages/count_tokens is NOT treated as a routable messages call" do
      # Falls through to the catch-all → anthropic passthrough.
      assert {"https://api.anthropic.com", :passthrough} =
               RouterLogic.route("/v1/messages/count_tokens", %{"model" => "gpt-4o"})
    end

    test "unknown path → anthropic passthrough" do
      assert {"https://api.anthropic.com", :passthrough} = RouterLogic.route("/v1/foo", %{})
    end
  end

  describe "standard mode routing" do
    setup do
      Rules.set_mode(:standard)
      on_exit(fn -> Rules.set_mode(:passthrough) end)
      :ok
    end

    test "everything → litellm with master-key swap" do
      assert {_url, :master_key} = RouterLogic.route("/v1/messages", %{"model" => "claude-x"})
      assert {_url, :master_key} = RouterLogic.route("/anything", %{})
    end
  end

  describe "runtime mutation" do
    test "custom rules replace the defaults" do
      rules = [%Rules.Rule{match: :any, target: {:url, "https://example.com"}, auth: :passthrough}]
      Rules.put(rules)

      assert {"https://example.com", :passthrough} = RouterLogic.route("/v1/chat/completions", %{})
      assert Rules.mode() == :custom

      Rules.set_mode(:passthrough)
    end
  end
end
