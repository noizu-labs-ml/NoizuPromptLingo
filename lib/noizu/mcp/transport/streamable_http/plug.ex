if Code.ensure_loaded?(Plug.Conn) do
  defmodule Noizu.MCP.Transport.StreamableHTTP.Plug do
    @moduledoc """
    Streamable HTTP server transport (MCP 2025-11-25): a single MCP endpoint
    handling POST/GET/DELETE, mountable in Phoenix or any Plug stack:

        # Phoenix router
        forward "/mcp", Noizu.MCP.Transport.StreamableHTTP.Plug, server: MyApp.MCP

        # standalone with Bandit
        {Bandit, plug: {Noizu.MCP.Transport.StreamableHTTP.Plug, server: MyApp.MCP}, port: 4040}

    Behavior per spec: `initialize` POSTs create a session and return
    `Mcp-Session-Id`; requests answer as `application/json` when the handler
    produces only a response, upgrading to an SSE stream when progress,
    logging, or server-initiated requests flow first; GET opens the general
    SSE stream (with `Last-Event-ID` resumability backed by
    `Noizu.MCP.Server.EventStore`); DELETE terminates the session.

    ## Options

      * `:server` (required) — the `use Noizu.MCP.Server` module
      * `:origins` — `:localhost` (default; allows non-browser clients and
        localhost origins), `:any`, or an explicit allowlist of origins.
        Origin validation guards against DNS-rebinding attacks.
      * `:idle_timeout` — session idle expiry in ms (default 30 minutes)
      * `:request_timeout` — max time to wait for a handler response
        (default 300_000)
      * `:keepalive` — SSE keepalive comment interval in ms (default 25_000)
      * `:context` — `{module, function}` invoked as `fun.(conn)` returning a
        map merged into session assigns at initialize (how plug-level auth
        reaches handlers)
    """

    @behaviour Plug
    import Plug.Conn

    alias Noizu.MCP.Protocol.Version
    alias Noizu.MCP.Server.EventStore
    alias Noizu.MCP.Server.Session
    alias Noizu.MCP.Transport.SSE
    alias Noizu.MCP.Transport.StreamableHTTP.Sink

    @impl Plug
    def init(opts) do
      %{
        server: Keyword.fetch!(opts, :server),
        origins: Keyword.get(opts, :origins, :localhost),
        idle_timeout: Keyword.get(opts, :idle_timeout, :timer.minutes(30)),
        request_timeout: Keyword.get(opts, :request_timeout, 300_000),
        init_timeout: Keyword.get(opts, :init_timeout, 30_000),
        keepalive: Keyword.get(opts, :keepalive, 25_000),
        sse_commit_after: Keyword.get(opts, :sse_commit_after, 200),
        context: Keyword.get(opts, :context),
        auth: Keyword.get(opts, :auth)
      }
    end

    @impl Plug
    def call(conn, opts) do
      cond do
        not origin_allowed?(conn, opts.origins) ->
          send_resp(conn, 403, "Forbidden origin")

        conn.path_info != [] ->
          send_resp(conn, 404, "Not found")

        true ->
          case authenticate(conn, opts.auth) do
            {:ok, conn} -> route(conn, opts)
            {:halt, conn} -> conn
          end
      end
    end

    defp route(conn, opts) do
      case conn.method do
        "POST" ->
          handle_post(conn, opts)

        "GET" ->
          handle_get(conn, opts)

        "DELETE" ->
          handle_delete(conn, opts)

        _ ->
          conn
          |> put_resp_header("allow", "GET, POST, DELETE")
          |> send_resp(405, "Method not allowed")
      end
    end

    # ── authorization (OAuth 2.1 resource server) ────────────────────────────

    defp authenticate(conn, nil), do: {:ok, conn}

    defp authenticate(conn, auth) do
      {verifier, verifier_opts} = normalize_verifier(Keyword.fetch!(auth, :verifier))

      case bearer_token(conn) do
        nil ->
          {:halt, unauthorized(conn, auth, "invalid_request")}

        token ->
          conn_info = %{method: conn.method, peer: conn.remote_ip, headers: conn.req_headers}

          case verifier.verify(token, conn_info, verifier_opts) do
            {:ok, claims} ->
              {:ok, assign(conn, :mcp_auth_claims, claims)}

            {:error, :invalid_token} ->
              {:halt, unauthorized(conn, auth, "invalid_token")}

            {:error, :insufficient_scope, meta} ->
              challenge =
                Noizu.MCP.Auth.WWWAuthenticate.format(
                  resource_params(auth) ++
                    [{"error", "insufficient_scope"}] ++
                    Enum.map(meta, fn {key, value} -> {to_string(key), to_string(value)} end)
                )

              conn
              |> put_resp_header("www-authenticate", challenge)
              |> send_resp(403, "Insufficient scope")
              |> then(&{:halt, &1})
          end
      end
    end

    defp normalize_verifier({module, opts}), do: {module, opts}
    defp normalize_verifier(module) when is_atom(module), do: {module, []}

    defp bearer_token(conn) do
      case get_req_header(conn, "authorization") do
        ["Bearer " <> token | _] -> token
        ["bearer " <> token | _] -> token
        _ -> nil
      end
    end

    defp unauthorized(conn, auth, error) do
      challenge =
        Noizu.MCP.Auth.WWWAuthenticate.format(resource_params(auth) ++ [{"error", error}])

      conn
      |> put_resp_header("www-authenticate", challenge)
      |> send_resp(401, "Unauthorized")
    end

    defp resource_params(auth) do
      case Keyword.get(auth, :resource_metadata) do
        nil -> []
        url -> [{"resource_metadata", url}]
      end
    end

    # ── POST ─────────────────────────────────────────────────────────────────

    defp handle_post(conn, opts) do
      with {:ok, conn, body} <- decoded_body(conn),
           :ok <- check_protocol_version(conn) do
        case classify(body) do
          {:initialize, id} ->
            handle_initialize(conn, opts, body, id)

          {:request, id} ->
            with {:ok, session} <- find_session(conn, opts.server) do
              handle_request(conn, opts, body, id, session)
            else
              {:error, conn_response} -> conn_response
            end

          :one_way ->
            with {:ok, session} <- find_session(conn, opts.server) do
              Session.deliver(session, Jason.encode!(body))
              send_resp(conn, 202, "")
            else
              {:error, conn_response} -> conn_response
            end

          :invalid ->
            send_resp(conn, 400, "Not a JSON-RPC message")
        end
      else
        {:error, :bad_body} ->
          send_resp(conn, 400, "Invalid JSON body")

        {:error, :bad_version} ->
          send_resp(conn, 400, "Unsupported MCP-Protocol-Version")
      end
    end

    defp classify(%{"method" => "initialize", "id" => id}) when is_integer(id) or is_binary(id),
      do: {:initialize, id}

    defp classify(%{"method" => _, "id" => id}) when is_integer(id) or is_binary(id),
      do: {:request, id}

    defp classify(%{"method" => _}), do: :one_way
    defp classify(%{"id" => _, "result" => _}), do: :one_way
    defp classify(%{"id" => _, "error" => _}), do: :one_way
    defp classify(_), do: :invalid

    defp handle_initialize(conn, opts, body, id) do
      server = opts.server
      session_id = Base.url_encode64(:crypto.strong_rand_bytes(24), padding: false)

      assigns =
        case opts.context do
          {module, fun} -> apply(module, fun, [conn])
          fun when is_function(fun, 1) -> fun.(conn)
          nil -> %{}
        end
        |> then(fn assigns ->
          case conn.assigns[:mcp_auth_claims] do
            nil -> assigns
            claims -> Map.put(assigns, :auth_claims, claims)
          end
        end)

      {:ok, session} =
        Noizu.MCP.Server.Supervisor.start_session(server,
          sink: {Sink, {server, session_id}},
          transport: :http,
          session_id: session_id,
          idle_timeout: opts.idle_timeout,
          assigns: assigns
        )

      registry = Module.concat(server, Registry)
      Registry.register(registry, {:http_stream, session_id, id}, nil)
      Session.deliver(session, Jason.encode!(body))

      receive do
        {:mcp_http, binary} ->
          Registry.unregister(registry, {:http_stream, session_id, id})

          conn
          |> put_resp_content_type("application/json")
          |> put_resp_header("mcp-session-id", session_id)
          |> send_resp(200, binary)
      after
        opts.init_timeout ->
          send_resp(conn, 500, "Initialize timed out")
      end
    end

    defp handle_request(conn, opts, body, id, session) do
      server = opts.server
      session_id = session_id!(conn)
      registry = Module.concat(server, Registry)

      monitor = Process.monitor(session)
      Registry.register(registry, {:http_stream, session_id, id}, nil)
      Session.deliver(session, Jason.encode!(body))

      deadline = System.monotonic_time(:millisecond) + opts.request_timeout
      stream_request(conn, opts, id, monitor, deadline, false)
    end

    defp stream_request(conn, opts, id, monitor, deadline, sse?) do
      remaining = max(deadline - System.monotonic_time(:millisecond), 0)

      receive do
        {:mcp_http, binary} ->
          final? = final_response?(binary, id)

          cond do
            final? and not sse? ->
              Process.demonitor(monitor, [:flush])

              conn
              |> put_resp_content_type("application/json")
              |> send_resp(200, binary)

            final? and sse? ->
              Process.demonitor(monitor, [:flush])
              {:ok, conn} = chunk(conn, SSE.encode(binary))
              conn

            not final? and sse? ->
              {:ok, conn} = chunk(conn, SSE.encode(binary))
              stream_request(conn, opts, id, monitor, deadline, true)

            true ->
              # First non-final message — upgrade to SSE.
              conn = open_sse(conn)
              {:ok, conn} = chunk(conn, SSE.encode(binary))
              stream_request(conn, opts, id, monitor, deadline, true)
          end

        {:DOWN, ^monitor, :process, _pid, _reason} ->
          if sse?, do: conn, else: send_resp(conn, 500, "Session terminated")
      after
        min(remaining, if(sse?, do: opts.keepalive, else: opts.sse_commit_after)) ->
          cond do
            remaining <= 0 and sse? ->
              conn

            remaining <= 0 ->
              Process.demonitor(monitor, [:flush])
              send_resp(conn, 504, "Request timed out")

            sse? ->
              {:ok, conn} = chunk(conn, ": keepalive\n\n")
              stream_request(conn, opts, id, monitor, deadline, true)

            true ->
              # No response within the grace window — commit to SSE so the
              # client sees response status promptly (it may be serializing
              # POST initiation on it) and gets keepalives during a long call.
              stream_request(open_sse(conn), opts, id, monitor, deadline, true)
          end
      end
    end

    defp open_sse(conn) do
      conn
      |> put_resp_content_type("text/event-stream")
      |> put_resp_header("cache-control", "no-cache")
      |> send_chunked(200)
    end

    defp final_response?(binary, id) do
      case Jason.decode(binary) do
        {:ok, %{"id" => ^id} = decoded} ->
          Map.has_key?(decoded, "result") or Map.has_key?(decoded, "error")

        _ ->
          false
      end
    end

    # ── GET (general SSE stream) ─────────────────────────────────────────────

    defp handle_get(conn, opts) do
      accepts_sse? =
        conn
        |> get_req_header("accept")
        |> Enum.any?(&(&1 =~ "text/event-stream" or &1 =~ "*/*"))

      with true <- accepts_sse? || {:error, :not_acceptable},
           {:ok, session} <- find_session(conn, opts.server) do
        server = opts.server
        session_id = session_id!(conn)
        registry = Module.concat(server, Registry)

        case Registry.register(registry, {:http_get, session_id}, nil) do
          {:ok, _} ->
            monitor = Process.monitor(session)

            conn =
              conn
              |> put_resp_content_type("text/event-stream")
              |> put_resp_header("cache-control", "no-cache")
              |> send_chunked(200)

            last_event_id = conn |> get_req_header("last-event-id") |> List.first()

            conn =
              Enum.reduce_while(
                EventStore.replay_after(server, session_id, last_event_id),
                conn,
                fn {event_id, binary}, conn ->
                  case chunk(conn, SSE.encode(binary, id: event_id)) do
                    {:ok, conn} -> {:cont, conn}
                    {:error, _} -> {:halt, conn}
                  end
                end
              )

            stream_get(conn, opts, monitor)

          {:error, {:already_registered, _}} ->
            send_resp(conn, 409, "A stream is already open for this session")
        end
      else
        {:error, :not_acceptable} ->
          send_resp(conn, 406, "GET requires Accept: text/event-stream")

        {:error, conn_response} ->
          conn_response
      end
    end

    defp stream_get(conn, opts, monitor) do
      receive do
        {:mcp_http_event, event_id, binary} ->
          case chunk(conn, SSE.encode(binary, id: event_id)) do
            {:ok, conn} -> stream_get(conn, opts, monitor)
            {:error, _closed} -> conn
          end

        :mcp_http_close ->
          conn

        {:DOWN, ^monitor, :process, _pid, _reason} ->
          conn
      after
        opts.keepalive ->
          case chunk(conn, ": keepalive\n\n") do
            {:ok, conn} -> stream_get(conn, opts, monitor)
            {:error, _closed} -> conn
          end
      end
    end

    # ── DELETE ───────────────────────────────────────────────────────────────

    defp handle_delete(conn, opts) do
      with {:ok, session} <- find_session(conn, opts.server) do
        GenServer.stop(session, :normal)
        send_resp(conn, 200, "")
      else
        {:error, conn_response} -> conn_response
      end
    end

    # ── helpers ──────────────────────────────────────────────────────────────

    defp find_session(conn, server) do
      case get_req_header(conn, "mcp-session-id") do
        [session_id | _] ->
          case Registry.lookup(Module.concat(server, Registry), {:session, session_id}) do
            [{pid, _} | _] -> {:ok, pid}
            [] -> {:error, send_resp(conn, 404, "Unknown or expired session")}
          end

        [] ->
          {:error, send_resp(conn, 400, "Missing Mcp-Session-Id header")}
      end
    end

    defp session_id!(conn), do: conn |> get_req_header("mcp-session-id") |> List.first()

    defp decoded_body(conn) do
      case conn.body_params do
        %Plug.Conn.Unfetched{} ->
          case read_body(conn) do
            {:ok, raw, conn} ->
              case Jason.decode(raw) do
                {:ok, body} -> {:ok, conn, body}
                {:error, _} -> {:error, :bad_body}
              end

            _ ->
              {:error, :bad_body}
          end

        %{} = parsed ->
          {:ok, conn, parsed}
      end
    end

    defp check_protocol_version(conn) do
      case get_req_header(conn, "mcp-protocol-version") do
        [] -> :ok
        [version | _] -> if Version.supported?(version), do: :ok, else: {:error, :bad_version}
      end
    end

    defp origin_allowed?(conn, policy) do
      case get_req_header(conn, "origin") do
        [] ->
          true

        [origin | _] ->
          case policy do
            :any ->
              true

            :localhost ->
              case URI.parse(origin) do
                %URI{host: host} when host in ["localhost", "127.0.0.1", "[::1]", "::1"] -> true
                _ -> false
              end

            allowed when is_list(allowed) ->
              origin in allowed
          end
      end
    end
  end
end
