defmodule ExLiteLLM.Providers.AnthropicTest do
  use ExUnit.Case, async: true

  alias ExLiteLLM.Providers.Adapter.Request
  alias ExLiteLLM.Providers.Anthropic

  describe "transform_request/1" do
    test "hoists system message to top-level system field" do
      req = %Request{
        model: "claude-haiku-4-5",
        messages: [
          %{"role" => "system", "content" => "You are terse."},
          %{"role" => "user", "content" => "hi"}
        ],
        params: %{"max_tokens" => 10}
      }

      body = Anthropic.transform_request(req)

      assert body["system"] == "You are terse."
      assert [%{"role" => "user", "content" => "hi"}] = body["messages"]
      assert body["max_tokens"] == 10
    end

    test "supplies a default max_tokens when absent (Anthropic requires it)" do
      req = %Request{model: "claude", messages: [%{"role" => "user", "content" => "x"}], params: %{}}
      body = Anthropic.transform_request(req)
      assert is_integer(body["max_tokens"])
    end

    test "maps stop → stop_sequences and translates tools" do
      req = %Request{
        model: "claude",
        messages: [%{"role" => "user", "content" => "x"}],
        params: %{
          "max_tokens" => 5,
          "stop" => ["END"],
          "tools" => [
            %{"function" => %{"name" => "get_weather", "description" => "w", "parameters" => %{"type" => "object"}}}
          ]
        }
      }

      body = Anthropic.transform_request(req)

      assert body["stop_sequences"] == ["END"]
      assert [%{"name" => "get_weather", "input_schema" => %{"type" => "object"}}] = body["tools"]
    end
  end

  describe "transform_response/2" do
    test "flattens text content blocks into an OpenAI message" do
      raw = %{
        "id" => "msg_1",
        "model" => "claude-haiku-4-5",
        "stop_reason" => "end_turn",
        "content" => [%{"type" => "text", "text" => "PONG"}],
        "usage" => %{"input_tokens" => 5, "output_tokens" => 2}
      }

      resp = Anthropic.transform_response(raw, %Request{model: "claude"})

      assert [%{message: %{"content" => "PONG", "role" => "assistant"}, finish_reason: "stop"}] =
               resp.choices

      assert resp.usage.prompt_tokens == 5
      assert resp.usage.completion_tokens == 2
      assert resp.usage.total_tokens == 7
    end

    test "maps tool_use blocks to OpenAI tool_calls and stop_reason tool_use → tool_calls" do
      raw = %{
        "id" => "msg_2",
        "stop_reason" => "tool_use",
        "content" => [
          %{"type" => "tool_use", "id" => "t1", "name" => "get_weather", "input" => %{"city" => "SF"}}
        ]
      }

      resp = Anthropic.transform_response(raw, %Request{model: "claude"})
      [choice] = resp.choices

      assert choice.finish_reason == "tool_calls"
      assert [%{"id" => "t1", "type" => "function", "function" => %{"name" => "get_weather"}}] =
               choice.message["tool_calls"]
    end
  end

  describe "chunk_parser/1" do
    test "content_block_delta → text chunk" do
      chunk =
        Anthropic.chunk_parser(%{
          "type" => "content_block_delta",
          "index" => 0,
          "delta" => %{"type" => "text_delta", "text" => "hi"}
        })

      assert chunk.text == "hi"
      refute chunk.is_finished
    end

    test "message_delta → finish with mapped stop reason" do
      chunk =
        Anthropic.chunk_parser(%{
          "type" => "message_delta",
          "delta" => %{"stop_reason" => "end_turn"},
          "usage" => %{"input_tokens" => 1, "output_tokens" => 3}
        })

      assert chunk.is_finished
      assert chunk.finish_reason == "stop"
      assert chunk.usage.completion_tokens == 3
    end

    test "message_stop → :done" do
      assert :done = Anthropic.chunk_parser(%{"type" => "message_stop"})
    end
  end
end
