defmodule NoizuPromptLingua.Domains.MockMCP.ModuleRuntimeTest do
  @moduledoc """
  ModuleRuntime — AST guard, compile/load, and Task-bounded invocation of
  LLM-authored tool modules.

  Tests toggle `config :noizu_prompt_lingua, :mock_mcp` (allow_modules /
  module_timeout_ms), so the file runs async: false. Generated modules get
  unique (slug, tool) names so lazy-compile paths are exercised on fresh atoms
  and loaded modules never collide across tests.
  """

  use ExUnit.Case, async: false

  alias NoizuPromptLingua.Domains.MockMCP.ModuleRuntime

  setup do
    original = Application.get_env(:noizu_prompt_lingua, :mock_mcp)

    on_exit(fn ->
      if original,
        do: Application.put_env(:noizu_prompt_lingua, :mock_mcp, original),
        else: Application.delete_env(:noizu_prompt_lingua, :mock_mcp)
    end)

    :ok
  end

  defp slug, do: "mrt-#{System.unique_integer([:positive])}"

  defp src(mod, body), do: "defmodule #{inspect(mod)} do\n#{body}\nend"

  defp call_src(mod, expr), do: src(mod, "  def call(_args, _ctx), do: #{expr}")

  # ── naming ────────────────────────────────────────────────────────────────

  describe "module_name/2" do
    test "deterministic pascal-cased name under the NplMockMCP prefix" do
      assert ModuleRuntime.module_name("team-a", "get_stats") ==
               Module.concat(["NplMockMCP", "TeamA", "GetStats"])

      assert ModuleRuntime.module_name("team-a", "get_stats") ==
               ModuleRuntime.module_name("team-a", "get_stats")
    end

    test "empty segments fall back to X" do
      assert ModuleRuntime.module_name("", "") == Module.concat(["NplMockMCP", "X", "X"])
    end
  end

  # ── guard/1 ───────────────────────────────────────────────────────────────

  describe "guard/1" do
    test "clean stdlib-only source passes" do
      source = """
      defmodule Clean do
        def call(args, _ctx), do: {:ok, Enum.map(Map.keys(args), &String.upcase(&1))}
      end
      """

      assert ModuleRuntime.guard(source) == :ok
    end

    test "forbidden alias calls are rejected" do
      body = "  def call(_a, _c), do: System.cmd(\"ls\", []) |> elem(0)"

      {:error, msg} = ModuleRuntime.guard(src(Bad, body))

      assert msg =~ "System.*"
    end

    test "the full denylist is reported, deduplicated" do
      body = """
        def call(_a, _c) do
          System.cmd("ls", [])
          File.read!("x")
          Code.eval_string("1")
          Module.concat(["X"])
          Process.whereis(:x)
          Task.async(fn -> :ok end)
          :os.cmd(~c"ls")
          :erlang.float_to_binary(1.0)
          :ets.insert(:t, {1, 2})
          :code.all_loaded()
          apply(&(&1 + 1), [1])
          spawn(fn -> :ok end)
          spawn_link(fn -> :ok end)
          spawn_monitor(fn -> :ok end)
          send(self(), :x)
          exit(:x)
          throw(:x)
          make_ref()
          node()
          nodes()
          binary_to_term(<<131, 100, 0, 1, ?x>>)
          spawn(fn -> System.cmd("ls", []) end)
          :ok
        end
      """

      {:error, msg} = ModuleRuntime.guard(src(Deny, body))

      for marker <- [
            "System.*",
            "File.*",
            "Code.*",
            "Module.*",
            "Process.*",
            "Task.*",
            ":os.*",
            ":erlang.*",
            ":ets.*",
            ":code.*",
            "apply/2",
            "spawn/1",
            "spawn_link/1",
            "spawn_monitor/1",
            "send/2",
            "exit/1",
            "throw/1",
            "make_ref/0",
            "node/0",
            "nodes/0",
            "binary_to_term/1"
          ] do
        assert msg =~ marker, "expected #{marker} in: #{msg}"
      end

      # duplicated System reference is de-duped in the message
      assert length(String.split(msg, "System.*")) == 2
    end

    test "a bare alias passed as a value is rejected" do
      {:error, msg} =
        ModuleRuntime.guard(src(AliasVal, "  def call(_a, _c), do: Process"))

      assert msg =~ "Process"
    end

    test "syntax errors are reported as guard failures" do
      {:error, msg} = ModuleRuntime.guard("def oops(")
      assert msg =~ "syntax error"
    end
  end

  # ── compile_and_load/2 ────────────────────────────────────────────────────

  describe "compile_and_load/2" do
    test "compiles and loads an exact-name module" do
      mod = Module.concat(["NplMockMCP", "Cl", "Exact"])
      assert {:ok, ^mod} = ModuleRuntime.compile_and_load(mod, call_src(mod, ~s({:ok, "x"})))
      assert Code.ensure_loaded?(mod)
    end

    test "a source defining the wrong module is rejected and purged" do
      expected = Module.concat(["NplMockMCP", "Cl", "Expected"])
      other = Module.concat(["NplMockMCP", "Cl", "Other"])

      assert {:error, msg} = ModuleRuntime.compile_and_load(expected, call_src(other, ":ok"))
      assert msg =~ "source must define module"
      assert msg =~ inspect(other)
      refute Code.ensure_loaded?(other)
    end

    test "disabled config short-circuits before the guard" do
      Application.put_env(:noizu_prompt_lingua, :mock_mcp, allow_modules: false)

      assert {:error, "module execution disabled (mock_mcp.allow_modules=false)"} =
               ModuleRuntime.compile_and_load(Nope, "garbage (")
    end

    test "compile errors surface as error strings" do
      mod = Module.concat(["NplMockMCP", "Cl", "Dup"])

      source = """
      defmodule #{inspect(mod)} do
        def call(_a, _c), do: definitely_undefined_variable + 1
      end
      """

      assert {:error, msg} = ModuleRuntime.compile_and_load(mod, source)
      assert is_binary(msg)
    end
  end

  # ── invoke/3 ──────────────────────────────────────────────────────────────

  describe "invoke/3" do
    test "binary result -> text content; gateway-shaped 4-tuple" do
      s = slug()
      mod = ModuleRuntime.module_name(s, "bintool")

      def_ = %{
        slug: s,
        modules_json: [%{"tool" => "bintool", "source" => call_src(mod, ~s({:ok, "hello"}))}]
      }

      assert {:ok, [%{"type" => "text", "text" => "hello"}], latency, [%{"impl" => "module"}]} =
               ModuleRuntime.invoke(def_, %{"name" => "bintool"}, %{})

      assert is_integer(latency) and latency >= 0
    end

    test "content shapes: typed map passes through; map/list encode; others inspect" do
      s = slug()

      def_ = %{
        slug: s,
        modules_json: [
          %{
            "tool" => "typed",
            "source" =>
              call_src(
                ModuleRuntime.module_name(s, "typed"),
                ~s({:ok, %{"type" => "json", "data" => %{"x" => 1}}})
              )
          },
          %{
            "tool" => "plainmap",
            "source" => call_src(ModuleRuntime.module_name(s, "plainmap"), ~s({:ok, %{"x" => 1}}))
          },
          %{
            "tool" => "plist",
            "source" => call_src(ModuleRuntime.module_name(s, "plist"), ~s({:ok, [%{"x" => 1}]}))
          },
          %{
            "tool" => "patom",
            "source" => call_src(ModuleRuntime.module_name(s, "patom"), ":ok")
          },
          %{
            "tool" => "pint",
            "source" => call_src(ModuleRuntime.module_name(s, "pint"), "{:ok, 42}")
          }
        ]
      }

      assert {:ok, [%{"type" => "json", "data" => %{"x" => 1}}], _, _} =
               ModuleRuntime.invoke(def_, %{"name" => "typed"}, %{})

      assert {:ok, [%{"type" => "text", "text" => ~s({"x":1})}], _, _} =
               ModuleRuntime.invoke(def_, %{"name" => "plainmap"}, %{})

      assert {:ok, [%{"type" => "text", "text" => ~s([{"x":1}])}], _, _} =
               ModuleRuntime.invoke(def_, %{"name" => "plist"}, %{})

      assert {:ok, [%{"type" => "text", "text" => ":ok"}], _, _} =
               ModuleRuntime.invoke(def_, %{"name" => "patom"}, %{})

      assert {:ok, [%{"type" => "text", "text" => "42"}], _, _} =
               ModuleRuntime.invoke(def_, %{"name" => "pint"}, %{})
    end

    test "custom entrypoint function name is honored" do
      s = slug()
      mod = ModuleRuntime.module_name(s, "fntool")

      def_ = %{
        slug: s,
        modules_json: [
          %{"tool" => "fntool", "source" => src(mod, "  def run(_a, _c), do: {:ok, \"ran\"}")}
        ]
      }

      assert {:ok, [%{"text" => "ran"}], _, _} =
               ModuleRuntime.invoke(def_, %{"name" => "fntool", "function" => "run"}, %{})
    end

    test "{:error, binary} and {:error, term} both surface as error tuples" do
      s = slug()

      def_ = %{
        slug: s,
        modules_json: [
          %{
            "tool" => "errbin",
            "source" => call_src(ModuleRuntime.module_name(s, "errbin"), ~s({:error, "nope"}))
          },
          %{
            "tool" => "errtuple",
            "source" =>
              call_src(ModuleRuntime.module_name(s, "errtuple"), ~s({:error, {:code, 7}}))
          }
        ]
      }

      assert {:error, "nope", _, [%{"impl" => "module"}]} =
               ModuleRuntime.invoke(def_, %{"name" => "errbin"}, %{})

      assert {:error, "{:code, 7}", _, _} =
               ModuleRuntime.invoke(def_, %{"name" => "errtuple"}, %{})
    end

    test "no stored module -> error" do
      def_ = %{slug: slug(), modules_json: []}

      assert {:error, "no module compiled for tool 'ghost'", _, [%{"impl" => "module"}]} =
               ModuleRuntime.invoke(def_, %{"name" => "ghost"}, %{})
    end

    test "stored source that fails the guard/compile surfaces the error" do
      s = slug()

      def_ = %{
        slug: s,
        modules_json: [%{"tool" => "bad", "source" => "def oops("}]
      }

      assert {:error, msg, _, _} = ModuleRuntime.invoke(def_, %{"name" => "bad"}, %{})
      assert msg =~ "syntax error"
    end

    test "stored forbidden source is rejected by the guard at load time" do
      s = slug()

      def_ = %{
        slug: s,
        modules_json: [
          %{
            "tool" => "sneaky",
            "source" => """
            defmodule #{inspect(ModuleRuntime.module_name(s, "sneaky"))} do
              def call(_a, _c), do: System.cmd(~c"ls", []) |> elem(0)
            end
            """
          }
        ]
      }

      assert {:error, msg, _, _} = ModuleRuntime.invoke(def_, %{"name" => "sneaky"}, %{})
      assert msg =~ "forbidden references"
    end

    test "module crash -> {:error, \"module crashed: ...\"} (trapping caller)" do
      # Task.async links the caller; only a trapping caller survives the linked
      # crash to receive the {:exit, reason} tuple. (NOTE: gateway-side processes
      # that do not trap would die with the task instead of getting this tuple.)
      Process.flag(:trap_exit, true)

      s = slug()

      def_ = %{
        slug: s,
        modules_json: [
          %{
            "tool" => "crashy",
            "source" =>
              call_src(ModuleRuntime.module_name(s, "crashy"), ~S(raise "kaboom from module"))
          }
        ]
      }

      assert {:error, msg, _, _} = ModuleRuntime.invoke(def_, %{"name" => "crashy"}, %{})
      assert msg =~ "module crashed"
      assert msg =~ "kaboom from module"
    end

    test "module timeout is enforced via Task.yield" do
      Application.put_env(:noizu_prompt_lingua, :mock_mcp,
        allow_modules: true,
        module_timeout_ms: 50
      )

      s = slug()

      def_ = %{
        slug: s,
        modules_json: [
          %{
            "tool" => "slow",
            "source" => call_src(ModuleRuntime.module_name(s, "slow"), ":timer.sleep(5_000)")
          }
        ]
      }

      assert {:error, "module call timed out after 50ms", _, _} =
               ModuleRuntime.invoke(def_, %{"name" => "slow"}, %{})
    end
  end

  # ── ctx helper closures ───────────────────────────────────────────────────

  describe "build_ctx closures" do
    test "redis works, undesigned db/weaviate/call_tool surface errors" do
      s = slug()
      mod = ModuleRuntime.module_name(s, "ctxuser")
      key = "rk-#{System.unique_integer([:positive])}"

      source = """
      defmodule #{inspect(mod)} do
        def call(args, ctx) do
          ctx.redis_set.(args["key"], "v1")
          {:ok, v} = ctx.redis_get.(args["key"])
          ctx.redis_del.(args["key"])
          {:ok,
           %{
             "redis" => v,
             "db" => ctx.db_query.("SELECT 1"),
             "dbx" => ctx.db_execute.("CREATE TABLE t (id int)"),
             "wv" => ctx.weaviate_add.("nope", "text"),
             "wq" => ctx.weaviate_query.("nope", "q"),
             "ct" => ctx.call_tool.("ghost", %{})
           }}
        end
      end
      """

      def_ = %{
        slug: s,
        tools_json: [],
        modules_json: [%{"tool" => "ctxuser", "source" => source}]
      }

      assert {:ok, [%{"type" => "text", "text" => raw}], _, _} =
               ModuleRuntime.invoke(def_, %{"name" => "ctxuser"}, %{"key" => key})

      out = Jason.decode!(raw)
      assert out["redis"] == "v1"
      assert out["db"] =~ "no database provisioned"
      assert out["dbx"] =~ "no database provisioned"
      assert out["wv"] =~ "unknown collection 'nope'"
      assert out["wq"] =~ "unknown collection 'nope'"
      assert out["ct"] =~ "unknown tool: ghost"
    end
  end
end
