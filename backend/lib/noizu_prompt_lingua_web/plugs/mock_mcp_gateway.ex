defmodule NoizuPromptLinguaWeb.Plugs.MockMCPGateway do
  @moduledoc """
  MCP JSON-RPC gateway for dynamic mock MCP servers. Serves the full MCP surface
  for a mock defined in the DB:

    * tools  — `tools/list`, `tools/call` (generated tools fabricated by the LLM
      using each tool's private handler; built-in `db_*`/`redis_*` tools execute
      for real against the mock's datastore)
    * resources — `resources/list`, `resources/read`
    * prompts — `prompts/list`, `prompts/get`

  Route: mockmcp.<host>/mcp/{slug}/mcp
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
      "GET" -> send_resp(conn, 501, "SSE not yet supported for mock MCPs")
      "DELETE" -> send_resp(conn, 200, "")
      _ -> send_resp(conn, 405, "Method not allowed")
    end
  end

  defp handle_post(conn, slug) do
    case request_payload(conn) do
      {:ok, %{"jsonrpc" => "2.0"} = request} -> dispatch_jsonrpc(conn, slug, request)
      {:ok, _} -> json_error(conn, nil, -32600, "Invalid Request")
      :parse_error -> json_error(conn, nil, -32700, "Parse error")
    end
  end

  defp request_payload(%{body_params: %{"jsonrpc" => _} = params}), do: {:ok, params}
  defp request_payload(conn) do
    case Plug.Conn.read_body(conn) do
      {:ok, "", _conn} -> {:ok, conn.body_params}
      {:ok, body, _conn} ->
        case Jason.decode(body) do
          {:ok, decoded} -> {:ok, decoded}
          {:error, _} -> :parse_error
        end
      _ -> :parse_error
    end
  end

  defp dispatch_jsonrpc(conn, slug, %{"method" => method, "id" => id} = request) do
    params = request["params"] || %{}

    case method do
      "initialize" -> handle_initialize(conn, slug, id, params)
      "tools/list" -> handle_tools_list(conn, slug, id)
      "tools/call" -> handle_tools_call(conn, slug, id, params)
      "resources/list" -> handle_resources_list(conn, slug, id)
      "resources/read" -> handle_resources_read(conn, slug, id, params)
      "prompts/list" -> handle_prompts_list(conn, slug, id)
      "prompts/get" -> handle_prompts_get(conn, slug, id, params)
      "ping" -> json_result(conn, id, %{})
      _ -> json_error(conn, id, -32601, "Method not found: #{method}")
    end
  end

  defp dispatch_jsonrpc(conn, _slug, %{"method" => "notifications/" <> _}),
    do: send_resp(conn, 202, "")

  defp dispatch_jsonrpc(conn, _slug, _request),
    do: json_error(conn, nil, -32600, "Invalid Request")

  # ── initialize ───────────────────────────────────────────────

  defp handle_initialize(conn, slug, id, _params) do
    with_active(conn, slug, id, fn def_ ->
      session_id = Base.encode16(:crypto.strong_rand_bytes(16), case: :lower)

      result = %{
        protocolVersion: "2025-03-26",
        capabilities: %{
          tools: %{listChanged: false},
          resources: %{listChanged: false, subscribe: false},
          prompts: %{listChanged: false}
        },
        serverInfo: %{name: "mock-#{def_.slug}", version: "1.0.0"}
      }

      conn
      |> put_resp_header("mcp-session-id", session_id)
      |> json_result(id, result)
    end)
  end

  # ── tools ────────────────────────────────────────────────────

  defp handle_tools_list(conn, slug, id) do
    with_active(conn, slug, id, fn def_ ->
      # Only the mock's generated (semantic) tools are exposed. The mock's
      # Postgres/Redis are the agent's PRIVATE backing store, never surfaced as
      # tools to consumers.
      tools = Enum.map(def_.tools_json || [], &public_tool/1)
      json_result(conn, id, %{tools: tools})
    end)
  end

  # Strip the private "handler" before sending to clients.
  defp public_tool(tool) do
    %{
      name: tool["name"],
      description: tool["description"],
      inputSchema: tool["inputSchema"] || %{"type" => "object", "properties" => %{}}
    }
  end

  defp handle_tools_call(conn, slug, id, %{"name" => tool_name} = params) do
    arguments = params["arguments"] || %{}

    with_active(conn, slug, id, fn def_ ->
      case find_by(def_.tools_json, "name", tool_name) do
        nil -> json_error(conn, id, -32602, "Unknown tool: #{tool_name}")
        tool -> run_generated_tool(conn, id, def_, tool, arguments)
      end
    end)
  end

  defp handle_tools_call(conn, _slug, id, _params),
    do: json_error(conn, id, -32602, "Missing 'name' parameter")

  defp run_generated_tool(conn, id, def_, tool, arguments) do
    opts = MockMCP.active_llm_opts(def_)

    case Agent.handle_tool_call(def_, tool["name"], arguments, tool["handler"], opts) do
      {:ok, content, latency, trace} ->
        MockMCP.log_call(def_.id, %{method: "tools/call", tool_name: tool["name"],
          arguments: arguments, response: %{content: content, trace: trace}, latency_ms: latency})
        json_result(conn, id, %{content: content})

      {:error, reason, latency, trace} ->
        MockMCP.log_call(def_.id, %{method: "tools/call", tool_name: tool["name"],
          arguments: arguments, error: inspect(reason), response: %{trace: trace}, latency_ms: latency})
        json_error(conn, id, -32000, "Tool call failed: #{inspect(reason)}")
    end
  end

  # ── resources ────────────────────────────────────────────────

  defp handle_resources_list(conn, slug, id) do
    with_active(conn, slug, id, fn def_ ->
      resources =
        Enum.map(def_.resources_json || [], fn r ->
          %{uri: r["uri"], name: r["name"], description: r["description"],
            mimeType: r["mimeType"] || "text/plain"}
        end)

      json_result(conn, id, %{resources: resources})
    end)
  end

  defp handle_resources_read(conn, slug, id, %{"uri" => uri}) do
    with_active(conn, slug, id, fn def_ ->
      case find_by(def_.resources_json, "uri", uri) do
        nil ->
          json_error(conn, id, -32002, "Resource not found: #{uri}")

        resource ->
          opts = MockMCP.active_llm_opts(def_)

          case Agent.handle_resource_read(def_, resource, opts) do
            {:ok, contents, latency, trace} ->
              MockMCP.log_call(def_.id, %{method: "resources/read", tool_name: uri,
                response: %{contents: contents, trace: trace}, latency_ms: latency})
              json_result(conn, id, %{contents: contents})

            {:error, reason, latency, trace} ->
              MockMCP.log_call(def_.id, %{method: "resources/read", tool_name: uri,
                error: inspect(reason), response: %{trace: trace}, latency_ms: latency})
              json_error(conn, id, -32000, "Resource read failed: #{inspect(reason)}")
          end
      end
    end)
  end

  defp handle_resources_read(conn, _slug, id, _params),
    do: json_error(conn, id, -32602, "Missing 'uri' parameter")

  # ── prompts ──────────────────────────────────────────────────

  defp handle_prompts_list(conn, slug, id) do
    with_active(conn, slug, id, fn def_ ->
      prompts =
        Enum.map(def_.prompts_json || [], fn p ->
          %{name: p["name"], description: p["description"], arguments: p["arguments"] || []}
        end)

      json_result(conn, id, %{prompts: prompts})
    end)
  end

  defp handle_prompts_get(conn, slug, id, %{"name" => name} = params) do
    arguments = params["arguments"] || %{}

    with_active(conn, slug, id, fn def_ ->
      case find_by(def_.prompts_json, "name", name) do
        nil ->
          json_error(conn, id, -32602, "Prompt not found: #{name}")

        prompt_def ->
          opts = MockMCP.active_llm_opts(def_)

          case Agent.handle_prompt_get(def_, prompt_def, arguments, opts) do
            {:ok, messages, latency, trace} ->
              MockMCP.log_call(def_.id, %{method: "prompts/get", tool_name: name,
                arguments: arguments, response: %{messages: messages, trace: trace}, latency_ms: latency})
              json_result(conn, id, %{description: prompt_def["description"], messages: messages})

            {:error, reason, latency, trace} ->
              MockMCP.log_call(def_.id, %{method: "prompts/get", tool_name: name,
                arguments: arguments, error: inspect(reason), response: %{trace: trace}, latency_ms: latency})
              json_error(conn, id, -32000, "Prompt get failed: #{inspect(reason)}")
          end
      end
    end)
  end

  defp handle_prompts_get(conn, _slug, id, _params),
    do: json_error(conn, id, -32602, "Missing 'name' parameter")

  # ── helpers ──────────────────────────────────────────────────

  # Load the active definition or emit the appropriate JSON-RPC error.
  defp with_active(conn, slug, id, fun) do
    case MockMCP.get_active(slug) do
      nil ->
        case MockMCP.get(slug) do
          nil -> json_error(conn, id, -32000, "Mock MCP '#{slug}' not found")
          %{status: status} -> json_error(conn, id, -32000, "Mock MCP '#{slug}' is #{status}, not active")
        end
      def_ -> fun.(def_)
    end
  end

  defp find_by(nil, _key, _val), do: nil
  defp find_by(list, key, val), do: Enum.find(list, &(&1[key] == val))

  defp json_result(conn, id, result) do
    body = Jason.encode!(%{jsonrpc: "2.0", id: id, result: result})
    conn |> put_resp_content_type("application/json") |> send_resp(200, body)
  end

  defp json_error(conn, id, code, message) do
    body = Jason.encode!(%{jsonrpc: "2.0", id: id, error: %{code: code, message: message}})
    conn |> put_resp_content_type("application/json") |> send_resp(200, body)
  end
end
