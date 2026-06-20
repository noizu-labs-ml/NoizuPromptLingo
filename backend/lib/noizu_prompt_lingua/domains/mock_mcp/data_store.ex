defmodule NoizuPromptLingua.Domains.MockMCP.DataStore do
  @moduledoc """
  Real, stateful backing store for a mock MCP. Two facilities:

    * **Postgres** — the mock's own isolated, provisioned database (see
      `MockMCP.provision_db/1`). Mocks can create/alter schema and run
      queries/DML against it.
    * **Redis** — a per-mock keyspace (`mockmcp:<slug>:*`) on the shared Redis,
      via `NoizuPromptLingua.Redis`.

  These power the built-in `db_*` / `redis_*` tools, which execute for real
  rather than being fabricated by the LLM.
  """

  alias NoizuPromptLingua.Redis

  # ── Postgres (provisioned per-mock DB) ───────────────────────

  @doc "Run a read query against the mock's DB. Returns {:ok, %{columns, rows}}."
  def db_query(def_, sql, params \\ []), do: db_run(def_, sql, params)

  @doc "Run DDL/DML (schema create/alter, insert/update/delete) against the mock's DB."
  def db_execute(def_, sql, params \\ []), do: db_run(def_, sql, params)

  @doc "List public tables in the mock's DB (for the portal State browser)."
  def list_tables(def_) do
    case db_query(def_,
           "SELECT table_name FROM information_schema.tables " <>
             "WHERE table_schema = 'public' ORDER BY table_name") do
      {:ok, %{rows: rows}} -> {:ok, Enum.map(rows, &List.first/1)}
      other -> other
    end
  end

  defp db_run(%{db_provisioned: true, db_name: db_name}, sql, params)
       when is_binary(db_name) and is_binary(sql) do
    case start_conn(db_name) do
      {:ok, conn} ->
        try do
          case Postgrex.query(conn, sql, params) do
            {:ok, %Postgrex.Result{columns: cols, rows: rows, num_rows: n, command: cmd}} ->
              {:ok, %{columns: cols || [], rows: rows || [], num_rows: n, command: cmd}}
            {:error, %Postgrex.Error{} = e} ->
              {:error, db_error_message(e)}
            {:error, e} ->
              {:error, inspect(e)}
          end
        after
          GenServer.stop(conn, :normal, 5_000)
        end

      {:error, reason} ->
        {:error, "could not connect to mock database: #{inspect(reason)}"}
    end
  end

  defp db_run(_def, _sql, _params),
    do: {:error, "no database provisioned for this mock — provision one first"}

  # Short-lived connection to the mock's database, reusing the app Repo's
  # host/credentials but targeting the provisioned database.
  defp start_conn(db_name) do
    Postgrex.start_link(Keyword.put(repo_conn_opts(), :database, db_name))
  end

  defp repo_conn_opts do
    cfg = NoizuPromptLingua.Repo.config()

    case cfg[:url] do
      url when is_binary(url) ->
        uri = URI.parse(url)
        {user, pass} =
          case uri.userinfo do
            nil -> {nil, nil}
            ui -> case String.split(ui, ":", parts: 2) do
                     [u, p] -> {u, p}
                     [u] -> {u, nil}
                   end
          end
        [hostname: uri.host || "localhost", port: uri.port || 5432,
         username: user, password: pass]

      _ ->
        [hostname: cfg[:hostname] || "localhost", port: cfg[:port] || 5432,
         username: cfg[:username], password: cfg[:password]]
    end
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
  end

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
            value = case redis_get(def_, k) do
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

  defp ns(%{slug: slug}, key), do: "mockmcp:#{slug}:#{key}"

  defp strip_prefix(str, prefix) do
    case String.starts_with?(str, prefix) do
      true -> String.replace_prefix(str, prefix, "")
      false -> str
    end
  end
end
