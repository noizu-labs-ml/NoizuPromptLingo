if Code.ensure_loaded?(Req) do
  defmodule Noizu.MCP.Transport.StreamableHTTP.Client do
    @moduledoc """
    Streamable HTTP client transport (Req-based).

        {Noizu.MCP.Client,
         transport: {Noizu.MCP.Transport.StreamableHTTP.Client, url: "https://example.com/mcp"}}

    Every outbound message is an HTTP POST; JSON responses and SSE streams are
    both handled, the `Mcp-Session-Id` is captured from the initialize
    response and echoed on subsequent requests along with
    `MCP-Protocol-Version`, and a long-lived GET stream (with `Last-Event-ID`
    reconnect/resume) carries unsolicited server→client traffic.

    Options: `:url` (required), `:headers` (extra request headers),
    `:req_options` (merged into every Req call).
    """

    use GenServer
    require Logger

    alias Noizu.MCP.Transport.SSE

    @behaviour Noizu.MCP.Transport.Client

    @impl Noizu.MCP.Transport.Client
    def start_link(owner, opts) do
      GenServer.start_link(__MODULE__, {owner, opts})
    end

    @impl Noizu.MCP.Transport.Client
    def send_message(transport, iodata, _routing) do
      GenServer.call(transport, {:send, IO.iodata_to_binary(iodata)})
    end

    @impl Noizu.MCP.Transport.Client
    def close(transport), do: GenServer.stop(transport, :normal)

    @impl GenServer
    def init({owner, opts}) do
      {:ok, task_sup} = Task.Supervisor.start_link()
      url = Keyword.fetch!(opts, :url)

      auth =
        case Keyword.get(opts, :auth) do
          nil ->
            nil

          {module, auth_opts} ->
            {:ok, auth_state} = module.init(Keyword.put(auth_opts, :mcp_url, url))
            {module, auth_state}
        end

      state = %{
        owner: owner,
        url: url,
        auth: auth,
        headers: Keyword.get(opts, :headers, []),
        req_options: Keyword.get(opts, :req_options, []),
        session_id: nil,
        protocol_version: nil,
        task_sup: task_sup,
        get_stream: nil,
        last_event_id: nil,
        send_queue: :queue.new(),
        sending: false
      }

      send(owner, {:mcp_transport, self(), {:up, %{}}})
      {:ok, state}
    end

    @impl GenServer
    def handle_call({:send, binary}, _from, state) do
      # POST initiation is serialized: the next POST starts only after the
      # previous one's response status arrived, so message order is preserved
      # (e.g. notifications/initialized lands before the first request).
      # Response *bodies* still stream concurrently in their own tasks.
      state = %{state | send_queue: :queue.in(binary, state.send_queue)}
      {:reply, :ok, maybe_send_next(state)}
    end

    def handle_call(:auth_headers, _from, %{auth: nil} = state), do: {:reply, [], state}

    def handle_call(:auth_headers, _from, %{auth: {module, auth_state}} = state) do
      {headers, auth_state} = module.headers(auth_state)
      {:reply, headers, %{state | auth: {module, auth_state}}}
    end

    def handle_call({:auth_unauthorized, _challenge}, _from, %{auth: nil} = state),
      do: {:reply, {:error, :no_auth_strategy}, state}

    def handle_call(
          {:auth_unauthorized, challenge},
          _from,
          %{auth: {module, auth_state}} = state
        ) do
      case module.handle_unauthorized(challenge, %{url: state.url}, auth_state) do
        {:retry, auth_state} ->
          {:reply, :retry, %{state | auth: {module, auth_state}}}

        {:error, reason, auth_state} ->
          {:reply, {:error, reason}, %{state | auth: {module, auth_state}}}
      end
    end

    defp maybe_send_next(%{sending: true} = state), do: state

    defp maybe_send_next(state) do
      case :queue.out(state.send_queue) do
        {:empty, _} ->
          state

        {{:value, binary}, queue} ->
          snapshot = post_context(state)

          Task.Supervisor.start_child(state.task_sup, fn ->
            do_post(binary, snapshot)
          end)

          %{state | send_queue: queue, sending: true}
      end
    end

    @impl GenServer
    def handle_cast({:session_id, session_id}, state) do
      {:noreply, %{state | session_id: state.session_id || session_id}}
    end

    def handle_cast({:protocol_version, version}, state) do
      state = %{state | protocol_version: version}
      {:noreply, ensure_get_stream(state)}
    end

    def handle_cast({:last_event_id, id}, state) do
      {:noreply, %{state | last_event_id: id}}
    end

    def handle_cast({:session_expired, _}, state) do
      send(state.owner, {:mcp_transport, self(), {:down, :session_expired}})
      {:stop, :normal, state}
    end

    def handle_cast(:post_initiated, state) do
      {:noreply, maybe_send_next(%{state | sending: false})}
    end

    @impl GenServer
    def handle_info({:DOWN, _ref, :process, pid, _reason}, %{get_stream: pid} = state) do
      # The GET stream loop supervises its own reconnects; if the whole task
      # dies, restart it.
      {:noreply, ensure_get_stream(%{state | get_stream: nil})}
    end

    def handle_info(_other, state), do: {:noreply, state}

    defp post_context(state) do
      %{
        transport: self(),
        owner: state.owner,
        url: state.url,
        headers: state.headers,
        req_options: state.req_options,
        session_id: state.session_id,
        protocol_version: state.protocol_version,
        auth?: state.auth != nil
      }
    end

    defp auth_headers(%{auth?: false}), do: []
    defp auth_headers(ctx), do: GenServer.call(ctx.transport, :auth_headers, 60_000)

    defp ensure_get_stream(%{get_stream: pid} = state) when is_pid(pid), do: state

    defp ensure_get_stream(state) do
      snapshot = post_context(state)
      last_event_id = state.last_event_id

      {:ok, pid} =
        Task.Supervisor.start_child(state.task_sup, fn ->
          get_stream_loop(snapshot, last_event_id, 1_000)
        end)

      Process.monitor(pid)
      %{state | get_stream: pid}
    end

    # ── POST ────────────────────────────────────────────────────────────────

    defp do_post(binary, ctx, attempts \\ 0) do
      headers =
        [{"content-type", "application/json"}, {"accept", "application/json, text/event-stream"}]
        |> add_session_headers(ctx)
        |> Kernel.++(auth_headers(ctx))
        |> Kernel.++(ctx.headers)

      options =
        Keyword.merge(
          [url: ctx.url, headers: headers, body: binary, into: :self, receive_timeout: :infinity],
          ctx.req_options
        )

      result = Req.post(options)
      # Status/headers are in — the next queued POST may start while we keep
      # streaming this response's body.
      GenServer.cast(ctx.transport, :post_initiated)

      case result do
        {:ok, resp} ->
          case handle_post_response(resp, ctx) do
            {:unauthorized, challenge} when attempts < 2 ->
              case GenServer.call(ctx.transport, {:auth_unauthorized, challenge}, 300_000) do
                :retry ->
                  do_post(binary, ctx, attempts + 1)

                {:error, reason} ->
                  Logger.warning("MCP HTTP authorization failed: #{inspect(reason)}")
              end

            {:unauthorized, _challenge} ->
              Logger.warning("MCP HTTP request unauthorized after retry")

            _ ->
              :ok
          end

        {:error, error} ->
          Logger.warning("MCP HTTP POST failed: #{inspect(error)}")
      end
    end

    defp handle_post_response(%{status: 202} = resp, _ctx) do
      drain(resp)
      :ok
    end

    defp handle_post_response(%{status: 200} = resp, ctx) do
      capture_session_id(resp, ctx)

      case content_type(resp) do
        "text/event-stream" <> _ ->
          stream_sse(resp, ctx, "")

        _json ->
          case collect_body(resp, []) do
            {:ok, body} -> deliver(ctx, body)
            {:error, reason} -> Logger.warning("MCP HTTP response error: #{inspect(reason)}")
          end
      end
    end

    defp handle_post_response(%{status: 404} = resp, ctx) do
      drain(resp)

      if ctx.session_id do
        GenServer.cast(ctx.transport, {:session_expired, ctx.session_id})
      end
    end

    defp handle_post_response(%{status: status} = resp, _ctx) when status in [401, 403] do
      drain(resp)

      challenge =
        resp
        |> Req.Response.get_header("www-authenticate")
        |> List.first()
        |> Noizu.MCP.Auth.WWWAuthenticate.parse()

      step_up? = challenge && challenge.params["error"] == "insufficient_scope"

      if status == 401 or step_up? do
        {:unauthorized, challenge}
      else
        Logger.warning("MCP HTTP POST got 403")
      end
    end

    defp handle_post_response(%{status: status} = resp, _ctx) do
      drain(resp)
      Logger.warning("MCP HTTP POST got unexpected status #{status}")
    end

    # ── SSE streaming (shared by POST upgrades and the GET stream) ──────────

    defp stream_sse(resp, ctx, buffer) do
      receive do
        message ->
          case Req.parse_message(resp, message) do
            {:ok, parts} ->
              buffer =
                Enum.reduce(parts, buffer, fn
                  {:data, chunk}, buffer ->
                    {events, buffer} = SSE.parse(buffer, chunk)
                    Enum.each(events, &handle_sse_event(&1, ctx))
                    buffer

                  :done, _buffer ->
                    throw(:done)

                  _other, buffer ->
                    buffer
                end)

              stream_sse(resp, ctx, buffer)

            {:error, reason} ->
              Logger.warning("MCP HTTP SSE stream error: #{inspect(reason)}")

            :unknown ->
              stream_sse(resp, ctx, buffer)
          end
      end
    catch
      :done -> :ok
    end

    defp handle_sse_event(%SSE.Event{} = event, ctx) do
      if event.id, do: GenServer.cast(ctx.transport, {:last_event_id, event.id})
      if event.data != "", do: deliver(ctx, event.data)
    end

    # ── GET stream with reconnect/resume ────────────────────────────────────

    defp get_stream_loop(ctx, last_event_id, backoff) do
      headers =
        [{"accept", "text/event-stream"}]
        |> add_session_headers(ctx)
        |> then(fn headers ->
          if last_event_id, do: [{"last-event-id", last_event_id} | headers], else: headers
        end)
        |> Kernel.++(auth_headers(ctx))
        |> Kernel.++(ctx.headers)

      options =
        Keyword.merge(
          [url: ctx.url, headers: headers, into: :self, receive_timeout: :infinity],
          ctx.req_options
        )

      case Req.get(options) do
        {:ok, %{status: 200} = resp} ->
          stream_sse(resp, ctx, "")
          get_stream_loop(ctx, nil, 1_000)

        {:ok, %{status: 405} = resp} ->
          # Server doesn't offer a general stream — allowed by spec.
          drain(resp)
          :ok

        {:ok, %{status: 404} = resp} ->
          drain(resp)
          GenServer.cast(ctx.transport, {:session_expired, ctx.session_id})

        {:ok, %{status: status} = resp} ->
          drain(resp)
          Logger.warning("MCP HTTP GET stream status #{status}, retrying")
          Process.sleep(backoff)
          get_stream_loop(ctx, last_event_id, min(backoff * 2, 30_000))

        {:error, error} ->
          Logger.debug("MCP HTTP GET stream error: #{inspect(error)}, retrying")
          Process.sleep(backoff)
          get_stream_loop(ctx, last_event_id, min(backoff * 2, 30_000))
      end
    end

    # ── helpers ─────────────────────────────────────────────────────────────

    defp deliver(ctx, binary) do
      sniff_metadata(ctx, binary)
      send(ctx.owner, {:mcp_transport, ctx.transport, {:message, binary, %{}}})
    end

    # The initialize response carries the negotiated protocol version; capture
    # it so subsequent requests send MCP-Protocol-Version, and open the
    # general GET stream once the handshake is done.
    defp sniff_metadata(ctx, binary) do
      with nil <- ctx.protocol_version,
           {:ok, %{"result" => %{"protocolVersion" => version}}} <- Jason.decode(binary) do
        GenServer.cast(ctx.transport, {:protocol_version, version})
      else
        _ -> :ok
      end
    end

    defp capture_session_id(resp, ctx) do
      case Req.Response.get_header(resp, "mcp-session-id") do
        [session_id | _] -> GenServer.cast(ctx.transport, {:session_id, session_id})
        [] -> :ok
      end
    end

    defp add_session_headers(headers, ctx) do
      headers
      |> then(fn h ->
        if ctx.session_id, do: [{"mcp-session-id", ctx.session_id} | h], else: h
      end)
      |> then(fn h ->
        if ctx.protocol_version,
          do: [{"mcp-protocol-version", ctx.protocol_version} | h],
          else: h
      end)
    end

    defp content_type(resp) do
      resp |> Req.Response.get_header("content-type") |> List.first() || ""
    end

    defp collect_body(resp, acc) do
      receive do
        message ->
          case Req.parse_message(resp, message) do
            {:ok, parts} ->
              case Enum.reduce(parts, {acc, false}, fn
                     {:data, chunk}, {acc, done?} -> {[chunk | acc], done?}
                     :done, {acc, _} -> {acc, true}
                     _other, state -> state
                   end) do
                {acc, true} -> {:ok, acc |> Enum.reverse() |> IO.iodata_to_binary()}
                {acc, false} -> collect_body(resp, acc)
              end

            {:error, reason} ->
              {:error, reason}

            :unknown ->
              collect_body(resp, acc)
          end
      after
        30_000 -> {:error, :body_timeout}
      end
    end

    defp drain(resp) do
      case collect_body(resp, []) do
        {:ok, _} -> :ok
        {:error, _} -> :ok
      end
    end
  end
end
