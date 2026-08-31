defmodule ExLiteLLM.Anthropic.Translate do
  @moduledoc """
  Bidirectional Anthropic Messages ↔ OpenAI Chat translation for the
  `/v1/messages` endpoint — litellm's `anthropic_endpoints` adapter.

  Claude Code (and any Anthropic-SDK client) speaks the Messages API. When the
  requested model resolves to an OpenAI-family provider, the gateway translates:

    * **request** — Anthropic Messages body → OpenAI chat body (`system` field →
      system message, content blocks → OpenAI content/tool messages, `tools`
      input_schema → parameters, `stop_sequences` → `stop`).
    * **response** — OpenAI `ModelResponse` → Anthropic message (content blocks,
      `tool_calls` → `tool_use`, `finish_reason` → `stop_reason`, and crucially
      `usage.prompt_tokens/completion_tokens` → `usage.input_tokens/output_tokens`
      — Anthropic clients hard-depend on those fields).
    * **stream** — normalized provider chunks → Anthropic SSE events
      (`message_start` → `content_block_*` → `message_delta` → `message_stop`).
  """

  alias ExLiteLLM.Core.ModelResponse

  # === request: Anthropic → OpenAI ===

  @doc "Translate an Anthropic Messages request body into an OpenAI chat body."
  @spec request_to_openai(map()) :: map()
  def request_to_openai(body) do
    messages = system_messages(body["system"]) ++ translate_messages(body["messages"] || [])

    %{"model" => body["model"], "messages" => messages}
    |> copy(body, "max_tokens")
    |> copy(body, "temperature")
    |> copy(body, "top_p")
    |> copy(body, "stream")
    |> copy(body, "stop_sequences", "stop")
    |> put_tools(body["tools"])
    |> put_tool_choice(body["tool_choice"])
    |> put_reasoning_effort(body)
    |> Map.reject(fn {_k, v} -> is_nil(v) end)
  end

  defp system_messages(nil), do: []
  defp system_messages(system) when is_binary(system), do: [%{"role" => "system", "content" => system}]

  defp system_messages(blocks) when is_list(blocks) do
    text = Enum.map_join(blocks, "\n", fn
      %{"type" => "text", "text" => t} -> t
      _ -> ""
    end)

    [%{"role" => "system", "content" => text}]
  end

  defp translate_messages(messages) do
    Enum.flat_map(messages, &translate_message/1)
  end

  # A single Anthropic message can expand to several OpenAI messages (e.g. an
  # assistant turn with text + tool_use, or a user turn carrying tool_results).
  defp translate_message(%{"role" => role, "content" => content}) when is_binary(content) do
    [%{"role" => role, "content" => content}]
  end

  defp translate_message(%{"role" => "assistant", "content" => blocks}) when is_list(blocks) do
    text =
      blocks
      |> Enum.filter(&(&1["type"] == "text"))
      |> Enum.map_join("", & &1["text"])

    tool_calls =
      blocks
      |> Enum.filter(&(&1["type"] == "tool_use"))
      |> Enum.map(fn b ->
        %{
          "id" => b["id"],
          "type" => "function",
          "function" => %{"name" => b["name"], "arguments" => Jason.encode!(b["input"] || %{})}
        }
      end)

    msg = %{"role" => "assistant", "content" => (if text == "", do: nil, else: text)}
    msg = if tool_calls == [], do: msg, else: Map.put(msg, "tool_calls", tool_calls)
    [msg]
  end

  defp translate_message(%{"role" => "user", "content" => blocks}) when is_list(blocks) do
    {tool_results, rest} = Enum.split_with(blocks, &(&1["type"] == "tool_result"))

    tool_msgs =
      Enum.map(tool_results, fn tr ->
        %{
          "role" => "tool",
          "tool_call_id" => tr["tool_use_id"],
          "content" => tool_result_content(tr["content"])
        }
      end)

    user_content = user_blocks(rest)
    user_msgs = if user_content in [nil, "", []], do: [], else: [%{"role" => "user", "content" => user_content}]

    tool_msgs ++ user_msgs
  end

  defp translate_message(other), do: [other]

  defp tool_result_content(content) when is_binary(content), do: content

  defp tool_result_content(blocks) when is_list(blocks) do
    Enum.map_join(blocks, "\n", fn
      %{"type" => "text", "text" => t} -> t
      other -> Jason.encode!(other)
    end)
  end

  defp tool_result_content(other), do: Jason.encode!(other)

  # User content blocks → OpenAI content (string when all-text, else parts).
  defp user_blocks(blocks) do
    if Enum.all?(blocks, &(&1["type"] == "text")) do
      Enum.map_join(blocks, "", & &1["text"])
    else
      Enum.map(blocks, fn
        %{"type" => "text", "text" => t} ->
          %{"type" => "text", "text" => t}

        %{"type" => "image", "source" => %{"type" => "base64", "media_type" => mt, "data" => data}} ->
          %{"type" => "image_url", "image_url" => %{"url" => "data:#{mt};base64,#{data}"}}

        %{"type" => "image", "source" => %{"type" => "url", "url" => url}} ->
          %{"type" => "image_url", "image_url" => %{"url" => url}}

        other ->
          %{"type" => "text", "text" => Jason.encode!(other)}
      end)
    end
  end

  defp put_tools(body, nil), do: body

  defp put_tools(body, tools) when is_list(tools) do
    Map.put(
      body,
      "tools",
      Enum.map(tools, fn t ->
        %{
          "type" => "function",
          "function" => %{
            "name" => t["name"],
            "description" => t["description"],
            "parameters" => t["input_schema"] || %{"type" => "object", "properties" => %{}}
          }
        }
      end)
    )
  end

  defp put_tool_choice(body, nil), do: body
  defp put_tool_choice(body, %{"type" => "auto"}), do: Map.put(body, "tool_choice", "auto")
  defp put_tool_choice(body, %{"type" => "any"}), do: Map.put(body, "tool_choice", "required")

  defp put_tool_choice(body, %{"type" => "tool", "name" => name}),
    do: Map.put(body, "tool_choice", %{"type" => "function", "function" => %{"name" => name}})

  defp put_tool_choice(body, _), do: body

  # Anthropic `thinking` is not an OpenAI field. Map it onto reasoning_effort
  # so gpt-oss / similar models actually spend CoT budget. Deployment YAML
  # overwrites this later (haiku=low, opus=high).
  defp put_reasoning_effort(acc, %{"thinking" => %{"type" => t}}) when t in ["enabled", "adaptive"] do
    Map.put_new(acc, "reasoning_effort", "high")
  end

  defp put_reasoning_effort(acc, %{"thinking" => %{"type" => "disabled"}}) do
    Map.put_new(acc, "reasoning_effort", "low")
  end

  defp put_reasoning_effort(acc, _), do: acc

  defp copy(acc, body, key, as \\ nil) do
    case Map.get(body, key) do
      nil -> acc
      v -> Map.put(acc, as || key, v)
    end
  end

  # === response: ModelResponse → Anthropic message ===

  @doc "Translate a normalized OpenAI ModelResponse into an Anthropic Messages response."
  @spec response_from_model_response(ModelResponse.t(), String.t()) :: map()
  def response_from_model_response(%ModelResponse{} = r, requested_model) do
    choice = List.first(r.choices) || %{}
    message = choice_field(choice, :message) || %{}
    content_blocks = build_content_blocks(message)

    %{
      "id" => "msg_" <> (r.id || rand()),
      "type" => "message",
      "role" => "assistant",
      "model" => requested_model,
      "content" => content_blocks,
      "stop_reason" => stop_reason(choice_field(choice, :finish_reason)),
      "stop_sequence" => nil,
      "usage" => usage(r.usage)
    }
  end

  defp build_content_blocks(message) do
    text = message["content"] || message[:content]
    reasoning = message["reasoning"] || message[:reasoning] || message["reasoning_content"] || message[:reasoning_content]
    tool_calls = message["tool_calls"] || message[:tool_calls] || []

    thinking_blocks =
      if reasoning in [nil, ""], do: [], else: [%{"type" => "thinking", "thinking" => reasoning}]

    text_blocks = if text in [nil, ""], do: [], else: [%{"type" => "text", "text" => text}]

    tool_blocks =
      Enum.map(tool_calls, fn tc ->
        fun = tc["function"] || tc[:function] || %{}

        %{
          "type" => "tool_use",
          "id" => tc["id"] || tc[:id] || "toolu_" <> rand(),
          "name" => fun["name"] || fun[:name],
          "input" => decode_arguments(fun["arguments"] || fun[:arguments])
        }
      end)

    case thinking_blocks ++ text_blocks ++ tool_blocks do
      [] -> [%{"type" => "text", "text" => ""}]
      blocks -> blocks
    end
  end

  defp decode_arguments(nil), do: %{}

  defp decode_arguments(args) when is_binary(args) do
    case Jason.decode(args) do
      {:ok, map} when is_map(map) -> map
      _ -> %{}
    end
  end

  defp decode_arguments(args) when is_map(args), do: args

  @doc "Map an OpenAI finish_reason to an Anthropic stop_reason."
  @spec stop_reason(String.t() | nil) :: String.t()
  def stop_reason("stop"), do: "end_turn"
  def stop_reason("length"), do: "max_tokens"
  def stop_reason("tool_calls"), do: "tool_use"
  def stop_reason("content_filter"), do: "refusal"
  def stop_reason(nil), do: "end_turn"
  def stop_reason(other), do: other

  @doc "Map OpenAI usage → Anthropic usage (the fields Anthropic clients require)."
  @spec usage(map() | nil) :: map()
  def usage(nil), do: %{"input_tokens" => 0, "output_tokens" => 0}

  def usage(u) do
    %{
      "input_tokens" => u["prompt_tokens"] || u[:prompt_tokens] || 0,
      "output_tokens" => u["completion_tokens"] || u[:completion_tokens] || 0
    }
  end

  # === streaming: normalized chunks → Anthropic SSE events ===

  @doc """
  Build the Anthropic SSE preamble (message_start only). Content blocks are
  opened lazily by `ExLiteLLM.Anthropic.Stream` so tool-only / reasoning-only
  replies are not wrapped in an empty text block.
  """
  @spec stream_preamble(String.t()) :: [String.t()]
  def stream_preamble(model) do
    {state, frames} = ExLiteLLM.Anthropic.Stream.new(model) |> ExLiteLLM.Anthropic.Stream.preamble()
    _ = state
    frames
  end

  @doc "Translate one normalized text delta into an Anthropic content_block_delta event."
  @spec stream_text_delta(String.t()) :: String.t()
  def stream_text_delta(text), do: stream_text_delta(0, text)

  @spec stream_text_delta(non_neg_integer(), String.t()) :: String.t()
  def stream_text_delta(index, text) do
    sse("content_block_delta", %{
      "type" => "content_block_delta",
      "index" => index,
      "delta" => %{"type" => "text_delta", "text" => text}
    })
  end

  @spec stream_thinking_delta(non_neg_integer(), String.t()) :: String.t()
  def stream_thinking_delta(index, text) do
    sse("content_block_delta", %{
      "type" => "content_block_delta",
      "index" => index,
      "delta" => %{"type" => "thinking_delta", "thinking" => text}
    })
  end

  @spec stream_input_json_delta(non_neg_integer(), String.t()) :: String.t()
  def stream_input_json_delta(index, partial_json) do
    sse("content_block_delta", %{
      "type" => "content_block_delta",
      "index" => index,
      "delta" => %{"type" => "input_json_delta", "partial_json" => partial_json}
    })
  end

  @doc "Build the closing events (content_block_stop, message_delta, message_stop)."
  @spec stream_closing(String.t() | nil, map() | nil) :: [String.t()]
  def stream_closing(finish_reason, usage_map) do
    [
      sse("content_block_stop", %{"type" => "content_block_stop", "index" => 0})
      | stream_closing_after_blocks(finish_reason, usage_map)
    ]
  end

  @doc "message_delta + message_stop after content blocks have already been closed."
  @spec stream_closing_after_blocks(String.t() | nil, map() | nil) :: [String.t()]
  def stream_closing_after_blocks(finish_reason, usage_map) do
    [
      sse("message_delta", %{
        "type" => "message_delta",
        "delta" => %{"stop_reason" => stop_reason(finish_reason), "stop_sequence" => nil},
        "usage" => %{"output_tokens" => output_tokens(usage_map)}
      }),
      sse("message_stop", %{"type" => "message_stop"})
    ]
  end

  @doc "Anthropic error SSE event (used when the upstream 4xx after the stream started)."
  @spec stream_error(String.t(), String.t()) :: String.t()
  def stream_error(type, message) do
    sse("error", %{
      "type" => "error",
      "error" => %{"type" => type, "message" => message}
    })
  end

  defp output_tokens(nil), do: 0
  defp output_tokens(u), do: u["completion_tokens"] || u[:completion_tokens] || 0

  @doc "Format one Anthropic SSE frame (`event:` + `data:` lines)."
  @spec sse(String.t(), map()) :: String.t()
  def sse(event, data), do: "event: #{event}\ndata: #{Jason.encode!(data)}\n\n"

  # --- helpers ---

  defp choice_field(choice, key), do: choice[key] || choice[to_string(key)]

  defp rand, do: 12 |> :crypto.strong_rand_bytes() |> Base.url_encode64(padding: false)
end
