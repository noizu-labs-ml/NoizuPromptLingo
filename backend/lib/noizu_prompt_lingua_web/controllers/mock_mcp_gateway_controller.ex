defmodule NoizuPromptLinguaWeb.MockMCPGatewayController do
  @moduledoc """
  Thin controller wrapper that delegates dynamic mock-MCP JSON-RPC requests to
  `NoizuPromptLinguaWeb.Plugs.MockMCPGateway`. Served at
  `mockmcp.<host>/mcp/:slug/mcp` for all HTTP verbs.
  """
  use NoizuPromptLinguaWeb, :controller

  def handle(conn, _params) do
    NoizuPromptLinguaWeb.Plugs.MockMCPGateway.call(conn, [])
  end
end
