defmodule NoizuPromptLinguaWeb.MCP.TransportPlug do
  @moduledoc """
  Streamable-HTTP transport for the public NPL syntax MCP.

  `JsonRpcGuard` answers malformed JSON-RPC framing (`jsonrpc` missing /
  != "2.0" ⇒ -32600) before the lib transport. Authentication is optional:
  missing `Authorization` proceeds as an anonymous caller; a Bearer token
  is verified (OAuth site-approval or legacy MCP JWT) and attached as
  `mcp_auth_claims`. Invalid tokens 401.
  """

  @behaviour Plug
  import Plug.Conn

  alias NoizuPromptLingua.MCP.DualTokenVerifier
  alias NoizuPromptLinguaWeb.MCPConfig

  @impl true
  def init(opts), do: Noizu.MCP.Transport.StreamableHTTP.Plug.init(opts)

  @impl true
  def call(conn, opts) do
    case NoizuPromptLinguaWeb.MCP.JsonRpcGuard.check(conn) do
      {:ok, conn} ->
        case optional_auth(conn) do
          {:ok, conn} -> Noizu.MCP.Transport.StreamableHTTP.Plug.call(conn, opts)
          {:halt, conn} -> conn
        end

      {:halt, conn} ->
        conn
    end
  end

  defp optional_auth(conn) do
    case bearer_token(conn) do
      nil ->
        {:ok, conn}

      token ->
        conn_info = %{method: conn.method, peer: conn.remote_ip, headers: conn.req_headers}
        {_mod, verifier_opts} = Keyword.get(MCPConfig.auth_opts(), :verifier)

        case DualTokenVerifier.verify(token, conn_info, verifier_opts) do
          {:ok, claims} ->
            {:ok, assign(conn, :mcp_auth_claims, claims)}

          {:error, _} ->
            conn =
              conn
              |> put_resp_content_type("text/plain")
              |> send_resp(401, "Unauthorized")

            {:halt, conn}
        end
    end
  end

  defp bearer_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> String.trim(token)
      _ -> nil
    end
  end
end
