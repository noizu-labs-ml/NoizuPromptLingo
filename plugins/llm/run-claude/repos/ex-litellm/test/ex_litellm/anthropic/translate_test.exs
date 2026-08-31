defmodule ExLiteLLM.Anthropic.TranslateTest do
  use ExUnit.Case, async: true

  alias ExLiteLLM.Anthropic.Translate
  alias ExLiteLLM.Core.ModelResponse

  test "thinking.enabled maps to reasoning_effort high" do
    out =
      Translate.request_to_openai(%{
        "model" => "groq/opus",
        "max_tokens" => 32,
        "messages" => [%{"role" => "user", "content" => "hi"}],
        "thinking" => %{"type" => "enabled", "budget_tokens" => 128}
      })

    assert out["reasoning_effort"] == "high"
    assert out["max_tokens"] == 32
  end

  test "non-stream response puts Groq reasoning into a thinking block" do
    resp =
      ModelResponse.new(%{
        id: "x",
        choices: [
          %{
            finish_reason: "stop",
            message: %{"role" => "assistant", "content" => "pong", "reasoning" => "because"}
          }
        ],
        usage: %{"prompt_tokens" => 1, "completion_tokens" => 2}
      })

    out = Translate.response_from_model_response(resp, "groq/opus")
    assert [%{"type" => "thinking", "thinking" => "because"}, %{"type" => "text", "text" => "pong"}] =
             out["content"]
  end
end
