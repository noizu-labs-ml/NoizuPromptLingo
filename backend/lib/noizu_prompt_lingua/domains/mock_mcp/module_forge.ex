defmodule NoizuPromptLingua.Domains.MockMCP.ModuleForge do
  @moduledoc """
  Builds runtime module implementations for a mock MCP's deterministic tools
  (those with `"impl" => "module"`). For each such tool:

    1. the agent generates Elixir source (`Agent.generate_module/4`);
    2. `ModuleRuntime.guard/1` + `compile_and_load/2` validate + load it;
    3. a test pass invokes the module with agent-generated sample args;
    4. on a compile error / crash / timeout, the agent repairs the source and we
       retry — bounded by `@max_attempts`.

  Successful `{tool, module, function, source}` records are persisted to
  `mock_mcp_definitions.modules_json` (the source of truth). In dev, when
  `config :noizu_prompt_lingua, :mock_mcp, modules_dir: <path>` is set, the
  source is also written to `<path>/<slug>/<tool>.ex` for inspection/VCS.
  """
  require Logger

  alias NoizuPromptLingua.Domains.MockMCP
  alias NoizuPromptLingua.Domains.MockMCP.{Agent, ModuleRuntime}

  @max_attempts 5

  @doc """
  Forge + persist DRAFT modules for every `impl: "module"` tool on `def_`. Each
  is auto-repaired to compile + pass its test, but stored with `status: "draft"`
  (or `"error"`) — nothing serves until the owner approves it (`approve/2`).
  Returns `{:ok, %{modules: [entry]}}` or `{:error, :modules_disabled}`.
  """
  def forge(def_, opts \\ []) do
    if ModuleRuntime.allowed?() do
      entries =
        def_.tools_json
        |> List.wrap()
        |> Enum.filter(&module_tool?/1)
        |> Enum.map(&forge_tool(def_, &1, opts))

      {:ok, _} = MockMCP.set_modules(def_.id, entries)
      maybe_write_disk(def_, Enum.filter(entries, &(&1["status"] != "error")))

      {:ok, %{modules: entries}}
    else
      {:error, :modules_disabled}
    end
  end

  @doc """
  Validate + persist an owner-edited `source` for `tool_name` (review/edit step).
  AST-guards + compiles; stores the source as a `"draft"` on success or `"error"`
  (with `last_error`) on failure so edits are never lost. Returns
  `{:ok, entry}` or `{:error, message, entry}`.
  """
  def update_source(def_, tool_name, source, _opts \\ []) when is_binary(source) do
    module = ModuleRuntime.module_name(def_.slug, tool_name)

    case ModuleRuntime.compile_and_load(module, source) do
      {:ok, _} ->
        entry = entry(tool_name, module, source, "draft", nil)
        {:ok, _} = MockMCP.put_module(def_.id, entry)
        {:ok, entry}

      {:error, err} ->
        entry = entry(tool_name, module, source, "error", err)
        {:ok, _} = MockMCP.put_module(def_.id, entry)
        {:error, err, entry}
    end
  end

  @doc "Approve a draft module so it serves live. Re-compiles to confirm validity."
  def approve(def_, tool_name) do
    case MockMCP.get_module(def_, tool_name) do
      nil ->
        {:error, :not_found}

      %{"source" => source} = m ->
        module = ModuleRuntime.module_name(def_.slug, tool_name)

        case ModuleRuntime.compile_and_load(module, source) do
          {:ok, _} ->
            entry = Map.merge(m, %{"status" => "approved", "last_error" => nil})
            {:ok, _} = MockMCP.put_module(def_.id, entry)
            {:ok, entry}

          {:error, err} ->
            {:error, err}
        end
    end
  end

  @doc """
  Run the test pass for one tool on demand (compiles the stored source first).
  Returns `{:ok, [%{args, result}]}` so the owner can see behavior before approving.
  """
  def test_module(def_, tool_name, opts \\ []) do
    with %{} = tool <- find_tool(def_, tool_name),
         %{"source" => source} <- MockMCP.get_module(def_, tool_name),
         {:ok, _} <- ModuleRuntime.compile_and_load(ModuleRuntime.module_name(def_.slug, tool_name), source),
         {:ok, samples} <- Agent.module_tests(tool, opts) do
      results =
        Enum.map(samples, fn args ->
          outcome =
            case ModuleRuntime.invoke(def_, Map.put(tool, "function", "call"), args) do
              {:ok, content, _l, _t} -> %{"ok" => true, "content" => content}
              {:error, reason, _l, _t} -> %{"ok" => false, "error" => to_string(reason)}
            end

          %{"args" => args, "result" => outcome}
        end)

      {:ok, results}
    else
      nil -> {:error, :not_found}
      {:error, reason} -> {:error, reason}
    end
  end

  defp module_tool?(tool), do: (tool["impl"] || tool[:impl]) == "module"
  defp find_tool(def_, name), do: Enum.find(def_.tools_json || [], &(&1["name"] == name))

  defp entry(tool, module, source, status, error) do
    %{"tool" => tool, "module" => inspect(module), "function" => "call",
      "source" => source, "status" => status, "last_error" => error}
  end

  # Generate → compile → test, repairing up to @max_attempts. Returns a draft
  # entry on success, or an "error" entry (carrying the best source + last error).
  defp forge_tool(def_, tool, opts) do
    module = ModuleRuntime.module_name(def_.slug, tool["name"])

    case Agent.generate_module(def_.prompt, tool, module, opts) do
      {:ok, source} -> attempt(def_, tool, module, source, opts, 1)
      {:error, reason} -> entry(tool["name"], module, "", "error", "generation failed: #{inspect(reason)}")
    end
  end

  defp attempt(_def, tool, module, source, _opts, n) when n > @max_attempts,
    do: entry(tool["name"], module, source, "error", "exceeded #{@max_attempts} attempts")

  defp attempt(def_, tool, module, source, opts, n) do
    case ModuleRuntime.compile_and_load(module, source) do
      {:ok, _mod} ->
        case test_pass(def_, tool, opts) do
          :ok ->
            entry(tool["name"], module, source, "draft", nil)

          {:retry, error} ->
            Logger.info("[MockMCP.ModuleForge] #{tool["name"]} test failed (attempt #{n}): #{error}")
            repair(def_, tool, module, source, error, opts, n)
        end

      {:error, error} ->
        Logger.info("[MockMCP.ModuleForge] #{tool["name"]} compile failed (attempt #{n}): #{error}")
        repair(def_, tool, module, source, error, opts, n)
    end
  end

  defp repair(def_, tool, module, source, error, opts, n) do
    case Agent.repair_module(source, error, module, opts) do
      {:ok, fixed} -> attempt(def_, tool, module, fixed, opts, n + 1)
      {:error, reason} -> entry(tool["name"], module, source, "error", "repair failed: #{inspect(reason)}")
    end
  end

  # Invoke the freshly-loaded module with agent-generated sample args. Only hard
  # failures (compile/crash/timeout) trigger a retry; business `{:error, msg}`
  # returns and successes pass.
  defp test_pass(def_, tool, opts) do
    case Agent.module_tests(tool, opts) do
      {:ok, samples} ->
        samples
        |> Enum.reduce_while(:ok, fn args, _acc ->
          case ModuleRuntime.invoke(def_, Map.put(tool, "function", "call"), args) do
            {:error, reason, _l, _t} ->
              if hard_failure?(reason), do: {:halt, {:retry, to_string(reason)}}, else: {:cont, :ok}

            {:ok, _content, _l, _t} ->
              {:cont, :ok}
          end
        end)

      {:error, _reason} ->
        # Couldn't produce test args — don't block on the optional test pass.
        :ok
    end
  end

  defp hard_failure?(reason) when is_binary(reason),
    do: String.contains?(reason, ["crashed", "timed out", "no module compiled", "forbidden references", "syntax error"])

  defp hard_failure?(_), do: true

  # ── Dev disk write (inspection / VCS) ────────────────────────

  defp maybe_write_disk(def_, built) do
    case Application.get_env(:noizu_prompt_lingua, :mock_mcp, [])[:modules_dir] do
      dir when is_binary(dir) and dir != "" ->
        target = Path.join([dir, def_.slug])
        File.mkdir_p(target)

        Enum.each(built, fn rec ->
          path = Path.join(target, "#{rec["tool"]}.ex")
          File.write(path, rec["source"])
        end)

        :ok

      _ ->
        :ok
    end
  end
end
