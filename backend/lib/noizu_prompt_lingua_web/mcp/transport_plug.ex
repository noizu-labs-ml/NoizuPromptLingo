defmodule NoizuPromptLinguaWeb.MCP.TransportPlug do
  @moduledoc """
  The lib streamable-HTTP transport mounted behind the NPL-owned
  `JsonRpcGuard` (B4). Same init opts as
  `Noizu.MCP.Transport.StreamableHTTP.Plug`; the guard answers malformed
  JSON-RPC framing (`jsonrpc` missing / != "2.0" ⇒ -32600) BEFORE the
  transport can classify-and-hang on it, then validated requests continue
  through the pinned lib plug unchanged.

  Mounted as the root `/mcp` forward (router.ex) and used by the
  custom/set gateway controllers' serve paths — one guard seam for every
  transport surface.
  """

  @behaviour Plug

  @impl true
  def init(opts), do: Noizu.MCP.Transport.StreamableHTTP.Plug.init(opts)

  @impl true
  def call(conn, opts) do
    case NoizuPromptLinguaWeb.MCP.JsonRpcGuard.check(conn) do
      {:ok, conn} -> Noizu.MCP.Transport.StreamableHTTP.Plug.call(conn, opts)
      {:halt, conn} -> conn
    end
  end
end
