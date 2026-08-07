defmodule NoizuPromptLinguaWeb.OAuthController do
  use NoizuPromptLinguaWeb, :controller

  @moduledoc """
  OAuth 2.1 Authorization Server endpoints for MCP connectors.

  - `GET  /oauth/authorize` — auth code + PKCE (+ consent)
  - `POST /oauth/consent` — approve/deny
  - `POST /oauth/token` — authorization_code | refresh_token
  - `POST /oauth/register` — RFC 7591 DCR (minimal)
  - `POST /oauth/revoke` — RFC 7009
  """

  alias NoizuPromptLingua.OAuth.{
    AuthorizationServer,
    Clients,
    Elevation,
    Grants,
    Pkce,
    RedirectPolicy,
    TokenService
  }

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Users.User

  # ── Discovery ────────────────────────────────────────────────────────────

  def metadata(conn, _params) do
    conn
    |> put_resp_header("cache-control", "public, max-age=60")
    |> json(AuthorizationServer.metadata())
  end

  # ── Authorize ────────────────────────────────────────────────────────────

  def authorize(conn, params) do
    with :ok <- validate_authorize_params(params),
         client when not is_nil(client) <- Clients.get_active(params["client_id"]),
         true <- RedirectPolicy.registered?(client.redirect_uris, params["redirect_uri"]),
         true <- "authorization_code" in client.grant_types,
         true <- Pkce.valid_challenge?(params["code_challenge_method"] || "S256", params["code_challenge"]) do
      case current_oauth_user(conn) do
        nil ->
          conn
          |> put_session(:oauth_authorize_params, sanitize_params(params))
          |> put_session(:oauth_return_to, "/oauth/authorize")
          |> redirect(to: "/auth/oidc")

        user ->
          resource = params["resource"] || default_resource()
          existing = Grants.find_active(user.id, client.client_id, resource)

          if existing && params["prompt"] != "consent" do
            # Silent re-auth when standing consent exists
            finish_authorize(conn, user, client, params, existing)
          else
            render_consent(conn, user, client, params, resource)
          end
      end
    else
      nil ->
        oauth_error(conn, params, "invalid_client", "Unknown client_id")

      false ->
        oauth_error(conn, params, "invalid_request", "Invalid redirect_uri, grant, or PKCE")

      {:error, desc} ->
        oauth_error(conn, params, "invalid_request", desc)
    end
  end

  def consent(conn, %{"decision" => decision} = params) do
    case current_oauth_user(conn) do
      nil ->
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(401, html_page("Sign in required", "<p>Please <a href=\"/auth/oidc\">sign in</a>.</p>"))

      user ->
        stored = get_session(conn, :oauth_pending) || %{}
        client_id = params["client_id"] || stored["client_id"]
        redirect_uri = params["redirect_uri"] || stored["redirect_uri"]
        state = params["state"] || stored["state"]
        resource = params["resource"] || stored["resource"] || default_resource()
        scope = params["scope"] || stored["scope"] || "mcp"
        code_challenge = params["code_challenge"] || stored["code_challenge"]
        client = Clients.get_active(client_id)

        cond do
          is_nil(client) or not RedirectPolicy.registered?(client.redirect_uris, redirect_uri) ->
            send_resp(conn, 400, "invalid client or redirect_uri")

          decision != "approve" ->
            redirect_with_error(conn, redirect_uri, state, "access_denied", "User denied consent")

          not is_binary(code_challenge) ->
            send_resp(conn, 400, "missing code_challenge")

          true ->
            grant = Grants.approve!(user.id, client.client_id, resource, scope)

            code =
              TokenService.issue_code!(%{
                client_id: client.client_id,
                user_id: user.id,
                redirect_uri: redirect_uri,
                resource: resource,
                scope: scope,
                code_challenge: code_challenge,
                grant_id: grant.grant_id
              })

            conn
            |> delete_session(:oauth_pending)
            |> delete_session(:oauth_authorize_params)
            |> redirect(external: build_redirect(redirect_uri, code: code, state: state))
        end
    end
  end

  def consent(conn, _params), do: send_resp(conn, 400, "decision required")

  # ── Token ────────────────────────────────────────────────────────────────

  def token(conn, params) do
    params = normalize_token_params(conn, params)
    exchange_type = NoizuPromptLingua.OAuth.TokenExchange.grant_type()

    result =
      case params["grant_type"] do
        "authorization_code" ->
          TokenService.exchange_code(params)

        "refresh_token" ->
          TokenService.refresh(params)

        ^exchange_type ->
          NoizuPromptLingua.OAuth.TokenExchange.exchange(params)

        "urn:ietf:params:oauth:grant-type:token-exchange" ->
          NoizuPromptLingua.OAuth.TokenExchange.exchange(params)

        _ ->
          {:error, :unsupported_grant_type}
      end

    case result do
      {:ok, body} ->
        json(conn, body)

      {:error, :invalid_client} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "invalid_client"})

      {:error, :invalid_grant} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "invalid_grant"})

      {:error, :unauthorized_client} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "unauthorized_client"})

      {:error, :unsupported_grant_type} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "unsupported_grant_type"})

      {:error, _} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "invalid_request"})
    end
  end

  # ── Register (DCR) ───────────────────────────────────────────────────────

  def register(conn, params) do
    case Clients.register(params) do
      {:ok, body} ->
        conn
        |> put_status(:created)
        |> json(body)

      {:error, :invalid_redirect_uri} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "invalid_redirect_uri", error_description: "redirect_uri not allowed"})

      {:error, _} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "invalid_client_metadata"})
    end
  end

  # ── Revoke ───────────────────────────────────────────────────────────────

  def revoke(conn, params) do
    # RFC 7009: always 200
    _ = TokenService.revoke(params)
    send_resp(conn, 200, "")
  end

  # ── Elevation (destructive tool step-up) ─────────────────────────────────

  def elevate_show(conn, %{"txn" => txn}) do
    case current_oauth_user(conn) do
      nil ->
        conn
        |> put_session(:oauth_return_to, "/oauth/elevate?txn=#{URI.encode_www_form(txn)}")
        |> redirect(to: "/auth/oidc")

      user ->
        case Elevation.get_txn(txn) do
          {:ok, entry} ->
            if entry.user_id == user.id do
              html =
                html_page(
                  "Approve sensitive action",
                  """
                  <p>Signed in as <strong>#{html_escape(user.email)}</strong></p>
                  <p>A client wants permission to run a <strong>destructive</strong> tool:</p>
                  <dl>
                    <dt>Tool</dt><dd><code>#{html_escape(entry.tool)}</code></dd>
                    <dt>Action</dt><dd><code>#{html_escape(entry[:action] || "—")}</code></dd>
                  </dl>
                  <p>This grant is single-use and expires in about one minute.</p>
                  <form method="post" action="/oauth/elevate">
                    <input type="hidden" name="txn" value="#{html_escape(txn)}" />
                    <button type="submit" name="decision" value="approve" style="margin-right:1rem;padding:0.6rem 1.2rem;">Approve once</button>
                    <button type="submit" name="decision" value="deny" style="padding:0.6rem 1.2rem;">Deny</button>
                  </form>
                  """
                )

              conn
              |> put_resp_content_type("text/html")
              |> send_resp(200, html)
            else
              conn
              |> put_resp_content_type("text/html")
              |> send_resp(403, html_page("Forbidden", "<p>This elevation request is not for your account.</p>"))
            end

          {:error, _} ->
            conn
            |> put_resp_content_type("text/html")
            |> send_resp(404, html_page("Expired", "<p>This elevation request expired or was already used.</p>"))
        end
    end
  end

  def elevate_show(conn, _params) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(400, html_page("Missing txn", "<p>Elevation requires a <code>txn</code> query parameter.</p>"))
  end

  def elevate_submit(conn, %{"txn" => txn, "decision" => decision}) do
    case current_oauth_user(conn) do
      nil ->
        redirect(conn, to: "/auth/oidc")

      user ->
        if decision == "approve" do
          case Elevation.approve!(txn, user.id) do
            {:ok, token, exp} ->
              html =
                html_page(
                  "Elevation granted",
                  """
                  <p>Single-use elevation token (expires #{exp}):</p>
                  <p><code style="word-break:break-all">#{html_escape(token)}</code></p>
                  <p>Retry the tool call with header <code>X-MCP-Elevation: &lt;token&gt;</code>.</p>
                  """
                )

              conn
              |> put_resp_content_type("text/html")
              |> send_resp(200, html)

            {:error, reason} ->
              conn
              |> put_resp_content_type("text/html")
              |> send_resp(400, html_page("Failed", "<p>#{html_escape(inspect(reason))}</p>"))
          end
        else
          _ = Elevation.get_txn(txn)
          conn
          |> put_resp_content_type("text/html")
          |> send_resp(200, html_page("Denied", "<p>Elevation denied. The client will not receive a token.</p>"))
        end
    end
  end

  def elevate_submit(conn, _params) do
    send_resp(conn, 400, "txn and decision required")
  end

  # ── Resume after OIDC ────────────────────────────────────────────────────

  @doc false
  def resume_authorize_after_login(conn, user_id) do
    conn
    |> put_session(:oauth_user_id, user_id)
    |> then(fn c ->
      case get_session(c, :oauth_authorize_params) do
        params when is_map(params) and map_size(params) > 0 ->
          redirect(c, to: "/oauth/authorize?" <> URI.encode_query(params))

        _ ->
          c
      end
    end)
  end

  # ── Helpers ──────────────────────────────────────────────────────────────

  defp finish_authorize(conn, user, client, params, grant) do
    code =
      TokenService.issue_code!(%{
        client_id: client.client_id,
        user_id: user.id,
        redirect_uri: params["redirect_uri"],
        resource: params["resource"] || default_resource(),
        scope: params["scope"] || grant.scope || "mcp",
        code_challenge: params["code_challenge"],
        grant_id: grant.grant_id
      })

    conn
    |> delete_session(:oauth_authorize_params)
    |> redirect(
      external: build_redirect(params["redirect_uri"], code: code, state: params["state"])
    )
  end

  defp render_consent(conn, user, client, params, resource) do
    pending = sanitize_params(Map.put(params, "resource", resource))

    html =
      html_page(
        "Authorize #{html_escape(client.client_name)}",
        """
        <p>Signed in as <strong>#{html_escape(user.email)}</strong></p>
        <p><strong>#{html_escape(client.client_name)}</strong> wants to access your Tobor Locker MCP tools.</p>
        <dl>
          <dt>Resource</dt><dd><code>#{html_escape(resource)}</code></dd>
          <dt>Scopes</dt><dd><code>#{html_escape(params["scope"] || "mcp")}</code></dd>
        </dl>
        <form method="post" action="/oauth/consent">
          <input type="hidden" name="client_id" value="#{html_escape(client.client_id)}" />
          <input type="hidden" name="redirect_uri" value="#{html_escape(params["redirect_uri"])}" />
          <input type="hidden" name="state" value="#{html_escape(params["state"] || "")}" />
          <input type="hidden" name="resource" value="#{html_escape(resource)}" />
          <input type="hidden" name="scope" value="#{html_escape(params["scope"] || "mcp")}" />
          <input type="hidden" name="code_challenge" value="#{html_escape(params["code_challenge"])}" />
          <button type="submit" name="decision" value="approve" style="margin-right:1rem;padding:0.6rem 1.2rem;">Allow</button>
          <button type="submit" name="decision" value="deny" style="padding:0.6rem 1.2rem;">Deny</button>
        </form>
        """
      )

    conn
    |> put_session(:oauth_pending, pending)
    |> put_resp_content_type("text/html")
    |> send_resp(200, html)
  end

  defp validate_authorize_params(params) do
    cond do
      params["response_type"] not in [nil, "code"] ->
        {:error, "response_type must be code"}

      not is_binary(params["client_id"]) or params["client_id"] == "" ->
        {:error, "client_id required"}

      not is_binary(params["redirect_uri"]) or params["redirect_uri"] == "" ->
        {:error, "redirect_uri required"}

      not is_binary(params["code_challenge"]) ->
        {:error, "code_challenge required (PKCE S256)"}

      (params["code_challenge_method"] || "S256") != "S256" ->
        {:error, "only S256 PKCE is supported"}

      true ->
        :ok
    end
  end

  defp current_oauth_user(conn) do
    case get_session(conn, :oauth_user_id) do
      id when is_binary(id) -> Repo.get(User, id)
      _ -> nil
    end
  end

  defp sanitize_params(params) do
    Map.take(params, [
      "client_id",
      "redirect_uri",
      "response_type",
      "scope",
      "state",
      "code_challenge",
      "code_challenge_method",
      "resource",
      "prompt"
    ])
  end

  defp default_resource do
    base = AuthorizationServer.issuer_url() |> String.trim_trailing("/")
    "#{base}/mcp"
  end

  defp build_redirect(uri, opts) do
    query =
      opts
      |> Enum.reject(fn {_k, v} -> is_nil(v) or v == "" end)
      |> URI.encode_query()

    sep = if String.contains?(uri, "?"), do: "&", else: "?"
    uri <> sep <> query
  end

  defp redirect_with_error(conn, redirect_uri, state, error, desc) do
    if is_binary(redirect_uri) and redirect_uri != "" do
      redirect(conn,
        external:
          build_redirect(redirect_uri,
            error: error,
            error_description: desc,
            state: state
          )
      )
    else
      conn
      |> put_resp_content_type("text/html")
      |> send_resp(400, html_page("Error", "<p>#{html_escape(error)}: #{html_escape(desc)}</p>"))
    end
  end

  defp oauth_error(conn, params, error, desc) do
    redirect_uri = params["redirect_uri"]
    state = params["state"]
    client = Clients.get_active(params["client_id"])

    if client && is_binary(redirect_uri) &&
         RedirectPolicy.registered?(client.redirect_uris, redirect_uri) do
      redirect_with_error(conn, redirect_uri, state, error, desc)
    else
      conn
      |> put_resp_content_type("text/html")
      |> send_resp(
        400,
        html_page("OAuth error", "<p>#{html_escape(error)}: #{html_escape(desc)}</p>")
      )
    end
  end

  defp normalize_token_params(conn, params) do
    # Support client_secret_basic
    case Plug.Conn.get_req_header(conn, "authorization") do
      ["Basic " <> encoded] ->
        case Base.decode64(encoded) do
          {:ok, decoded} ->
            case String.split(decoded, ":", parts: 2) do
              [cid, secret] ->
                params
                |> Map.put_new("client_id", cid)
                |> Map.put_new("client_secret", secret)

              _ ->
                params
            end

          _ ->
            params
        end

      _ ->
        params
    end
  end

  defp html_escape(nil), do: ""

  defp html_escape(str) do
    str
    |> to_string()
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
  end

  defp html_page(title, body) do
    """
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="utf-8"/>
      <meta name="viewport" content="width=device-width, initial-scale=1"/>
      <title>#{html_escape(title)} · Tobor Locker</title>
      <style>
        body { font-family: system-ui, sans-serif; max-width: 32rem; margin: 3rem auto; padding: 0 1rem; color: #111; }
        code { background: #f4f4f5; padding: 0.1rem 0.3rem; border-radius: 4px; word-break: break-all; }
        dt { font-weight: 600; margin-top: 0.75rem; }
        dd { margin: 0.25rem 0 0; }
        button { cursor: pointer; }
      </style>
    </head>
    <body>
      <h1>#{html_escape(title)}</h1>
      #{body}
    </body>
    </html>
    """
  end
end
