defmodule NoizuPromptLingua.Domains.MockMCP.InternalOps do
  @moduledoc """
  The mock agent's PRIVATE data operations over its own backing store
  (`DataStore`). These are NOT MCP tools — they are never advertised to or
  callable by MCP consumers. The agent uses them internally, over a bounded
  tool-use loop, to keep generated tool/resource/prompt responses stateful and
  consistent across calls.

    * `db_*`  — the mock's isolated provisioned Postgres schema (only when
      `db_provisioned`)
    * `redis_*` — the mock's per-mock Redis keyspace (always available)
    * `weaviate_*` — the mock's per-mock Weaviate collections for semantic search
      (only when the mock designed collections)
    * `call_tool` — invoke another of this mock's tools (module- or LLM-backed),
      so an LLM-served tool can compose the mock's own surface
  """

  alias NoizuPromptLingua.Domains.MockMCP.DataStore
  alias NoizuPromptLingua.Domains.MockMCP.Dispatch

  @redis_ops ~w(redis_get redis_set redis_del redis_keys)
  @db_ops ~w(db_query db_execute)
  @weaviate_ops ~w(weaviate_add weaviate_query)
  @tool_ops ~w(call_tool)

  @doc "Whether a name is a recognised internal op."
  def op?(name), do: name in (@redis_ops ++ @db_ops ++ @weaviate_ops ++ @tool_ops)

  @doc """
  Human-readable description of the ops available to a given definition, for
  injection into the agent's system prompt.
  """
  def available(def_) do
    redis = """
    - redis_get   {"key": string}
    - redis_set   {"key": string, "value": string, "ttl": integer (optional seconds)}
    - redis_del   {"key": string}
    - redis_keys  {"pattern": string (glob, default "*")}
    """

    db =
      if Map.get(def_, :db_provisioned) do
        """
        - db_execute {"sql": string}   (CREATE/ALTER/INSERT/UPDATE/DELETE on your private schema)
        - db_query   {"sql": string}   (SELECT from your private schema)
        """
      else
        "(no SQL schema provisioned for this mock — only Redis ops are available)"
      end

    weaviate =
      case weaviate_collections(def_) do
        [] ->
          "(no Weaviate collections designed for this mock)"

        names ->
          """
          - weaviate_add   {"collection": string, "text": string, "properties": object (optional)}
          - weaviate_query {"collection": string, "query": string, "limit": integer (optional)}
          Collections: #{Enum.join(names, ", ")}
          """
      end

    tools =
      case tool_names(def_) do
        [] ->
          "(this mock has no other tools to call)"

        names ->
          """
          - call_tool {"tool": string, "arguments": object}   (invoke another of this mock's tools)
          Tools: #{Enum.join(names, ", ")}
          """
      end

    "Redis ops:\n#{redis}\nDatabase ops:\n#{db}\nWeaviate ops:\n#{weaviate}\nTool calls:\n#{tools}"
  end

  defp tool_names(%{tools_json: tools}) when is_list(tools) do
    tools |> Enum.map(fn t -> t["name"] || t[:name] end) |> Enum.filter(&is_binary/1)
  end

  defp tool_names(_), do: []

  defp weaviate_collections(%{schema_json: %{"weaviate" => classes}}) when is_list(classes) do
    classes
    |> Enum.map(fn c -> c["name"] || c[:name] end)
    |> Enum.filter(&(is_binary(&1) and &1 != ""))
  end

  defp weaviate_collections(_), do: []

  @doc """
  Execute an internal op. Returns `{:ok, json_encodable}` or `{:error, message}`.
  The result is fed back to the model as the op's outcome. `opts` carries the
  active LLM connection opts + `:tool_depth` (only used by `call_tool`).
  """
  def exec(def_, op, args, opts \\ [])

  def exec(def_, "db_query", %{"sql" => sql}, _opts), do: DataStore.db_query(def_, sql)
  def exec(def_, "db_execute", %{"sql" => sql}, _opts), do: DataStore.db_execute(def_, sql)
  def exec(_def, "db_" <> _, _, _opts), do: {:error, "missing required 'sql' argument"}

  def exec(def_, "redis_set", %{"key" => k, "value" => v} = a, _opts),
    do: passthrough(DataStore.redis_set(def_, k, v, a["ttl"]), %{"ok" => true})

  def exec(def_, "redis_get", %{"key" => k}, _opts),
    do: passthrough(DataStore.redis_get(def_, k), :value)

  def exec(def_, "redis_del", %{"key" => k}, _opts),
    do: passthrough(DataStore.redis_del(def_, k), :value)

  def exec(def_, "redis_keys", a, _opts),
    do: passthrough(DataStore.redis_keys(def_, a["pattern"] || "*"), :value)

  def exec(_def, "redis_" <> _, _, _opts), do: {:error, "missing required arguments"}

  def exec(def_, "weaviate_add", %{"collection" => c, "text" => t} = a, _opts),
    do: DataStore.weaviate_add(def_, c, t, a["properties"] || %{})

  def exec(def_, "weaviate_query", %{"collection" => c, "query" => q} = a, _opts),
    do: DataStore.weaviate_query(def_, c, q, limit: a["limit"])

  def exec(_def, "weaviate_" <> _, _, _opts),
    do: {:error, "missing required arguments (collection + text/query)"}

  def exec(def_, "call_tool", %{"tool" => t} = a, opts) do
    case Dispatch.call_tool(def_, t, a["arguments"] || %{}, opts) do
      {:ok, content} -> {:ok, %{"content" => content}}
      {:error, reason} when is_binary(reason) -> {:error, reason}
      {:error, reason} -> {:error, inspect(reason)}
    end
  end

  def exec(_def, "call_tool", _a, _opts), do: {:error, "missing required 'tool' argument"}

  def exec(_def, name, _, _opts), do: {:error, "unknown internal op: #{name}"}

  defp passthrough({:ok, value}, :value), do: {:ok, %{"result" => value}}
  defp passthrough({:ok, _}, replacement), do: {:ok, replacement}
  defp passthrough({:error, reason}, _), do: {:error, inspect(reason)}
end
