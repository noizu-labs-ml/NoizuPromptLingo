defmodule Noizu.MCP.Auth.TokenVerifier do
  @moduledoc """
  Server-side bearer-token verification for the Streamable HTTP transport.

  MCP servers are OAuth 2.1 *resource servers*: they validate access tokens
  but never issue them. Implement this behaviour and pass it to the transport
  plug:

      forward "/mcp", Noizu.MCP.Transport.StreamableHTTP.Plug,
        server: MyApp.MCP,
        auth: [
          verifier: {MyApp.TokenVerifier, []},
          resource_metadata: "https://api.example.com/.well-known/oauth-protected-resource"
        ]

      defmodule MyApp.TokenVerifier do
        @behaviour Noizu.MCP.Auth.TokenVerifier

        @impl true
        def verify(token, _conn_info, _opts) do
          with {:ok, claims} <- MyApp.JWT.verify(token),
               # RFC 8707: the token must be audience-bound to THIS server.
               true <- claims["aud"] == "https://api.example.com/mcp" || {:error, :invalid_token} do
            {:ok, claims}
          end
        end
      end

  Verified claims are exposed to handlers as `ctx.assigns.auth_claims`
  (seeded at session initialize).
  """

  @type conn_info :: %{method: String.t(), peer: term(), headers: [{binary(), binary()}]}

  @doc """
  Verify a bearer token. Return `{:ok, claims}`, `{:error, :invalid_token}`
  (→ 401), or `{:error, :insufficient_scope, meta}` (→ 403 with an
  `insufficient_scope` challenge; `meta` may include `"scope"`).

  Audience validation (RFC 8707) is the verifier's responsibility — reject
  tokens minted for other resources.
  """
  @callback verify(token :: String.t(), conn_info(), opts :: term()) ::
              {:ok, claims :: map()}
              | {:error, :invalid_token}
              | {:error, :insufficient_scope, meta :: map()}
end
