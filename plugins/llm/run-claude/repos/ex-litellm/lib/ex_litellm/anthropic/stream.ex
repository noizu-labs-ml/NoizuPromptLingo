defmodule ExLiteLLM.Anthropic.Stream do
  @moduledoc """
  Assemble Anthropic SSE from normalized OpenAI-family chunks.

  Unlike a naive "always open a text block" translator, this starts content
  blocks lazily so:

    * Groq gpt-oss `delta.reasoning` becomes `thinking` blocks (Claude Code
      sees work instead of an empty turn).
    * `delta.tool_calls` become `tool_use` + `input_json_delta`.
    * A stream that only reasons or only calls tools does not emit a fake
      empty text block with `stop_reason=end_turn`.
  """

  alias ExLiteLLM.Anthropic.Translate

  @type block :: :none | {:text, non_neg_integer()} | {:thinking, non_neg_integer()} | {:tool, non_neg_integer()}
  @type t :: %{
          model: String.t(),
          block: block(),
          next_index: non_neg_integer(),
          finish_reason: String.t() | nil,
          usage: map() | nil,
          frames: [String.t()]
        }

  @spec new(String.t()) :: t()
  def new(model) do
    %{model: model, block: :none, next_index: 0, finish_reason: nil, usage: nil, frames: []}
  end

  @doc "message_start only — content blocks are opened when the first delta arrives."
  @spec preamble(t()) :: {t(), [String.t()]}
  def preamble(%{model: model} = state) do
    message = %{
      "id" => "msg_" <> rand(),
      "type" => "message",
      "role" => "assistant",
      "model" => model,
      "content" => [],
      "stop_reason" => nil,
      "stop_sequence" => nil,
      "usage" => %{"input_tokens" => 0, "output_tokens" => 0}
    }

    take(%{state | frames: state.frames ++ [Translate.sse("message_start", %{"type" => "message_start", "message" => message})]})
  end

  @spec push(t(), map() | :done) :: {t(), [String.t()]}
  def push(state, :done), do: take(state)

  def push(state, chunk) when is_map(chunk) do
    state
    |> put_finish(chunk)
    |> emit_reasoning(chunk_reasoning(chunk))
    |> emit_text(chunk_text(chunk))
    |> emit_tools(chunk_tools(chunk))
    |> take()
  end

  @doc "Close the open block (if any) and emit message_delta + message_stop."
  @spec close(t()) :: {t(), [String.t()]}
  def close(state) do
    state
    |> close_block()
    |> ensure_block()
    |> append(Translate.stream_closing_after_blocks(state.finish_reason, state.usage))
    |> take()
  end

  # --- emit ---

  defp emit_reasoning(state, text) when text in [nil, ""], do: state

  defp emit_reasoning(state, text) do
    state
    |> ensure({:thinking, :idx})
    |> delta(fn i -> Translate.stream_thinking_delta(i, text) end)
  end

  defp emit_text(state, text) when text in [nil, ""], do: state

  defp emit_text(state, text) do
    state
    |> ensure({:text, :idx})
    |> delta(fn i -> Translate.stream_text_delta(i, text) end)
  end

  defp emit_tools(state, nil), do: state
  defp emit_tools(state, []), do: state

  defp emit_tools(state, tool_calls) when is_list(tool_calls) do
    Enum.reduce(tool_calls, state, &emit_tool(&2, &1))
  end

  defp emit_tool(state, tc) when is_map(tc) do
    id = tc["id"] || tc[:id]
    fun = tc["function"] || tc[:function] || %{}
    name = fun["name"] || fun[:name]
    args = fun["arguments"] || fun[:arguments] || ""

    state =
      if is_binary(id) and id != "" and is_binary(name) and name != "" do
        state
        |> close_if_not(:tool)
        |> start_tool(id, name)
      else
        ensure_tool_open(state)
      end

    if is_binary(args) and args != "" do
      delta(state, fn i -> Translate.stream_input_json_delta(i, args) end)
    else
      state
    end
  end

  defp emit_tool(state, _), do: state

  defp start_tool(state, id, name) do
    i = state.next_index
    frame =
      Translate.sse("content_block_start", %{
        "type" => "content_block_start",
        "index" => i,
        "content_block" => %{"type" => "tool_use", "id" => id, "name" => name, "input" => %{}}
      })

    %{state | block: {:tool, i}, next_index: i + 1, frames: state.frames ++ [frame]}
  end

  defp ensure_tool_open(%{block: {:tool, _}} = state), do: state
  defp ensure_tool_open(state), do: state

  defp ensure(state, {kind, :idx}) do
    case state.block do
      {^kind, _} ->
        state

      _ ->
        i = state.next_index
        state = close_block(state)
        frame = start_frame(kind, i)
        %{state | block: {kind, i}, next_index: i + 1, frames: state.frames ++ [frame]}
    end
  end

  defp close_if_not(%{block: {kind, _}} = state, kind), do: state
  defp close_if_not(state, _kind), do: close_block(state)

  defp start_frame(:text, i) do
    Translate.sse("content_block_start", %{
      "type" => "content_block_start",
      "index" => i,
      "content_block" => %{"type" => "text", "text" => ""}
    })
  end

  defp start_frame(:thinking, i) do
    Translate.sse("content_block_start", %{
      "type" => "content_block_start",
      "index" => i,
      "content_block" => %{"type" => "thinking", "thinking" => ""}
    })
  end

  defp delta(%{block: {_, i}} = state, fun), do: %{state | frames: state.frames ++ [fun.(i)]}
  defp delta(state, _fun), do: state

  defp close_block(%{block: :none} = state), do: state

  defp close_block(%{block: {_, i}} = state) do
    frame = Translate.sse("content_block_stop", %{"type" => "content_block_stop", "index" => i})
    %{state | block: :none, frames: state.frames ++ [frame]}
  end

  # Anthropic clients reject a message with no content blocks.
  defp ensure_block(%{next_index: 0} = state) do
    i = 0

    start =
      Translate.sse("content_block_start", %{
        "type" => "content_block_start",
        "index" => i,
        "content_block" => %{"type" => "text", "text" => ""}
      })

    stop = Translate.sse("content_block_stop", %{"type" => "content_block_stop", "index" => i})
    %{state | next_index: 1, frames: state.frames ++ [start, stop]}
  end

  defp ensure_block(state), do: state

  defp put_finish(state, chunk) do
    %{
      state
      | finish_reason: chunk[:finish_reason] || chunk["finish_reason"] || state.finish_reason,
        usage: chunk[:usage] || chunk["usage"] || state.usage
    }
  end

  defp chunk_text(chunk), do: chunk[:text] || chunk["text"] || ""
  defp chunk_reasoning(chunk), do: chunk[:reasoning] || chunk["reasoning"] || ""
  defp chunk_tools(chunk), do: chunk[:tool_use] || chunk["tool_use"]

  defp append(state, frames), do: %{state | frames: state.frames ++ frames}

  defp take(state) do
    frames = state.frames
    {%{state | frames: []}, frames}
  end

  defp rand, do: 12 |> :crypto.strong_rand_bytes() |> Base.url_encode64(padding: false)
end
