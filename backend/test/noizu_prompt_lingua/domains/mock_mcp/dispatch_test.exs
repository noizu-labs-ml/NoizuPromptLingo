defmodule NoizuPromptLingua.Domains.MockMCP.DispatchTest do
  @moduledoc """
  Dispatch — tool-call routing (:module / :llm / {:pending, reason}) and the
  depth-guarded call_tool router. The LLM path runs against the local Bandit
  stub; the module path against a stored (fresh-atom) generated module. The
  allow_modules config toggle keeps this file async: false.
  """

  use ExUnit.Case, async: false

  alias NoizuPromptLingua.Domains.MockMCP.Dispatch
  alias NoizuPromptLingua.Domains.MockMCP.ModuleRuntime
  alias NoizuPromptLingua.MockMCPStub

  setup do
    original = Application.get_env(:noizu_prompt_lingua, :mock_mcp)

    on_exit(fn ->
      if original,
        do: Application.put_env(:noizu_prompt_lingua, :mock_mcp, original),
        else: Application.delete_env(:noizu_prompt_lingua, :mock_mcp)
    end)

    stub = MockMCPStub.start()
    on_exit(fn -> MockMCPStub.stop(stub) end)

    {:ok, stub: stub}
  end

  defp slug, do: "dsp-#{System.unique_integer([:positive])}"
  defp ep(stub, seg), do: "http://127.0.0.1:#{stub.port}/#{seg}"

  defp module_entry(mod, source, status) do
    %{
      "tool" => "ping",
      "module" => inspect(mod),
      "function" => "call",
      "source" => source,
      "status" => status,
      "last_error" => nil
    }
  end

  # ── route/2 ───────────────────────────────────────────────────────────────

  describe "route/2" do
    test "llm-implemented (or unset impl) tools route to :llm" do
      def_ = %{slug: slug(), modules_json: []}
      assert Dispatch.route(def_, %{"name" => "a", "impl" => "llm"}) == :llm
      assert Dispatch.route(def_, %{"name" => "b"}) == :llm
    end

    test "module tool with an approved entry routes to :module" do
      s = slug()

      def_ = %{
        slug: s,
        modules_json: [module_entry(ModuleRuntime.module_name(s, "ping"), ":oksrc", "approved")]
      }

      assert Dispatch.route(def_, %{"name" => "ping", "impl" => "module"}) == :module
    end

    test "module tool with atom-key module entries is still recognised" do
      s = slug()

      def_ = %{
        slug: s,
        modules_json: [%{tool: "ping", status: "approved", source: "x"}]
      }

      assert Dispatch.route(def_, %{"name" => "ping", "impl" => "module"}) == :module
    end

    test "module tool with no generated module is pending" do
      def_ = %{slug: slug(), modules_json: []}

      assert {:pending, msg} = Dispatch.route(def_, %{"name" => "ping", "impl" => "module"})
      assert msg =~ "no generated module"
    end

    test "module tool in a non-approved state is pending owner review" do
      for status <- ["draft", "error"] do
        s = slug()

        def_ = %{
          slug: s,
          modules_json: [module_entry(ModuleRuntime.module_name(s, "ping"), ":oksrc", status)]
        }

        assert {:pending, msg} = Dispatch.route(def_, %{"name" => "ping", "impl" => "module"})
        assert msg =~ "'#{status}'"
        assert msg =~ "pending owner review"
      end
    end

    test "module tools route as pending when module execution is disabled" do
      Application.put_env(:noizu_prompt_lingua, :mock_mcp, allow_modules: false)
      def_ = %{slug: slug(), modules_json: []}

      assert {:pending, msg} = Dispatch.route(def_, %{"name" => "ping", "impl" => "module"})
      assert msg =~ "module execution is disabled"
    end
  end

  # ── call_tool/4 ───────────────────────────────────────────────────────────

  describe "call_tool/4" do
    test "depth guard cuts runaway tool->tool recursion" do
      def_ = %{slug: slug(), tools_json: [], modules_json: []}

      assert {:error, "max tool-call depth (3) exceeded"} =
               Dispatch.call_tool(def_, "any", %{}, tool_depth: 4)
    end

    test "unknown tool" do
      def_ = %{slug: slug(), tools_json: [], modules_json: []}

      assert {:error, "unknown tool: nope"} = Dispatch.call_tool(def_, "nope", %{})
    end

    test "llm-routed tool is served by the agent (stubbed)", %{stub: stub} do
      MockMCPStub.seq(stub, "dspok", [{:content, %{"type" => "text", "text" => "stubbed"}}])

      def_ = %{
        slug: slug(),
        prompt: "echo server",
        tools_json: [%{"name" => "greet", "impl" => "llm", "handler" => "be warm"}],
        modules_json: []
      }

      assert {:ok, [%{"type" => "text", "text" => "stubbed"}]} =
               Dispatch.call_tool(def_, "greet", %{"who" => "x"}, endpoint: ep(stub, "dspok"))
    end

    test "llm-routed tool failure propagates the raw reason", %{stub: stub} do
      MockMCPStub.seq(stub, "dspboom", [{:status, 500, "kaboom"}])

      def_ = %{
        slug: slug(),
        prompt: "echo server",
        tools_json: [%{"name" => "greet", "impl" => "llm", "handler" => "h"}],
        modules_json: []
      }

      assert {:error, {:http_error, 500, "kaboom"}} =
               Dispatch.call_tool(def_, "greet", %{}, endpoint: ep(stub, "dspboom"))
    end

    test "pending module tool -> error with the pending reason" do
      def_ = %{
        slug: slug(),
        tools_json: [%{"name" => "ping", "impl" => "module"}],
        modules_json: []
      }

      assert {:error, msg} = Dispatch.call_tool(def_, "ping", %{})
      assert msg =~ "no generated module"
    end

    test "approved module tool is invoked for real" do
      s = slug()
      mod = ModuleRuntime.module_name(s, "ping")

      source = """
      defmodule #{inspect(mod)} do
        def call(_a, _c), do: {:ok, %{"pong" => true}}
      end
      """

      def_ = %{
        slug: s,
        prompt: "echo server",
        tools_json: [%{"name" => "ping", "impl" => "module"}],
        modules_json: [module_entry(mod, source, "approved")]
      }

      assert {:ok, [%{"type" => "text", "text" => ~s({"pong":true})}]} =
               Dispatch.call_tool(def_, "ping", %{})
    end
  end
end
