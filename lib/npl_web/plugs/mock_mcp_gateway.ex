defmodule NPLWeb.Plugs.MockMCPGateway do
  @moduledoc """
  MCP JSON-RPC gateway for dynamic mock MCP servers.
  Handles initialize, tools/list, tools/call for mock MCPs defined in the DB.

  Route: mockmcp.tobor.locker/mcp/{slug}/mcp
  """
  import Plug.Conn

  alias NoizuPromptLingua.Domains.MockMCP
  alias NoizuPromptLingua.Domains.MockMCP.Agent

  @behaviour Plug

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    slug = conn.params["slug"] || conn.path_params["slug"]

    case conn.method do
      "POST" -> handle_post(conn, slug)
      "GET" -> handle_sse_open(conn, slug)
      "DELETE" -> handle_session_close(conn, slug)
      _ -> send_resp(conn, 405, "Method not allowed")
    end
  end

  defp handle_post(conn, slug) do
    {:ok, body, conn} = Plug.Conn.read_body(conn)

    case Jason.decode(body) do
      {:ok, %{"jsonrpc" => "2.0"} = request} ->
        dispatch_jsonrpc(conn, slug, request)
      {:ok, _} ->
        json_error(conn, nil, -32600, "Invalid Request")
      {:error, _} ->
        json_error(conn, nil, -32700, "Parse error")
    end
  end

  defp handle_sse_open(conn, _slug) do
    send_resp(conn, 501, "SSE not yet supported for mock MCPs")
  end

  defp handle_session_close(conn, _slug) do
    send_resp(conn, 200, "")
  end

  defp dispatch_jsonrpc(conn, slug, %{"method" => method, "id" => id} = request) do
    params = request["params"] || %{}

    case method do
      "initialize" ->
        handle_initialize(conn, slug, id, params)
      "tools/list" ->
        handle_tools_list(conn, slug, id, params)
      "tools/call" ->
        handle_tools_call(conn, slug, id, params)
      "ping" ->
        json_result(conn, id, %{})
      _ ->
        json_error(conn, id, -32601, "Method not found: #{method}")
    end
  end

  defp dispatch_jsonrpc(conn, _slug, %{"method" => "notifications/" <> _}) do
    send_resp(conn, 202, "")
  end

  defp dispatch_jsonrpc(conn, _slug, _request) do
    json_error(conn, nil, -32600, "Invalid Request")
  end

  defp handle_initialize(conn, slug, id, _params) do
    case MockMCP.get_active(slug) do
      nil ->
        case MockMCP.get(slug) do
          nil -> json_error(conn, id, -32000, "Mock MCP '#{slug}' not found")
          %{status: status} -> json_error(conn, id, -32000, "Mock MCP '#{slug}' is #{status}, not active")
        end
      def_ ->
        session_id = Base.encode16(:crypto.strong_rand_bytes(16), case: :lower)
        result = %{
          protocolVersion: "2025-03-26",
          capabilities: %{tools: %{listChanged: false}},
          serverInfo: %{name: "mock-#{def_.slug}", version: "1.0.0"}
        }
        conn
        |> put_resp_header("mcp-session-id", session_id)
        |> json_result(id, result)
    end
  end

  defp handle_tools_list(conn, slug, id, _params) do
    tools = MockMCP.get_tools(slug)
    mcp_tools = Enum.map(tools, fn tool ->
      %{
        name: tool["name"],
        description: tool["description"],
        inputSchema: tool["inputSchema"] || %{"type" => "object", "properties" => %{}}
      }
    end)
    json_result(conn, id, %{tools: mcp_tools})
  end

  defp handle_tools_call(conn, slug, id, %{"name" => tool_name} = params) do
    arguments = params["arguments"] || %{}

    case MockMCP.get_active(slug) do
      nil ->
        json_error(conn, id, -32000, "Mock MCP '#{slug}' not active")
      def_ ->
        opts = [
          provider: def_.llm_provider,
          model: def_.llm_model,
          endpoint: def_.llm_endpoint
        ]

        case Agent.handle_tool_call(def_.prompt, tool_name, arguments, opts) do
          {:ok, content, latency} ->
            MockMCP.log_call(def_.id, %{
              method: "tools/call",
              tool_name: tool_name,
              arguments: arguments,
              response: %{content: content},
              latency_ms: latency
            })
            json_result(conn, id, %{content: content})

          {:error, reason, latency} ->
            MockMCP.log_call(def_.id, %{
              method: "tools/call",
              tool_name: tool_name,
              arguments: arguments,
              error: inspect(reason),
              latency_ms: latency
            })
            json_error(conn, id, -32000, "Tool call failed: #{inspect(reason)}")
        end
    end
  end

  defp handle_tools_call(conn, _slug, id, _params) do
    json_error(conn, id, -32602, "Missing 'name' parameter")
  end

  # ── JSON-RPC helpers ─────────────────────────────────────────

  defp json_result(conn, id, result) do
    body = Jason.encode!(%{jsonrpc: "2.0", id: id, result: result})
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, body)
  end

  defp json_error(conn, id, code, message) do
    body = Jason.encode!(%{jsonrpc: "2.0", id: id, error: %{code: code, message: message}})
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, body)
  end
end
