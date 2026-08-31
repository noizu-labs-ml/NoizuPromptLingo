defmodule ExLiteLLM.Providers.GroqTest do
  use ExUnit.Case, async: true

  alias ExLiteLLM.Providers.Adapter.Request
  alias ExLiteLLM.Providers.Groq

  defp req(params, model \\ "openai/gpt-oss-20b") do
    %Request{model: model, params: params, provider: :groq}
  end

  test "gpt-oss hides reasoning, aliases max_tokens, and floors completion budget" do
    body = Groq.transform_request(req(%{"max_tokens" => 64, "messages" => []}))
    assert body["model"] == "openai/gpt-oss-20b"
    assert body["include_reasoning"] == false
    assert body["max_completion_tokens"] == 2048
    refute Map.has_key?(body, "max_tokens")
  end

  test "coerces illegal reasoning_effort values instead of forwarding a Groq 400" do
    assert %{"reasoning_effort" => "high"} =
             Groq.transform_request(req(%{"reasoning_effort" => "max", "messages" => []}))

    assert %{"reasoning_effort" => "medium"} =
             Groq.transform_request(req(%{"reasoning_effort" => "auto", "messages" => []}))

    body = Groq.transform_request(req(%{"reasoning_effort" => "nope", "messages" => []}))
    refute Map.has_key?(body, "reasoning_effort")
  end

  test "strips Claude Code pattern fields Groq rejects as invalid regex" do
    body =
      Groq.transform_request(
        req(%{
          "messages" => [],
          "tools" => [
            %{
              "type" => "function",
              "function" => %{
                "name" => "Artifact",
                "parameters" => %{
                  "type" => "object",
                  "properties" => %{
                    "after" => %{
                      "type" => "string",
                      "pattern" => "^[A-Za-z0-9_=-]{1,4096}$"
                    }
                  }
                }
              }
            }
          ]
        })
      )

    after_schema = get_in(body, ["tools", Access.at(0), "function", "parameters", "properties", "after"])
    refute Map.has_key?(after_schema, "pattern")
    assert after_schema["type"] == "string"
  end

  test "non-gpt-oss models keep max_tokens and do not force include_reasoning" do
    body =
      Groq.transform_request(
        req(%{"max_tokens" => 64, "messages" => []}, "llama-3.1-8b-instant")
      )

    assert body["max_tokens"] == 64
    refute Map.has_key?(body, "include_reasoning")
    refute Map.has_key?(body, "max_completion_tokens")
  end

  test "chunk_parser reads delta.reasoning" do
    chunk =
      ExLiteLLM.Providers.OpenAICompatible.Shared.chunk_parser(%{
        "choices" => [
          %{
            "index" => 0,
            "delta" => %{"content" => "", "reasoning" => "hmm"},
            "finish_reason" => nil
          }
        ]
      })

    assert chunk.text == ""
    assert chunk.reasoning == "hmm"
  end
end
