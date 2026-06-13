defmodule Noizu.MCP.Transport.SSETest do
  use ExUnit.Case, async: true

  alias Noizu.MCP.Transport.SSE

  describe "encode/2" do
    test "data only" do
      assert IO.iodata_to_binary(SSE.encode("hello")) == "data: hello\n\n"
    end

    test "with id and event" do
      encoded = IO.iodata_to_binary(SSE.encode("x", id: "s:1", event: "message", retry: 500))
      assert encoded == "id: s:1\nevent: message\nretry: 500\ndata: x\n\n"
    end

    test "multi-line data" do
      assert IO.iodata_to_binary(SSE.encode("a\nb")) == "data: a\ndata: b\n\n"
    end
  end

  describe "parse/2" do
    test "single event" do
      assert {[%SSE.Event{data: "hello", id: nil}], ""} = SSE.parse("", "data: hello\n\n")
    end

    test "partial chunks buffer until terminator" do
      {events, buffer} = SSE.parse("", "data: hel")
      assert events == []
      assert buffer == "data: hel"

      assert {[%SSE.Event{data: "hello"}], ""} = SSE.parse(buffer, "lo\n\n")
    end

    test "multiple events in one chunk" do
      chunk = "id: 1\ndata: a\n\nid: 2\ndata: b\n\ndata: c"
      {events, buffer} = SSE.parse("", chunk)

      assert [%{id: "1", data: "a"}, %{id: "2", data: "b"}] = events
      assert buffer == "data: c"
    end

    test "multi-line data joins with newline" do
      assert {[%SSE.Event{data: "a\nb"}], ""} = SSE.parse("", "data: a\ndata: b\n\n")
    end

    test "comments and unknown fields are ignored" do
      assert {[%SSE.Event{data: "x", retry: 1000}], ""} =
               SSE.parse("", ": keepalive\nfoo: bar\nretry: 1000\ndata: x\n\n")
    end

    test "crlf line endings" do
      assert {[%SSE.Event{data: "x", id: "7"}], ""} = SSE.parse("", "id: 7\r\ndata: x\r\n\r\n")
    end

    test "blocks without data are dropped" do
      assert {[], ""} = SSE.parse("", ": just a comment\n\n")
    end
  end
end
