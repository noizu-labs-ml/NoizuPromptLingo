defmodule NoizuPromptLinguaWeb.MockMCPControllerTest do
  @moduledoc """
  MockMCPController — definitions CRUD + activate lifecycle, LLM connection
  pool, models quick-pick, generate-tools, playground invoke (+ call log),
  provision-db / state browser (db tables/query + redis), and the module
  forge/review endpoints.

  The LLM boundary is `Agent.run/2`'s direct-HTTP path: any LLM connection
  created with an `endpoint` bypasses GenAI and POSTs OpenAI-shaped JSON to
  that URL, so tests point `endpoint` at a local Bandit stub (same recipe as
  the ContentGenerator tests; no stub libs, bandit ships with Phoenix).
  Behavior is selected by the URL's last path segment.

  Security note (finding, not regression): `POST .../state/db/query` executes
  arbitrary SQL with only a transaction-local `search_path` pin. The
  `cross-schema escape` / `unbounded result set` tests below PIN THE CURRENT
  UNGUARDED BEHAVIOR (200 + rows from outside the mock's schema; no row
  limit) — they are bug documentation, not an endorsement.
  """

  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.Domains.MockMCP
  alias NoizuPromptLingua.Repo

  @base "/api/v1/organizations"

  # ── LLM stub ──────────────────────────────────────────────────────────────

  # OpenAI-compatible completions stub. Content selection by last path segment:
  #   /surface    valid tools/resources/prompts/schema surface JSON
  #   /toolcall   {"type":"text",...} parseable tool-call response
  #   /badjson    200 but content is not JSON (invalid surface / raw-text tool)
  #   /status500  HTTP 500 (LLM call failed)
  #   /junksrc    non-Elixir "module source" (drives the forge repair loop)
  defmodule StubLLM do
    def init(opts), do: opts

    def call(conn, _opts) do
      {:ok, _body, conn} = Plug.Conn.read_body(conn)

      content =
        case List.last(conn.path_info) do
          "surface" ->
            Jason.encode!(%{
              "tools" => [
                %{
                  "name" => "echo",
                  "description" => "Echo a greeting",
                  "handler" => "llm",
                  "inputSchema" => %{"type" => "object"}
                }
              ],
              "resources" => [%{"uri" => "mock://notes", "mimeType" => "text/plain"}],
              "prompts" => [%{"name" => "hello", "arguments" => []}],
              "schema" => %{"postgres" => [], "weaviate" => []}
            })

          "toolcall" ->
            Jason.encode!(%{"type" => "text", "text" => "mocked tool output"})

          "badjson" ->
            "this is not json at all"

          "junksrc" ->
            "defModule oops("

          _ ->
            "unmatched"
        end

      case List.last(conn.path_info) do
        "status500" ->
          conn
          |> Plug.Conn.put_resp_content_type("application/json")
          |> Plug.Conn.send_resp(500, "kaboom")

        _ ->
          body = Jason.encode!(%{"choices" => [%{"message" => %{"content" => content}}]})

          conn
          |> Plug.Conn.put_resp_content_type("application/json")
          |> Plug.Conn.send_resp(200, body)
      end
    end
  end

  # Bind an ephemeral port, then hand it to Bandit (tiny TOCTOU window OK).
  defp start_stub_server do
    {:ok, sock} = :gen_tcp.listen(0, ip: {127, 0, 0, 1})
    {:ok, port} = :inet.port(sock)
    :gen_tcp.close(sock)

    {:ok, pid} = Bandit.start_link(plug: StubLLM, scheme: :http, ip: {127, 0, 0, 1}, port: port)

    on_exit(fn ->
      if Process.alive?(pid), do: Process.exit(pid, :shutdown)
    end)

    port
  end

  # ── fixtures ──────────────────────────────────────────────────────────────

  defp create_org(conn, suffix) do
    slug = "mm-#{suffix}"

    org_id =
      conn
      |> post(@base, %{organization: %{slug: slug, name: "Mock Org #{suffix}"}})
      |> json_response(201)
      |> get_in(["organization", "id"])

    # Seed the TRP stub org so Projects.get_project lookups resolve.
    NoizuPromptLingua.TRP.TestStub.seed_org(org_id, slug, "Mock Org #{suffix}")
    NoizuPromptLingua.TRP.Cache.clear()

    org_id
  end

  defp create_llm(conn, org_id, mode, opts \\ []) do
    port = Keyword.get(opts, :port)

    payload = %{
      "label" => "llm-#{mode}-#{System.unique_integer([:positive])}",
      "provider" => "openai",
      "model" => "stub-model",
      "endpoint" => (port && "http://127.0.0.1:#{port}/#{mode}") || nil,
      "api_key" => opts[:api_key] || "sk-stub"
    }

    %{"llm" => %{"id" => id}} =
      post(conn, "#{@base}/#{org_id}/mock-mcp-llms", payload) |> json_response(201)

    id
  end

  defp create_def(conn, org_id, attrs \\ %{}) do
    payload =
      Map.merge(
        %{
          "slug" => "mock-#{System.unique_integer([:positive])}",
          "title" => "Mock Def",
          "prompt" => "A tiny echo server.",
          "auto_generate_tools" => false
        },
        attrs
      )

    resp = post(conn, "#{@base}/#{org_id}/mock-mcp", payload)
    {resp.status, resp}
  end

  setup %{conn: conn} do
    %{access_token: token, user: user} = setup_user_and_token()
    auth = authenticated_conn(conn, token)
    org_id = create_org(auth, System.unique_integer([:positive]))
    port = start_stub_server()

    {:ok, conn: auth, user: user, org_id: org_id, port: port}
  end

  # ── auth matrix ───────────────────────────────────────────────────────────

  describe "auth matrix" do
    test "unauthenticated -> 401", %{org_id: org_id} do
      conn = build_conn()
      conn = get(conn, "#{@base}/#{org_id}/mock-mcp")
      assert conn.status == 401
    end

    test "non-member -> 403 not a member", %{org_id: org_id} do
      %{access_token: other_token} = setup_user_and_token()
      other = authenticated_conn(build_conn(), other_token)

      assert %{"error" => "Not a member of this organization"} =
               json_response(get(other, "#{@base}/#{org_id}/mock-mcp"), 403)
    end

    test "viewer may read but not write", %{org_id: org_id} do
      %{access_token: vtok} = viewer = setup_user_and_token()

      assert {:ok, _} =
               NoizuPromptLingua.Authz.ScopedMemberships.add_member(
                 "organization",
                 org_id,
                 viewer.user.id,
                 "viewer"
               )

      vconn = authenticated_conn(build_conn(), vtok)
      assert %{"definitions" => _} = json_response(get(vconn, "#{@base}/#{org_id}/mock-mcp"), 200)

      assert %{"models" => _, "default" => _} =
               json_response(get(vconn, "#{@base}/#{org_id}/mock-mcp-models"), 200)

      assert %{"error" => "Insufficient permissions"} =
               json_response(post(vconn, "#{@base}/#{org_id}/mock-mcp", %{"slug" => "x"}), 403)
    end

    test "unknown org -> 404", %{conn: conn} do
      assert %{"error" => "Organization not found"} =
               json_response(get(conn, "#{@base}/no-such-org-xyz/mock-mcp"), 404)
    end
  end

  # ── definition CRUD + lifecycle ───────────────────────────────────────────

  describe "definition CRUD" do
    test "index empty then with filters", %{conn: conn, org_id: org_id} do
      assert %{"definitions" => []} = json_response(get(conn, "#{@base}/#{org_id}/mock-mcp"), 200)

      {201, resp} = create_def(conn, org_id)
      json_response(resp, 201)

      {201, resp2} =
        create_def(conn, org_id, %{"slug" => "mock-arch", "title" => "Arch", "prompt" => "p"})

      json_response(resp2, 201)

      put(conn, "#{@base}/#{org_id}/mock-mcp/mock-arch", %{"status" => "archived"})
      |> json_response(200)

      all = json_response(get(conn, "#{@base}/#{org_id}/mock-mcp"), 200)["definitions"]
      assert length(all) == 2

      assert [%{"slug" => "mock-arch"}] =
               json_response(get(conn, "#{@base}/#{org_id}/mock-mcp?status=archived"), 200)[
                 "definitions"
               ]

      assert [] =
               json_response(
                 get(conn, "#{@base}/#{org_id}/mock-mcp?project_id=#{Ecto.UUID.generate()}"),
                 200
               )[
                 "definitions"
               ]
    end

    test "create with project + active llm; show embeds llm + counts", %{
      conn: conn,
      org_id: org_id,
      port: port
    } do
      llm_id = create_llm(conn, org_id, "surface", port: port)

      project =
        post(conn, "#{@base}/#{org_id}/projects", %{
          "project" => %{"name" => "P", "slug" => "mm-proj-#{System.unique_integer([:positive])}"}
        })
        |> json_response(201)
        |> get_in(["project", "id"])

      {201, resp} =
        create_def(conn, org_id, %{
          "project_id" => project,
          "active_llm_id" => llm_id,
          "api_key" => nil
        })

      def_ = json_response(resp, 201)["definition"]
      assert def_["project_id"] == project
      assert def_["active_llm_id"] == llm_id
      assert def_["status"] == "draft"
      assert def_["tool_count"] == 0

      shown =
        json_response(get(conn, "#{@base}/#{org_id}/mock-mcp/#{def_["slug"]}"), 200)["definition"]

      assert shown["active_llm"]["id"] == llm_id
      assert shown["active_llm"]["api_key_set"] == true
      refute shown["active_llm"]["api_key"]
    end

    test "create validation errors", %{conn: conn, org_id: org_id} do
      {422, resp} = create_def(conn, org_id, %{"prompt" => nil})
      assert %{"errors" => errors} = json_response(resp, 422)
      assert errors["prompt"]

      # project from another org -> 422
      other_org = create_org(conn, System.unique_integer([:positive]))

      foreign_project =
        post(conn, "#{@base}/#{other_org}/projects", %{
          "project" => %{"name" => "F", "slug" => "fp-#{System.unique_integer([:positive])}"}
        })
        |> json_response(201)
        |> get_in(["project", "id"])

      {422, resp} = create_def(conn, org_id, %{"project_id" => foreign_project})

      assert %{"error" => "Project does not belong to this organization"} =
               json_response(resp, 422)

      # llm from another org -> 422
      foreign_llm = create_llm(conn, other_org, "surface")
      {422, resp} = create_def(conn, org_id, %{"active_llm_id" => foreign_llm})

      assert %{"error" => "LLM connection does not belong to this organization"} =
               json_response(resp, 422)
    end

    test "update fields; blank llm id tolerated", %{conn: conn, org_id: org_id} do
      {201, resp} = create_def(conn, org_id)
      slug = json_response(resp, 201)["definition"]["slug"]

      updated =
        json_response(
          put(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}", %{
            "title" => "Renamed",
            "prompt" => "New prompt.",
            "status" => "draft",
            "active_llm_id" => "",
            "schema_sql" => "CREATE TABLE notes(id int)",
            "tools_json" => [%{"name" => "x"}]
          }),
          200
        )["definition"]

      assert updated["title"] == "Renamed"
      assert updated["schema_sql"] == "CREATE TABLE notes(id int)"
      assert updated["active_llm_id"] == nil

      assert %{"definition" => %{"active_llm_id" => nil}} =
               json_response(get(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}"), 200)
    end

    test "update with foreign llm -> 422", %{conn: conn, org_id: org_id} do
      {201, resp} = create_def(conn, org_id)
      slug = json_response(resp, 201)["definition"]["slug"]
      other_org = create_org(conn, System.unique_integer([:positive]))
      foreign_llm = create_llm(conn, other_org, "surface")

      assert %{"error" => "LLM connection does not belong to this organization"} =
               json_response(
                 put(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}", %{
                   "active_llm_id" => foreign_llm
                 }),
                 422
               )
    end

    test "activate then delete lifecycle; unknown slug 404", %{conn: conn, org_id: org_id} do
      {201, resp} = create_def(conn, org_id)
      slug = json_response(resp, 201)["definition"]["slug"]

      assert %{"definition" => %{"status" => "active"}} =
               json_response(post(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}/activate"), 200)

      assert %{"deleted" => true} =
               json_response(delete(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}"), 200)

      assert %{"error" => "Mock MCP not found"} =
               json_response(delete(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}"), 404)

      assert %{"error" => "Mock MCP not found"} =
               json_response(
                 get(conn, "#{@base}/#{org_id}/mock-mcp/nope-#{System.unique_integer()}"),
                 404
               )
    end
  end

  # ── LLM connection pool ───────────────────────────────────────────────────

  describe "llm connection pool" do
    test "list is flat top-level; api_key_set true/false", %{conn: conn, org_id: org_id} do
      assert %{"llms" => []} = json_response(get(conn, "#{@base}/#{org_id}/mock-mcp-llms"), 200)

      with_key = create_llm(conn, org_id, "surface")
      no_key = create_llm(conn, org_id, "surface", api_key: "")

      llms = json_response(get(conn, "#{@base}/#{org_id}/mock-mcp-llms"), 200)["llms"]
      assert length(llms) == 2
      assert Enum.find(llms, &(&1["id"] == with_key))["api_key_set"] == true
      assert Enum.find(llms, &(&1["id"] == no_key))["api_key_set"] == false
    end

    test "create 422 when required fields missing", %{conn: conn, org_id: org_id} do
      resp = post(conn, "#{@base}/#{org_id}/mock-mcp-llms", %{"label" => "x"})
      assert %{"errors" => errors} = json_response(resp, 422)
      assert errors["provider"] && errors["model"]
    end

    test "update keeps blank api_key; 404 unknown", %{conn: conn, org_id: org_id, port: port} do
      id = create_llm(conn, org_id, "surface", port: port)

      assert %{"llm" => %{"id" => ^id, "label" => "renamed", "api_key_set" => true}} =
               json_response(
                 put(conn, "#{@base}/#{org_id}/mock-mcp-llms/#{id}", %{
                   "label" => "renamed",
                   "api_key" => ""
                 }),
                 200
               )

      bogus = Ecto.UUID.generate()

      assert %{"error" => "LLM connection not found"} =
               json_response(
                 put(conn, "#{@base}/#{org_id}/mock-mcp-llms/#{bogus}", %{"label" => "x"}),
                 404
               )
    end

    test "delete 200 then 404", %{conn: conn, org_id: org_id} do
      id = create_llm(conn, org_id, "surface")

      assert %{"deleted" => true} =
               json_response(delete(conn, "#{@base}/#{org_id}/mock-mcp-llms/#{id}"), 200)

      assert %{"error" => "LLM connection not found"} =
               json_response(delete(conn, "#{@base}/#{org_id}/mock-mcp-llms/#{id}"), 404)
    end
  end

  # ── generate-tools / invoke / call log ────────────────────────────────────

  describe "generate-tools (LLM stubbed via endpoint)" do
    test "happy path stores surface", %{conn: conn, org_id: org_id, port: port} do
      llm_id = create_llm(conn, org_id, "surface", port: port)
      {201, resp} = create_def(conn, org_id, %{"active_llm_id" => llm_id})
      slug = json_response(resp, 201)["definition"]["slug"]

      out =
        json_response(post(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}/generate-tools"), 200)

      assert [%{"name" => "echo"}] = out["tools"]
      assert [%{"uri" => "mock://notes"}] = out["resources"]
      assert [%{"name" => "hello"}] = out["prompts"]
      assert %{"postgres" => [], "weaviate" => []} = out["schema"]

      assert %{"definition" => %{"tool_count" => 1}} =
               json_response(get(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}"), 200)
    end

    test "invalid surface JSON -> 422 with raw", %{conn: conn, org_id: org_id, port: port} do
      llm_id = create_llm(conn, org_id, "badjson", port: port)
      {201, resp} = create_def(conn, org_id, %{"active_llm_id" => llm_id})
      slug = json_response(resp, 201)["definition"]["slug"]

      assert %{"error" => "LLM returned invalid surface JSON", "raw" => raw} =
               json_response(
                 post(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}/generate-tools"),
                 422
               )

      assert raw =~ "not json"
    end

    test "LLM failure -> 502 bad gateway", %{conn: conn, org_id: org_id, port: port} do
      llm_id = create_llm(conn, org_id, "status500", port: port)
      {201, resp} = create_def(conn, org_id, %{"active_llm_id" => llm_id})
      slug = json_response(resp, 201)["definition"]["slug"]

      assert %{"error" => "LLM call failed"} =
               json_response(
                 post(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}/generate-tools"),
                 502
               )
    end
  end

  describe "invoke playground + call log" do
    setup %{conn: conn, org_id: org_id, port: port} do
      llm_id = create_llm(conn, org_id, "toolcall", port: port)
      {201, resp} = create_def(conn, org_id, %{"active_llm_id" => llm_id})
      slug = json_response(resp, 201)["definition"]["slug"]

      tools = [
        %{
          "name" => "greet",
          "description" => "Greet",
          "handler" => "llm",
          "inputSchema" => %{"type" => "object"}
        }
      ]

      {:ok, _} = MockMCP.set_tools(slug, tools)

      {:ok, slug: slug}
    end

    test "unknown tool -> 404", %{conn: conn, org_id: org_id, slug: slug} do
      assert %{"error" => "Unknown tool: nope"} =
               json_response(
                 post(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}/invoke", %{"tool" => "nope"}),
                 404
               )
    end

    test "happy path -> content + logged", %{conn: conn, org_id: org_id, slug: slug} do
      out =
        json_response(
          post(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}/invoke", %{
            "tool" => "greet",
            "arguments" => %{"who" => "x"}
          }),
          200
        )

      assert [%{"text" => "mocked tool output"}] = out["content"]
      assert is_integer(out["latency_ms"])

      calls = json_response(get(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}/calls"), 200)["calls"]
      assert [%{"tool_name" => "greet", "method" => "invoke", "error" => nil}] = calls
    end

    test "LLM failure -> 502 + error logged", %{
      conn: conn,
      org_id: org_id,
      slug: slug,
      port: port
    } do
      # Flip the def's LLM to a failing endpoint.
      failing = create_llm(conn, org_id, "status500", port: port)
      put(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}", %{"active_llm_id" => failing})

      resp = post(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}/invoke", %{"tool" => "greet"})
      assert %{"error" => _} = json_response(resp, 502)

      calls = json_response(get(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}/calls"), 200)["calls"]
      assert [%{"tool_name" => "greet", "error" => err}] = calls
      assert err =~ "http_error"
    end
  end

  # ── state browser ─────────────────────────────────────────────────────────

  describe "provision-db + state browser" do
    setup %{conn: conn, org_id: org_id} do
      {201, resp} = create_def(conn, org_id)
      slug = json_response(resp, 201)["definition"]["slug"]
      {:ok, slug: slug}
    end

    test "provision is idempotent", %{conn: conn, org_id: org_id, slug: slug} do
      expected_db = MockMCP.schema_name(slug)
      out = json_response(post(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}/provision-db"), 200)
      assert out["provisioned"] == true
      assert out["db_name"] == expected_db

      assert %{"db_name" => ^expected_db, "provisioned" => true} =
               json_response(post(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}/provision-db"), 200)
    end

    test "tables endpoint lists the mock schema", %{conn: conn, org_id: org_id, slug: slug} do
      post(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}/provision-db")
      reset_search_path()

      assert %{"tables" => tables} =
               json_response(
                 get(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}/state/db/tables"),
                 200
               )

      refute "notes" in tables
    end

    # NOTE (cov-w2d): db_run pins the mock schema with `SET LOCAL search_path`;
    # on the sandbox connection that persists past the call and breaks Guardian
    # session loads on subsequent requests, so each test below exposes exactly
    # ONE db-touching HTTP call (last action). The full create/insert/select
    # chain is domain-level coverage (Wave 4).
    test "query runs DDL into the mock schema", %{conn: conn, org_id: org_id, slug: slug} do
      post(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}/provision-db")
      reset_search_path()

      assert %{"columns" => [], "rows" => []} =
               json_response(
                 post(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}/state/db/query", %{
                   "sql" => "CREATE TABLE notes(id int)"
                 }),
                 200
               )
    end

    test "query surfaces postgres errors as 422", %{conn: conn, org_id: org_id, slug: slug} do
      post(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}/provision-db")
      reset_search_path()

      assert %{"error" => error} =
               json_response(
                 post(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}/state/db/query", %{
                   "sql" => "SELECT * FROM missing_table"
                 }),
                 422
               )

      assert error =~ "does not exist"
    end

    test "query without sql -> 400; unprovisioned -> 422", %{
      conn: conn,
      org_id: org_id,
      slug: slug
    } do
      assert %{"error" => "missing 'sql'"} =
               json_response(
                 post(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}/state/db/query", %{}),
                 400
               )

      assert %{"error" => msg} =
               json_response(
                 post(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}/state/db/query", %{
                   "sql" => "SELECT 1"
                 }),
                 422
               )

      assert msg =~ "no database provisioned"

      assert %{"error" => msg} =
               json_response(
                 get(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}/state/db/tables"),
                 422
               )

      assert msg =~ "no database provisioned"
    end

    @doc "BUG PIN: no guard stops reads of OTHER schemas via qualified names."
    test "BUG PIN: cross-schema reads are not blocked", %{conn: conn, org_id: org_id, slug: slug} do
      post(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}/provision-db")
      reset_search_path()

      assert %{"columns" => ["count"], "rows" => [[n]]} =
               json_response(
                 post(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}/state/db/query", %{
                   "sql" => "SELECT count(*) FROM public.organizations"
                 }),
                 200
               )

      assert is_integer(n) and n >= 1
    end

    @doc "BUG PIN: no row limit — generate_series streams every row to the caller."
    test "BUG PIN: unbounded result sets", %{conn: conn, org_id: org_id, slug: slug} do
      post(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}/provision-db")
      reset_search_path()

      assert %{"rows" => rows} =
               json_response(
                 post(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}/state/db/query", %{
                   "sql" => "SELECT * FROM generate_series(1, 5000)"
                 }),
                 200
               )

      assert length(rows) == 5000
    end

    test "redis keyspace dump", %{conn: conn, org_id: org_id, slug: slug} do
      def_ = MockMCP.get(slug)
      {:ok, _} = MockMCP.DataStore.redis_set(def_, "alpha", "one")
      {:ok, _} = MockMCP.DataStore.redis_set(def_, "beta", "two")

      assert %{"entries" => entries} =
               json_response(get(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}/state/redis"), 200)

      keys = Enum.map(entries, & &1["key"])
      assert "alpha" in keys and "beta" in keys
      assert %{"value" => "one"} = Enum.find(entries, &(&1["key"] == "alpha"))
    end
  end

  # DataStore.db_run pins the mock schema with `SET LOCAL search_path` inside a
  # transaction; on the sandbox connection that transaction is the test's own,
  # so the path persists for the rest of the test and breaks Guardian's
  # session load on the NEXT request. Reset it between HTTP calls.
  defp reset_search_path do
    Ecto.Adapters.SQL.query!(Repo, "SET search_path TO public", [])
    :ok
  end

  # ── modules (forge / review) ──────────────────────────────────────────────

  describe "module endpoints" do
    setup %{conn: conn, org_id: org_id} do
      {201, resp} = create_def(conn, org_id)
      slug = json_response(resp, 201)["definition"]["slug"]
      {:ok, slug: slug}
    end

    test "generate-modules with no module tools -> 200 empty", %{
      conn: conn,
      org_id: org_id,
      slug: slug
    } do
      assert %{"modules" => []} =
               json_response(
                 post(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}/generate-modules"),
                 200
               )
    end

    test "generate-modules drives the forge+repair loop to error entries", %{
      conn: conn,
      org_id: org_id,
      slug: slug,
      port: port
    } do
      llm_id = create_llm(conn, org_id, "junksrc", port: port)
      put(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}", %{"active_llm_id" => llm_id})

      MockMCP.set_tools(slug, [
        %{"name" => "ping", "impl" => "module", "description" => "p", "inputSchema" => %{}}
      ])

      assert %{"modules" => [%{"tool" => "ping", "status" => "error"}]} =
               json_response(
                 post(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}/generate-modules"),
                 200
               )
    end

    test "generate-modules disabled -> 403", %{conn: conn, org_id: org_id, slug: slug} do
      Application.put_env(:noizu_prompt_lingua, :mock_mcp, allow_modules: false)

      on_exit(fn -> Application.delete_env(:noizu_prompt_lingua, :mock_mcp) end)

      assert %{"error" => "module execution is disabled (mock_mcp.allow_modules=false)"} =
               json_response(
                 post(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}/generate-modules"),
                 403
               )
    end

    test "list modules", %{conn: conn, org_id: org_id, slug: slug} do
      MockMCP.set_modules(slug, [
        %{
          "tool" => "ping",
          "status" => "draft",
          "source" => "defmodule X do end",
          "module" => "X",
          "function" => "call",
          "last_error" => nil
        }
      ])

      assert %{"modules" => [%{"tool" => "ping"}]} =
               json_response(get(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}/modules"), 200)
    end

    test "update_module: garbage -> 422, valid -> draft; missing source -> 400", %{
      conn: conn,
      org_id: org_id,
      slug: slug
    } do
      url = "#{@base}/#{org_id}/mock-mcp/#{slug}/modules/ping"

      assert %{"error" => error, "module" => %{"status" => "error"}} =
               json_response(put(conn, url, %{"source" => "def oops("}), 422)

      assert error =~ "syntax error"

      module = NoizuPromptLingua.Domains.MockMCP.ModuleRuntime.module_name(slug, "ping")

      source = """
      defmodule #{inspect(module)} do
        def call(_args, _ctx), do: {:ok, %{"ok" => true}}
      end
      """

      assert %{"module" => %{"tool" => "ping", "status" => "draft"}} =
               json_response(put(conn, url, %{"source" => source}), 200)

      assert %{"error" => "missing 'source'"} = json_response(put(conn, url, %{}), 400)
    end

    test "approve + test + delete module lifecycle", %{conn: conn, org_id: org_id, slug: slug} do
      module = NoizuPromptLingua.Domains.MockMCP.ModuleRuntime.module_name(slug, "ping")

      source = """
      defmodule #{inspect(module)} do
        def call(_args, _ctx), do: {:ok, %{"pong" => true}}
      end
      """

      MockMCP.set_tools(slug, [
        %{"name" => "ping", "impl" => "module", "description" => "p", "inputSchema" => %{}}
      ])

      MockMCP.set_modules(slug, [
        %{
          "tool" => "ping",
          "module" => inspect(module),
          "function" => "call",
          "source" => source,
          "status" => "draft",
          "last_error" => nil
        }
      ])

      base = "#{@base}/#{org_id}/mock-mcp/#{slug}/modules/ping"

      assert %{"module" => %{"status" => "approved"}} =
               json_response(post(conn, base <> "/approve"), 200)

      out = json_response(post(conn, base <> "/test"), 200)
      assert is_list(out["results"])

      assert %{"ok" => true} = json_response(delete(conn, base), 200)

      assert %{"error" => "no module for tool 'ping'"} =
               json_response(post(conn, base <> "/approve"), 404)

      assert %{"error" => "no module for tool 'ghost'"} =
               json_response(
                 post(conn, "#{@base}/#{org_id}/mock-mcp/#{slug}/modules/ghost/test"),
                 404
               )
    end
  end

  # ── create auto-generate task ─────────────────────────────────────────────
end
