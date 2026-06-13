if Code.ensure_loaded?(Plug.Conn) do
  defmodule Noizu.MCP.Inspector.Plug do
    @moduledoc """
    HTTP surface of the inspector: serves the single-page UI from
    `priv/inspector/` and a JSON + SSE bridge to inspector sessions.

    Every `/api/*` call requires the per-run bearer token (also accepted as
    `?token=` for `EventSource`, which cannot set headers). Binds are expected
    to be localhost-only; any cross-origin browser request is rejected.
    """

    use Plug.Router

    alias Noizu.MCP.Client
    alias Noizu.MCP.Inspector
    alias Noizu.MCP.Inspector.Session
    alias Noizu.MCP.Transport.SSE
    alias Noizu.MCP.Types.{Prompt, PromptMessage, Resource, ResourceContents}
    alias Noizu.MCP.Types.{ResourceTemplate, Tool}

    @keepalive 25_000

    def init(config), do: config

    def call(conn, config) do
      conn
      |> put_private(:inspector, config)
      |> super(config)
    end

    plug(:origin_guard)

    plug(Plug.Static, at: "/assets", from: {:noizu_mcp, "priv/inspector/assets"})

    plug(:match)
    plug(:api_auth)

    plug(Plug.Parsers,
      parsers: [:json],
      json_decoder: Jason,
      pass: ["application/json"]
    )

    plug(:dispatch)

    # ── UI ───────────────────────────────────────────────────────────────────

    get "/" do
      index = Path.join(Application.app_dir(:noizu_mcp, "priv/inspector"), "index.html")

      conn
      |> put_resp_content_type("text/html")
      |> send_resp(200, File.read!(index))
    end

    # ── sessions ─────────────────────────────────────────────────────────────

    get "/api/servers" do
      config = conn.private.inspector

      json(conn, 200, %{
        "servers" => Enum.sort(Inspector.discover_servers()),
        "has_default" => config.default_target != nil
      })
    end

    post "/api/connect" do
      config = conn.private.inspector

      case Inspector.start_session(config, conn.body_params["target"]) do
        {:ok, _session_id, session} ->
          # Non-blocking: the handshake runs in the background. info/1
          # returns immediately with status "connecting" or "ready"
          # (in-process targets are instant). The browser subscribes to SSE
          # and receives a "status" event when the session transitions.
          {:ok, info} = Session.info(session)
          json(conn, 200, info)

        {:error, :no_target} ->
          json(conn, 400, %{"error" => "no target configured — choose one in the UI"})

        {:error, reason} ->
          json(conn, 502, %{"error" => connect_error(reason)})
      end
    end

    get "/api/session/:id" do
      with_session(conn, id, fn session, _client ->
        {:ok, info} = Session.info(session)
        {200, info}
      end)
    end

    delete "/api/session/:id" do
      with_session(conn, id, fn session, _client ->
        client = Session.client(session)
        Client.close(client)
        {200, %{"ok" => true}}
      end)
    end

    # ── feature listings ─────────────────────────────────────────────────────

    get "/api/session/:id/tools" do
      list(conn, id, &Client.list_tools/1, "tools", &Tool.to_map/1)
    end

    get "/api/session/:id/resources" do
      list(conn, id, &Client.list_resources/1, "resources", &Resource.to_map/1)
    end

    get "/api/session/:id/resource_templates" do
      list(
        conn,
        id,
        &Client.list_resource_templates/1,
        "resourceTemplates",
        &ResourceTemplate.to_map/1
      )
    end

    get "/api/session/:id/prompts" do
      list(conn, id, &Client.list_prompts/1, "prompts", &Prompt.to_map/1)
    end

    # ── tool calls ───────────────────────────────────────────────────────────

    post "/api/session/:id/calls" do
      %{"name" => name} = conn.body_params

      with_session(conn, id, fn session, _client ->
        case Session.call_tool(session, name, conn.body_params["arguments"] || %{}) do
          {:ok, call_id} -> {202, %{"call_id" => call_id}}
          {:error, reason} -> {502, %{"error" => describe(reason)}}
        end
      end)
    end

    delete "/api/session/:id/calls/:call_id" do
      with_session(conn, id, fn session, _client ->
        case Integer.parse(call_id) do
          {call_id, ""} ->
            case Session.cancel_call(session, call_id) do
              :ok -> {200, %{"ok" => true}}
              {:error, :unknown_call} -> {404, %{"error" => "unknown call"}}
            end

          _ ->
            {400, %{"error" => "bad call id"}}
        end
      end)
    end

    # ── resources ────────────────────────────────────────────────────────────

    post "/api/session/:id/resources/read" do
      %{"uri" => uri} = conn.body_params

      with_client(conn, id, fn client ->
        with {:ok, contents} <- Client.read_resource(client, uri) do
          {:ok, %{"contents" => Enum.map(contents, &ResourceContents.to_map/1)}}
        end
      end)
    end

    post "/api/session/:id/resources/subscribe" do
      %{"uri" => uri} = conn.body_params
      with_client(conn, id, fn client -> ok_map(Client.subscribe_resource(client, uri)) end)
    end

    post "/api/session/:id/resources/unsubscribe" do
      %{"uri" => uri} = conn.body_params
      with_client(conn, id, fn client -> ok_map(Client.unsubscribe_resource(client, uri)) end)
    end

    # ── prompts / completion ─────────────────────────────────────────────────

    post "/api/session/:id/prompts/get" do
      %{"name" => name} = conn.body_params

      with_client(conn, id, fn client ->
        with {:ok, %{description: description, messages: messages}} <-
               Client.get_prompt(client, name, conn.body_params["arguments"] || %{}) do
          {:ok,
           %{
             "description" => description,
             "messages" => Enum.map(messages, &PromptMessage.to_map/1)
           }}
        end
      end)
    end

    post "/api/session/:id/complete" do
      %{"ref" => ref, "argument" => %{"name" => arg_name, "value" => value}} = conn.body_params

      reference =
        case ref do
          %{"type" => "ref/prompt", "name" => name} -> {:prompt, name}
          %{"type" => "ref/resource", "uri" => uri} -> {:resource_template, uri}
          _ -> nil
        end

      if reference do
        with_client(conn, id, fn client ->
          with {:ok, completion} <- Client.complete(client, reference, arg_name, value) do
            {:ok,
             %{
               "values" => completion.values,
               "total" => completion.total,
               "hasMore" => completion.has_more
             }}
          end
        end)
      else
        json(conn, 400, %{"error" => "bad completion ref"})
      end
    end

    # ── misc client operations ───────────────────────────────────────────────

    post "/api/session/:id/rpc" do
      %{"method" => method} = conn.body_params

      with_client(conn, id, fn client ->
        Client.request(client, method, conn.body_params["params"])
      end)
    end

    post "/api/session/:id/ping" do
      with_client(conn, id, fn client -> ok_map(Client.ping(client)) end)
    end

    post "/api/session/:id/log_level" do
      %{"level" => level} = conn.body_params
      with_client(conn, id, fn client -> ok_map(Client.set_log_level(client, level)) end)
    end

    post "/api/session/:id/roots" do
      roots = conn.body_params["roots"] || []

      with_session(conn, id, fn session, _client ->
        :ok = Session.set_roots(session, roots)
        {200, %{"ok" => true}}
      end)
    end

    # ── pending sampling/elicitation ─────────────────────────────────────────

    post "/api/session/:id/respond/:request_id" do
      with_session(conn, id, fn session, _client ->
        case Session.respond_pending(session, request_id, conn.body_params) do
          :ok -> {200, %{"ok" => true}}
          {:error, :unknown_request} -> {404, %{"error" => "unknown request"}}
          {:error, :bad_response} -> {400, %{"error" => "bad response shape"}}
        end
      end)
    end

    # ── config export ────────────────────────────────────────────────────────

    get "/api/session/:id/export" do
      with_session(conn, id, fn session, _client ->
        {:ok, info} = Session.info(session)
        target = info["target"]

        entry =
          case target do
            %{"type" => "stdio"} ->
              %{"command" => target["command"]}
              |> maybe_put("args", target["args"])
              |> maybe_put("env", target["env"])

            %{"type" => "url"} ->
              %{"type" => "http", "url" => target["url"]}

            _ ->
              nil
          end

        server_name =
          case info["server_info"] do
            %{name: name} -> name
            %{"name" => name} -> name
            _ -> "mcp-server"
          end

        {200,
         %{
           "target" => target,
           "entry" => entry,
           "servers_file" => entry && %{"mcpServers" => %{server_name => entry}},
           "note" =>
             unless(entry,
               do: "In-process module targets have no external client config equivalent."
             )
         }}
      end)
    end

    # ── SSE event stream ─────────────────────────────────────────────────────

    get "/api/session/:id/events" do
      with_session(conn, id, fn session, _client ->
        last_seq =
          (List.first(get_req_header(conn, "last-event-id")) ||
             conn.query_params["last_event_id"])
          |> parse_seq()

        {:ok, replay} = Session.subscribe_events(session, last_seq)
        monitor = Process.monitor(session)

        conn =
          conn
          |> put_resp_content_type("text/event-stream")
          |> put_resp_header("cache-control", "no-cache")
          |> send_chunked(200)

        conn =
          Enum.reduce_while(replay, conn, fn event, conn ->
            case chunk(conn, encode_event(event)) do
              {:ok, conn} -> {:cont, conn}
              {:error, _} -> {:halt, conn}
            end
          end)

        {:halted, stream_events(conn, monitor)}
      end)
    end

    match _ do
      send_resp(conn, 404, "Not found")
    end

    defp stream_events(conn, monitor) do
      receive do
        {:inspector_event, event} ->
          case chunk(conn, encode_event(event)) do
            {:ok, conn} -> stream_events(conn, monitor)
            {:error, _closed} -> conn
          end

        {:DOWN, ^monitor, :process, _pid, _reason} ->
          conn
      after
        @keepalive ->
          case chunk(conn, ": keepalive\n\n") do
            {:ok, conn} -> stream_events(conn, monitor)
            {:error, _closed} -> conn
          end
      end
    end

    defp encode_event(%{seq: seq, event: type, data: data}) do
      SSE.encode(Jason.encode!(data), id: seq, event: type)
    end

    defp parse_seq(nil), do: nil

    defp parse_seq(value) do
      case Integer.parse(value) do
        {seq, ""} -> seq
        _ -> nil
      end
    end

    # ── helpers ──────────────────────────────────────────────────────────────

    defp with_session(conn, session_id, fun) do
      config = conn.private.inspector

      case Inspector.lookup_session(config, session_id) do
        {:ok, session} ->
          try do
            case fun.(session, nil) do
              {:halted, conn} -> conn
              {status, payload} -> json(conn, status, payload)
            end
          catch
            :exit, reason -> json(conn, 502, %{"error" => describe(reason)})
          end

        {:error, :not_found} ->
          json(conn, 404, %{"error" => "unknown or expired session"})
      end
    end

    defp with_client(conn, session_id, fun) do
      with_session(conn, session_id, fn session, _ ->
        client = Session.client(session)

        case fun.(client) do
          :ok -> {200, %{"ok" => true}}
          {:ok, payload} -> {200, payload}
          {:error, reason} -> {502, %{"error" => describe(reason)}}
        end
      end)
    end

    defp list(conn, session_id, lister, key, encoder) do
      with_client(conn, session_id, fn client ->
        with {:ok, items} <- lister.(client) do
          {:ok, %{key => Enum.map(items, encoder)}}
        end
      end)
    end

    defp ok_map(:ok), do: {:ok, %{"ok" => true}}
    defp ok_map(other), do: other

    defp json(conn, status, payload) do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(status, Jason.encode!(payload))
    end

    defp connect_error({:shutdown, {:connect_failed, inner}}), do: connect_error(inner)

    defp connect_error({:timeout, {GenServer, :call, [_pid, :await_ready, _timeout]}}),
      do:
        "Connection timed out — the server did not complete the MCP handshake. " <>
          "If this is an SSE-transport server (/sse endpoint), note that noizu_mcp " <>
          "speaks Streamable HTTP (2025-06-18+), not the legacy SSE transport."

    defp connect_error({:connect_failed, inner}), do: connect_error(inner)
    defp connect_error({:noproc, _}), do: "Connection failed — server process not found"

    defp connect_error({:shutdown, {:transport_down, reason}}),
      do: "Connection lost: #{inspect(reason)}"

    defp connect_error(reason), do: describe(reason)

    defp describe(%Noizu.MCP.Error{} = error),
      do: %{"code" => error.code, "message" => error.message, "data" => error.data}

    defp describe(reason) when is_binary(reason), do: reason
    defp describe(reason), do: inspect(reason)

    defp maybe_put(map, _key, nil), do: map
    defp maybe_put(map, _key, []), do: map
    defp maybe_put(map, key, value), do: Map.put(map, key, value)

    # ── auth / origin plugs ──────────────────────────────────────────────────

    defp origin_guard(conn, _opts) do
      case get_req_header(conn, "origin") do
        [] ->
          conn

        [origin | _] ->
          case URI.parse(origin) do
            %URI{host: host} when host in ["localhost", "127.0.0.1", "[::1]", "::1"] ->
              conn

            _ ->
              conn |> send_resp(403, "Forbidden origin") |> halt()
          end
      end
    end

    defp api_auth(%{path_info: ["api" | _]} = conn, _opts) do
      config = conn.private.inspector

      if config.token == nil do
        conn
      else
        conn = fetch_query_params(conn)

        token =
          case get_req_header(conn, "authorization") do
            ["Bearer " <> token | _] -> token
            _ -> conn.query_params["token"]
          end

        if is_binary(token) and Plug.Crypto.secure_compare(token, config.token) do
          conn
        else
          conn
          |> put_resp_content_type("application/json")
          |> send_resp(401, ~s({"error":"missing or invalid token"}))
          |> halt()
        end
      end
    end

    defp api_auth(conn, _opts), do: conn
  end
end
