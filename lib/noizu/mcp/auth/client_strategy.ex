defmodule Noizu.MCP.Auth.ClientStrategy do
  @moduledoc """
  Client-side authorization strategy for the Streamable HTTP transport.

  Configure on the transport:

      {Noizu.MCP.Client,
       transport:
         {:streamable_http,
          url: "https://api.example.com/mcp",
          auth: {Noizu.MCP.Auth.Static, token: System.fetch_env!("MCP_TOKEN")}}}

  Or the full OAuth 2.1 flow — see `Noizu.MCP.Auth.OAuth`.

  Strategy state lives in the transport process; `c:headers/1` is consulted
  for every request, and `c:handle_unauthorized/3` runs (serialized) when the
  server answers 401, or 403 with an `insufficient_scope` challenge.
  """

  alias Noizu.MCP.Auth.WWWAuthenticate

  @type state :: term()

  @doc "Initialize. `opts` includes `:mcp_url` (the server URL) injected by the transport."
  @callback init(opts :: keyword()) :: {:ok, state()} | {:error, term()}

  @doc "Authorization headers for the next request (may refresh tokens)."
  @callback headers(state()) :: {[{binary(), binary()}], state()}

  @doc """
  React to a 401/403 challenge. Return `{:retry, state}` to retry the request
  with fresh `c:headers/1`, or `{:error, reason, state}` to give up.
  """
  @callback handle_unauthorized(WWWAuthenticate.t() | nil, info :: map(), state()) ::
              {:retry, state()} | {:error, term(), state()}
end
