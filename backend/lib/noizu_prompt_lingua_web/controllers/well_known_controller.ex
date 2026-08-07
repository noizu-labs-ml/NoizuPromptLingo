defmodule NoizuPromptLinguaWeb.WellKnownController do
  use NoizuPromptLinguaWeb, :controller

  @moduledoc """
  Public discovery documents for MCP OAuth migration (Phase 0+).

  - `GET /.well-known/jwks.json` — MCP JWT verification keys
  - Later phases add `oauth-authorization-server` and per-host PRM
  """

  alias NoizuPromptLingua.OAuth.Jwks

  def jwks(conn, _params) do
    conn
    |> put_resp_header("cache-control", "public, max-age=60")
    |> json(Jwks.document())
  end
end
