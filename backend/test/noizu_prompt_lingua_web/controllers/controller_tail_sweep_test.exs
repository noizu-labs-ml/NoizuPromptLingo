defmodule NoizuPromptLinguaWeb.ControllerTailSweepTest do
  @moduledoc """
  Coverage sweep for the still-test-less controller tail (Wave 4B):

    TokenController, ToolsController (validation arms only — the happy paths
    are live-network), BrowserController, BrowserSessionController,
    NPLController, UserController, VoiceAssistantController,
    OAuthConnectionsController, MemoryController, PolicyController,
    CustomRoleController.

  Slugs are UUID-suffixed throughout: the org slug→id resolver positives-cache
  outlives the test VM (see tool_set_gateway_test for the original finding).
  """

  use NoizuPromptLinguaWeb.ConnCase, async: false

  alias NoizuPromptLingua.Authz.ScopedMemberships
  alias NoizuPromptLingua.OAuth.Grants
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.McpApiKey
  alias NoizuPromptLingua.Schema.Organizations.Organization
  alias NoizuPromptLingua.Schema.Users.User

  import Ecto.Query, only: [from: 2]

  setup %{conn: conn} do
    %{access_token: token, user: user} = setup_user_and_token()
    auth = authenticated_conn(conn, token)

    # Org the caller is a plain viewer of (org_viewer-piped scopes).
    org =
      Repo.insert!(%Organization{
        name: "Tail Org",
        slug: "tail-org-" <> Ecto.UUID.generate()
      })

    {:ok, _} = ScopedMemberships.add_member("organization", org.id, user.id, "viewer")

    {:ok, conn: auth, user: user, org: org, token: token}
  end

  defp uniq, do: Ecto.UUID.generate()

  defp fwd(conn, tag),
    do: Plug.Conn.put_req_header(conn, "x-forwarded-for", "tail-#{tag}-#{uniq()}")

  # ── TokenController (POST /api/mcp/token) ─────────────────────────────────

  describe "TokenController" do
    test "mints an MCP JWT for a raw API key", %{conn: conn, user: user} do
      {raw_key, _key} = insert_api_key(user.id)

      resp =
        conn
        |> fwd("token-ok")
        |> post("/api/mcp/token", %{key: raw_key})
        |> json_response(200)

      assert resp["token_type"] == "Bearer"
      assert resp["expires_in"] > 0
      assert resp["expires_at"]
    end

    test "missing key -> 400", %{conn: conn} do
      conn = conn |> fwd("token-missing") |> post("/api/mcp/token", %{})

      assert conn.status == 400
    end

    test "bogus key -> 401", %{conn: conn} do
      conn = conn |> fwd("token-bad") |> post("/api/mcp/token", %{key: "mcp_t_nope"})

      assert conn.status == 401
    end

    test "mint disabled -> 410", %{conn: conn, user: user} do
      {raw_key, _key} = insert_api_key(user.id)
      prev = Application.get_env(:noizu_prompt_lingua, :mcp_legacy_api_keys)

      Application.put_env(:noizu_prompt_lingua, :mcp_legacy_api_keys, mint_enabled: false)

      on_exit(fn ->
        case prev do
          nil -> Application.delete_env(:noizu_prompt_lingua, :mcp_legacy_api_keys)
          kw -> Application.put_env(:noizu_prompt_lingua, :mcp_legacy_api_keys, kw)
        end
      end)

      conn = conn |> fwd("token-gone") |> post("/api/mcp/token", %{key: raw_key})

      assert conn.status == 410
    end
  end

  # ── ToolsController (POST /api/v1/tools/*) ────────────────────────────────

  describe "ToolsController" do
    test "web_search without a query -> 400", %{conn: conn} do
      conn = post(conn, "/api/v1/tools/web-search", %{"query" => "  "})
      assert conn.status == 400
      assert json_response(conn, 400)["error"] =~ "query is required"
    end

    test "web_search limit passes through when integer (unconfigured provider -> 503)", %{
      conn: conn
    } do
      # JINA_API_KEY is unset in TEST, so a valid query degrades to 503.
      conn = post(conn, "/api/v1/tools/web-search", %{"query" => "elixir", "limit" => 2})
      assert conn.status == 503
    end

    test "site_to_md without source -> 400", %{conn: conn} do
      conn = post(conn, "/api/v1/tools/site-to-md", %{})
      assert conn.status == 400
      assert json_response(conn, 400)["error"] =~ "source is required"
    end
  end

  # ── BrowserController ─────────────────────────────────────────────────────

  describe "BrowserController" do
    test "status reports disconnected with no controller", %{conn: conn, org: org} do
      resp = get(conn, "/api/v1/organizations/#{org.slug}/browser/status") |> json_response(200)
      assert resp["connected"] == false
    end

    test "captures lists (empty) for a known org", %{conn: conn, org: org} do
      resp = get(conn, "/api/v1/organizations/#{org.slug}/browser/captures") |> json_response(200)
      assert resp["captures"] == []
    end

    test "captures for an unknown org -> 404", %{conn: conn} do
      conn = get(conn, "/api/v1/organizations/never-a-slug/browser/captures")
      assert conn.status == 404
    end
  end

  # ── BrowserSessionController ──────────────────────────────────────────────

  describe "BrowserSessionController" do
    test "install serves the bash launcher", %{conn: conn} do
      conn = get(conn, "/browser-sessions")

      assert conn.status == 200
      assert hd(get_resp_header(conn, "content-type")) =~ "text/x-shellscript"
      assert conn.resp_body =~ "browser-controller"
    end

    test "bootstrap with a bogus key -> 401", %{conn: conn} do
      conn = conn |> fwd("boot-bad") |> post("/api/mcp/browser-bootstrap", %{key: "mcp_t_nope"})
      assert conn.status == 401
    end

    test "bootstrap exchanges a raw key for a token + primary org", %{
      conn: conn,
      user: user,
      org: org
    } do
      # setup already granted the caller a viewer membership (primary org).
      {raw_key, _key} = insert_api_key(user.id)

      resp =
        conn
        |> fwd("boot-ok")
        |> post("/api/mcp/browser-bootstrap", %{key: raw_key})
        |> json_response(200)

      assert resp["token"]
      assert resp["org_id"] == org.id
      assert resp["url"] =~ "wss://"
    end
  end

  # ── NPLController ─────────────────────────────────────────────────────────

  describe "NPLController" do
    test "sections + conventions + labels respond", %{conn: conn} do
      sections = get(conn, "/api/v1/npl/sections") |> json_response(200)
      assert is_map(sections)

      conventions = get(conn, "/api/v1/npl/conventions?section=syntax") |> json_response(200)
      assert is_map(conventions)

      labels = get(conn, "/api/v1/npl/labels") |> json_response(200)
      assert is_map(labels)
    end

    test "unknown convention in a real section -> 404", %{conn: conn} do
      %{"sections" => [%{"slug" => section} | _]} =
        get(conn, "/api/v1/npl/sections") |> json_response(200)

      # (An unknown SECTION 500s via the reader's error arm — flagged in the
      # W4B report as a soft-fail; the :not_found arm is slug-level.)
      conn = get(conn, "/api/v1/npl/conventions/#{section}/no-such-slug")
      assert conn.status == 404
    end

    test "generate_spec produces formatted output", %{conn: conn} do
      resp =
        post(conn, "/api/v1/npl/spec", %{"components" => [%{"spec" => "syntax"}]})
        |> json_response(200)

      assert resp["length"] == String.length(resp["spec"])
    end
  end

  # ── UserController (GET/PATCH /api/v1/users/me) ────────────────────────────

  describe "UserController" do
    test "show returns the serialized caller", %{conn: conn, user: user} do
      resp = get(conn, "/api/v1/users/me") |> json_response(200)
      assert resp["user"]["id"] == user.id
    end

    test "update persists bio", %{conn: conn} do
      resp =
        patch(conn, "/api/v1/users/me", %{user: %{bio: "hello there"}})
        |> json_response(200)

      assert resp["user"]["bio"] == "hello there"
    end

    test "privileged role self-assignment -> 422", %{conn: conn} do
      conn = patch(conn, "/api/v1/users/me", %{user: %{role: "admin"}})
      assert conn.status == 422
      assert json_response(conn, 422)["error"] =~ "role"
    end

    test "missing user param -> 400 fallback", %{conn: conn} do
      conn = patch(conn, "/api/v1/users/me", %{})
      assert conn.status == 400
    end
  end

  # ── VoiceAssistantController ──────────────────────────────────────────────

  describe "VoiceAssistantController" do
    test "approval_script builds the ticket draft for a member", %{conn: conn, org: org} do
      # NB: org UUID in path — the controller feeds the raw segment into Authz
      # (a slug here is a QueryCastException 500; flagged in the W4B report).
      resp =
        post(conn, "/api/v1/organizations/#{org.id}/assistant/approval-script", %{
          "transcript" => "file an expense report for the team lunch"
        })
        |> json_response(200)

      assert resp["approval_script"] =~ "Ticket.Create"
      assert resp["preview"]["organization"] == org.id
      assert resp["execution_enabled"] == false
    end

    test "non-member -> 403", %{conn: conn, org: org} do
      # A fresh session whose user holds no membership in this org. (A SLUG
      # org_id here QueryCastException-500s instead of 403 — the controller
      # feeds the raw path segment to Authz; flagged in the W4B report.)
      %{access_token: t2} = setup_user_and_token()

      conn =
        authenticated_conn(conn, t2)
        |> post("/api/v1/organizations/#{org.id}/assistant/approval-script", %{})

      assert conn.status == 403
    end
  end

  # ── OAuthConnectionsController ────────────────────────────────────────────

  describe "OAuthConnectionsController" do
    test "lists the caller's pairing grants", %{conn: conn, user: user} do
      # approve!/4 returns the grant struct itself (not a tagged tuple).
      grant = Grants.approve!(user.id, "tail-client", "https://mcp.example.com/tail")
      gid = grant.grant_id

      resp = get(conn, "/api/v1/auth/mcp/connections") |> json_response(200)

      assert [%{"grant_id" => ^gid, "status" => "active"}] = resp["connections"]
    end

    test "revoke: own grant -> ok, unknown/foreign -> 404", %{conn: conn, user: user} do
      grant = Grants.approve!(user.id, "tail-client-2", "https://mcp.example.com/tail2")

      assert json_response(delete(conn, "/api/v1/auth/mcp/connections/#{grant.grant_id}"), 200)[
               "status"
             ] == "revoked"

      assert json_response(delete(conn, "/api/v1/auth/mcp/connections/#{grant.grant_id}"), 404)

      assert json_response(delete(conn, "/api/v1/auth/mcp/connections/#{uniq()}"), 404)
    end
  end

  # ── MemoryController (read-only browser surface) ──────────────────────────

  describe "MemoryController" do
    test "agents lists the org scope selector (empty)", %{conn: conn, org: org} do
      resp = get(conn, "/api/organization/#{org.slug}/agents") |> json_response(200)
      assert resp["agents"] == []
    end

    test "agents for an unknown org -> 404", %{conn: conn} do
      conn = get(conn, "/api/organization/never-a-slug/agents")
      assert conn.status == 404
    end

    test "list for an unknown agent slug -> error arm (not 500)", %{conn: conn, org: org} do
      conn = get(conn, "/api/organization/#{org.slug}/agent/never-an-agent/memory")
      assert conn.status in [400, 404, 422]
    end
  end

  # ── PolicyController ──────────────────────────────────────────────────────

  describe "PolicyController (admin-scoped CRUD + user-scoped check/explain)" do
    test "index and create", %{conn: conn, user: user} do
      promote_admin(user)

      assert is_map(json_response(get(conn, "/api/v1/policies"), 200))

      resp =
        post(conn, "/api/v1/policies", %{
          policy: %{
            name: "tail-policy-#{uniq()}",
            policy_document: %{"statements" => [%{"effect" => "allow", "actions" => ["*"]}]}
          }
        })
        |> json_response(201)

      assert resp["policy"]["id"]
    end

    test "show/update/delete + system-policy guards", %{conn: conn, user: user} do
      promote_admin(user)

      {:ok, policy} =
        NoizuPromptLingua.Authz.Policies.create_policy(%{
          name: "tail-crud-#{uniq()}",
          policy_document: %{"statements" => [%{"effect" => "deny", "actions" => ["*"]}]}
        })

      assert json_response(get(conn, "/api/v1/policies/#{policy.id}"), 200)["policy"]["id"]

      updated =
        patch(conn, "/api/v1/policies/#{policy.id}", %{
          policy: %{description: "updated"}
        })
        |> json_response(200)

      assert updated["policy"]["description"] == "updated"

      assert json_response(delete(conn, "/api/v1/policies/#{policy.id}"), 200)["message"] =~
               "deleted"

      assert json_response(get(conn, "/api/v1/policies/#{policy.id}"), 404)
    end

    test "check + explain + my_policies answer for the caller", %{conn: conn, org: org} do
      resp =
        post(conn, "/api/v1/policies/check", %{
          resource_type: "organization",
          resource_id: org.id,
          action: "organization:view"
        })
        |> json_response(200)

      assert is_boolean(resp["allowed"])

      assert is_map(
               post(conn, "/api/v1/policies/explain", %{
                 resource_type: "organization",
                 resource_id: org.id,
                 action: "organization:view"
               })
               |> json_response(200)
             )

      assert is_map(json_response(get(conn, "/api/v1/policies/me"), 200))
    end
  end

  # ── CustomRoleController ──────────────────────────────────────────────────

  describe "CustomRoleController" do
    test "create/show/index/update/delete a custom role", %{conn: conn, user: user} do
      # The manage_settings gate floors at "member"; the setup caller is a
      # viewer, so this test brings its own org with a member-role grant.
      org =
        Repo.insert!(%Organization{
          name: "Tail Role Org",
          slug: "tail-role-org-" <> uniq()
        })

      {:ok, _} = ScopedMemberships.add_member("organization", org.id, user.id, "member")

      # NB: org UUID in path — the controller feeds the raw segment into Authz
      # (a slug here is a QueryCastException 500; flagged in the W4B report).
      base = "/api/v1/organizations/#{org.id}/roles"

      # index (viewer is enough)
      assert is_map(json_response(get(conn, base), 200))

      created =
        post(conn, base, %{
          role: %{name: "tail-role-#{uniq()}", display_name: "Tail Role", description: "sweep"}
        })
        |> json_response(201)

      role_id = created["role"]["id"]
      assert role_id

      assert json_response(get(conn, "#{base}/#{role_id}"), 200)["role"]["id"]

      updated =
        put(conn, "#{base}/#{role_id}", %{role: %{description: "renamed"}})
        |> json_response(200)

      assert updated["role"]["description"] == "renamed"

      assert json_response(delete(conn, "#{base}/#{role_id}"), 200)["message"] =~ "deactivated"
    end

    test "viewer cannot create (manage_settings gate) -> 403", %{conn: conn, org: org} do
      conn =
        post(conn, "/api/v1/organizations/#{org.id}/roles", %{
          role: %{name: "tail-role-denied", display_name: "Denied"}
        })

      assert conn.status == 403
    end
  end

  # ── fixtures ──────────────────────────────────────────────────────────────

  # Raw API key (bcrypt-verified by TokenController/BrowserSessionController).
  defp insert_api_key(user_id) do
    raw = "mcp_t_" <> String.replace(Ecto.UUID.generate(), "-", "")

    key =
      Repo.insert!(%McpApiKey{
        id: Ecto.UUID.generate(),
        user_id: user_id,
        key_prefix: binary_part(raw, 0, 8),
        key_hash: Bcrypt.hash_pwd_salt(raw),
        status: "active"
      })

    {raw, key}
  end

  # Promote the caller to a global admin (the :admin pipeline's RequireRole
  # reads the user's role from the DB, so the existing session token works).
  defp promote_admin(user) do
    Repo.update_all(from(u in User, where: u.id == ^user.id), set: [role: :admin])
    :ok
  end
end
