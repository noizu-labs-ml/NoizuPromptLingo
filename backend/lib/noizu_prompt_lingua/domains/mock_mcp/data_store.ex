defmodule NoizuPromptLingua.Domains.MockMCP.DataStore do
  @moduledoc """
  Real, stateful backing store for a mock MCP. Two facilities:

    * **Postgres** — the mock's own isolated, provisioned schema
      (`mockmcp_<slug>`) inside the app database (see `MockMCP.provision_db/1`).
      Mocks can create/alter tables and run queries/DML within it; every
      statement is scoped to the schema via a transaction-local `search_path`,
      so unqualified objects resolve to and are created in the mock's schema.
    * **Redis** — a per-mock keyspace (`mockmcp:<slug>:*`) on the shared Redis,
      via `NoizuPromptLingua.Redis`.

  These power the built-in `db_*` / `redis_*` tools, which execute for real
  rather than being fabricated by the LLM.
  """

  alias NoizuPromptLingua.Redis
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Domains.MockMCP.WeaviateStore

  # ── Postgres (provisioned per-mock DB) ───────────────────────

  @doc "Run a read query against the mock's DB. Returns {:ok, %{columns, rows}}."
  def db_query(def_, sql, params \\ []), do: db_run(def_, sql, params)

  @doc "Run DDL/DML (schema create/alter, insert/update/delete) against the mock's DB."
  def db_execute(def_, sql, params \\ []), do: db_run(def_, sql, params)

  @doc "List tables in the mock's schema (for the portal State browser)."
  def list_tables(%{db_provisioned: true, db_name: schema} = def_) when is_binary(schema) do
    case db_query(
           def_,
           "SELECT table_name FROM information_schema.tables " <>
             "WHERE table_schema = $1 ORDER BY table_name",
           [schema]
         ) do
      {:ok, %{rows: rows}} -> {:ok, Enum.map(rows, &List.first/1)}
      other -> other
    end
  end

  def list_tables(_def),
    do: {:error, "no database provisioned for this mock — provision one first"}

  # Run the mock's SQL inside a transaction with a transaction-local
  # `search_path` pinned to its schema, so unqualified reads/DDL resolve to and
  # land in the mock's own schema. Reuses the app Repo's pool/credentials — no
  # separate database or connection.
  defp db_run(%{db_provisioned: true, db_name: schema}, sql, params)
       when is_binary(schema) and is_binary(sql) do
    safe = String.replace(schema, ~r/[^a-z0-9_]/, "")

    txn =
      Repo.transaction(fn ->
        Ecto.Adapters.SQL.query!(Repo, ~s(SET LOCAL search_path TO "#{safe}"), [])

        case Ecto.Adapters.SQL.query(Repo, sql, params) do
          {:ok, result} -> result
          {:error, e} -> Repo.rollback(e)
        end
      end)

    case txn do
      {:ok, %Postgrex.Result{columns: cols, rows: rows, num_rows: n, command: cmd}} ->
        {:ok, %{columns: cols || [], rows: rows || [], num_rows: n, command: cmd}}

      {:error, %Postgrex.Error{} = e} ->
        {:error, db_error_message(e)}

      {:error, e} ->
        {:error, inspect(e)}
    end
  end

  defp db_run(_def, _sql, _params),
    do: {:error, "no database provisioned for this mock — provision one first"}

  defp db_error_message(%Postgrex.Error{postgres: %{message: m}}), do: m
  defp db_error_message(%Postgrex.Error{message: m}) when is_binary(m), do: m
  defp db_error_message(e), do: inspect(e)

  # ── Redis (per-mock keyspace) ────────────────────────────────

  @doc "Set a key (optional ttl seconds) within the mock's keyspace."
  def redis_set(def_, key, value, ttl \\ nil) do
    opts = if is_integer(ttl) and ttl > 0, do: [ex: ttl], else: []
    Redis.set(ns(def_, key), to_string(value), opts)
  end

  def redis_get(def_, key), do: Redis.get(ns(def_, key))
  def redis_del(def_, key), do: Redis.del(ns(def_, key))

  @doc "List keys matching a glob within the mock's keyspace (returns bare keys)."
  def redis_keys(def_, pattern \\ "*") do
    full = ns(def_, pattern)
    prefix = ns(def_, "")
    # account for the global key_prefix Redis.prefix/1 adds on top.
    global = Redis.prefix("")

    case Redis.command(["KEYS", Redis.prefix(full)]) do
      {:ok, keys} ->
        {:ok, Enum.map(keys, &strip_prefix(&1, global <> prefix))}

      other ->
        other
    end
  end

  @doc "Dump keys + values in the mock's keyspace (for the portal State browser)."
  def redis_dump(def_, pattern \\ "*") do
    case redis_keys(def_, pattern) do
      {:ok, keys} ->
        entries =
          Enum.map(keys, fn k ->
            value =
              case redis_get(def_, k) do
                {:ok, v} -> v
                _ -> nil
              end

            %{key: k, value: value}
          end)

        {:ok, entries}

      other ->
        other
    end
  end

  # ── Weaviate (per-mock collections) ──────────────────────────

  @doc "Embed `text` and store it (+ optional props) in the mock's `collection`."
  def weaviate_add(def_, collection, text, props \\ %{}),
    do: WeaviateStore.add(def_, collection, text, props)

  @doc "Semantic search the mock's `collection` for the nearest objects to `query`."
  def weaviate_query(def_, collection, query, opts \\ []),
    do: WeaviateStore.query(def_, collection, query, opts)

  defp ns(%{slug: slug}, key), do: "mockmcp:#{slug}:#{key}"

  defp strip_prefix(str, prefix) do
    case String.starts_with?(str, prefix) do
      true -> String.replace_prefix(str, prefix, "")
      false -> str
    end
  end
end
