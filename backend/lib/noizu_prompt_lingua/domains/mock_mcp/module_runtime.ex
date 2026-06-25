defmodule NoizuPromptLingua.Domains.MockMCP.ModuleRuntime do
  @moduledoc """
  Runtime compilation + invocation of mock-MCP tool modules — Elixir authored by
  the generation agent and compiled with `Code.compile_string/2` into the running
  BEAM.

  Source of truth is the DB (`mock_mcp_definitions.modules_json`); the prod
  release filesystem is ephemeral, so modules are (re)compiled lazily on first
  use after a restart. Module names are deterministic per (mock, tool) so a
  recompile redefines in place.

  **Safety** — this is reduced-blast-radius, NOT a true sandbox:
    * gated by `config :noizu_prompt_lingua, :mock_mcp, allow_modules: <bool>`;
    * an AST denylist (`guard/1`) rejects source that references dangerous modules
      (System/File/Code/Module/Node/Port/Process/Task/Application/Repo/our app
      modules, raw OS/file/network/erlang/ets, dynamic `apply`/`spawn`) before it
      is ever compiled — generated modules reach state only through the `ctx`
      helper closures (`db_query`/`redis_*`/`weaviate_*`);
    * each call runs in a `Task` with a timeout.

  Module contract (what the agent must emit):

      defmodule <ExactName> do
        # args :: %{string => term}; ctx :: %{atom => (... -> term)}
        # return {:ok, json_encodable} | {:error, message}
        def call(args, ctx), do: ...
      end
  """

  alias NoizuPromptLingua.Domains.MockMCP.DataStore
  alias NoizuPromptLingua.Domains.MockMCP.Dispatch

  @prefix "NplMockMCP"
  @default_timeout 10_000

  # Module roots (alias first segment) generated code may NOT reference.
  @forbidden_aliases ~w(System File Code Module Node Port Process Task Agent
    GenServer Supervisor Application Mix IEx Ecto Repo NoizuPromptLingua Noizu
    Macro)a

  # Erlang modules (atom-literal `:mod.fun`) generated code may NOT reference.
  @forbidden_erl ~w(os file erlang rpc code init application net_adm net_kernel
    ets dets mnesia persistent_term gen_tcp gen_udp ssl inet httpc os_mon
    erpc global)a

  # Bare calls (no module) that bypass the guard.
  @forbidden_bare ~w(apply spawn spawn_link spawn_monitor send exit throw
    make_ref node nodes binary_to_term)a

  # ── Config ───────────────────────────────────────────────────

  defp cfg, do: Application.get_env(:noizu_prompt_lingua, :mock_mcp, [])
  def allowed?, do: Keyword.get(cfg(), :allow_modules, true) == true
  defp timeout, do: cfg()[:module_timeout_ms] || @default_timeout

  # ── Naming ───────────────────────────────────────────────────

  @doc "Deterministic module name (atom) for a (mock slug, tool name)."
  def module_name(slug, tool_name),
    do: Module.concat([@prefix, pascal(slug), pascal(tool_name)])

  defp pascal(s) do
    s
    |> to_string()
    |> String.split(~r/[^A-Za-z0-9]+/, trim: true)
    |> Enum.map_join("", fn w -> String.upcase(String.first(w)) <> (String.slice(w, 1..-1//1) || "") end)
    |> case do
      "" -> "X"
      other -> other
    end
  end

  # ── AST guard ────────────────────────────────────────────────

  @doc """
  Static-analyze `source`. Returns `:ok` or `{:error, message}` listing the
  forbidden references found. Pure syntax/AST check; no evaluation.
  """
  def guard(source) when is_binary(source) do
    case Code.string_to_quoted(source) do
      {:ok, ast} ->
        case collect_violations(ast) do
          [] -> :ok
          v -> {:error, "forbidden references: #{Enum.join(Enum.uniq(v), ", ")}"}
        end

      {:error, {meta, msg, token}} ->
        {:error, "syntax error: #{inspect(msg)} #{inspect(token)} (#{inspect(meta)})"}
    end
  end

  defp collect_violations(ast) do
    {_ast, acc} = Macro.prewalk(ast, [], &visit/2)
    acc
  end

  # Aliased module call:  Foo.Bar.baz(...)
  defp visit({{:., _, [{:__aliases__, _, [root | _]}, _fun]}, _, _} = node, acc) do
    if root in @forbidden_aliases, do: {node, ["#{root}.*" | acc]}, else: {node, acc}
  end

  # Erlang module call:  :os.cmd(...)
  defp visit({{:., _, [erl, _fun]}, _, _} = node, acc) when is_atom(erl) do
    if erl in @forbidden_erl, do: {node, [":#{erl}.*" | acc]}, else: {node, acc}
  end

  # Bare reserved call:  apply(...), spawn(...), send(...)
  defp visit({name, _, args} = node, acc) when is_atom(name) and is_list(args) do
    if name in @forbidden_bare, do: {node, ["#{name}/#{length(args)}" | acc]}, else: {node, acc}
  end

  # Bare alias reference used as a value (e.g. passing `System` around).
  defp visit({:__aliases__, _, [root | _]} = node, acc) when is_atom(root) do
    if root in @forbidden_aliases, do: {node, ["#{root}" | acc]}, else: {node, acc}
  end

  defp visit(node, acc), do: {node, acc}

  # ── Compile / load ───────────────────────────────────────────

  @doc """
  Guard, then compile + load `source`, asserting it defines `expected` (an atom
  module name). Returns `{:ok, module}` or `{:error, message}`.
  """
  def compile_and_load(expected, source) when is_atom(expected) and is_binary(source) do
    cond do
      not allowed?() ->
        {:error, "module execution disabled (mock_mcp.allow_modules=false)"}

      true ->
        with :ok <- guard(source) do
          do_compile(expected, source)
        end
    end
  end

  defp do_compile(expected, source) do
    try do
      compiled = Code.compile_string(source, "mockmcp/#{expected}.ex")

      if Enum.any?(compiled, fn {m, _} -> m == expected end) do
        {:ok, expected}
      else
        names = Enum.map_join(compiled, ", ", fn {m, _} -> inspect(m) end)
        purge(compiled)
        {:error, "source must define module #{inspect(expected)} (defined: #{names})"}
      end
    rescue
      e -> {:error, Exception.message(e)}
    catch
      kind, reason -> {:error, "compile #{kind}: #{inspect(reason)}"}
    end
  end

  defp purge(compiled) do
    Enum.each(compiled, fn {m, _} ->
      :code.purge(m)
      :code.delete(m)
    end)
  end

  # Ensure the (mock, tool) module is loaded; lazily compile from stored source.
  defp ensure_loaded(def_, tool_name) do
    mod = module_name(def_.slug, tool_name)

    if Code.ensure_loaded?(mod) do
      {:ok, mod}
    else
      case find_source(def_, tool_name) do
        nil -> {:error, "no module compiled for tool '#{tool_name}'"}
        source -> compile_and_load(mod, source)
      end
    end
  end

  defp find_source(def_, tool_name) do
    (def_.modules_json || [])
    |> Enum.find(fn m -> (m["tool"] || m[:tool]) == tool_name end)
    |> case do
      %{} = m -> m["source"] || m[:source]
      _ -> nil
    end
  end

  # ── Invocation ───────────────────────────────────────────────

  @doc """
  Invoke the tool's module. Returns the gateway-shaped 4-tuple
  `{:ok, content, latency_ms, trace}` / `{:error, reason, latency_ms, trace}`,
  matching `Agent.handle_tool_call/5`.
  """
  def invoke(def_, tool, args) do
    start = System.monotonic_time(:millisecond)
    result = do_invoke(def_, tool, args)
    latency = System.monotonic_time(:millisecond) - start

    case result do
      {:ok, content} -> {:ok, content, latency, [%{"impl" => "module"}]}
      {:error, reason} -> {:error, reason, latency, [%{"impl" => "module"}]}
    end
  end

  defp do_invoke(def_, tool, args) do
    with {:ok, mod} <- ensure_loaded(def_, tool["name"]) do
      ctx = build_ctx(def_)
      fun = String.to_atom(tool["function"] || "call")
      task = Task.async(fn -> apply(mod, fun, [args, ctx]) end)

      case Task.yield(task, timeout()) || Task.shutdown(task, :brutal_kill) do
        {:ok, {:ok, content}} -> {:ok, to_content(content)}
        {:ok, {:error, msg}} -> {:error, to_string_safe(msg)}
        {:ok, other} -> {:ok, to_content(other)}
        nil -> {:error, "module call timed out after #{timeout()}ms"}
        {:exit, reason} -> {:error, "module crashed: #{inspect(reason)}"}
      end
    end
  end

  # Safe, stateful helpers exposed to generated modules (the only sanctioned way
  # to touch the mock's backing store).
  defp build_ctx(def_) do
    %{
      db_query: fn sql -> DataStore.db_query(def_, sql) end,
      db_execute: fn sql -> DataStore.db_execute(def_, sql) end,
      redis_get: fn key -> DataStore.redis_get(def_, key) end,
      redis_set: fn key, value -> DataStore.redis_set(def_, key, value) end,
      redis_del: fn key -> DataStore.redis_del(def_, key) end,
      weaviate_add: fn collection, text -> DataStore.weaviate_add(def_, collection, text) end,
      weaviate_query: fn collection, query -> DataStore.weaviate_query(def_, collection, query) end,
      # Invoke another of this mock's tools (depth-guarded against recursion).
      call_tool: fn tool_name, tool_args -> Dispatch.call_tool(def_, tool_name, tool_args, tool_depth: 1) end
    }
  end

  defp to_content(content) when is_binary(content), do: [%{"type" => "text", "text" => content}]
  defp to_content(%{"type" => _} = content), do: [content]
  defp to_content(content) when is_map(content) or is_list(content),
    do: [%{"type" => "text", "text" => Jason.encode!(content)}]
  defp to_content(other), do: [%{"type" => "text", "text" => to_string_safe(other)}]

  defp to_string_safe(v) when is_binary(v), do: v
  defp to_string_safe(v), do: inspect(v)
end
