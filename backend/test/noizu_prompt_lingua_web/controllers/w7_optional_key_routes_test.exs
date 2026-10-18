defmodule NoizuPromptLinguaWeb.W7OptionalKeyRoutesTest do
  @moduledoc """
  W7 optional MCP-key acceptance on the personas index and ticket show
  routes (`:mcp_key_optional` in front of `:authenticated`, mirroring the
  boards/tickets listings scope). Proves, on both routes:

    * a valid raw MCP API key authenticates the key owner (200 path),
    * no credentials pass through anonymous and still 401 on the Guardian
      pipeline (existing behavior preserved),
    * an invalid key resolves to nothing and falls through to the same 401
      (the plug's `require: false` rejection semantics).
  """

  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.TRP.{Cache, TestStub}

  setup %{conn: conn} do
    Cache.clear()
    TestStub.reset()

    %{user: user, access_token: token} = setup_user_and_token()

    conn =
      conn
      |> authenticated_conn(token)
      |> unique_ip()

    slug = "w7-opt-org-#{System.unique_integer([:positive])}"

    created =
      post(conn, "/api/v1/organizations", %{organization: %{slug: slug, name: "W7 Optional Org"}})

    org_id = json_response(created, 201)["organization"]["id"]

    # mirror into the stub so Projects.get_project scans resolve
    TestStub.seed_org(org_id, slug)

    # seed data the two routes read: one persona, one ticket
    post(conn, "/api/v1/organizations/#{org_id}/personas", %{
      persona: %{slug: "w7-persona", name: "W7 Persona"}
    })

    %{"ticket" => %{"id" => ticket_id}} =
      json_response(
        post(conn, "/api/v1/organizations/#{org_id}/tickets", %{
          ticket: %{"title" => "W7 Show", "ticket_type" => "task"}
        }),
        201
      )

    {:ok, _key, raw_key} = MCPApiKeys.generate_api_key(user.id, "w7-optional")

    {:ok, conn: conn, org_id: org_id, ticket_id: ticket_id, raw_key: raw_key}
  end

  defp unique_ip(conn) do
    uniq = System.unique_integer([:positive])

    put_req_header(conn, "x-forwarded-for", "10.7.#{rem(uniq, 250)}.#{rem(uniq, 251)}")
  end

  defp keyed_conn(conn, raw_key) do
    put_req_header(conn, "authorization", "Bearer #{raw_key}")
  end

  # ── GET /personas ─────────────────────────────────────────────

  describe "GET /api/v1/organizations/:org_id/personas with optional MCP key" do
    test "valid raw MCP API key authenticates the key owner", %{
      conn: conn,
      org_id: org_id,
      raw_key: raw_key
    } do
      body =
        conn
        |> keyed_conn(raw_key)
        |> get("/api/v1/organizations/#{org_id}/personas")
        |> json_response(200)

      assert [%{"name" => "W7 Persona"}] = body["personas"]
    end

    test "no credentials passes through anonymous and 401s", %{org_id: org_id} do
      # fresh conn: no Authorization header of any kind
      assert json_response(
               build_conn()
               |> unique_ip()
               |> get("/api/v1/organizations/#{org_id}/personas"),
               401
             )
    end

    test "invalid key falls through and 401s", %{conn: conn, org_id: org_id} do
      conn
      |> keyed_conn("not-a-real-key")
      |> get("/api/v1/organizations/#{org_id}/personas")
      |> json_response(401)
    end
  end

  # ── GET /tickets/:id ──────────────────────────────────────────

  describe "GET /api/v1/organizations/:org_id/tickets/:id with optional MCP key" do
    test "valid raw MCP API key authenticates the key owner", %{
      conn: conn,
      org_id: org_id,
      ticket_id: ticket_id,
      raw_key: raw_key
    } do
      body =
        conn
        |> keyed_conn(raw_key)
        |> get("/api/v1/organizations/#{org_id}/tickets/#{ticket_id}")
        |> json_response(200)

      assert body["ticket"]["id"] == ticket_id
    end

    test "no credentials passes through anonymous and 401s", %{
      org_id: org_id,
      ticket_id: ticket_id
    } do
      # fresh conn: no Authorization header of any kind
      assert json_response(
               build_conn()
               |> unique_ip()
               |> get("/api/v1/organizations/#{org_id}/tickets/#{ticket_id}"),
               401
             )
    end

    test "invalid key falls through and 401s", %{
      conn: conn,
      org_id: org_id,
      ticket_id: ticket_id
    } do
      conn
      |> keyed_conn("not-a-real-key")
      |> get("/api/v1/organizations/#{org_id}/tickets/#{ticket_id}")
      |> json_response(401)
    end
  end
end
