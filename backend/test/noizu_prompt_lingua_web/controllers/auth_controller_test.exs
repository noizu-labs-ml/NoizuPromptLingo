defmodule NoizuPromptLinguaWeb.AuthControllerTest do
  @moduledoc """
  Session plane of AuthController: refresh-token rotation + reuse denial (the
  security-critical path), /auth/me serialization, and the user-scoped MCP API
  key CRUD (create/list/show/update/clone/revoke), key-to-JWT minting, mcp
  config/catalog, and the default-endpoint show/update.

  Auth routes share a per-IP Hammer bucket (:rate_limited_auth, 10/min); each
  test pins a unique x-forwarded-for so the suite never self-throttles.
  """

  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.MCPApiKeys

  setup %{conn: conn} do
    %{user: user, access_token: token, refresh_token: refresh} = setup_user_and_token()

    # Unique rate-limit bucket per test (the plug prefers x-forwarded-for).
    conn =
      conn
      |> put_req_header(
        "x-forwarded-for",
        "10.77.#{rem(System.unique_integer([:positive]), 200)}.1"
      )
      |> authenticated_conn(token)

    {:ok, conn: conn, user: user, refresh_token: refresh}
  end

  # ── refresh rotation (security-critical) ────────────────────────────────────

  describe "POST /api/v1/auth/refresh" do
    test "rotates: new pair issued, old refresh token revoked", %{
      conn: conn,
      refresh_token: refresh
    } do
      body = conn |> post("/api/v1/auth/refresh", %{refresh_token: refresh}) |> json_response(200)

      assert is_binary(body["access_token"]) and body["access_token"] != ""
      assert is_binary(body["refresh_token"]) and body["refresh_token"] != refresh

      # Reuse of the rotated-away refresh token is denied even though the JWT
      # itself is still signature-valid (jti revoked in the store).
      conn2 = put_req_header(build_fresh_conn(), "x-forwarded-for", "10.77.98.2")

      assert json_response(post(conn2, "/api/v1/auth/refresh", %{refresh_token: refresh}), 401)[
               "error"
             ] == "Invalid refresh token"

      # The NEW refresh token chains: it rotates again cleanly.
      conn3 =
        authenticated_conn(
          put_req_header(build_fresh_conn(), "x-forwarded-for", "10.77.98.3"),
          body["refresh_token"]
        )

      second =
        post(conn3, "/api/v1/auth/refresh", %{refresh_token: body["refresh_token"]})
        |> json_response(200)

      assert is_binary(second["access_token"])
    end

    test "garbage token -> 401", %{conn: conn} do
      assert json_response(post(conn, "/api/v1/auth/refresh", %{refresh_token: "not-a-jwt"}), 401)[
               "error"
             ]
    end

    test "an ACCESS token is not a refresh token -> 401 (typ mismatch)", %{
      conn: conn,
      user: user
    } do
      {:ok, access_token, _} =
        NoizuPromptLingua.Guardian.encode_and_sign(
          %NoizuPromptLingua.Users.Sessions.UserSession{
            id: Ecto.UUID.generate(),
            user: {:ref, NoizuPromptLingua.Users.User, user.id},
            status: :active,
            details: %{}
          },
          %{},
          token_type: "access",
          ttl: {1, :hour}
        )

      assert json_response(
               post(conn, "/api/v1/auth/refresh", %{refresh_token: access_token}),
               401
             )[
               "error"
             ]
    end

    test "valid JWT whose jti was never stored -> 401 (Redis allowlist miss)", %{
      conn: conn,
      user: user
    } do
      {:ok, orphan_refresh, _} =
        NoizuPromptLingua.Guardian.encode_and_sign(
          %NoizuPromptLingua.Users.Sessions.UserSession{
            id: Ecto.UUID.generate(),
            user: {:ref, NoizuPromptLingua.Users.User, user.id},
            status: :active,
            details: %{}
          },
          %{},
          token_type: "refresh",
          ttl: {7, :day}
        )

      assert json_response(
               post(conn, "/api/v1/auth/refresh", %{refresh_token: orphan_refresh}),
               401
             )["error"]
    end
  end

  # ── me ──────────────────────────────────────────────────────────────────────

  describe "GET /api/v1/auth/me" do
    test "returns the serialized user (DB columns incl. role/bio) + organizations", %{
      conn: conn,
      user: user
    } do
      body = json_response(get(conn, "/api/v1/auth/me"), 200)

      assert body["user"]["id"] == user.id
      assert body["user"]["email"] == user.email
      assert Map.has_key?(body["user"], "role")
      assert Map.has_key?(body["user"], "bio")
      assert is_list(body["organizations"])
    end
  end

  # ── MCP API keys ────────────────────────────────────────────────────────────

  describe "mcp api keys CRUD" do
    test "create -> list -> show -> update -> clone -> revoke", %{conn: conn} do
      created =
        conn
        |> post("/api/v1/auth/mcp-keys", %{key: %{label: "cli"}})
        |> json_response(201)

      key = created["key"]
      assert key["label"] == "cli"
      assert key["status"] == "active"
      assert is_binary(created["raw_key"]) and created["raw_key"] != ""
      refute Map.has_key?(key, "key_hash")

      listed = conn |> get("/api/v1/auth/mcp-keys") |> json_response(200)
      assert Enum.any?(listed["keys"], &(&1["id"] == key["id"]))

      shown = conn |> get("/api/v1/auth/mcp-keys/#{key["id"]}") |> json_response(200)
      assert shown["key"]["id"] == key["id"]

      renamed =
        conn
        |> patch("/api/v1/auth/mcp-keys/#{key["id"]}", %{label: "renamed"})
        |> json_response(200)

      assert renamed["key"]["label"] == "renamed"

      cloned =
        conn
        |> post("/api/v1/auth/mcp-keys/#{key["id"]}/clone", %{label: "clone"})
        |> json_response(201)

      assert cloned["key"]["id"] != key["id"]
      assert is_binary(cloned["raw_key"])

      revoked = conn |> delete("/api/v1/auth/mcp-keys/#{key["id"]}") |> json_response(200)
      assert revoked["key"]["status"] == "revoked"

      # Revoking an already-revoked key is idempotent (the row stays listed).
      again = conn |> delete("/api/v1/auth/mcp-keys/#{key["id"]}") |> json_response(200)
      assert again["key"]["status"] == "revoked"
    end

    test "create with toolset_config and bogus expires_at", %{conn: conn} do
      ok =
        conn
        |> post("/api/v1/auth/mcp-keys", %{
          key: %{label: "tooled", toolset_config: %{"groups" => %{"sessions" => %{}}}}
        })
        |> json_response(201)

      # Group configs are normalized to carry a "tools" map.
      assert ok["key"]["toolset_config"] == %{"groups" => %{"sessions" => %{"tools" => %{}}}}

      body =
        conn
        |> post("/api/v1/auth/mcp-keys", %{key: %{label: "x", expires_at: "not-a-date"}})
        |> json_response(422)

      assert body["error"] =~ "expires_at"
    end

    test "another user's key is invisible (404) for show/update/clone/revoke", %{conn: conn} do
      %{user: other} = setup_user_and_token()
      {:ok, other_key, _raw} = MCPApiKeys.generate_api_key(other.id, "theirs")

      for {method, path} <- [
            {:get, "/api/v1/auth/mcp-keys/#{other_key.id}"},
            {:patch, "/api/v1/auth/mcp-keys/#{other_key.id}"},
            {:post, "/api/v1/auth/mcp-keys/#{other_key.id}/clone"},
            {:delete, "/api/v1/auth/mcp-keys/#{other_key.id}"}
          ] do
        conn =
          case method do
            :get -> get(conn, path)
            :patch -> patch(conn, path, %{label: "x"})
            :post -> post(conn, path, %{})
            :delete -> delete(conn, path)
          end

        assert json_response(conn, 404)["error"] == "Key not found"
      end
    end
  end

  describe "POST /api/v1/auth/mcp/token (mint from pasted key)" do
    test "mints a JWT for your own raw key", %{conn: conn} do
      created =
        conn
        |> post("/api/v1/auth/mcp-keys", %{key: %{label: "mint-me"}})
        |> json_response(201)

      body =
        conn
        |> post("/api/v1/auth/mcp/token", %{key: created["raw_key"]})
        |> json_response(200)

      assert is_binary(body["token"])
      assert body["token_type"] == "Bearer"
      assert body["expires_in"] > 0
      assert is_binary(body["expires_at"])
    end

    test "unknown key and foreign key both 401 (no existence leak); missing key 400", %{
      conn: conn
    } do
      assert json_response(
               post(conn, "/api/v1/auth/mcp/token", %{key: "npl_totally_unknown"}),
               401
             )[
               "error"
             ]

      %{user: other} = setup_user_and_token()
      {:ok, _other_key, other_raw} = MCPApiKeys.generate_api_key(other.id, "theirs")

      assert json_response(post(conn, "/api/v1/auth/mcp/token", %{key: other_raw}), 401)["error"]

      assert json_response(post(conn, "/api/v1/auth/mcp/token", %{}), 400)["error"] ==
               "key required"
    end

    test "mint disabled -> 410 gone", %{conn: conn} do
      prev = Application.get_env(:noizu_prompt_lingua, :mcp_legacy_api_keys)

      Application.put_env(:noizu_prompt_lingua, :mcp_legacy_api_keys, mint_enabled: false)

      try do
        assert json_response(post(conn, "/api/v1/auth/mcp/token", %{key: "x"}), 410)
      after
        Application.put_env(:noizu_prompt_lingua, :mcp_legacy_api_keys, prev)
      end
    end
  end

  describe "POST /api/v1/auth/mcp-keys/setup (one-step create + mint)" do
    test "creates key + token in one call", %{conn: conn} do
      body =
        conn
        |> post("/api/v1/auth/mcp-keys/setup", %{key: %{label: "setup"}, resource: "mcp"})
        |> json_response(201)

      assert is_binary(body["raw_key"])
      assert is_binary(body["token"])
      assert body["key"]["label"] == "setup"
    end

    test "bogus expires_at -> 422", %{conn: conn} do
      body =
        conn
        |> post("/api/v1/auth/mcp-keys/setup", %{key: %{expires_at: "yesterday"}})
        |> json_response(422)

      assert body["error"] =~ "expires_at"
    end
  end

  # ── mcp config / catalog / default endpoint ─────────────────────────────────

  describe "mcp config + catalog" do
    test "default packaging payload", %{conn: conn} do
      body = json_response(get(conn, "/api/v1/auth/mcp/config"), 200)

      assert is_binary(body["host"])
      assert is_list(body["servers"])
      assert body["legacy_api_key_mint_enabled"] == true
      assert body["oauth"]["authorization_server_metadata"] =~ "oauth-authorization-server"
    end

    test "packaging=setup exposes ala_carte + default_scope; bad packaging -> 422", %{conn: conn} do
      body = json_response(get(conn, "/api/v1/auth/mcp/config?packaging=setup"), 200)
      assert body["default_scope"]
      assert is_list(body["ala_carte"])

      body = json_response(get(conn, "/api/v1/auth/mcp/config?packaging=bogus"), 422)
      assert body["error"] =~ "invalid packaging"
    end

    test "catalog lists customizable groups", %{conn: conn} do
      body = json_response(get(conn, "/api/v1/auth/mcp/catalog"), 200)
      assert is_list(body["groups"])
      assert length(body["groups"]) > 0
    end
  end

  describe "default endpoint show/update" do
    test "show returns the account default scope", %{conn: conn, user: user} do
      body = json_response(get(conn, "/api/v1/auth/mcp/default-endpoint"), 200)

      assert body["scope"]["user_id"] == user.id
      assert body["scope"]["is_default"] == true
    end

    test "update merges a config; invalid visibility -> 422", %{conn: conn} do
      body =
        conn
        |> patch("/api/v1/auth/mcp/default-endpoint", %{
          config: %{"groups" => %{"chat" => %{"disabled" => true}}}
        })
        |> json_response(200)

      assert body["scope"]["config"]["groups"]["chat"]["disabled"] == true

      body =
        conn
        |> patch("/api/v1/auth/mcp/default-endpoint", %{config: %{visibility: "bogus"}})
        |> json_response(422)

      assert body["errors"]
    end

    test "controller-level 401 without a session" do
      controller = NoizuPromptLinguaWeb.AuthController
      conn = Phoenix.ConnTest.build_conn()

      call = fn action, params ->
        conn |> Map.put(:params, params) |> controller.call(controller.init(action))
      end

      assert json_response(call.(:show_default_mcp, %{}), 401)["error"]
      assert json_response(call.(:update_default_mcp, %{}), 401)["error"]
    end
  end

  # ── helpers ─────────────────────────────────────────────────────────────────

  defp build_fresh_conn do
    Phoenix.ConnTest.build_conn()
  end
end
