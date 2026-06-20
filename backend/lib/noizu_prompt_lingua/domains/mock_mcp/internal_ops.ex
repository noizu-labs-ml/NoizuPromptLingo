defmodule NoizuPromptLingua.Domains.MockMCP.InternalOps do
  @moduledoc """
  The mock agent's PRIVATE data operations over its own backing store
  (`DataStore`). These are NOT MCP tools — they are never advertised to or
  callable by MCP consumers. The agent uses them internally, over a bounded
  tool-use loop, to keep generated tool/resource/prompt responses stateful and
  consistent across calls.

    * `db_*`  — the mock's isolated provisioned Postgres database (only when
      `db_provisioned`)
    * `redis_*` — the mock's per-mock Redis keyspace (always available)
  """

  alias NoizuPromptLingua.Domains.MockMCP.DataStore

  @redis_ops ~w(redis_get redis_set redis_del redis_keys)
  @db_ops ~w(db_query db_execute)

  @doc "Whether a name is a recognised internal op."
  def op?(name), do: name in (@redis_ops ++ @db_ops)

  @doc """
  Human-readable description of the ops available to a given definition, for
  injection into the agent's system prompt.
  """
  def available(%{db_provisioned: provisioned?}) do
    redis = """
    - redis_get   {"key": string}
    - redis_set   {"key": string, "value": string, "ttl": integer (optional seconds)}
    - redis_del   {"key": string}
    - redis_keys  {"pattern": string (glob, default "*")}
    """

    db =
      if provisioned? do
        """
        - db_execute {"sql": string}   (CREATE/ALTER/INSERT/UPDATE/DELETE on your private DB)
        - db_query   {"sql": string}   (SELECT from your private DB)
        """
      else
        "(no SQL database provisioned for this mock — only Redis ops are available)"
      end

    "Redis ops:\n#{redis}\nDatabase ops:\n#{db}"
  end

  @doc """
  Execute an internal op. Returns `{:ok, json_encodable}` or `{:error, message}`.
  The result is fed back to the model as the op's outcome.
  """
  def exec(def_, "db_query", %{"sql" => sql}), do: DataStore.db_query(def_, sql)
  def exec(def_, "db_execute", %{"sql" => sql}), do: DataStore.db_execute(def_, sql)
  def exec(_def, "db_" <> _, _), do: {:error, "missing required 'sql' argument"}

  def exec(def_, "redis_set", %{"key" => k, "value" => v} = a),
    do: passthrough(DataStore.redis_set(def_, k, v, a["ttl"]), %{"ok" => true})

  def exec(def_, "redis_get", %{"key" => k}),
    do: passthrough(DataStore.redis_get(def_, k), :value)

  def exec(def_, "redis_del", %{"key" => k}),
    do: passthrough(DataStore.redis_del(def_, k), :value)

  def exec(def_, "redis_keys", a),
    do: passthrough(DataStore.redis_keys(def_, a["pattern"] || "*"), :value)

  def exec(_def, "redis_" <> _, _), do: {:error, "missing required arguments"}
  def exec(_def, name, _), do: {:error, "unknown internal op: #{name}"}

  defp passthrough({:ok, value}, :value), do: {:ok, %{"result" => value}}
  defp passthrough({:ok, _}, replacement), do: {:ok, replacement}
  defp passthrough({:error, reason}, _), do: {:error, inspect(reason)}
end
