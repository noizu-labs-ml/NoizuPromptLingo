defmodule NoizuPromptLingua.Domains.MockMCP.DataStoreTest do
  @moduledoc """
  DataStore — the mock's real Postgres schema (transaction-local search_path),
  the per-mock Redis keyspace, and the Weaviate/DB passthroughs used by the
  agent's internal ops.

  The schema is provisioned for real via `MockMCP.provision_db/1` (its CREATE
  SCHEMA + DDL run inside the sandbox transaction and roll back). NOTE: db_run
  pins search_path with SET LOCAL; on the sandbox connection that persists for
  the remainder of the test, so the teardown resets it (mirrors the controller
  suite's reset_search_path/0).
  """

  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.MockMCP
  alias NoizuPromptLingua.Domains.MockMCP.DataStore
  alias NoizuPromptLingua.Domains.MockMCP.InternalOps
  alias NoizuPromptLingua.Repo

  setup do
    on_exit(fn ->
      Ecto.Adapters.SQL.query!(Repo, "SET search_path TO public", [])
    end)

    :ok
  end

  defp insert_org(prefix) do
    %{rows: [[raw_id]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["#{prefix}-#{System.unique_integer([:positive])}", "Test Org"]
      )

    Ecto.UUID.load!(raw_id)
  end

  defp create_def(prefix, overrides) do
    org_id = insert_org("#{prefix}-org")

    {:ok, def_} =
      MockMCP.create(%{
        organization_id: org_id,
        slug: "#{prefix}-#{System.unique_integer([:positive])}",
        title: "Data Store Test",
        prompt: "stateful mock"
      })

    {:ok, def_} = MockMCP.update(def_.id, overrides)
    MockMCP.get(def_.id)
  end

  # Provision WITHOUT designed DDL: applying statements pins search_path with
  # SET LOCAL on the sandbox connection (its wrapping transaction never ends),
  # which would break provision_db's own trailing Repo.update. In production the
  # transaction commits and the pin dies — this is a test-env-only artifact, so
  # tables are created here through db_execute instead. The DDL error branch is
  # covered by provision_db's bad-DDL test in mock_mcp_test (its rollback lifts
  # the pin).
  defp provisioned_def do
    def_ = create_def("ds", %{})

    assert {:ok, def_} = MockMCP.provision_db(def_.id)
    assert def_.db_provisioned
    assert def_.db_name == MockMCP.schema_name(def_.slug)

    assert {:ok, _} =
             DataStore.db_execute(def_, "CREATE TABLE notes (id serial primary key, body text)")

    def_
  end

  # ── unprovisioned guards ──────────────────────────────────────────────────

  test "db ops and list_tables error when nothing is provisioned" do
    def_ = %{
      slug: "bare-#{System.unique_integer([:positive])}",
      db_provisioned: false,
      db_name: nil
    }

    for fun <- [
          &DataStore.db_query(&1, "SELECT 1"),
          &DataStore.db_execute(&1, "SELECT 1"),
          &DataStore.list_tables(&1)
        ] do
      assert {:error, msg} = fun.(def_)
      assert msg =~ "no database provisioned"
    end
  end

  # ── provisioned Postgres round trip ───────────────────────────────────────

  describe "provisioned Postgres" do
    test "DDL, DML, queries and list_tables run inside the mock schema" do
      def_ = provisioned_def()

      assert {:ok, %{command: :create_table}} =
               DataStore.db_execute(def_, "CREATE TABLE extras (id int)")

      assert {:ok, %{num_rows: 1}} =
               DataStore.db_execute(def_, "INSERT INTO notes (body) VALUES ('hello')")

      assert {:ok, %{columns: ["id", "body"], rows: [[_, "hello"]]}} =
               DataStore.db_query(def_, "SELECT id, body FROM notes ORDER BY id LIMIT 1")

      assert {:ok, ["extras", "notes"]} = DataStore.list_tables(def_)

      # notes was created by the DESIGN DDL, extras by db_execute — both live in
      # the mock's schema only.
      assert {:ok, %{num_rows: 0}} = DataStore.db_execute(def_, "DELETE FROM extras")
    end

    test "postgres errors surface as {:error, message}" do
      def_ = provisioned_def()

      assert {:error, msg} = DataStore.db_query(def_, "SELECT * FROM missing_table")
      assert msg =~ "does not exist"
    end

    test "params are passed through to the query" do
      def_ = provisioned_def()

      assert {:ok, %{rows: [[7]]}} = DataStore.db_query(def_, "SELECT $1::int + $2::int", [3, 4])
    end

    test "db_name is sanitized before it pins the search_path" do
      # A hand-built definition whose db_name carries characters Postgres would
      # choke on: db_run strips them down to the bare identifier.
      def_ = %{slug: "weird", db_provisioned: true, db_name: "Weird-Name.2"}

      assert {:ok, %{rows: [[1]]}} = DataStore.db_query(def_, "SELECT 1")
    end
  end

  # ── Redis keyspace ────────────────────────────────────────────────────────

  describe "Redis keyspace" do
    test "set/get/del round-trips inside the mock namespace" do
      def_ = %{slug: "redis-#{System.unique_integer([:positive])}"}
      key = "k-#{System.unique_integer([:positive])}"

      assert {:ok, _} = DataStore.redis_set(def_, key, "v1", 60)
      assert {:ok, "v1"} = DataStore.redis_get(def_, key)
      assert {:ok, _} = DataStore.redis_del(def_, key)
      assert {:ok, nil} = DataStore.redis_get(def_, key)
    end

    test "redis_keys and redis_dump scope to the mock's keyspace" do
      def_ = %{slug: "dump-#{System.unique_integer([:positive])}"}
      a = "alpha-#{System.unique_integer([:positive])}"
      b = "beta-#{System.unique_integer([:positive])}"
      DataStore.redis_set(def_, a, "one")
      DataStore.redis_set(def_, b, "two")

      assert {:ok, keys} = DataStore.redis_keys(def_)
      assert a in keys and b in keys

      assert {:ok, entries} = DataStore.redis_dump(def_)
      assert %{key: ^a, value: "one"} = Enum.find(entries, &(&1.key == a))

      # pattern filtering stays inside the namespace
      assert {:ok, pattern_keys} = DataStore.redis_keys(def_, "alpha-*")
      assert [^a] = pattern_keys
    end
  end

  # ── Weaviate passthrough ──────────────────────────────────────────────────

  test "weaviate passthroughs reject undesigned collections without network calls" do
    def_ = %{slug: "wv-#{System.unique_integer([:positive])}", schema_json: nil}

    assert {:error, msg} = DataStore.weaviate_add(def_, "Nope", "text")
    assert msg =~ "unknown collection 'Nope'"

    assert {:error, msg} = DataStore.weaviate_query(def_, "Nope", "q")
    assert msg =~ "unknown collection 'Nope'"
  end

  # ── InternalOps db branches needing a provisioned schema ──────────────────

  describe "InternalOps db ops against a provisioned schema" do
    test "db_query/db_execute exec for real" do
      def_ = provisioned_def()

      assert {:ok, %{rows: [[1]]}} =
               InternalOps.exec(def_, "db_query", %{"sql" => "SELECT 1"})

      assert {:ok, _} =
               InternalOps.exec(def_, "db_execute", %{"sql" => "CREATE TABLE ops_t (id int)"})
    end

    test "available/1 lists tools and weaviate collections when designed" do
      def_ =
        create_def("avail", %{
          tools_json: [%{"name" => "ping"}, %{"name" => "second_tool"}],
          schema_json: %{"weaviate" => [%{"name" => "Facts"}, %{:name => "AtomKeys"}]}
        })

      text = InternalOps.available(def_)
      assert text =~ "call_tool"
      assert text =~ "ping"
      assert text =~ "Facts"
      assert text =~ "AtomKeys"
    end
  end
end
