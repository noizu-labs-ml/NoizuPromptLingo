defmodule NoizuPromptLinguaWeb.SSOOidcStub.Store do
  @moduledoc """
  Per-test endpoint responses for the local OIDC/OAuth stub server. Keyed by
  {port, path} so concurrent suites and multi-call flows (GitHub's token →
  /user → /emails) never collide; entries are single-use (taken on read).
  """
  @table :sso_oidc_stub_responses

  def put(key, value) do
    ensure()
    :ets.insert(@table, {key, value})
  end

  def take(key) do
    ensure()

    case :ets.take(@table, key) do
      [{_, v}] -> v
      [] -> []
    end
  end

  defp ensure do
    if :ets.whereis(@table) == :undefined do
      :ets.new(@table, [:named_table, :public, :set])
    end

    true
  end
end

defmodule NoizuPromptLinguaWeb.SSOOidcStub do
  @moduledoc """
  A tiny local IdP stand-in (discovery document + JWKS + token endpoint) so the
  SSOController's OIDC round-trip — authorization_uri, fetch_tokens, verify —
  is exercised against this test's own process instead of a real provider.
  """
  @behaviour Plug

  import Plug.Conn

  @impl true
  def init(opts), do: opts

  @impl true
  def call(%Plug.Conn{path_info: ["discovery"]} = conn, opts) do
    send_json(conn, 200, %{
      "issuer" => "https://stub-idp.test",
      "authorization_endpoint" => "https://stub-idp.test/authorize",
      "token_endpoint" => "http://127.0.0.1:#{opts.port}/token",
      "userinfo_endpoint" => "https://stub-idp.test/userinfo",
      "jwks_uri" => "http://127.0.0.1:#{opts.port}/jwks",
      "response_types_supported" => ["code"],
      "claims_supported" => ["iss", "sub", "aud", "exp", "email", "nonce"]
    })
  end

  def call(%Plug.Conn{path_info: ["jwks"]} = conn, opts) do
    send_json(conn, 200, %{"keys" => [opts.public_jwk]})
  end

  def call(conn, _opts) do
    case NoizuPromptLinguaWeb.SSOOidcStub.Store.take({conn.port, hd(conn.path_info)}) do
      %{status: status, json: json} -> send_json(conn, status, json)
      %{json: json} -> send_json(conn, 200, json)
      _ -> send_json(conn, 500, %{"error" => "no queued response"})
    end
  end

  defp send_json(conn, status, body) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(body))
    |> halt()
  end
end

