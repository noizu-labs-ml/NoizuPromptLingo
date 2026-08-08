defmodule NoizuPromptLinguaWeb.SSOController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Guardian
  alias NoizuPromptLingua.Organizations
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Users.User, as: UserSchema

  def providers(conn, _params) do
    providers =
      []
      |> maybe_add(:oidc_enabled, "oidc")

    json(conn, %{providers: providers})
  end

  # ── OIDC ──────────────────────────────────────────────────────

  def oidc_init(conn, _params) do
    config = oidc_config()

    # `state` guards against login-CSRF - an attacker completing a flow so the
    # victim is silently signed in as the attacker - and `nonce` against
    # id_token replay. Neither was previously sent. Ueberauth already does this
    # for the social providers; the raw OIDC path was the gap.
    state = random_token()
    nonce = random_token()

    {:ok, uri} =
      OpenIDConnect.authorization_uri(config, config.redirect_uri, %{
        state: state,
        nonce: nonce
      })

    conn
    |> put_session(:sso_state, state)
    |> put_session(:sso_nonce, nonce)
    |> redirect(external: uri)
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

  # ── Code Exchange ────────────────────────────────────────────

  def exchange(conn, %{"code" => code}) do
    with {:ok, claimed} <- NoizuPromptLingua.Auth.SSO.claim_session(code),
         {:ok, session} <-
           NoizuPromptLingua.Users.Sessions.get(claimed.id, Noizu.Context.system(), []),
         {:ok, access_token, _} <-
           Guardian.encode_and_sign(session, %{}, token_type: "access", ttl: {1, :hour}),
         {:ok, refresh_token, _} <-
           Guardian.encode_and_sign(session, %{}, token_type: "refresh", ttl: {7, :day}) do
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
         {:ok, access_token, _} <-
           Guardian.encode_and_sign(session, %{}, token_type: "access", ttl: {1, :hour}),
         {:ok, refresh_token, _} <-
           Guardian.encode_and_sign(session, %{}, token_type: "refresh", ttl: {7, :day}) do
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

  defp handle_sso_callback(conn, provider_type, attrs) do
    case NoizuPromptLingua.Auth.SSO.authenticate_sso(provider_type, attrs) do
      {:ok, session} ->
        user = resolve_user_from_session(session)
        conn = put_session(conn, :oauth_user_id, user.id)

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

  defp resolve_user_from_session(%NoizuPromptLingua.Users.Sessions.UserSession{} = session) do
    case session.user do
      {:ref, _, id} ->
        {:ok, user} = NoizuPromptLingua.Users.get_user(id, Noizu.Context.system())
        user

      %NoizuPromptLingua.Users.User{} = user ->
        user
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
end
