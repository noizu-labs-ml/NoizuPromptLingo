if Code.ensure_loaded?(Req) do
  defmodule Noizu.MCP.Auth.OAuth do
    @moduledoc """
    OAuth 2.1 client strategy for MCP Streamable HTTP: discovery (RFC 9728
    protected-resource metadata → RFC 8414 / OIDC authorization-server
    metadata), PKCE S256 authorization-code flow with the RFC 8707 `resource`
    parameter, token refresh, and `insufficient_scope` step-up.

        {Noizu.MCP.Client,
         transport:
           {:streamable_http,
            url: "https://api.example.com/mcp",
            auth:
              {Noizu.MCP.Auth.OAuth,
               client_id: "my-client",
               redirect_uri: "http://localhost:8910/callback",
               scope: "mcp:tools",
               authorize_user: &MyApp.OAuth.open_browser_and_await_callback/1}}}

    `:authorize_user` is how the host application drives the user agent — a
    library cannot open a browser for you. It receives the authorization URL
    and must return `{:ok, %{"code" => code, "state" => state}}` from the
    redirect callback, or `{:error, reason}`.

    ## Options

      * `:client_id` (required), `:client_secret` (optional, confidential clients)
      * `:redirect_uri` (required), `:scope` (optional)
      * `:authorize_user` (required) — fun/1 or `{module, function}`
      * `:resource` — RFC 8707 resource indicator; defaults to the MCP URL
      * `:resource_metadata` — override the RFC 9728 discovery URL
    """

    @behaviour Noizu.MCP.Auth.ClientStrategy

    require Logger
    alias Noizu.MCP.Auth.WWWAuthenticate

    @impl true
    def init(opts) do
      with {:ok, client_id} <- fetch(opts, :client_id),
           {:ok, redirect_uri} <- fetch(opts, :redirect_uri),
           {:ok, authorize_user} <- fetch(opts, :authorize_user) do
        mcp_url = Keyword.get(opts, :mcp_url)

        {:ok,
         %{
           client_id: client_id,
           client_secret: Keyword.get(opts, :client_secret),
           redirect_uri: redirect_uri,
           scope: Keyword.get(opts, :scope),
           authorize_user: authorize_user,
           mcp_url: mcp_url,
           resource: Keyword.get(opts, :resource, mcp_url),
           resource_metadata: Keyword.get(opts, :resource_metadata),
           req_options: Keyword.get(opts, :req_options, []),
           token_endpoint: nil,
           authorization_endpoint: nil,
           access_token: nil,
           refresh_token: nil,
           expires_at: nil
         }}
      end
    end

    defp fetch(opts, key) do
      case Keyword.fetch(opts, key) do
        {:ok, value} -> {:ok, value}
        :error -> {:error, {:missing_option, key}}
      end
    end

    @impl true
    def headers(state) do
      state = maybe_refresh(state)

      case state.access_token do
        nil -> {[], state}
        token -> {[{"authorization", "Bearer #{token}"}], state}
      end
    end

    @impl true
    def handle_unauthorized(challenge, _info, state) do
      scope = challenge_scope(challenge) || state.scope

      with {:ok, state} <- discover(state, challenge),
           {:ok, state} <- refresh_or_authorize(state, scope, challenge) do
        {:retry, state}
      else
        {:error, reason} -> {:error, reason, state}
      end
    end

    # ── discovery ─────────────────────────────────────────────────────────────

    defp discover(%{token_endpoint: endpoint} = state, _challenge) when is_binary(endpoint),
      do: {:ok, state}

    defp discover(state, challenge) do
      metadata_url =
        challenge_param(challenge, "resource_metadata") ||
          state.resource_metadata ||
          default_resource_metadata(state.mcp_url)

      with {:ok, resource_metadata} <- get_json(state, metadata_url),
           [authorization_server | _] <- resource_metadata["authorization_servers"] || [],
           {:ok, as_metadata} <- authorization_server_metadata(state, authorization_server),
           token_endpoint when is_binary(token_endpoint) <- as_metadata["token_endpoint"],
           authorization_endpoint when is_binary(authorization_endpoint) <-
             as_metadata["authorization_endpoint"] do
        {:ok,
         %{
           state
           | token_endpoint: token_endpoint,
             authorization_endpoint: authorization_endpoint,
             resource: state.resource || resource_metadata["resource"]
         }}
      else
        _ -> {:error, :discovery_failed}
      end
    end

    defp default_resource_metadata(nil), do: nil

    defp default_resource_metadata(mcp_url) do
      uri = URI.parse(mcp_url)
      %{uri | path: "/.well-known/oauth-protected-resource", query: nil} |> URI.to_string()
    end

    defp authorization_server_metadata(state, issuer) do
      base = String.trim_trailing(issuer, "/")

      # RFC 8414, falling back to OIDC discovery.
      case get_json(state, base <> "/.well-known/oauth-authorization-server") do
        {:ok, metadata} -> {:ok, metadata}
        _ -> get_json(state, base <> "/.well-known/openid-configuration")
      end
    end

    # ── token acquisition ─────────────────────────────────────────────────────

    defp refresh_or_authorize(state, scope, challenge) do
      step_up? = challenge_param(challenge, "error") == "insufficient_scope"

      cond do
        state.refresh_token && not step_up? ->
          case refresh(state) do
            {:ok, state} -> {:ok, state}
            {:error, _} -> authorize(state, scope)
          end

        true ->
          authorize(state, scope)
      end
    end

    defp authorize(state, scope) do
      verifier =
        :crypto.strong_rand_bytes(48) |> Base.url_encode64(padding: false)

      code_challenge =
        :crypto.hash(:sha256, verifier) |> Base.url_encode64(padding: false)

      oauth_state = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)

      query =
        [
          {"response_type", "code"},
          {"client_id", state.client_id},
          {"redirect_uri", state.redirect_uri},
          {"state", oauth_state},
          {"code_challenge", code_challenge},
          {"code_challenge_method", "S256"}
        ]
        |> put_param("scope", scope)
        |> put_param("resource", state.resource)

      url = state.authorization_endpoint <> "?" <> URI.encode_query(query)

      with {:ok, params} <- run_authorize_user(state.authorize_user, url),
           :ok <- check_state(params, oauth_state),
           {:ok, code} <- Map.fetch(params, "code") do
        exchange(state, [
          {"grant_type", "authorization_code"},
          {"code", code},
          {"redirect_uri", state.redirect_uri},
          {"code_verifier", verifier}
        ])
      else
        :error -> {:error, :no_authorization_code}
        {:error, reason} -> {:error, reason}
      end
    end

    defp refresh(state) do
      exchange(state, [
        {"grant_type", "refresh_token"},
        {"refresh_token", state.refresh_token}
      ])
    end

    defp exchange(state, grant_params) do
      form =
        grant_params
        |> Kernel.++([{"client_id", state.client_id}])
        |> put_param("client_secret", state.client_secret)
        |> put_param("resource", state.resource)

      options =
        Keyword.merge(
          [url: state.token_endpoint, form: form],
          state.req_options
        )

      case Req.post(options) do
        {:ok, %{status: 200, body: %{"access_token" => access_token} = body}} ->
          expires_at =
            case body["expires_in"] do
              seconds when is_integer(seconds) ->
                System.system_time(:second) + seconds - 30

              _ ->
                nil
            end

          {:ok,
           %{
             state
             | access_token: access_token,
               refresh_token: body["refresh_token"] || state.refresh_token,
               expires_at: expires_at
           }}

        {:ok, %{status: status, body: body}} ->
          Logger.warning("MCP OAuth token exchange failed (#{status}): #{inspect(body)}")
          {:error, {:token_exchange_failed, status}}

        {:error, error} ->
          {:error, {:token_exchange_failed, error}}
      end
    end

    defp maybe_refresh(%{expires_at: nil} = state), do: state

    defp maybe_refresh(state) do
      if System.system_time(:second) >= state.expires_at and state.refresh_token do
        case refresh(state) do
          {:ok, state} -> state
          {:error, _} -> state
        end
      else
        state
      end
    end

    # ── helpers ───────────────────────────────────────────────────────────────

    defp run_authorize_user(fun, url) when is_function(fun, 1), do: fun.(url)
    defp run_authorize_user({module, fun}, url), do: apply(module, fun, [url])

    defp check_state(params, expected) do
      if params["state"] in [nil, expected], do: :ok, else: {:error, :state_mismatch}
    end

    defp challenge_param(%WWWAuthenticate{params: params}, key), do: params[key]
    defp challenge_param(nil, _key), do: nil

    defp challenge_scope(challenge), do: challenge_param(challenge, "scope")

    defp put_param(params, _key, nil), do: params
    defp put_param(params, key, value), do: params ++ [{key, value}]

    defp get_json(state, url) when is_binary(url) do
      case Req.get(Keyword.merge([url: url], state.req_options)) do
        {:ok, %{status: 200, body: %{} = body}} -> {:ok, body}
        _ -> {:error, :metadata_fetch_failed}
      end
    end

    defp get_json(_state, _), do: {:error, :metadata_fetch_failed}
  end
end
