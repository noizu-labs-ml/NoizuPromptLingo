defmodule NoizuPromptLingua.Domains.MockMCP.Dispatch do
  @moduledoc """
  Single source of truth for routing a mock-MCP tool call:

    * `:module`           — declared `"impl":"module"` with an APPROVED implementation
    * `:llm`              — declared `"impl":"llm"` (or unset) → LLM inference
    * `{:pending, reason}` — declared `"impl":"module"` but not yet live (disabled,
      not generated, or a draft/error awaiting owner approval)

  Used by the gateway plug for top-level client calls and by the agent's
  `call_tool` internal op (one tool invoking another), with a depth guard against
  runaway tool→tool recursion.
  """
  alias NoizuPromptLingua.Domains.MockMCP.{Agent, ModuleRuntime}

  @max_tool_depth 3

  @doc "Routing decision for a tool descriptor."
  def route(def_, tool) do
    if tool["impl"] == "module" do
      if ModuleRuntime.allowed?() do
        name = tool["name"]
        entry = Enum.find(def_.modules_json || [], fn m -> (m["tool"] || m[:tool]) == name end)

        case entry && (entry["status"] || entry[:status]) do
          "approved" -> :module
          nil -> {:pending, "Tool '#{name}' has no generated module yet — generate and approve one before calling it."}
          status -> {:pending, "Tool '#{name}' module implementation is '#{status}', pending owner review/approval — not yet live."}
        end
      else
        {:pending, "Tool '#{tool["name"]}' is module-implemented but module execution is disabled on this server."}
      end
    else
      :llm
    end
  end

  @doc """
  Invoke a tool by name, returning `{:ok, content} | {:error, reason}` (content is
  the MCP content list). `opts` carries the active LLM connection opts plus
  `:tool_depth` (incremented on each nested LLM tool call).
  """
  def call_tool(def_, tool_name, arguments, opts \\ []) do
    depth = opts[:tool_depth] || 0

    cond do
      depth > @max_tool_depth ->
        {:error, "max tool-call depth (#{@max_tool_depth}) exceeded"}

      true ->
        case Enum.find(def_.tools_json || [], &(&1["name"] == tool_name)) do
          nil -> {:error, "unknown tool: #{tool_name}"}
          tool -> do_call(def_, tool, arguments, opts, depth)
        end
    end
  end

  defp do_call(def_, tool, arguments, opts, depth) do
    case route(def_, tool) do
      :module ->
        unwrap(ModuleRuntime.invoke(def_, tool, arguments))

      {:pending, reason} ->
        {:error, reason}

      :llm ->
        child = Keyword.put(opts, :tool_depth, depth + 1)
        unwrap(Agent.handle_tool_call(def_, tool["name"], arguments, tool["handler"], child))
    end
  end

  defp unwrap({:ok, content, _latency, _trace}), do: {:ok, content}
  defp unwrap({:error, reason, _latency, _trace}), do: {:error, reason}
end
