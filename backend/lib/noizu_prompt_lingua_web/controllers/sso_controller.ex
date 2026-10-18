defmodule NoizuPromptLinguaWeb.SSOController do
  use NoizuPromptLinguaWeb, :controller
  require Logger

  alias NoizuPromptLingua.Guardian
  alias NoizuPromptLingua.Organizations
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Users.User, as: UserSchema

  def providers(conn, _params) do
    providers =
      []
      |> maybe_add(:oidc_enabled, "oidc")
      |> maybe_add(:github_enabled, "github")
      |> maybe_add(:google_enabled, "google")

    json(conn, %{providers: providers})
  end

  # Server-advertised SSO config for the tobor-kit `noizu-auth` component
  # (REST transport fetches GET {api-base}/auth/config for provider discovery:
  # providers: [{id, label, href}]). Only enabled providers are published —
  # the component renders redirect buttons for exactly what the server
  # advertises, so a disabled provider never lights up a dead button.
  # Canonical order mirrors the tobor-kit SOCIAL_PIPES order (google before
  # github) so server and client agree when both lists are rendered.
  @auth_config_providers [
    {:oidc_enabled, "oidc", "Continue with SSO", "/auth/oidc"},
    {:google_enabled, "google", "Sign in with Google", "/auth/google"},
    {:github_enabled, "github", "Sign in with GitHub", "/auth/github"}
  ]

  def auth_config(conn, _params) do
    providers =
      for {flag, id, label, href} <- @auth_config_providers,
          Application.get_env(:noizu_prompt_lingua, flag, false) === true,
          do: %{id: id, label: label, href: href}

    json(conn, %{providers: providers})
  end

  # ── OIDC ──────────────────────────────────────────────────────

  def oidc_init(conn, _params) do
    with config when is_map(config) <- oidc_config_or_nil(),
         state = random_token(),
         nonce = random_token(),
         {:ok, uri} <-
           OpenIDConnect.authorization_uri(config, config.redirect_uri, %{
             state: state,
             nonce: nonce
           }) do
      conn
      |> put_session(:sso_state, state)
      |> put_session(:sso_nonce, nonce)
      |> redirect(external: uri)
    else
      nil ->
        Logger.error("[SSO] OIDC init skipped: :oidc_provider is not configured")
        redirect_with_error(conn, "oidc_failed")

      {:error, reason} ->
        Logger.error("[SSO] OIDC authorization_uri failed: #{inspect(reason)}")
        redirect_with_error(conn, "oidc_failed")
    end
  end

  defp verify_state(nil, _received), do: {:error, :state_mismatch}
  defp verify_state(_expected, nil), do: {:error, :state_mismatch}

  defp verify_state(expected, received) do
    if Plug.Crypto.secure_compare(expected, received),
      do: :ok,
      else: {:error, :state_mismatch}
  end

  # A provider that omits the nonce it was given is not proof of replay, but one
  # that returns a DIFFERENT nonce is.
  defp verify_nonce(_expected, nil), do: :ok
  defp verify_nonce(nil, _received), do: :ok

  defp verify_nonce(expected, received) do
    if Plug.Crypto.secure_compare(expected, received), do: :ok, else: {:error, :nonce_mismatch}
  end

  defp random_token, do: :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)

  def oidc_callback(conn, %{"code" => code} = params) do
    expected_state = get_session(conn, :sso_state)
    expected_nonce = get_session(conn, :sso_nonce)

    # One-time use: cleared before the exchange, so a replayed callback cannot
    # reuse a state value that already succeeded.
    conn =
      conn
      |> delete_session(:sso_state)
      |> delete_session(:sso_nonce)

    # State is checked FIRST, before the provider config is even read: a forged
    # callback then costs no discovery fetch and no token request.
    with :ok <- verify_state(expected_state, params["state"]),
         config <- oidc_config(),
         {:ok, tokens} <-
           OpenIDConnect.fetch_tokens(config, %{code: code, redirect_uri: config.redirect_uri}),
         {:ok, claims} <- OpenIDConnect.verify(config, tokens["id_token"]),
         :ok <- verify_nonce(expected_nonce, claims["nonce"]) do
      # The OIDC :default flow is the Authentik IdP — the only supported provider.
      handle_sso_callback(conn, :authentik, %{
        email: claims["email"],
        name: %{first: claims["given_name"] || "", last: claims["family_name"] || ""},
        sub: claims["sub"]
      })
    else
      {:error, :state_mismatch} -> redirect_with_error(conn, "state_mismatch")
      _ -> redirect_with_error(conn, "oidc_failed")
    end
  end

  def oidc_callback(conn, _params) do
    redirect_with_error(conn, "oidc_failed")
  end

  # ── Google (full OIDC, mirrors the Authentik flow above) ─────

  def google_init(conn, _params) do
    with config when is_map(config) <- provider_config_or_nil(:google_provider),
         state = random_token(),
         nonce = random_token(),
         {:ok, uri} <-
           OpenIDConnect.authorization_uri(config, config.redirect_uri, %{
             state: state,
             nonce: nonce
           }) do
      conn
      |> put_session(:google_sso_state, state)
      |> put_session(:google_sso_nonce, nonce)
      |> redirect(external: uri)
    else
      nil ->
        Logger.error("[SSO] Google init skipped: :google_provider is not configured")
        redirect_with_error(conn, "google_failed")

      {:error, reason} ->
        Logger.error("[SSO] Google authorization_uri failed: #{inspect(reason)}")
        redirect_with_error(conn, "google_failed")
    end
  end

  def google_callback(conn, %{"code" => code} = params) do
    expected_state = get_session(conn, :google_sso_state)
    expected_nonce = get_session(conn, :google_sso_nonce)

    conn =
      conn
      |> delete_session(:google_sso_state)
      |> delete_session(:google_sso_nonce)

    # State first — a forged callback costs no discovery fetch, no token call.
    with :ok <- verify_state(expected_state, params["state"]),
         config when is_map(config) <- provider_config_or_nil(:google_provider),
         {:ok, tokens} <-
           OpenIDConnect.fetch_tokens(config, %{code: code, redirect_uri: config.redirect_uri}),
         {:ok, claims} <- OpenIDConnect.verify(config, tokens["id_token"]),
         :ok <- verify_nonce(expected_nonce, claims["nonce"]) do
      handle_sso_callback(conn, :google, %{
        email: claims["email"],
        name: %{first: claims["given_name"] || "", last: claims["family_name"] || ""},
        sub: claims["sub"]
      })
    else
      {:error, :state_mismatch} -> redirect_with_error(conn, "state_mismatch")
      _ -> redirect_with_error(conn, "google_failed")
    end
  end

  def google_callback(conn, _params) do
    redirect_with_error(conn, "google_failed")
  end

  # ── GitHub (plain OAuth2 — no discovery document, no id_token nonce) ──

  def github_init(conn, _params) do
    with config when is_map(config) <- provider_config_or_nil(:github_provider),
         state = random_token() do
      uri =
        config.authorize_url
        |> URI.parse()
        |> URI.append_query(
          URI.encode_query(%{
            client_id: config.client_id,
            redirect_uri: config.redirect_uri,
            scope: config.scope,
            state: state
          })
        )
        |> URI.to_string()

      conn
      |> put_session(:github_sso_state, state)
      |> redirect(external: uri)
    else
      nil ->
        Logger.error("[SSO] GitHub init skipped: :github_provider is not configured")
        redirect_with_error(conn, "github_failed")
    end
  end

  def github_callback(conn, %{"code" => code} = params) do
    expected_state = get_session(conn, :github_sso_state)

    conn = delete_session(conn, :github_sso_state)

    # State first — a forged callback never reaches the token endpoint.
    with :ok <- verify_state(expected_state, params["state"]),
         config when is_map(config) <- provider_config_or_nil(:github_provider),
         {:ok, access_token} <- github_exchange_code(config, code),
         {:ok, identity} <- github_fetch_identity(config, access_token) do
      handle_sso_callback(conn, :github, %{
        email: identity.email,
        name: %{first: identity.name || "", last: ""},
        sub: identity.sub
      })
    else
      {:error, :state_mismatch} -> redirect_with_error(conn, "state_mismatch")
      _ -> redirect_with_error(conn, "github_failed")
    end
  end

  def github_callback(conn, _params) do
    redirect_with_error(conn, "github_failed")
  end

  # GitHub OAuth Apps answer form-encoded unless JSON is requested.
  defp github_exchange_code(config, code) do
    case Req.post(config.token_url,
           headers: [{"accept", "application/json"}],
           form: [
             client_id: config.client_id,
             client_secret: config.client_secret,
             code: code,
             redirect_uri: config.redirect_uri
           ]
         ) do
      {:ok, %Req.Response{status: 200, body: %{"access_token" => token}}}
      when is_binary(token) and token != "" ->
        {:ok, token}

      {:ok, %Req.Response{status: status, body: body}} ->
        # Log only the provider's error fields — the body carries the token.
        Logger.error(
          "[SSO] GitHub token exchange failed (#{status}): #{inspect(gh_safe_body(body))}"
        )

        {:error, :github_exchange}

      {:error, reason} ->
        Logger.error("[SSO] GitHub token exchange error: #{inspect(reason)}")
        {:error, :github_exchange}
    end
  end

  # Identity via /user + the primary verified email from /user/emails. The
  # numeric id is the stable subject (GitHub emails can change; the id cannot).
  defp github_fetch_identity(config, access_token) do
    headers = [
      {"authorization", "Bearer #{access_token}"},
      {"accept", "application/vnd.github+json"},
      {"user-agent", "noizu-prompt-lingua"}
    ]

    with {:ok, %Req.Response{status: 200, body: user}} <-
           Req.get(config.user_url, headers: headers),
         {:ok, %Req.Response{status: 200, body: emails}} <-
           Req.get(config.emails_url, headers: headers) do
      primary =
        Enum.find(emails, & &1["primary"]) || Enum.find(emails, & &1["verified"]) ||
          List.first(emails)

      {:ok,
       %{
         sub: to_string(user["id"]),
         email: (primary && primary["email"]) || user["email"],
         name: user["name"] || user["login"]
       }}
    else
      {:ok, %Req.Response{status: status, body: body}} ->
        Logger.error("[SSO] GitHub identity fetch failed (#{status}): #{inspect(gh_safe_body(body))}")
        {:error, :github_identity}

      {:error, reason} ->
        Logger.error("[SSO] GitHub identity fetch error: #{inspect(reason)}")
        {:error, :github_identity}
    end
  end

  # Keep secrets out of logs: only string error fields from a provider body.
  defp gh_safe_body(body) when is_map(body) do
    body
    |> Map.take(["error", "error_description", "message"])
    |> Map.filter(fn {_k, v} -> is_binary(v) end)
  end

  defp gh_safe_body(_body), do: %{}

  # ── Code Exchange ────────────────────────────────────────────

  def exchange(conn, %{"code" => code}) do
    with {:ok, claimed} <- NoizuPromptLingua.Auth.SSO.claim_session(code),
         {:ok, session} <-
           NoizuPromptLingua.Users.Sessions.get(claimed.id, Noizu.Context.system(), []),
         user when not is_nil(user) <- resolve_user_from_session(session),
         {:ok, access_token, refresh_token} <- issue_guardian_pair(session) do
      orgs = Organizations.list_user_organizations(user.id)

      conn
      |> put_status(:ok)
      |> json(%{
        user: serialize_user(user),
        organizations: orgs,
        access_token: access_token,
        refresh_token: refresh_token
      })
    else
      _ -> conn |> put_status(:unauthorized) |> json(%{error: "Invalid or expired SSO code"})
    end
  end

  # ── Registration (new SSO user provides name/bio) ────────────

  # Peek at the pending identity (e.g. to prefill/display the email).
  def registration(conn, %{"token" => token}) do
    case NoizuPromptLingua.Auth.RegistrationToken.verify(token) do
      {:ok, identity} ->
        json(conn, %{email: identity[:email], provider: identity[:provider]})

      _ ->
        conn |> put_status(:not_found) |> json(%{error: "Invalid or expired registration"})
    end
  end

  # Create the account from the verified identity + form fields, then log in.
  def register(conn, %{"token" => token} = params) do
    # Role is intentionally NOT taken from the client. New accounts always
    # default to :user; elevated roles are granted later by an admin.
    attrs = %{
      first: params["first"] || "",
      last: params["last"] || "",
      bio: params["bio"]
    }

    with {:ok, identity} <- NoizuPromptLingua.Auth.RegistrationToken.verify(token),
         {:ok, created} <- NoizuPromptLingua.Auth.SSO.register_user(identity, attrs),
         {:ok, session} <-
           NoizuPromptLingua.Users.Sessions.get(created.id, Noizu.Context.system(), []),
         {:ok, access_token, refresh_token} <- issue_guardian_pair(session) do
      user = resolve_user_from_session(session)
      orgs = Organizations.list_user_organizations(user.id)

      conn
      |> put_status(:ok)
      |> json(%{
        user: serialize_user(user),
        organizations: orgs,
        access_token: access_token,
        refresh_token: refresh_token
      })
    else
      {:error, reason} when reason in [:expired, :invalid] ->
        conn |> put_status(:unauthorized) |> json(%{error: "Invalid or expired registration"})

      _ ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: "Registration failed"})
    end
  end

  # ── Helpers ──────────────────────────────────────────────────

  defp oidc_config, do: Application.fetch_env!(:noizu_prompt_lingua, :oidc_provider)

  defp oidc_config_or_nil do
    Application.get_env(:noizu_prompt_lingua, :oidc_provider)
  end

  # Generic per-provider config lookup (:google_provider / :github_provider —
  # same shape as :oidc_provider for Google; a flat map for GitHub).
  defp provider_config_or_nil(key) do
    Application.get_env(:noizu_prompt_lingua, key)
  end

  defp handle_sso_callback(conn, provider_type, attrs) do
    case NoizuPromptLingua.Auth.SSO.authenticate_sso(provider_type, attrs) do
      {:ok, session} ->
        # authenticate_sso returns the freshly-inserted schema struct with
        # :user not loaded; re-fetch the entity (as register/2 and exchange/2
        # do) so resolve_user_from_session/1 has a resolvable user. A get
        # failure must not 500 after Authentik already succeeded — fall back
        # to the raw session's user_id.
        user = load_session_user(session)

        conn =
          if user && Map.get(user, :id) do
            put_session(conn, :oauth_user_id, user.id)
          else
            conn
          end

        # If this login was started from MCP OAuth authorize, resume that flow
        # instead of the SPA hand-off (connectors need a browser code redirect).
        case get_session(conn, :oauth_authorize_params) do
          params when is_map(params) and map_size(params) > 0 ->
            redirect(conn, to: "/oauth/authorize?" <> URI.encode_query(params))

          _ ->
            # session.claim_code is the one-time hand-off code (no Redis).
            redirect(conn,
              external:
                "#{frontend_url()}/auth/sso-callback?code=#{session.claim_code}&provider=#{provider_type}"
            )
        end

      {:registration_required, identity} ->
        # No account yet — sign the verified identity into a stateless token.
        token = NoizuPromptLingua.Auth.RegistrationToken.sign(identity)
        redirect(conn, external: "#{frontend_url()}/auth/register?token=#{token}")

      {:error, _} ->
        redirect(conn, external: "#{frontend_url()}/auth/sso-callback?error=sso_failed")
    end
  end

  defp redirect_with_error(conn, error) do
    redirect(conn, external: "#{frontend_url()}/auth/sso-callback?error=#{error}")
  end

  # The configured frontend URL, falling back to localhost so a missing or empty
  # FRONTEND_URL never produces a relative redirect. A relative redirect would
  # be resolved against the backend host, landing the browser on Phoenix for
  # frontend routes like /auth/sso-callback (→ NoRouteError).
  defp frontend_url do
    case Application.get_env(:noizu_prompt_lingua, :frontend_url) do
      url when is_binary(url) and url != "" -> url
      _ -> "http://localhost:3000"
    end
  end

  defp load_session_user(session) do
    case NoizuPromptLingua.Users.Sessions.get(session.id, Noizu.Context.system(), []) do
      {:ok, loaded} -> resolve_user_from_session(loaded)
      _ -> resolve_user_from_session(session)
    end
  end

  defp user_ref_from_session(%{user: user}) when not is_nil(user), do: user
  defp user_ref_from_session(%{user_id: id}) when is_binary(id), do: id
  defp user_ref_from_session(_), do: nil

  # Entity.ref/1 sometimes wraps as {:ok, {:ref, mod, id}}.
  defp unwrap_user_ref({:ok, inner}), do: unwrap_user_ref(inner)
  defp unwrap_user_ref(other), do: other

  defp resolve_user_from_session(session) do
    case unwrap_user_ref(user_ref_from_session(session)) do
      {:ref, _, id} ->
        case NoizuPromptLingua.Users.get_user(id, Noizu.Context.system()) do
          {:ok, user} -> user
          _ -> nil
        end

      %NoizuPromptLingua.Users.User{} = user ->
        user

      id when is_binary(id) ->
        case NoizuPromptLingua.Users.get_user(id, Noizu.Context.system()) do
          {:ok, user} -> user
          _ -> nil
        end

      _ ->
        nil
    end
  end

  # Serialize from the Ecto schema (DB columns) so role/bio are present in the
  # login response, matching GET /auth/me. The versioned entity loader does not
  # map every column.
  defp serialize_user(user) do
    u = Repo.get(UserSchema, user.id) || user

    %{
      id: u.id,
      email: u.email,
      user_name: u.user_name,
      handle: u.handle,
      role: u.role,
      bio: u.bio,
      status: u.status,
      verified: u.verified
    }
  end

  defp maybe_add(list, flag, name) do
    if Application.get_env(:noizu_prompt_lingua, flag), do: [name | list], else: list
  end

  # Password login used to register refresh JTIs in Redis. SSO is now the only
  # live login path and was skipping that step, so AuthController.refresh
  # rejected every SSO refresh after the 1h access token died.
  defp issue_guardian_pair(session) do
    with {:ok, access_token, _} <-
           Guardian.encode_and_sign(session, %{}, token_type: "access", ttl: {1, :hour}),
         {:ok, refresh_token, claims} <-
           Guardian.encode_and_sign(session, %{}, token_type: "refresh", ttl: {7, :day}) do
      case claims do
        %{"jti" => jti} when is_binary(jti) and jti != "" ->
          NoizuPromptLingua.Auth.TokenStore.store_refresh_jti(jti)

        _ ->
          :ok
      end

      {:ok, access_token, refresh_token}
    end
  end
end