defmodule NoizuPromptLinguaWeb.SSOControllerTest do
  @moduledoc """
  The SSO surface: provider discovery (`/api/v1/auth/sso/providers` + the
  tobor-kit `/api/v1/auth/config` shape), the OIDC redirect flows (Authentik
  and Google — init + callback with state/nonce handling; a forged callback
  must be refused before any network work), the GitHub OAuth2 flow (code
  exchange + identity fetch), the claim-code exchange, and the
  registration-token peek / register endpoints.

  Network boundary: the IdP is a local Bandit stub (see SSOOidcStub) serving
  the discovery document, JWKS, token endpoint, and (for GitHub) the /user and
  /user/emails identity endpoints; the id_token is signed with a
  test-generated RSA key whose public half the stub serves. No real outbound
  calls — every remote endpoint is 127.0.0.1.

  Not covered by design: Samly SAML ACS (disabled at compile in tests) and
  OpenIDConnect's internal HTTP failure modes beyond a 500 token response.
  """

  use NoizuPromptLinguaWeb.ConnCase

  import Ecto.Query, only: [from: 2]

  alias NoizuPromptLingua.Auth.RegistrationToken
  alias NoizuPromptLingua.Auth.TokenStore
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Users.Sessions.UserSession, as: SessionSchema
  alias NoizuPromptLingua.Schema.Users.User, as: UserSchema

  @provider_config_key :oidc_provider

  setup %{conn: conn} do
    %{user: user, access_token: token} = setup_user_and_token()

    # Unique rate-limit bucket per test (auth routes use :rate_limited_auth).
    conn =
      conn
      |> put_req_header(
        "x-forwarded-for",
        "10.78.#{rem(System.unique_integer([:positive]), 200)}.1"
      )
      |> authenticated_conn(token)

    {:ok, conn: conn, user: user}
  end

  # ── providers ───────────────────────────────────────────────────────────────

  describe "GET /api/v1/auth/sso/providers" do
    test "no providers when oidc is disabled", %{conn: conn} do
      assert json_response(get(conn, "/api/v1/auth/sso/providers"), 200) == %{"providers" => []}
    end

    test "oidc listed when enabled", %{conn: conn} do
      prev = Application.get_env(:noizu_prompt_lingua, :oidc_enabled)

      Application.put_env(:noizu_prompt_lingua, :oidc_enabled, true)

      try do
        assert json_response(get(conn, "/api/v1/auth/sso/providers"), 200) == %{
                 "providers" => ["oidc"]
               }
      after
        Application.put_env(:noizu_prompt_lingua, :oidc_enabled, prev)
      end
    end

    test "google and github listed only when enabled", %{conn: conn} do
      assert json_response(get(conn, "/api/v1/auth/sso/providers"), 200) == %{"providers" => []}

      prev_google = Application.get_env(:noizu_prompt_lingua, :google_enabled)
      prev_github = Application.get_env(:noizu_prompt_lingua, :github_enabled)

      Application.put_env(:noizu_prompt_lingua, :google_enabled, true)

      try do
        assert json_response(get(conn, "/api/v1/auth/sso/providers"), 200) == %{
                 "providers" => ["google"]
               }
      after
        Application.put_env(:noizu_prompt_lingua, :google_enabled, prev_google)
      end

      Application.put_env(:noizu_prompt_lingua, :google_enabled, true)
      Application.put_env(:noizu_prompt_lingua, :github_enabled, true)

      try do
        assert json_response(get(conn, "/api/v1/auth/sso/providers"), 200) == %{
                 "providers" => ["google", "github"]
               }
      after
        Application.put_env(:noizu_prompt_lingua, :google_enabled, prev_google)
        Application.put_env(:noizu_prompt_lingua, :github_enabled, prev_github)
      end
    end
  end

  # ── auth config (tobor-kit noizu-auth provider discovery) ──────────────────

  describe "GET /api/v1/auth/config" do
    test "empty providers when nothing is enabled", %{conn: conn} do
      assert json_response(get(conn, "/api/v1/auth/config"), 200) == %{"providers" => []}
    end

    test "publishes only enabled providers with id/label/href", %{conn: conn} do
      prev_google = Application.get_env(:noizu_prompt_lingua, :google_enabled)
      prev_github = Application.get_env(:noizu_prompt_lingua, :github_enabled)

      Application.put_env(:noizu_prompt_lingua, :google_enabled, true)

      try do
        assert json_response(get(conn, "/api/v1/auth/config"), 200) == %{
                 "providers" => [
                   %{
                     "id" => "google",
                     "label" => "Sign in with Google",
                     "href" => "/auth/google"
                   }
                 ]
               }
      after
        Application.put_env(:noizu_prompt_lingua, :google_enabled, prev_google)
      end

      Application.put_env(:noizu_prompt_lingua, :google_enabled, true)
      Application.put_env(:noizu_prompt_lingua, :github_enabled, true)

      try do
        assert %{
                 "providers" => [
                   %{"id" => "google", "href" => "/auth/google"},
                   %{"id" => "github", "href" => "/auth/github"}
                 ]
               } = json_response(get(conn, "/api/v1/auth/config"), 200)
      after
        Application.put_env(:noizu_prompt_lingua, :google_enabled, prev_google)
        Application.put_env(:noizu_prompt_lingua, :github_enabled, prev_github)
      end
    end
  end

  # ── OIDC init ───────────────────────────────────────────────────────────────

  describe "GET /auth/oidc (init)" do
    test "unconfigured provider redirects back with oidc_failed", %{conn: conn} do
      prev = Application.get_env(:noizu_prompt_lingua, @provider_config_key)
      Application.delete_env(:noizu_prompt_lingua, @provider_config_key)

      try do
        conn = get(conn, "/auth/oidc")
        assert redirected_to(conn, 302) =~ "error=oidc_failed"
      after
        if prev, do: Application.put_env(:noizu_prompt_lingua, @provider_config_key, prev)
      end
    end

    test "configured provider redirects to the IdP and stores state + nonce", %{conn: conn} do
      {:ok, _server, config, _opts} = start_oidc_stack()
      put_provider_config(config)

      conn = get(conn, "/auth/oidc")
      location = redirected_to(conn, 302)

      assert location =~ "https://stub-idp.test/authorize"
      assert location =~ "client_id=npl-test-client"
      assert location =~ "response_type=code"

      state = get_session(conn, :sso_state)
      nonce = get_session(conn, :sso_nonce)
      assert is_binary(state) and byte_size(state) > 20
      assert is_binary(nonce) and byte_size(nonce) > 20
      assert location =~ "state=#{state}"
    end
  end

  # ── OIDC callback ───────────────────────────────────────────────────────────

  describe "GET /auth/oidc/callback" do
    test "missing session state -> state_mismatch, before any IdP call", %{conn: conn} do
      conn =
        conn
        |> init_test_session(%{})
        |> get("/auth/oidc/callback?code=abc&state=forged")

      assert redirected_to(conn, 302) =~ "error=state_mismatch"
    end

    test "no code param -> oidc_failed", %{conn: conn} do
      conn =
        conn
        |> init_test_session(%{"sso_state" => "s-123"})
        |> get("/auth/oidc/callback?state=s-123")

      assert redirected_to(conn, 302) =~ "error=oidc_failed"
    end

    test "matching state but failing token endpoint -> oidc_failed catch-all", %{conn: conn} do
      {:ok, _server, config, opts} = start_oidc_stack()
      put_provider_config(config)

      NoizuPromptLinguaWeb.SSOOidcStub.Store.put({opts.port, "token"}, %{
        status: 500,
        json: %{"error" => "boom"}
      })

      conn =
        conn
        |> init_test_session(%{"sso_state" => "s-123", "sso_nonce" => "n-123"})
        |> get("/auth/oidc/callback?code=abc&state=s-123")

      assert redirected_to(conn, 302) =~ "error=oidc_failed"
    end

    test "full round-trip logs in an existing user and hands off a claim code", %{
      conn: conn,
      user: user
    } do
      {:ok, _server, config, opts} = start_oidc_stack()
      put_provider_config(config)

      jwt = id_token(opts.jwk, %{"sub" => "subj-1", "email" => user.email, "nonce" => "n-123"})
      NoizuPromptLinguaWeb.SSOOidcStub.Store.put({opts.port, "token"}, token_response(jwt))

      conn =
        conn
        |> init_test_session(%{"sso_state" => "s-123", "sso_nonce" => "n-123"})
        |> get("/auth/oidc/callback?code=real-code&state=s-123")

      location = redirected_to(conn, 302)
      assert location =~ "auth/sso-callback?code="
      assert location =~ "provider=authentik"

      # Session gained oauth_user_id and the one-time state/nonce were cleared.
      assert get_session(conn, :oauth_user_id) == user.id
      assert get_session(conn, :sso_state) == nil

      # The credential link + hand-off session landed.
      session =
        Repo.one(
          from(s in SessionSchema,
            where: s.user_id == ^user.id and not is_nil(s.claim_code)
          )
        )

      assert session && is_binary(session.claim_code)
    end

    test "unknown identity routes to registration with a verifiable token", %{conn: conn} do
      {:ok, _server, config, opts} = start_oidc_stack()
      put_provider_config(config)

      email = "sso-new-#{System.unique_integer([:positive])}@example.com"

      jwt = id_token(opts.jwk, %{"sub" => "brand-new-sub", "email" => email, "nonce" => "n-123"})
      NoizuPromptLinguaWeb.SSOOidcStub.Store.put({opts.port, "token"}, token_response(jwt))

      conn =
        conn
        |> init_test_session(%{"sso_state" => "s-123", "sso_nonce" => "n-123"})
        |> get("/auth/oidc/callback?code=real-code&state=s-123")

      location = redirected_to(conn, 302)
      assert location =~ "/auth/register?token="

      token = location |> URI.parse() |> Map.get(:query) |> URI.decode_query() |> Map.get("token")
      assert {:ok, identity} = RegistrationToken.verify(token)
      assert identity[:email] == email
      assert identity[:provider] == "authentik"
    end

    test "an in-flight MCP OAuth authorize is resumed instead of the SPA hand-off", %{
      conn: conn,
      user: user
    } do
      {:ok, _server, config, opts} = start_oidc_stack()
      put_provider_config(config)

      jwt = id_token(opts.jwk, %{"sub" => "subj-2", "email" => user.email, "nonce" => "n-123"})
      NoizuPromptLinguaWeb.SSOOidcStub.Store.put({opts.port, "token"}, token_response(jwt))

      conn =
        conn
        |> init_test_session(%{
          "sso_state" => "s-123",
          "sso_nonce" => "n-123",
          "oauth_authorize_params" => %{"client_id" => "abc", "response_type" => "code"}
        })
        |> get("/auth/oidc/callback?code=real-code&state=s-123")

      assert redirected_to(conn, 302) =~ ~r|^/oauth/authorize\?|
    end
  end

  # ── Google (OIDC) ──────────────────────────────────────────────────────────

  describe "GET /auth/google (init)" do
    test "unconfigured provider redirects back with google_failed", %{conn: conn} do
      prev = Application.get_env(:noizu_prompt_lingua, :google_provider)
      Application.delete_env(:noizu_prompt_lingua, :google_provider)

      try do
        conn = get(conn, "/auth/google")
        assert redirected_to(conn, 302) =~ "error=google_failed"
      after
        if prev, do: Application.put_env(:noizu_prompt_lingua, :google_provider, prev)
      end
    end

    test "configured provider redirects to the IdP and stores state + nonce", %{conn: conn} do
      {:ok, _server, config, _opts} = start_oidc_stack()
      put_provider_config(:google_provider, config)

      conn = get(conn, "/auth/google")
      location = redirected_to(conn, 302)

      assert location =~ "https://stub-idp.test/authorize"
      assert location =~ "client_id=npl-test-client"

      state = get_session(conn, :google_sso_state)
      nonce = get_session(conn, :google_sso_nonce)
      assert is_binary(state) and byte_size(state) > 20
      assert is_binary(nonce) and byte_size(nonce) > 20
      assert location =~ "state=#{state}"
    end
  end

  describe "GET /auth/google/callback" do
    test "missing session state -> state_mismatch, before any IdP call", %{conn: conn} do
      conn =
        conn
        |> init_test_session(%{})
        |> get("/auth/google/callback?code=abc&state=forged")

      assert redirected_to(conn, 302) =~ "error=state_mismatch"
    end

    test "no code param -> google_failed", %{conn: conn} do
      conn =
        conn
        |> init_test_session(%{"google_sso_state" => "s-123"})
        |> get("/auth/google/callback?state=s-123")

      assert redirected_to(conn, 302) =~ "error=google_failed"
    end

    test "full round-trip logs in an existing user and hands off a claim code", %{
      conn: conn,
      user: user
    } do
      {:ok, _server, config, opts} = start_oidc_stack()
      put_provider_config(:google_provider, config)

      jwt = id_token(opts.jwk, %{"sub" => "g-subj-1", "email" => user.email, "nonce" => "n-123"})
      NoizuPromptLinguaWeb.SSOOidcStub.Store.put({opts.port, "token"}, token_response(jwt))

      conn =
        conn
        |> init_test_session(%{"google_sso_state" => "s-123", "google_sso_nonce" => "n-123"})
        |> get("/auth/google/callback?code=real-code&state=s-123")

      location = redirected_to(conn, 302)
      assert location =~ "auth/sso-callback?code="
      assert location =~ "provider=google"
      assert get_session(conn, :oauth_user_id) == user.id
      assert get_session(conn, :google_sso_state) == nil
    end
  end

  # ── GitHub (OAuth2) ────────────────────────────────────────────────────────

  describe "GET /auth/github (init)" do
    test "unconfigured provider redirects back with github_failed", %{conn: conn} do
      prev = Application.get_env(:noizu_prompt_lingua, :github_provider)
      Application.delete_env(:noizu_prompt_lingua, :github_provider)

      try do
        conn = get(conn, "/auth/github")
        assert redirected_to(conn, 302) =~ "error=github_failed"
      after
        if prev, do: Application.put_env(:noizu_prompt_lingua, :github_provider, prev)
      end
    end

    test "configured provider redirects to the authorize URL and stores state", %{conn: conn} do
      {:ok, _server, config, _opts} = start_github_stack()
      put_provider_config(:github_provider, config)

      conn = get(conn, "/auth/github")
      location = redirected_to(conn, 302)

      assert location =~ "https://github.com/login/oauth/authorize"
      assert location =~ "client_id=gh-test-client"
      # URI.append_query encodes the scope's colon as %3A and space as +
      # (note: =~ with a plain string is a literal substring check)
      assert location =~ "scope=read%3Auser+user%3Aemail"

      state = get_session(conn, :github_sso_state)
      assert is_binary(state) and byte_size(state) > 20
      assert location =~ "state=#{state}"
    end
  end

  describe "GET /auth/github/callback" do
    test "missing session state -> state_mismatch, before any GitHub call", %{conn: conn} do
      conn =
        conn
        |> init_test_session(%{})
        |> get("/auth/github/callback?code=abc&state=forged")

      assert redirected_to(conn, 302) =~ "error=state_mismatch"
    end

    test "no code param -> github_failed", %{conn: conn} do
      conn =
        conn
        |> init_test_session(%{"github_sso_state" => "s-123"})
        |> get("/auth/github/callback?state=s-123")

      assert redirected_to(conn, 302) =~ "error=github_failed"
    end

    test "full round-trip exchanges the code, reads the primary email, logs in", %{
      conn: conn,
      user: user
    } do
      {:ok, _server, config, opts} = start_github_stack()
      put_provider_config(:github_provider, config)

      NoizuPromptLinguaWeb.SSOOidcStub.Store.put({opts.port, "token"}, %{
        json: %{"access_token" => "gho-stub-token", "token_type" => "bearer"}
      })

      NoizuPromptLinguaWeb.SSOOidcStub.Store.put({opts.port, "user"}, %{
        json: %{"id" => 98_765, "login" => "octocat", "name" => "Octo Cat", "email" => nil}
      })

      NoizuPromptLinguaWeb.SSOOidcStub.Store.put({opts.port, "emails"}, %{
        json: [
          %{"email" => "secondary@example.com", "primary" => false, "verified" => true},
          %{"email" => user.email, "primary" => true, "verified" => true}
        ]
      })

      conn =
        conn
        |> init_test_session(%{"github_sso_state" => "s-123"})
        |> get("/auth/github/callback?code=real-code&state=s-123")

      location = redirected_to(conn, 302)
      assert location =~ "auth/sso-callback?code="
      assert location =~ "provider=github"
      assert get_session(conn, :oauth_user_id) == user.id

      # The fingerprint used the numeric GitHub id, not the email.
      cred =
        Repo.one(
          from(c in NoizuPromptLingua.Schema.Users.Credentials.UserCredential,
            where: c.user_id == ^user.id and c.fingerprint == "github:98765"
          )
        )

      assert cred
    end

    test "failing token endpoint -> github_failed catch-all", %{conn: conn} do
      {:ok, _server, config, opts} = start_github_stack()
      put_provider_config(:github_provider, config)

      NoizuPromptLinguaWeb.SSOOidcStub.Store.put({opts.port, "token"}, %{
        status: 500,
        json: %{"error" => "boom"}
      })

      conn =
        conn
        |> init_test_session(%{"github_sso_state" => "s-123"})
        |> get("/auth/github/callback?code=abc&state=s-123")

      assert redirected_to(conn, 302) =~ "error=github_failed"
    end
  end

  # ── code exchange ───────────────────────────────────────────────────────────

  describe "POST /api/v1/auth/sso/exchange" do
    test "exchanges a live claim code once; reuse and unknown codes are 401", %{conn: conn} do
      code = "claim-#{System.unique_integer([:positive])}"
      insert_claim_session(code, seconds: 300)

      body = conn |> post("/api/v1/auth/sso/exchange", %{code: code}) |> json_response(200)

      assert is_binary(body["access_token"])
      assert is_binary(body["refresh_token"])
      assert body["user"]["id"]
      assert is_list(body["organizations"])

      # Single-use: the code was cleared in the same UPDATE that matched.
      assert json_response(post(conn, "/api/v1/auth/sso/exchange", %{code: code}), 401)["error"] ==
               "Invalid or expired SSO code"

      # The refresh jti was stored, so /auth/refresh will accept it later.
      {:ok, %{"jti" => jti}} = NoizuPromptLingua.Guardian.decode_and_verify(body["refresh_token"])
      assert TokenStore.valid_refresh_jti?(jti)

      assert json_response(
               post(conn, "/api/v1/auth/sso/exchange", %{code: "never-existed"}),
               401
             )["error"]
    end

    test "expired claim code -> 401", %{conn: conn} do
      code = "claim-exp-#{System.unique_integer([:positive])}"
      insert_claim_session(code, seconds: -60)

      assert json_response(post(conn, "/api/v1/auth/sso/exchange", %{code: code}), 401)["error"]
    end
  end

  # ── registration ────────────────────────────────────────────────────────────

  describe "registration peek + register" do
    test "GET /auth/sso/registration peeks at the pending identity", %{conn: conn} do
      identity = %{provider: "authentik", sub: "peek-sub", email: "peek@example.com"}
      token = RegistrationToken.sign(identity)

      body =
        json_response(
          get(conn, "/api/v1/auth/sso/registration?token=#{URI.encode_www_form(token)}"),
          200
        )

      assert body["email"] == "peek@example.com"
      assert body["provider"] == "authentik"

      assert json_response(get(conn, "/api/v1/auth/sso/registration?token=garbage"), 404)["error"]
    end

    test "POST /auth/sso/register creates the account, ignores client role, logs in", %{
      conn: conn
    } do
      email = "sso-register-#{System.unique_integer([:positive])}@example.com"
      token = RegistrationToken.sign(%{provider: "authentik", sub: "reg-sub-1", email: email})

      body =
        conn
        |> post("/api/v1/auth/sso/register", %{
          token: token,
          first: "New",
          last: "User",
          role: "admin"
        })
        |> json_response(200)

      assert body["user"]["email"] == email
      # Role is server-assigned: a client-sent "admin" never lands.
      assert body["user"]["role"] == "user"
      assert is_binary(body["access_token"])
      assert is_binary(body["refresh_token"])

      user_row = Repo.get_by(UserSchema, email: email)
      assert user_row.verified == true
      assert user_row.status == :active
    end

    test "expired registration token -> 401", %{conn: conn} do
      expired =
        Phoenix.Token.sign(
          NoizuPromptLinguaWeb.Endpoint,
          "sso_registration",
          %{provider: "authentik", sub: "s", email: "e@example.com"},
          signed_at: System.system_time(:second) - 700
        )

      assert json_response(post(conn, "/api/v1/auth/sso/register", %{token: expired}), 401)[
               "error"
             ] == "Invalid or expired registration"

      assert json_response(post(conn, "/api/v1/auth/sso/register", %{token: "garbage"}), 401)[
               "error"
             ]
    end

    test "unsupported provider identity -> 422 Registration failed", %{conn: conn} do
      token =
        RegistrationToken.sign(%{provider: "not-authentik", sub: "x", email: "x@example.com"})

      assert json_response(post(conn, "/api/v1/auth/sso/register", %{token: token}), 422)["error"] ==
               "Registration failed"
    end
  end

  # ── helpers ─────────────────────────────────────────────────────────────────

  defp put_provider_config(config), do: put_provider_config(@provider_config_key, config)

  defp put_provider_config(key, config) do
    prev = Application.get_env(:noizu_prompt_lingua, key)
    Application.put_env(:noizu_prompt_lingua, key, config)

    ExUnit.Callbacks.on_exit(fn ->
      Application.put_env(:noizu_prompt_lingua, key, prev)
    end)
  end

  # Boots the local IdP stand-in: Finch + document cache (shared, started once)
  # and a per-test Bandit server on a free port. Returns {config, plug_opts}.
  defp start_oidc_stack do
    ensure_oidc_processes()

    port = free_port()

    jwk = JOSE.JWK.generate_key({:rsa, 2048})

    public_jwk =
      case JOSE.JWK.to_public_map(jwk) do
        %{} = map -> map
        {_, map} -> map
      end

    opts = %{
      port: port,
      jwk: jwk,
      public_jwk: public_jwk
    }

    case Bandit.start_link(
           plug: {NoizuPromptLinguaWeb.SSOOidcStub, opts},
           scheme: :http,
           port: port
         ) do
      {:ok, pid} ->
        {:ok, pid, oidc_config(port), opts}

      {:error, :eaddrinuse} ->
        # Collision on the picked port: recurse with a new draw.
        :erlang.garbage_collect()
        start_oidc_stack()

      {:error, {:shutdown, {:failed_to_start_child, :listener, {:error, :eaddrinuse}}}} ->
        # Same collision, wrapped: Bandit sometimes surfaces the listener's
        # :eaddrinuse through its supervisor-child shutdown tuple (seen on
        # CI) — retry instead of crashing the test.
        :erlang.garbage_collect()
        start_oidc_stack()
    end
  end

  defp oidc_config(port) do
    %{
      discovery_document_uri: "http://127.0.0.1:#{port}/discovery",
      client_id: "npl-test-client",
      client_secret: "npl-test-secret",
      redirect_uri: "http://localhost:3000/auth/oidc-callback",
      scope: "openid email profile",
      response_type: "code",
      leeway: 30
    }
  end

  # GitHub stack: the same Bandit stub, no JWKS/discovery — the flat config
  # mirrors runtime.exs' :github_provider shape with 127.0.0.1 endpoints.
  defp start_github_stack do
    port = free_port()

    config = %{
      client_id: "gh-test-client",
      client_secret: "gh-test-secret",
      redirect_uri: "http://localhost:3000/auth/github/callback",
      authorize_url: "https://github.com/login/oauth/authorize",
      token_url: "http://127.0.0.1:#{port}/token",
      user_url: "http://127.0.0.1:#{port}/user",
      emails_url: "http://127.0.0.1:#{port}/emails",
      scope: "read:user user:email"
    }

    opts = %{port: port}

    case Bandit.start_link(plug: {NoizuPromptLinguaWeb.SSOOidcStub, opts}, scheme: :http, port: port) do
      {:ok, pid} ->
        {:ok, pid, config, opts}

      {:error, :eaddrinuse} ->
        :erlang.garbage_collect()
        start_github_stack()

      {:error, {:shutdown, {:failed_to_start_child, :listener, {:error, :eaddrinuse}}}} ->
        :erlang.garbage_collect()
        start_github_stack()
    end
  end

  defp ensure_oidc_processes do
    unless Process.whereis(OpenIDConnect.Finch) do
      {:ok, pid} = Finch.start_link(name: OpenIDConnect.Finch)
      Process.unlink(pid)
    end

    unless Process.whereis(OpenIDConnect.Document.Cache) do
      {:ok, pid} = OpenIDConnect.Document.Cache.start_link()
      Process.unlink(pid)
    end

    :ok
  end

  # Ask the OS for a port nobody holds instead of drawing from 40000–60000,
  # which overlaps Linux's ephemeral range (32768–60999): outbound sockets
  # (Postgres, Redis, Finch) already sit there, and a collision surfaced as a
  # linked Bandit listener EXIT that killed the test before the eaddrinuse
  # retry below could match.
  defp free_port do
    {:ok, socket} = :gen_tcp.listen(0, [])
    {:ok, port} = :inet.port(socket)
    :ok = :gen_tcp.close(socket)
    port
  end

  defp id_token(jwk, extra_claims) do
    now = System.system_time(:second)

    claims =
      Map.merge(
        %{
          "iss" => "https://stub-idp.test",
          "aud" => "npl-test-client",
          "exp" => now + 600,
          "iat" => now
        },
        extra_claims
      )

    {_jws, jwt} = JOSE.JWT.sign(jwk, %{"alg" => "RS256"}, claims) |> JOSE.JWS.compact()
    jwt
  end

  defp token_response(jwt) do
    %{
      json: %{
        "access_token" => "at-#{System.unique_integer([:positive])}",
        "id_token" => jwt,
        "token_type" => "Bearer",
        "expires_in" => 300
      }
    }
  end

  defp insert_claim_session(code, seconds: delta) do
    # claim_code_expires_at is :utc_datetime_usec — keep microsecond precision.
    expires = DateTime.utc_now() |> DateTime.add(delta, :second)

    user = insert_sso_user()

    Repo.insert!(%SessionSchema{
      user_id: user.id,
      status: :active,
      details: %{},
      claim_code: code,
      claim_code_expires_at: expires
    })
  end

  defp insert_sso_user do
    uniq = System.unique_integer([:positive])

    Repo.insert!(%NoizuPromptLingua.Schema.Users.User{
      id: Ecto.UUID.generate(),
      email: "sso-exchange-#{uniq}@example.com",
      user_name: "ssox#{uniq}",
      handle: "ssox#{uniq}",
      status: :active,
      verified: true,
      flagged: false
    })
  end
end
