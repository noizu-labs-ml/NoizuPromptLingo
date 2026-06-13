defmodule HttpKitchenSink.Router do
  @moduledoc """
  Plain `Plug.Router` showing how the MCP endpoint co-exists with other
  routes. The MCP plug owns everything under `/mcp` (POST/GET/DELETE on the
  mount point itself; anything deeper is 404).
  """

  use Plug.Router

  plug :match
  plug :dispatch

  get "/health" do
    send_resp(conn, 200, "ok")
  end

  forward "/mcp",
    to: Noizu.MCP.Transport.StreamableHTTP.Plug,
    init_opts: [server: HttpKitchenSink.MCP]

  match _ do
    send_resp(conn, 404, "not found")
  end
end
