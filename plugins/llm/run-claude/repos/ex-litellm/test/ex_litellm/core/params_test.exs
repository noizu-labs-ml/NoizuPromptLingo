defmodule ExLiteLLM.Core.ParamsTest do
  use ExUnit.Case, async: true

  alias ExLiteLLM.Core.Params
  alias ExLiteLLM.Providers.{Groq, OpenAI}

  describe "optional/4 with drop_params" do
    test "OpenAI keeps standard params" do
      params = %{"model" => "gpt-4o", "messages" => [], "temperature" => 0.7, "max_tokens" => 100}
      out = Params.optional(params, OpenAI, "gpt-4o", true)

      assert out["temperature"] == 0.7
      assert out["max_tokens"] == 100
      assert out["model"] == "gpt-4o"
      assert out["messages"] == []
    end

    test "Groq drops its unsupported params when drop? is true" do
      params = %{
        "model" => "llama-3",
        "messages" => [],
        "temperature" => 0.5,
        "logit_bias" => %{"50256" => -100},
        "top_logprobs" => 5
      }

      out = Params.optional(params, Groq, "llama-3", true)

      assert out["temperature"] == 0.5
      refute Map.has_key?(out, "logit_bias")
      refute Map.has_key?(out, "top_logprobs")
    end

    test "Groq keeps unsupported params through when drop? is false" do
      params = %{"model" => "llama-3", "messages" => [], "logit_bias" => %{"1" => 1}}
      out = Params.optional(params, Groq, "llama-3", false)

      assert Map.has_key?(out, "logit_bias")
    end
  end
end
