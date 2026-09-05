defmodule NoizuPromptLingua.Domains.MockMCP.ModuleForgeTest do
  @moduledoc """
  ModuleForge — the generate → guard → compile → test → repair loop for
  module-implemented tools, plus the review lifecycle (update_source / approve /
  test_module) and the dev disk write.

  LLM generation/repair/sampling runs against the local Bandit stub; response
  SEQUENCES drive each loop turn (junk source → repair → good source). Config
  toggles (allow_modules / modules_dir) keep the file async: false.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.MockMCP
  alias NoizuPromptLingua.Domains.MockMCP.ModuleForge
  alias NoizuPromptLingua.Domains.MockMCP.ModuleRuntime
  alias NoizuPromptLingua.MockMCPStub
  alias NoizuPromptLingua.Repo

  setup do
    stub = MockMCPStub.start()
    on_exit(fn -> MockMCPStub.stop(stub) end)

    original_env = Application.get_env(:noizu_prompt_lingua, :mock_mcp)

    on_exit(fn ->
      if original_env,
        do: Application.put_env(:noizu_prompt_lingua, :mock_mcp, original_env),
        else: Application.delete_env(:noizu_prompt_lingua, :mock_mcp)
    end)

    {:ok, stub: stub}
  end

  defp ep(stub, seg), do: "http://127.0.0.1:#{stub.port}/#{seg}"

  defp insert_org(prefix) do
    %{rows: [[raw_id]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["#{prefix}-#{System.unique_integer([:positive])}", "Forge Org"]
      )

    Ecto.UUID.load!(raw_id)
  end

  defp create_def(opts \\ []) do
    module_tool? = Keyword.get(opts, :module_tool?, true)

    tools =
      if module_tool?,
        do: [%{"name" => "ping", "impl" => "module", "description" => "p", "inputSchema" => %{}}],
        else: [%{"name" => "soft", "impl" => "llm", "handler" => "h"}]

    {:ok, def_} =
      MockMCP.create(%{
        organization_id: insert_org("forge"),
        slug: "forge-#{System.unique_integer([:positive])}",
        title: "Forge",
        prompt: "a forge mock"
      })

    {:ok, def_} = MockMCP.update(def_.id, %{tools_json: tools})
    MockMCP.get(def_.id)
  end

  defp good_source(def_, tool \\ "ping") do
    mod = ModuleRuntime.module_name(def_.slug, tool)

    """
    defmodule #{inspect(mod)} do
      def call(_args, _ctx), do: {:ok, %{"ok" => true}}
    end
    """
  end

  defp crashy_source(def_, tool \\ "ping") do
    mod = ModuleRuntime.module_name(def_.slug, tool)

    """
    defmodule #{inspect(mod)} do
      def call(_args, _ctx), do: {:error, "crashed on sample"}
    end
    """
  end

  @junk_source "defModule oops("

  # The repair loop / review lifecycle deliberately recompiles the same module
  # name, which the compiler warns about; silence exactly that warning for the
  # duration of the call.
  defp quiet(fun) do
    Code.compiler_options(ignore_module_conflict: true)

    try do
      fun.()
    after
      Code.compiler_options(ignore_module_conflict: false)
    end
  end

  # ── forge/2 ───────────────────────────────────────────────────────────────

  describe "forge/2" do
    test "modules disabled -> {:error, :modules_disabled}" do
      Application.put_env(:noizu_prompt_lingua, :mock_mcp, allow_modules: false)

      assert {:error, :modules_disabled} = ModuleForge.forge(create_def())
    end

    test "no module tools -> empty entries persisted" do
      def_ = create_def(module_tool?: false)

      assert {:ok, %{modules: []}} = ModuleForge.forge(def_)
      assert MockMCP.get(def_.id).modules_json == []
    end

    test "happy path: generated source compiles and passes its test -> draft", %{stub: stub} do
      def_ = create_def()

      MockMCPStub.seq(stub, "gen", [
        {:text, good_source(def_)},
        {:content, [%{"x" => 1}]}
      ])

      assert {:ok, %{modules: [%{"tool" => "ping", "status" => "draft", "source" => src}]}} =
               ModuleForge.forge(def_, endpoint: ep(stub, "gen"))

      assert src =~ "def call"

      [entry] = MockMCP.get(def_.id).modules_json
      assert entry["status"] == "draft"
    end

    test "compile failure triggers one repair round -> draft", %{stub: stub} do
      def_ = create_def()

      MockMCPStub.seq(stub, "gen", [
        {:text, @junk_source},
        {:text, good_source(def_)},
        {:content, [%{}]}
      ])

      assert {:ok, %{modules: [%{"status" => "draft"}]}} =
               ModuleForge.forge(def_, endpoint: ep(stub, "gen"))
    end

    test "test-pass failure (hard error) triggers repair -> draft", %{stub: stub} do
      def_ = create_def()

      MockMCPStub.seq(stub, "gen", [
        {:text, crashy_source(def_)},
        {:content, [%{}]},
        {:text, good_source(def_)},
        {:content, [%{}]}
      ])

      assert {:ok, %{modules: [%{"status" => "draft"}]}} =
               quiet(fn -> ModuleForge.forge(def_, endpoint: ep(stub, "gen")) end)
    end

    test "unrepairable source exhausts the attempt budget -> error entry", %{stub: stub} do
      def_ = create_def()
      MockMCPStub.seq(stub, "gen", [{:text, @junk_source}])

      assert {:ok, %{modules: [%{"status" => "error", "last_error" => err}]}} =
               ModuleForge.forge(def_, endpoint: ep(stub, "gen"))

      assert err =~ "exceeded 5 attempts"
    end

    test "generation failure -> error entry carrying the reason", %{stub: stub} do
      def_ = create_def()
      MockMCPStub.seq(stub, "gen", [{:status, 500, "kaboom"}])

      assert {:ok, %{modules: [%{"status" => "error", "source" => "", "last_error" => err}]}} =
               ModuleForge.forge(def_, endpoint: ep(stub, "gen"))

      assert err =~ "generation failed"
    end

    test "built sources are written to modules_dir when configured", %{stub: stub} do
      def_ = create_def()
      dir = Path.join(System.tmp_dir!(), "forge-disk-#{System.unique_integer([:positive])}")

      Application.put_env(:noizu_prompt_lingua, :mock_mcp,
        allow_modules: true,
        modules_dir: dir
      )

      on_exit(fn -> File.rm_rf(dir) end)

      MockMCPStub.seq(stub, "gen", [
        {:text, good_source(def_)},
        {:content, [%{}]}
      ])

      assert {:ok, %{modules: [%{"status" => "draft"}]}} =
               ModuleForge.forge(def_, endpoint: ep(stub, "gen"))

      assert File.read!(Path.join([dir, def_.slug, "ping.ex"])) =~ "def call"
    end
  end

  # ── update_source/4 ───────────────────────────────────────────────────────

  describe "update_source/4" do
    test "valid owner source is stored as a draft", %{stub: _stub} do
      def_ = create_def()

      assert {:ok, %{"tool" => "ping", "status" => "draft"}} =
               ModuleForge.update_source(def_, "ping", good_source(def_))

      [entry] = MockMCP.get(def_.id).modules_json
      assert entry["status"] == "draft"
    end

    test "garbage source is stored as an error entry (edits are never lost)" do
      def_ = create_def()

      assert {:error, err, %{"status" => "error", "last_error" => err}} =
               ModuleForge.update_source(def_, "ping", @junk_source)

      assert err =~ "syntax error"

      [entry] = MockMCP.get(def_.id).modules_json
      assert entry["source"] == @junk_source
    end

    test "when modules are disabled the source is still persisted (as error)" do
      def_ = create_def()

      Application.put_env(:noizu_prompt_lingua, :mock_mcp, allow_modules: false)

      assert {:error, err, %{"status" => "error"}} =
               ModuleForge.update_source(def_, "ping", good_source(def_))

      assert err =~ "module execution disabled"
    end
  end

  # ── approve/2 ─────────────────────────────────────────────────────────────

  describe "approve/2" do
    test "unknown module -> {:error, :not_found}" do
      assert {:error, :not_found} = ModuleForge.approve(create_def(), "ping")
    end

    test "draft compiles again and flips to approved" do
      def_ = create_def()
      ModuleForge.update_source(def_, "ping", good_source(def_))
      def_ = MockMCP.get(def_.id)

      assert {:ok, %{"status" => "approved", "last_error" => nil}} =
               quiet(fn -> ModuleForge.approve(def_, "ping") end)

      assert MockMCP.get(def_.id).modules_json |> hd() |> Map.get("status") == "approved"
    end

    test "approve re-compiles: broken stored source stays rejected" do
      def_ = create_def()
      {:error, _err, _entry} = ModuleForge.update_source(def_, "ping", @junk_source)
      def_ = MockMCP.get(def_.id)

      assert {:error, err} = ModuleForge.approve(def_, "ping")
      assert err =~ "syntax error"
    end
  end

  # ── test_module/3 ─────────────────────────────────────────────────────────

  describe "test_module/3" do
    test "unknown tool -> {:error, :not_found}", %{stub: _stub} do
      assert {:error, :not_found} = ModuleForge.test_module(create_def(), "ghost")
    end

    test "tool without a generated module -> {:error, :not_found}" do
      assert {:error, :not_found} = ModuleForge.test_module(create_def(), "ping")
    end

    test "runs the stored module over agent-generated samples", %{stub: stub} do
      def_ = create_def()
      ModuleForge.update_source(def_, "ping", good_source(def_))
      def_ = MockMCP.get(def_.id)

      MockMCPStub.seq(stub, "gen", [{:content, [%{"a" => 1}, %{"b" => 2}]}])

      assert {:ok, results} =
               quiet(fn -> ModuleForge.test_module(def_, "ping", endpoint: ep(stub, "gen")) end)

      assert length(results) == 2

      assert Enum.all?(
               results,
               &(&1["result"] == %{
                   "ok" => true,
                   "content" => [%{"type" => "text", "text" => ~s({"ok":true})}]
                 })
             )
    end

    test "sample failures are reported per-sample without blocking", %{stub: stub} do
      def_ = create_def()
      ModuleForge.update_source(def_, "ping", crashy_source(def_))
      def_ = MockMCP.get(def_.id)

      MockMCPStub.seq(stub, "gen", [{:content, [%{}]}])

      assert {:ok, [%{"result" => %{"ok" => false, "error" => err}}]} =
               quiet(fn -> ModuleForge.test_module(def_, "ping", endpoint: ep(stub, "gen")) end)

      assert err =~ "crashed on sample"
    end

    test "when the sampler itself fails -> {:error, reason}", %{stub: stub} do
      def_ = create_def()
      ModuleForge.update_source(def_, "ping", good_source(def_))
      def_ = MockMCP.get(def_.id)

      MockMCPStub.seq(stub, "gen", [{:status, 500, "kaboom"}])

      assert {:error, {:http_error, 500, "kaboom"}} =
               quiet(fn -> ModuleForge.test_module(def_, "ping", endpoint: ep(stub, "gen")) end)
    end
  end
end
