defmodule ExLiteLLM.Anthropic.StreamTest do
  use ExUnit.Case, async: true

  alias ExLiteLLM.Anthropic.Stream

  test "preamble is message_start only — no empty text block" do
    {_state, frames} = "groq/opus" |> Stream.new() |> Stream.preamble()
    joined = IO.iodata_to_binary(frames)
    assert joined =~ "message_start"
    refute joined =~ "content_block_start"
  end

  test "reasoning deltas open a thinking block, text opens a separate text block" do
    {state, _} = "groq/haiku" |> Stream.new() |> Stream.preamble()

    {state, frames} =
      Stream.push(state, %{text: "", reasoning: "let me think", finish_reason: nil})

    joined = IO.iodata_to_binary(frames)
    assert joined =~ "thinking"
    assert joined =~ "thinking_delta"
    assert joined =~ "let me think"

    {state, frames} =
      Stream.push(state, %{text: "pong", reasoning: "", finish_reason: "stop", is_finished: true})

    joined = IO.iodata_to_binary(frames)
    assert joined =~ "content_block_stop"
    assert joined =~ "text_delta"
    assert joined =~ "pong"

    {_state, frames} = Stream.close(state)
    joined = IO.iodata_to_binary(frames)
    assert joined =~ "message_delta"
    assert joined =~ "end_turn"
    assert joined =~ "message_stop"
  end

  test "tool_calls become tool_use + input_json_delta" do
    {state, _} = "groq/opus" |> Stream.new() |> Stream.preamble()

    {state, frames} =
      Stream.push(state, %{
        text: "",
        tool_use: [
          %{
            "id" => "call_1",
            "type" => "function",
            "function" => %{"name" => "ping", "arguments" => "{\"x\":1}"}
          }
        ],
        finish_reason: "tool_calls"
      })

    joined = IO.iodata_to_binary(frames)
    assert joined =~ "tool_use"
    assert joined =~ "ping"
    assert joined =~ "input_json_delta"
    assert joined =~ "partial_json"

    {_state, frames} = Stream.close(state)
    assert IO.iodata_to_binary(frames) =~ "tool_use"
  end

  test "empty stream still emits a text block so Anthropic clients accept it" do
    {state, _} = "m" |> Stream.new() |> Stream.preamble()
    {_state, frames} = Stream.close(state)
    joined = IO.iodata_to_binary(frames)
    assert joined =~ "content_block_start"
    assert joined =~ "content_block_stop"
    assert joined =~ "message_stop"
  end
end
