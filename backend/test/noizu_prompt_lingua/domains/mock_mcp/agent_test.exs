defmodule NoizuPromptLingua.Domains.MockMCP.AgentTest do
  @moduledoc """
  Agent — LLM integration for MockMCP.

  All inference runs through the direct-HTTP path: an endpoint on a local
  Bandit stub (see `NoizuPromptLingua.MockMCPStub`) bypasses the GenAI library,
  so request shaping, response parsing, the bounded internal-op loop, and every
  response-normalization branch are exercised against a controllable stub. The
  GenAI-library path (`run_genai`, no endpoint) is uncovered by design — it has
  no injectable transport and would place real provider calls on the network.
  """

  use ExUnit.Case, async: true

  alias NoizuPromptLingua.Domains.MockMCP.Agent
  alias NoizuPromptLingua.MockMCPStub

  setup do
    stub = MockMCPStub.start()
    on_exit(fn -> MockMCPStub.stop(stub) end)
    {:ok, stub: stub}
  end

  defp ep(stub, seg), do: "http://127.0.0.1:#{stub.port}/#{seg}"

  defp def_(overrides \\ %{}) do
    Map.merge(
      %{
        slug: "agt-#{System.unique_integer([:positive])}",
        prompt: "A tiny echo server.",
        tools_json: [],
        db_provisioned: false,
        db_name: nil
      },
      overrides
    )
  end

  # ── generate_surface/2 ────────────────────────────────────────────────────

  describe "generate_surface/2" do
    test "parses a full surface and normalizes fields", %{stub: stub} do
      MockMCPStub.seq(stub, "surface", [
        {:content,
         %{
           "tools" => [%{"name" => "echo"}],
           "resources" => [%{"uri" => "mock://r"}],
           "prompts" => [%{"name" => "hi"}],
           "schema" => %{
             "postgres" => ["CREATE TABLE t (id int)"],
             "weaviate" => [%{"name" => "Facts"}]
           }
         }}
      ])

      assert {:ok,
              %{
                "tools" => [%{"name" => "echo"}],
                "resources" => [%{"uri" => "mock://r"}],
                "prompts" => [%{"name" => "hi"}],
                "schema" => %{
                  "postgres" => ["CREATE TABLE t (id int)"],
                  "weaviate" => [%{"name" => "Facts"}]
                }
              }} = Agent.generate_surface("make a server", endpoint: ep(stub, "surface"))
    end

    test "coerces non-list fields and missing schema to empties", %{stub: stub} do
      MockMCPStub.seq(stub, "degraded", [
        {:content,
         %{
           "tools" => "not-a-list",
           "resources" => nil,
           "prompts" => 7,
           "schema" => "not-a-map"
         }}
      ])

      assert {:ok,
              %{
                "tools" => [],
                "resources" => [],
                "prompts" => [],
                "schema" => %{"postgres" => [], "weaviate" => []}
              }} = Agent.generate_surface("p", endpoint: ep(stub, "degraded"))
    end

    test "tolerates a bare tools array", %{stub: stub} do
      MockMCPStub.seq(stub, "baretools", [{:content, [%{"name" => "solo"}]}])

      assert {:ok, %{"tools" => [%{"name" => "solo"}], "resources" => [], "prompts" => []}} =
               Agent.generate_surface("p", endpoint: ep(stub, "baretools"))
    end

    test "strips markdown fences around the JSON", %{stub: stub} do
      MockMCPStub.seq(stub, "fenced", [
        {:text, "```json\n{\"tools\": [{\"name\": \"fenced\"}]}\n```"}
      ])

      assert {:ok, %{"tools" => [%{"name" => "fenced"}]}} =
               Agent.generate_surface("p", endpoint: ep(stub, "fenced"))
    end

    test "invalid JSON -> {:error, :invalid_surface_json, raw}", %{stub: stub} do
      MockMCPStub.seq(stub, "badjson", [{:text, "this is not json at all"}])

      assert {:error, :invalid_surface_json, raw} =
               Agent.generate_surface("p", endpoint: ep(stub, "badjson"))

      assert raw =~ "not json"
    end

    test "http failure surfaces as {:http_error, status, body}", %{stub: stub} do
      MockMCPStub.seq(stub, "boom", [{:status, 500, "kaboom"}])

      assert {:error, {:http_error, 500, "kaboom"}} =
               Agent.generate_surface("p", endpoint: ep(stub, "boom"))
    end

    test "unexpected response shape -> {:unexpected_response, _}", %{stub: stub} do
      MockMCPStub.seq(stub, "oddshape", [{:raw, Jason.encode!(%{"error" => "nope"})}])

      assert {:error, {:unexpected_response, %{"error" => "nope"}}} =
               Agent.generate_surface("p", endpoint: ep(stub, "oddshape"))
    end

    test "invalid JSON body -> {:invalid_json, _}", %{stub: stub} do
      MockMCPStub.seq(stub, "rawbad", [{:raw, "{oops"}])

      assert {:error, {:invalid_json, _}} =
               Agent.generate_surface("p", endpoint: ep(stub, "rawbad"))
    end
  end

  # ── handle_tool_call/5 ────────────────────────────────────────────────────

  describe "handle_tool_call/5" do
    test "text-shaped result", %{stub: stub} do
      MockMCPStub.seq(stub, "tooltext", [{:content, %{"type" => "text", "text" => "hi"}}])

      assert {:ok, [%{"type" => "text", "text" => "hi"}], latency, []} =
               Agent.handle_tool_call(def_(), "greet", %{"who" => "x"}, "be nice",
                 endpoint: ep(stub, "tooltext")
               )

      assert is_integer(latency) and latency >= 0
    end

    test "json-shaped result is re-encoded as text", %{stub: stub} do
      MockMCPStub.seq(stub, "tooljson", [
        {:content, %{"type" => "json", "data" => %{"a" => 1}}}
      ])

      assert {:ok, [%{"type" => "text", "text" => ~s({"a":1})}], _, _} =
               Agent.handle_tool_call(def_(), "t", %{}, "h", endpoint: ep(stub, "tooljson"))
    end

    test "bare map result is encoded; non-JSON falls through verbatim", %{stub: stub} do
      MockMCPStub.seq(stub, "toolmap", [{:content, %{"a" => 1}}])

      assert {:ok, [%{"text" => ~s({"a":1})}], _, _} =
               Agent.handle_tool_call(def_(), "t", %{}, "h", endpoint: ep(stub, "toolmap"))

      MockMCPStub.seq(stub, "toolraw", [{:text, "plain words"}])

      assert {:ok, [%{"text" => "plain words"}], _, _} =
               Agent.handle_tool_call(def_(), "t", nil, "h", endpoint: ep(stub, "toolraw"))
    end

    test "request carries prompt/tool/handler substitutions and the ops appendix", %{
      stub: stub
    } do
      MockMCPStub.seq(stub, "shape", [{:content, %{"type" => "text", "text" => "ok"}}])

      Agent.handle_tool_call(def_(), "my_tool", %{"a" => 1}, "handler text",
        endpoint: ep(stub, "shape")
      )

      {headers, body} = MockMCPStub.last_request(stub, "shape")
      assert List.keyfind(headers, "content-type", 0) == {"content-type", "application/json"}

      decoded = Jason.decode!(body)
      assert [system, user] = decoded["messages"]
      assert [%{"role" => "system"}, %{"role" => "user"}] = decoded["messages"]
      assert system["content"] =~ "You are handling the tool \"my_tool\""
      assert system["content"] =~ "handler text"
      assert system["content"] =~ "redis_get"
      assert user["content"] =~ ~s(Arguments: {"a":1})
    end

    test "LLM failure -> {:error, reason, latency, trace}", %{stub: stub} do
      MockMCPStub.seq(stub, "toolboom", [{:status, 500, "kaboom"}])

      assert {:error, {:http_error, 500, "kaboom"}, latency, []} =
               Agent.handle_tool_call(def_(), "t", %{}, "h", endpoint: ep(stub, "toolboom"))

      assert is_integer(latency)
    end
  end

  # ── bounded internal-op loop ──────────────────────────────────────────────

  describe "internal-op loop" do
    test "executes an op then finalizes; op lands on the trace", %{stub: stub} do
      d = def_()

      MockMCPStub.seq(stub, "oploop", [
        {:content, %{"op" => "redis_set", "args" => %{"key" => "k1", "value" => "v1"}}},
        {:content, %{"type" => "text", "text" => "done"}}
      ])

      assert {:ok, [%{"text" => "done"}], _, trace} =
               Agent.handle_tool_call(d, "t", %{}, "h", endpoint: ep(stub, "oploop"))

      assert [%{"op" => "redis_set", "args" => %{"key" => "k1"}, "result" => %{"ok" => true}}] =
               trace

      # The op actually hit the mock's keyspace.
      assert {:ok, "v1"} =
               NoizuPromptLingua.Domains.MockMCP.DataStore.redis_get(d, "k1")
    end

    test "failed op is recorded as a trace error and the loop continues", %{stub: stub} do
      MockMCPStub.seq(stub, "operr", [
        {:content, %{"op" => "db_query", "args" => %{"sql" => "SELECT 1"}}},
        {:text, "final"}
      ])

      assert {:ok, [%{"type" => "text", "text" => "final"}], _, trace} =
               Agent.handle_tool_call(def_(), "t", %{}, "h", endpoint: ep(stub, "operr"))

      assert [%{"op" => "db_query", "error" => err}] = trace
      assert err =~ "no database provisioned"
    end

    test "unrecognised op is treated as the final answer", %{stub: stub} do
      MockMCPStub.seq(stub, "opunk", [{:content, %{"op" => "frobnicate", "args" => %{}}}])

      assert {:ok, [%{"text" => raw}], _, []} =
               Agent.handle_tool_call(def_(), "t", %{}, "h", endpoint: ep(stub, "opunk"))

      assert %{"op" => "frobnicate", "args" => %{}} = Jason.decode!(raw)
    end

    test "an op message carrying a result \"type\" is final, not an op", %{stub: stub} do
      MockMCPStub.seq(stub, "optyped", [
        {:content, %{"op" => "redis_get", "type" => "text", "text" => "look ma, final"}}
      ])

      assert {:ok, [%{"type" => "text", "text" => "look ma, final"}], _, []} =
               Agent.handle_tool_call(def_(), "t", %{}, "h", endpoint: ep(stub, "optyped"))
    end

    test "budget exhaustion forces a final answer", %{stub: stub} do
      MockMCPStub.seq(stub, "opstorm", [
        {:content, %{"op" => "redis_keys", "args" => %{}}}
      ])

      assert {:ok, _, _, trace} =
               Agent.handle_tool_call(def_(), "t", %{}, "h", endpoint: ep(stub, "opstorm"))

      assert length(trace) == 5
    end

    test "a mid-loop LLM failure propagates with the ops already traced", %{stub: stub} do
      MockMCPStub.seq(stub, "opfail", [
        {:content, %{"op" => "redis_del", "args" => %{"key" => "gone"}}},
        {:status, 500, "kaboom"}
      ])

      assert {:error, {:http_error, 500, "kaboom"}, _, [%{"op" => "redis_del"}]} =
               Agent.handle_tool_call(def_(), "t", %{}, "h", endpoint: ep(stub, "opfail"))
    end
  end

  # ── handle_resource_read/3 ────────────────────────────────────────────────

  describe "handle_resource_read/3" do
    test "wraps the reply in an MCP contents entry", %{stub: stub} do
      MockMCPStub.seq(stub, "rsrc", [{:text, "resource body"}])

      resource = %{"uri" => "mock://notes", "mimeType" => "application/json", "handler" => "h"}

      assert {:ok,
              [
                %{
                  "uri" => "mock://notes",
                  "mimeType" => "application/json",
                  "text" => "resource body"
                }
              ], latency, []} =
               Agent.handle_resource_read(def_(), resource, endpoint: ep(stub, "rsrc"))

      assert is_integer(latency)
    end

    test "missing mimeType defaults to text/plain", %{stub: stub} do
      MockMCPStub.seq(stub, "rsrc2", [{:text, "b"}])

      assert {:ok, [%{"mimeType" => "text/plain"}], _, []} =
               Agent.handle_resource_read(def_(), %{"uri" => "mock://n", "handler" => "h"},
                 endpoint: ep(stub, "rsrc2")
               )
    end

    test "LLM failure -> {:error, reason, latency}", %{stub: stub} do
      MockMCPStub.seq(stub, "rsrcboom", [{:status, 503, "down"}])

      assert {:error, {:http_error, 503, "down"}, _, []} =
               Agent.handle_resource_read(def_(), %{"uri" => "mock://n", "handler" => "h"},
                 endpoint: ep(stub, "rsrcboom")
               )
    end
  end

  # ── handle_prompt_get/4 ───────────────────────────────────────────────────

  describe "handle_prompt_get/4" do
    test "normalizes a messages payload (string/map/junk entries)", %{stub: stub} do
      MockMCPStub.seq(stub, "pget", [
        {:content,
         %{
           "messages" => [
             %{"role" => "user", "content" => "hello"},
             %{"role" => "assistant", "content" => %{"type" => "text", "text" => "structured"}},
             %{"role" => "system", "content" => %{"weird" => true}},
             "bare string entry",
             42
           ]
         }}
      ])

      assert {:ok, messages, _, trace} =
               Agent.handle_prompt_get(def_(), %{"name" => "p", "handler" => "h"}, nil,
                 endpoint: ep(stub, "pget")
               )

      assert [
               %{"role" => "user", "content" => %{"type" => "text", "text" => "hello"}},
               %{"role" => "assistant", "content" => %{"type" => "text", "text" => "structured"}},
               %{"role" => "system", "content" => %{"weird" => true}},
               %{
                 "role" => "user",
                 "content" => %{"type" => "text", "text" => "bare string entry"}
               },
               %{"role" => "user", "content" => %{"type" => "text", "text" => "42"}}
             ] = messages

      assert trace == []
    end

    test "a bare message list (no messages key) is accepted", %{stub: stub} do
      MockMCPStub.seq(stub, "plist", [
        {:content, [%{"role" => "user", "content" => "one"}]}
      ])

      assert {:ok, [%{"role" => "user", "content" => %{"type" => "text", "text" => "one"}}], _,
              []} =
               Agent.handle_prompt_get(def_(), %{"name" => "p", "handler" => "h"}, %{"a" => 1},
                 endpoint: ep(stub, "plist")
               )
    end

    test "non-JSON reply becomes a single user message", %{stub: stub} do
      MockMCPStub.seq(stub, "praw", [{:text, "freeform"}])

      assert {:ok, [%{"role" => "user", "content" => %{"type" => "text", "text" => "freeform"}}],
              _, []} =
               Agent.handle_prompt_get(def_(), %{"name" => "p", "handler" => "h"}, %{},
                 endpoint: ep(stub, "praw")
               )
    end

    test "LLM failure -> {:error, reason, latency}", %{stub: stub} do
      MockMCPStub.seq(stub, "pboom", [{:status, 500, "kaboom"}])

      assert {:error, {:http_error, 500, "kaboom"}, _, []} =
               Agent.handle_prompt_get(def_(), %{"name" => "p", "handler" => "h"}, %{},
                 endpoint: ep(stub, "pboom")
               )
    end
  end

  # ── module generation ─────────────────────────────────────────────────────

  describe "module generation" do
    test "generate_module strips code fences", %{stub: stub} do
      MockMCPStub.seq(stub, "srcfenced", [
        {:text, "```elixir\ndefmodule X do\n  def call(_, _), do: :ok\nend\n```"}
      ])

      assert {:ok, "defmodule X do\n  def call(_, _), do: :ok\nend"} =
               Agent.generate_module("prompt", %{"name" => "t", "handler" => "h"}, X,
                 endpoint: ep(stub, "srcfenced")
               )
    end

    test "generate_module passes plain source through untouched", %{stub: stub} do
      MockMCPStub.seq(stub, "srcplain", [{:text, "defmodule Y do end"}])

      assert {:ok, "defmodule Y do end"} =
               Agent.generate_module("prompt", %{"name" => "t", "handler" => "h"}, Y,
                 endpoint: ep(stub, "srcplain")
               )
    end

    test "generate_module carries the contract + tool metadata in the request", %{stub: stub} do
      MockMCPStub.seq(stub, "srcshape", [{:text, "defmodule Z do end"}])

      Agent.generate_module(
        "server purpose",
        %{"name" => "tz", "inputSchema" => %{"type" => "object"}},
        Z, endpoint: ep(stub, "srcshape"))

      {_, body} = MockMCPStub.last_request(stub, "srcshape")
      system = Jason.decode!(body)["messages"] |> hd() |> Map.get("content")
      assert system =~ "Module name MUST be exactly: Z"
      assert system =~ "server purpose"
      assert system =~ "inputSchema:"
    end

    test "repair_module returns the corrected source", %{stub: stub} do
      MockMCPStub.seq(stub, "repair", [{:text, "defmodule W do end"}])

      assert {:ok, "defmodule W do end"} =
               Agent.repair_module("broken source", "compile blew up", W,
                 endpoint: ep(stub, "repair")
               )
    end

    test "module_tests accepts an array of samples", %{stub: stub} do
      MockMCPStub.seq(stub, "samples", [{:content, [%{"a" => 1}, %{"b" => 2}]}])

      assert {:ok, [%{"a" => 1}, %{"b" => 2}]} =
               Agent.module_tests(%{"name" => "t", "description" => "d"},
                 endpoint: ep(stub, "samples")
               )
    end

    test "module_tests wraps a single object sample", %{stub: stub} do
      MockMCPStub.seq(stub, "samplemap", [{:content, %{"a" => 1}}])

      assert {:ok, [%{"a" => 1}]} =
               Agent.module_tests(%{"name" => "t"}, endpoint: ep(stub, "samplemap"))
    end

    test "module_tests falls back to [%{}] for junk output", %{stub: stub} do
      MockMCPStub.seq(stub, "samplejunk", [{:text, "not json"}])

      assert {:ok, [%{}]} = Agent.module_tests(%{"name" => "t"}, endpoint: ep(stub, "samplejunk"))
    end

    test "module_tests propagates LLM failures", %{stub: stub} do
      MockMCPStub.seq(stub, "sampleboom", [{:status, 500, "kaboom"}])

      assert {:error, {:http_error, 500, "kaboom"}} =
               Agent.module_tests(%{"name" => "t"}, endpoint: ep(stub, "sampleboom"))
    end
  end

  # ── anthropic direct-HTTP shape ───────────────────────────────────────────

  describe "anthropic direct-HTTP provider" do
    test "request is split system/messages with x-api-key headers; reply parsed", %{stub: stub} do
      surface = Jason.encode!(%{"tools" => [], "resources" => [], "prompts" => []})

      MockMCPStub.seq(stub, "anthro", [
        {:raw, Jason.encode!(%{"content" => [%{"text" => surface}]})}
      ])

      assert {:ok, %{"tools" => [], "resources" => [], "prompts" => []}} =
               Agent.generate_surface("be an echo",
                 provider: "anthropic",
                 endpoint: ep(stub, "anthro"),
                 api_key: "sk-ant-test"
               )

      {headers, body} = MockMCPStub.last_request(stub, "anthro")
      assert {"x-api-key", "sk-ant-test"} in headers
      assert {"anthropic-version", "2023-06-01"} in headers

      decoded = Jason.decode!(body)
      assert decoded["system"] =~ "MCP server architect"
      assert [%{"role" => "user", "content" => "be an echo"}] = decoded["messages"]
      refute decoded["messages"] |> Enum.any?(&(&1["role"] == "system"))
    end

    test "unexpected anthropic shape -> {:unexpected_response, _}", %{stub: stub} do
      MockMCPStub.seq(stub, "anthroodd", [{:raw, Jason.encode!(%{"refusal" => "no"})}])

      assert {:error, {:unexpected_response, %{"refusal" => "no"}}} =
               Agent.generate_surface("p",
                 provider: "anthropic",
                 endpoint: ep(stub, "anthroodd")
               )
    end

    test "invalid anthropic JSON -> {:invalid_json, _}", %{stub: stub} do
      MockMCPStub.seq(stub, "anthrobad", [{:raw, "{nope"}])

      assert {:error, {:invalid_json, _}} =
               Agent.generate_surface("p",
                 provider: "anthropic",
                 endpoint: ep(stub, "anthrobad")
               )
    end
  end
end
