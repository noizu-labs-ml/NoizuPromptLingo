defmodule NoizuPromptLinguaWeb.OAuthControllerTest do
  @moduledoc """
  Controller-level coverage for the OAuth 2.1 endpoints beyond the consent
  flows already pinned by OAuthConsentTest (silent re-auth, manifest render,
  narrowing persistence): authorize param validation error arms, the signed-out
  authorize redirect, consent's stored-pending + deny/missing-challenge arms,
  every token grant branch and error arm (incl. client_secret_basic), DCR
  register, revoke, and the elevation step-up (show + submit, all arms).

  `metadata/2` is routed nowhere (discovery is served by WellKnownController at
  /oauth-authorization-server), so it is exercised by direct invocation.
  """

  use NoizuPromptLinguaWeb.ConnCase, async: false

  alias NoizuPromptLingua.OAuth.{Clients, Elevation, Grants, TokenService}
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.OAuthClient
  alias NoizuPromptLingua.Schema.Users.User

  @redirect_uri "http://127.0.0.1:9876/callback"

  setup do
    NoizuPromptLingua.OAuthTestSchema.ensure!()

    uniq = System.unique_integer([:positive])

    user =
      %User{
        id: Ecto.UUID.generate(),
        email: "oauthctl-#{uniq}@example.com",
        user_name: "oauthctl#{uniq}",
        handle: "oauthctl#{uniq}",
        status: :active,
        verified: true,
        flagged: false
      }
      |> Repo.insert!()

    {:ok, reg} =
      Clients.register(%{
        "client_name" => "oauth-ctl-cli-#{uniq}",
        "redirect_uris" => [@redirect_uri],
        "token_endpoint_auth_method" => "none"
      })

    client = Clients.get_active(reg["client_id"])

    verifier = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
    challenge = :crypto.hash(:sha256, verifier) |> Base.url_encode64(padding: false)

    conn =
      build_conn()
      |> put_req_header("x-forwarded-for", "10.9.#{rem(uniq, 250)}.#{rem(uniq, 251)}")

    %{
      user: user,
      client: client,
      conn: conn,
      challenge: challenge,
      verifier: verifier,
      uniq: uniq
    }
  end

  defp signed_in(conn, user),
    do: Plug.Test.init_test_session(conn, %{"oauth_user_id" => user.id})

  defp authorize_params(client, challenge, overrides \\ %{}) do
    Map.merge(
      %{
        "response_type" => "code",
        "client_id" => client.client_id,
        "redirect_uri" => @redirect_uri,
        "code_challenge" => challenge,
        "code_challenge_method" => "S256",
        "state" => "st-ctl"
      },
      overrides
    )
  end

  defp issue_code(client, user, challenge, redirect_uri \\ @redirect_uri) do
    TokenService.issue_code!(%{
      client_id: client.client_id,
      user_id: user.id,
      redirect_uri: redirect_uri,
      resource: "https://tobor.locker/mcp",
      scope: "mcp",
      code_challenge: challenge,
      grant_id: nil
    })
  end

  defp token_request(conn, body, headers \\ []) do
    conn =
      Enum.reduce(headers, conn, fn {k, v}, acc -> put_req_header(acc, k, v) end)

    post(conn, "/oauth/token", body)
  end

  # ── authorize: validation + error arms ────────────────────────────────────

  describe "GET /oauth/authorize validation" do
    test "missing client_id -> 400 html", %{conn: conn, challenge: challenge} do
      conn =
        get(conn, "/oauth/authorize", %{
          "response_type" => "code",
          "redirect_uri" => @redirect_uri,
          "code_challenge" => challenge
        })

      assert conn.status == 400
      assert conn.resp_body =~ "client_id required"
    end

    test "missing redirect_uri -> 400 html", %{conn: conn, client: client, challenge: challenge} do
      conn =
        get(conn, "/oauth/authorize", %{
          "response_type" => "code",
          "client_id" => client.client_id,
          "code_challenge" => challenge
        })

      assert conn.status == 400
      assert conn.resp_body =~ "redirect_uri required"
    end

    test "missing code_challenge -> external error redirect (client + redirect known)", %{
      conn: conn,
      client: client
    } do
      conn =
        get(
          conn,
          "/oauth/authorize",
          authorize_params(client, nil) |> Map.delete("code_challenge")
        )

      assert conn.status == 302
      assert conn.resp_body =~ URI.encode_www_form("code_challenge required")
    end

    test "plain PKCE method -> external error redirect (client + redirect known)", %{
      conn: conn,
      client: client,
      challenge: challenge
    } do
      conn =
        get(
          conn,
          "/oauth/authorize",
          authorize_params(client, challenge, %{"code_challenge_method" => "plain"})
        )

      assert conn.status == 302
      assert conn.resp_body =~ URI.encode_www_form("only S256 PKCE is supported")
    end

    test "response_type=token with unknown client -> 400 html invalid_request", %{conn: conn} do
      conn =
        get(conn, "/oauth/authorize", %{
          "response_type" => "token",
          "client_id" => "dcr_unknown",
          "redirect_uri" => @redirect_uri,
          "code_challenge" => String.duplicate("a", 43)
        })

      assert conn.status == 400
      assert conn.resp_body =~ "invalid_request"
    end

    test "response_type=token with known client -> external error redirect", %{
      conn: conn,
      client: client,
      challenge: challenge
    } do
      conn =
        get(
          conn,
          "/oauth/authorize",
          authorize_params(client, challenge, %{"response_type" => "token"})
        )

      assert conn.status == 302
      assert conn.resp_body =~ "error=invalid_request"
      assert conn.resp_body =~ "response_type"
    end

    test "unknown client_id -> 400 html invalid_client", %{conn: conn, challenge: challenge} do
      conn =
        get(
          conn,
          "/oauth/authorize",
          authorize_params(%{client_id: "dcr_nope"}, challenge)
        )

      assert conn.status == 400
      assert conn.resp_body =~ "invalid_client"
    end

    test "unregistered redirect_uri -> 400 html invalid_request", %{
      conn: conn,
      client: client,
      challenge: challenge
    } do
      conn =
        get(
          conn,
          "/oauth/authorize",
          authorize_params(client, challenge, %{"redirect_uri" => "http://127.0.0.1:9/evil"})
        )

      assert conn.status == 400
      assert conn.resp_body =~ "Invalid redirect_uri, grant, or PKCE"
    end
  end

  describe "GET /oauth/authorize signed-out" do
    test "no session defers to OIDC and stashes authorize params", %{
      conn: conn,
      client: client,
      challenge: challenge
    } do
      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> get("/oauth/authorize", authorize_params(client, challenge))

      assert conn.status == 302
      assert conn.resp_body =~ "/auth/oidc"

      stashed = get_session(conn, :oauth_authorize_params)
      assert stashed["client_id"] == client.client_id
      assert stashed["code_challenge"] == challenge
      assert stashed["state"] == "st-ctl"
    end
  end

  describe "GET /oauth/authorize prompt=consent" do
    test "standing grant + prompt=consent re-renders the manifest", %{
      conn: conn,
      user: user,
      client: client,
      challenge: challenge
    } do
      _grant = Grants.approve!(user.id, client.client_id, "https://tobor.locker/mcp", "mcp")

      conn =
        conn
        |> signed_in(user)
        |> get("/oauth/authorize", authorize_params(client, challenge, %{"prompt" => "consent"}))

      assert conn.status == 200
      assert conn.resp_body =~ "Requested tool access"
    end

    test "client lacking the code grant -> false arm (external error redirect)", %{
      conn: conn,
      user: user,
      challenge: challenge
    } do
      # Registered redirect_uri but the client is not allowed authorization_code.
      cid = "dcr_refreshonly-#{System.unique_integer([:positive])}"

      {:ok, _} =
        Repo.insert(%OAuthClient{
          client_id: cid,
          client_name: "refresh-only",
          redirect_uris: [@redirect_uri],
          grant_types: ["refresh_token"],
          status: "active"
        })

      conn =
        conn
        |> signed_in(user)
        |> get("/oauth/authorize", authorize_params(%{client_id: cid}, challenge))

      assert conn.status == 302
      assert conn.resp_body =~ "error=invalid_request"
      assert conn.resp_body =~ "Invalid"
    end
  end

  # ── consent: decision handling arms ───────────────────────────────────────

  describe "POST /oauth/consent" do
    test "missing decision -> 400", %{conn: conn} do
      conn = post(conn, "/oauth/consent", %{})

      assert conn.status == 400
      assert conn.resp_body =~ "decision required"
    end

    test "signed-out -> 401 html sign-in prompt", %{conn: conn, client: client} do
      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> post("/oauth/consent", %{"decision" => "approve", "client_id" => client.client_id})

      assert conn.status == 401
      assert conn.resp_body =~ "Sign in required"
    end

    test "unknown client and nothing stored -> 400", %{conn: conn, user: user} do
      conn =
        conn
        |> signed_in(user)
        |> post("/oauth/consent", %{"decision" => "approve", "client_id" => "dcr_ghost"})

      assert conn.status == 400
      assert conn.resp_body =~ "invalid client or redirect_uri"
    end

    test "approve with pending params in session falls back to stored values", %{
      conn: conn,
      user: user,
      client: client,
      challenge: challenge
    } do
      conn =
        conn
        |> signed_in(user)
        |> Plug.Test.init_test_session(%{
          "oauth_user_id" => user.id,
          "oauth_pending" => %{
            "client_id" => client.client_id,
            "redirect_uri" => @redirect_uri,
            "state" => "st-pending",
            "resource" => "https://tobor.locker/mcp",
            "scope" => "mcp",
            "code_challenge" => challenge
          }
        })
        |> post("/oauth/consent", %{"decision" => "approve"})

      assert conn.status == 302
      assert conn.resp_body =~ "code="
      assert conn.resp_body =~ "state=st-pending"
    end

    test "deny with no usable redirect_uri -> 400 html error page", %{
      conn: conn,
      user: user
    } do
      # Only a client whose registered URI list admits the blank URI can pass
      # the registered? gate and still fail the external-redirect guard — the
      # defensive 400 arm.
      cid = "dcr_blankuri-#{System.unique_integer([:positive])}"

      {:ok, _} =
        Repo.insert(%OAuthClient{
          client_id: cid,
          client_name: "blank-uri",
          redirect_uris: [""],
          grant_types: ["authorization_code", "refresh_token"],
          status: "active"
        })

      conn =
        conn
        |> signed_in(user)
        |> post("/oauth/consent", %{
          "decision" => "deny",
          "client_id" => cid,
          "redirect_uri" => ""
        })

      assert conn.status == 400
      assert conn.resp_body =~ "access_denied"
    end

    test "approve without code_challenge -> 400", %{
      conn: conn,
      user: user,
      client: client
    } do
      conn =
        conn
        |> signed_in(user)
        |> post("/oauth/consent", %{
          "decision" => "approve",
          "client_id" => client.client_id,
          "redirect_uri" => @redirect_uri
        })

      assert conn.status == 400
      assert conn.resp_body =~ "missing code_challenge"
    end

    test "bare approve with explicit params issues a code (narrowing capture ok-path)", %{
      conn: conn,
      user: user,
      client: client,
      challenge: challenge
    } do
      conn =
        conn
        |> signed_in(user)
        |> post("/oauth/consent", %{
          "decision" => "approve",
          "client_id" => client.client_id,
          "redirect_uri" => @redirect_uri,
          "state" => "st-bare",
          "resource" => "https://tobor.locker/mcp",
          "scope" => "mcp",
          "code_challenge" => challenge
        })

      assert conn.status == 302
      assert conn.resp_body =~ "code="
      assert conn.resp_body =~ "state=st-bare"
    end
  end

  # ── token: grant branches + error arms ────────────────────────────────────

  describe "POST /oauth/token" do
    test "unsupported grant_type -> 400", %{conn: conn} do
      conn = token_request(conn, %{"grant_type" => "password", "username" => "x"})

      assert conn.status == 400
      assert %{"error" => "unsupported_grant_type"} = json_response(conn, 400)
    end

    test "authorization_code with unknown client -> 401 invalid_client", %{conn: conn} do
      conn =
        token_request(conn, %{
          "grant_type" => "authorization_code",
          "client_id" => "dcr_missing",
          "code" => "ac_x",
          "code_verifier" => String.duplicate("v", 43),
          "redirect_uri" => @redirect_uri
        })

      assert conn.status == 401
      assert %{"error" => "invalid_client"} = json_response(conn, 401)
    end

    test "authorization_code with wrong client_secret -> 401 invalid_client", %{
      conn: conn,
      user: user,
      challenge: challenge,
      uniq: uniq
    } do
      {:ok, reg} =
        Clients.register(%{
          "client_name" => "secret-cli-#{uniq}",
          "redirect_uris" => [@redirect_uri],
          "token_endpoint_auth_method" => "client_secret_basic"
        })

      client = Clients.get_active(reg["client_id"])
      code = issue_code(client, user, challenge)

      conn =
        token_request(conn, %{
          "grant_type" => "authorization_code",
          "client_id" => client.client_id,
          "client_secret" => "wrong-secret",
          "code" => code,
          "code_verifier" => "nope",
          "redirect_uri" => @redirect_uri
        })

      assert conn.status == 401
      assert %{"error" => "invalid_client"} = json_response(conn, 401)
    end

    test "client not allowed authorization_code -> 400 unauthorized_client", %{conn: conn} do
      # A fetchable, active client whose grant_types exclude the code grant.
      cid = "dcr_restricted-#{System.unique_integer([:positive])}"

      {:ok, _} =
        Repo.insert(%OAuthClient{
          client_id: cid,
          client_name: "restricted",
          redirect_uris: [@redirect_uri],
          grant_types: ["refresh_token"],
          status: "active"
        })

      conn =
        token_request(conn, %{
          "grant_type" => "authorization_code",
          "client_id" => cid,
          "code" => "ac_x",
          "code_verifier" => String.duplicate("v", 43),
          "redirect_uri" => @redirect_uri
        })

      assert conn.status == 400
      assert %{"error" => "unauthorized_client"} = json_response(conn, 400)
    end

    test "authorization_code happy path mints access + refresh", %{
      conn: conn,
      user: user,
      client: client,
      challenge: challenge,
      verifier: verifier
    } do
      code = issue_code(client, user, challenge)

      conn =
        token_request(conn, %{
          "grant_type" => "authorization_code",
          "client_id" => client.client_id,
          "code" => code,
          "code_verifier" => verifier,
          "redirect_uri" => @redirect_uri
        })

      assert %{
               "access_token" => access,
               "token_type" => "Bearer",
               "refresh_token" => refresh,
               "expires_in" => ttl
             } = json_response(conn, 200)

      assert is_binary(access) and String.contains?(access, ".")
      assert String.starts_with?(refresh, "rt_")
      assert ttl > 0
    end

    test "authorization_code wrong verifier -> 400 invalid_grant", %{
      conn: conn,
      user: user,
      client: client,
      challenge: challenge
    } do
      code = issue_code(client, user, challenge)

      conn =
        token_request(conn, %{
          "grant_type" => "authorization_code",
          "client_id" => client.client_id,
          "code" => code,
          "code_verifier" => String.duplicate("z", 43),
          "redirect_uri" => @redirect_uri
        })

      assert conn.status == 400
      assert %{"error" => "invalid_grant"} = json_response(conn, 400)
    end

    test "authorization_code missing code -> 400 invalid_grant", %{
      conn: conn,
      client: client,
      verifier: verifier
    } do
      conn =
        token_request(conn, %{
          "grant_type" => "authorization_code",
          "client_id" => client.client_id,
          "code_verifier" => verifier,
          "redirect_uri" => @redirect_uri
        })

      assert conn.status == 400
      assert %{"error" => "invalid_grant"} = json_response(conn, 400)
    end

    test "non-binary code_verifier falls through to invalid_request", %{
      conn: conn,
      user: user,
      client: client,
      challenge: challenge
    } do
      code = issue_code(client, user, challenge)

      conn =
        token_request(conn, %{
          "grant_type" => "authorization_code",
          "client_id" => client.client_id,
          "code" => code,
          "code_verifier" => 123,
          "redirect_uri" => @redirect_uri
        })

      assert conn.status == 400
      assert %{"error" => "invalid_request"} = json_response(conn, 400)
    end

    test "token-exchange grant_type routes to the exchange handler", %{conn: conn} do
      conn =
        token_request(conn, %{
          "grant_type" => "urn:ietf:params:oauth:grant-type:token-exchange",
          "client_id" => "dcr_missing",
          "subject_token" => "junk"
        })

      # Unknown client inside the exchange handler -> invalid_client (401).
      assert conn.status in [400, 401]
      assert Map.has_key?(json_response(conn, conn.status), "error")
    end

    test "client_secret_basic header normalizes into client params", %{
      conn: conn,
      user: user,
      client: client,
      challenge: challenge,
      verifier: verifier,
      uniq: uniq
    } do
      {:ok, reg} =
        Clients.register(%{
          "client_name" => "basic-cli-#{uniq}",
          "redirect_uris" => [@redirect_uri],
          "token_endpoint_auth_method" => "client_secret_basic"
        })

      secret_client = Clients.get_active(reg["client_id"])
      code = issue_code(secret_client, user, challenge)

      basic = Base.encode64("#{secret_client.client_id}:#{reg["client_secret"]}")

      conn =
        token_request(
          conn,
          %{
            "grant_type" => "authorization_code",
            "code" => code,
            "code_verifier" => verifier,
            "redirect_uri" => @redirect_uri
          },
          [{"authorization", "Basic #{basic}"}]
        )

      assert %{"access_token" => _} = json_response(conn, 200)
    end

    test "malformed Basic header falls through -> invalid_client", %{conn: conn} do
      conn =
        token_request(
          conn,
          %{"grant_type" => "authorization_code", "code" => "ac_x"},
          [{"authorization", "Basic !!!not-base64!!!"}]
        )

      assert conn.status == 401
      assert %{"error" => "invalid_client"} = json_response(conn, 401)
    end
  end

  describe "POST /oauth/token refresh_token" do
    setup %{conn: conn, user: user, client: client, challenge: challenge, verifier: verifier} do
      code = issue_code(client, user, challenge)

      resp =
        token_request(conn, %{
          "grant_type" => "authorization_code",
          "client_id" => client.client_id,
          "code" => code,
          "code_verifier" => verifier,
          "redirect_uri" => @redirect_uri
        })

      %{"refresh_token" => refresh} = json_response(resp, 200)
      {:ok, refresh: refresh}
    end

    test "refresh rotates and old token is rejected on reuse", %{
      conn: conn,
      client: client,
      refresh: refresh
    } do
      conn =
        token_request(conn, %{
          "grant_type" => "refresh_token",
          "client_id" => client.client_id,
          "refresh_token" => refresh
        })

      assert %{"refresh_token" => rotated} = json_response(conn, 200)
      refute rotated == refresh

      # Old refresh token was revoked during rotation.
      conn2 =
        token_request(conn, %{
          "grant_type" => "refresh_token",
          "client_id" => client.client_id,
          "refresh_token" => refresh
        })

      assert conn2.status == 400
      assert %{"error" => "invalid_grant"} = json_response(conn2, 400)
    end

    test "refresh bound to another client -> 400 invalid_grant", %{
      conn: conn,
      user: user,
      challenge: challenge,
      verifier: verifier,
      refresh: refresh
    } do
      {:ok, other} =
        Clients.register(%{
          "client_name" => "other-cli-#{System.unique_integer([:positive])}",
          "redirect_uris" => [@redirect_uri],
          "token_endpoint_auth_method" => "none"
        })

      _ = {user, challenge, verifier}

      conn2 =
        token_request(conn, %{
          "grant_type" => "refresh_token",
          "client_id" => other["client_id"],
          "refresh_token" => refresh
        })

      assert conn2.status == 400
      assert %{"error" => "invalid_grant"} = json_response(conn2, 400)
    end
  end

  # ── register (DCR) ────────────────────────────────────────────────────────

  describe "POST /oauth/register" do
    test "happy path returns credentials incl. client_secret", %{conn: conn} do
      conn =
        post(conn, "/oauth/register", %{
          "redirect_uris" => ["http://127.0.0.1:8899/cb"],
          "client_name" => "dcr-happy",
          "token_endpoint_auth_method" => "client_secret_basic"
        })

      assert %{
               "client_id" => cid,
               "client_secret" => secret,
               "redirect_uris" => ["http://127.0.0.1:8899/cb"]
             } = json_response(conn, 201)

      assert String.starts_with?(cid, "dcr_")
      assert is_binary(secret) and secret != ""
    end

    test "non-allowlisted redirect_uri -> 400 invalid_redirect_uri", %{conn: conn} do
      conn =
        post(conn, "/oauth/register", %{
          "redirect_uris" => ["https://evil.example/cb"],
          "client_name" => "dcr-evil"
        })

      assert conn.status == 400
      assert %{"error" => "invalid_redirect_uri"} = json_response(conn, 400)
    end

    test "missing redirect_uris -> 400", %{conn: conn} do
      conn = post(conn, "/oauth/register", %{"client_name" => "dcr-no-redirect"})

      assert conn.status == 400
      assert %{"error" => err} = json_response(conn, 400)
      assert err in ["invalid_redirect_uri", "invalid_client_metadata"]
    end
  end

  # ── revoke ────────────────────────────────────────────────────────────────

  describe "POST /oauth/revoke" do
    test "revokes a live refresh token (always 200)", %{
      conn: conn,
      user: user,
      client: client,
      challenge: challenge,
      verifier: verifier
    } do
      code = issue_code(client, user, challenge)

      %{"refresh_token" => refresh} =
        token_request(conn, %{
          "grant_type" => "authorization_code",
          "client_id" => client.client_id,
          "code" => code,
          "code_verifier" => verifier,
          "redirect_uri" => @redirect_uri
        })
        |> json_response(200)

      revoke_conn = post(conn, "/oauth/revoke", %{"token" => refresh})
      assert revoke_conn.status == 200

      # Revoked refresh can no longer be used.
      conn2 =
        token_request(conn, %{
          "grant_type" => "refresh_token",
          "client_id" => client.client_id,
          "refresh_token" => refresh
        })

      assert conn2.status == 400
    end

    test "unknown / missing token still 200 (RFC 7009)", %{conn: conn} do
      assert post(conn, "/oauth/revoke", %{"token" => "rt_does_not_exist"}).status == 200
      assert post(conn, "/oauth/revoke", %{}).status == 200
    end
  end

  # ── elevation ─────────────────────────────────────────────────────────────

  describe "GET /oauth/elevate" do
    test "signed-out -> redirect to OIDC", %{conn: conn} do
      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> get("/oauth/elevate", %{"txn" => "elv_x"})

      assert conn.status == 302
      assert conn.resp_body =~ "/auth/oidc"
    end

    test "owner sees the approval page", %{conn: conn, user: user} do
      txn = Elevation.create_txn!(%{user_id: user.id, tool: "db_drop", action: "rm"})

      conn = conn |> signed_in(user) |> get("/oauth/elevate", %{"txn" => txn})

      assert conn.status == 200
      assert conn.resp_body =~ "Approve sensitive action"
      assert conn.resp_body =~ "db_drop"
    end

    test "another user's txn -> 403", %{conn: conn, user: user, uniq: uniq} do
      other =
        %User{
          id: Ecto.UUID.generate(),
          email: "elev-other-#{uniq}@example.com",
          user_name: "elevother#{uniq}",
          handle: "elevother#{uniq}",
          status: :active
        }
        |> Repo.insert!()

      txn = Elevation.create_txn!(%{user_id: other.id, tool: "db_drop"})

      conn = conn |> signed_in(user) |> get("/oauth/elevate", %{"txn" => txn})

      assert conn.status == 403
      assert conn.resp_body =~ "not for your account"
    end

    test "unknown txn -> 404 expired page", %{conn: conn, user: user} do
      conn =
        conn
        |> signed_in(user)
        |> get("/oauth/elevate", %{"txn" => "elv_missing"})

      assert conn.status == 404
      assert conn.resp_body =~ "expired or was already used"
    end

    test "missing txn param -> 400", %{conn: conn, user: user} do
      conn = conn |> signed_in(user) |> get("/oauth/elevate")

      assert conn.status == 400
      assert conn.resp_body =~ "Missing txn"
    end
  end

  describe "POST /oauth/elevate" do
    test "signed-out -> redirect to OIDC", %{conn: conn} do
      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> post("/oauth/elevate", %{"txn" => "elv_x", "decision" => "approve"})

      assert conn.status == 302
    end

    test "approve mints a single-use elevation token", %{conn: conn, user: user} do
      txn = Elevation.create_txn!(%{user_id: user.id, tool: "db_drop", action: "rm"})

      conn =
        conn
        |> signed_in(user)
        |> post("/oauth/elevate", %{"txn" => txn, "decision" => "approve"})

      assert conn.status == 200
      assert conn.resp_body =~ "Elevation granted"
      assert conn.resp_body =~ "X-MCP-Elevation"
    end

    test "approve of unknown txn -> 400 failed page", %{conn: conn, user: user} do
      conn =
        conn
        |> signed_in(user)
        |> post("/oauth/elevate", %{"txn" => "elv_missing", "decision" => "approve"})

      assert conn.status == 400
      assert conn.resp_body =~ "Failed"
    end

    test "approve by non-owner -> 400", %{conn: conn, user: user, uniq: uniq} do
      other =
        %User{
          id: Ecto.UUID.generate(),
          email: "elev-submit-#{uniq}@example.com",
          user_name: "elevsubmit#{uniq}",
          handle: "elevsubmit#{uniq}",
          status: :active
        }
        |> Repo.insert!()

      txn = Elevation.create_txn!(%{user_id: other.id, tool: "db_drop"})

      conn =
        conn
        |> signed_in(user)
        |> post("/oauth/elevate", %{"txn" => txn, "decision" => "approve"})

      assert conn.status == 400
    end

    test "deny -> 200 denied page", %{conn: conn, user: user} do
      txn = Elevation.create_txn!(%{user_id: user.id, tool: "db_drop"})

      conn =
        conn
        |> signed_in(user)
        |> post("/oauth/elevate", %{"txn" => txn, "decision" => "deny"})

      assert conn.status == 200
      assert conn.resp_body =~ "Elevation denied"
    end

    test "missing txn/decision -> 400", %{conn: conn, user: user} do
      conn = conn |> signed_in(user) |> post("/oauth/elevate", %{})

      assert conn.status == 400
      assert conn.resp_body =~ "txn and decision required"
    end
  end

  # ── metadata (unrouted action; served by WellKnown in production) ─────────

  describe "metadata/2" do
    test "returns discovery document with issuer + grant types", %{conn: _conn} do
      conn = NoizuPromptLinguaWeb.OAuthController.metadata(Phoenix.ConnTest.build_conn(), %{})

      assert conn.status == 200
      body = Jason.decode!(conn.resp_body)
      assert body["issuer"]
      assert "authorization_code" in body["grant_types_supported"]
    end
  end
end
