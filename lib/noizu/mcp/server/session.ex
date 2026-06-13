defmodule Noizu.MCP.Server.Session do
  @moduledoc """
  One MCP session: a GenServer owning the protocol state (`Noizu.MCP.Peer`)
  for a single connected client.

  Handler code never runs in this process — every feature request is executed
  in a supervised `Task` so ping, cancellation, and progress stay responsive
  while tools run. Cancellation kills the task; crashes are converted to
  sanitized protocol/tool errors while full details go to `Logger` and
  telemetry.
  """

  use GenServer, restart: :temporary
  require Logger

  alias Noizu.MCP.{Ctx, Error, JsonRpc, Peer}
  alias Noizu.MCP.Server.Features

  @log_severity %{
    debug: 0,
    info: 1,
    notice: 2,
    warning: 3,
    error: 4,
    critical: 5,
    alert: 6,
    emergency: 7
  }
  @log_levels Map.keys(@log_severity)

  # ── API ───────────────────────────────────────────────────────────────────

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @doc "Deliver an inbound wire binary (one JSON-RPC message) to the session."
  @spec deliver(pid(), binary()) :: :ok
  def deliver(session, binary), do: GenServer.cast(session, {:deliver, binary})

  @doc false
  def notify_progress(session, token, request_id, progress, opts) do
    GenServer.cast(session, {:notify_progress, token, request_id, progress, opts})
  end

  @doc false
  def notify_log(session, level, data, logger, request_id) do
    GenServer.cast(session, {:notify_log, level, data, logger, request_id})
  end

  @doc false
  def notify_changed(session, kind) when kind in [:tools, :resources, :prompts] do
    GenServer.cast(session, {:notify_changed, kind})
  end

  @doc false
  def notify_resource_updated(session, uri) do
    GenServer.cast(session, {:notify_resource_updated, uri})
  end

  @doc false
  def put_assign(session, key, value), do: GenServer.call(session, {:put_assign, key, value})

  @doc false
  # Server→client request (sampling/elicitation/roots), called from a handler
  # task via Noizu.MCP.Ctx. Blocks the calling task only; the session replies
  # when the client answers or the timeout fires.
  def server_request(session, method, params, opts) do
    GenServer.call(session, {:server_request, method, params, opts}, :infinity)
  end

  # ── GenServer ─────────────────────────────────────────────────────────────

  @impl true
  def init(opts) do
    server = Keyword.fetch!(opts, :server)
    sink = Keyword.fetch!(opts, :sink)
    session_id = Keyword.get(opts, :session_id) || generate_session_id()

    peer =
      Peer.new(
        role: :server,
        info: server.server_info(),
        capabilities: server.__mcp__(:capabilities),
        instructions: server.__mcp__(:instructions)
      )

    Registry.register(Module.concat(server, Registry), {:session, session_id}, %{})

    {:ok,
     rearm_idle_timer(%{
       server: server,
       sink: sink,
       transport: Keyword.get(opts, :transport, :test),
       session_id: session_id,
       idle_timeout: Keyword.get(opts, :idle_timeout, :infinity),
       idle_timer: nil,
       peer: peer,
       tasks: %{},
       refs: %{},
       assigns: Map.new(Keyword.get(opts, :assigns, %{})),
       subscriptions: MapSet.new(),
       out_timers: %{},
       log_level: nil,
       halt: nil
     })}
  end

  @impl true
  def handle_cast({:deliver, binary}, state) do
    state = rearm_idle_timer(state)

    case JsonRpc.decode(binary) do
      {:ok, message} ->
        {peer, effects} = Peer.ingest(state.peer, message)

        case run_effects(%{state | peer: peer}, effects) do
          %{halt: reason} = state when not is_nil(reason) -> {:stop, {:shutdown, reason}, state}
          state -> {:noreply, state}
        end

      {:error, error_response} ->
        send_out(state, error_response)
        {:noreply, state}
    end
  end

  def handle_cast({:notify_progress, token, request_id, progress, opts}, state) do
    params =
      %{"progressToken" => token, "progress" => progress}
      |> put_unless_nil("total", opts[:total])
      |> put_unless_nil("message", opts[:message])

    send_out(state, Peer.notification("notifications/progress", params), %{
      related_request_id: request_id
    })

    {:noreply, state}
  end

  def handle_cast({:notify_log, level, data, logger, request_id}, state) do
    if loggable?(state.log_level, level) do
      params =
        %{"level" => to_string(level), "data" => data}
        |> put_unless_nil("logger", logger)

      send_out(state, Peer.notification("notifications/message", params), %{
        related_request_id: request_id
      })
    end

    {:noreply, state}
  end

  def handle_cast({:notify_resource_updated, uri}, state) do
    if state.peer.phase == :ready and MapSet.member?(state.subscriptions, uri) do
      send_out(state, Peer.notification("notifications/resources/updated", %{"uri" => uri}))
    end

    {:noreply, state}
  end

  def handle_cast({:notify_changed, kind}, state) do
    if state.peer.phase == :ready do
      method =
        case kind do
          :tools -> "notifications/tools/list_changed"
          :resources -> "notifications/resources/list_changed"
          :prompts -> "notifications/prompts/list_changed"
        end

      send_out(state, Peer.notification(method, nil))
    end

    {:noreply, state}
  end

  @impl true
  def handle_call({:put_assign, key, value}, _from, state) do
    {:reply, :ok, %{state | assigns: Map.put(state.assigns, key, value)}}
  end

  def handle_call({:server_request, method, params, opts}, from, state) do
    if state.peer.phase == :ready do
      {peer, id, request} =
        Peer.request(state.peer, method, params, tag: {:server_req, from})

      timeout = Keyword.get(opts, :timeout, 60_000)
      timer = Process.send_after(self(), {:server_request_timeout, id}, timeout)

      state = %{state | peer: peer, out_timers: Map.put(state.out_timers, id, timer)}

      send_out(state, request, %{related_request_id: Keyword.get(opts, :related_request_id)})
      {:noreply, state}
    else
      {:reply, {:error, :not_ready}, state}
    end
  end

  @impl true
  def handle_info({ref, {:mcp_task, id, result}}, state) when is_reference(ref) do
    Process.demonitor(ref, [:flush])

    case Map.pop(state.refs, ref) do
      {nil, _} ->
        {:noreply, state}

      {^id, refs} ->
        state = %{state | refs: refs, tasks: Map.delete(state.tasks, id)}
        {:noreply, reply_result(state, id, result)}
    end
  end

  def handle_info(:idle_timeout, state) do
    Logger.info("MCP session #{state.session_id} idle timeout, terminating")
    {:stop, {:shutdown, :idle_timeout}, state}
  end

  def handle_info({:server_request_timeout, id}, state) do
    {timer, out_timers} = Map.pop(state.out_timers, id)

    if timer do
      {peer, notification, tag} = Peer.cancel_out(state.peer, id, "timeout")
      if notification, do: send_out(state, notification)

      case tag do
        {:server_req, from} -> GenServer.reply(from, {:error, :timeout})
        _ -> :ok
      end

      {:noreply, %{state | peer: peer, out_timers: out_timers}}
    else
      {:noreply, state}
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, reason}, state) do
    case Map.pop(state.refs, ref) do
      {nil, _} ->
        {:noreply, state}

      {id, refs} ->
        {entry, tasks} = Map.pop(state.tasks, id)
        state = %{state | refs: refs, tasks: tasks}

        Logger.error(
          "MCP handler for #{entry.method} (request #{inspect(id)}) crashed: " <>
            Exception.format_exit(reason)
        )

        :telemetry.execute(
          [:noizu_mcp, :server, :request, :exception],
          %{duration: System.monotonic_time() - entry.started_at},
          %{
            server: state.server,
            method: entry.method,
            session_id: state.session_id,
            reason: reason
          }
        )

        result =
          if entry.method == "tools/call" do
            {:ok,
             Noizu.MCP.Types.ToolResult.to_map(
               Noizu.MCP.Types.ToolResult.error("Tool execution failed")
             )}
          else
            {:error, Error.internal("Request handler failed")}
          end

        {:noreply, reply_result(state, id, result)}
    end
  end

  def handle_info(_other, state), do: {:noreply, state}

  # ── effects ───────────────────────────────────────────────────────────────

  defp run_effects(state, effects) do
    Enum.reduce(effects, state, &run_effect(&2, &1))
  end

  defp run_effect(state, {:send, message}) do
    routing =
      case message do
        %{id: id} when not is_nil(id) -> %{related_request_id: id}
        _ -> %{}
      end

    send_out(state, message, routing)
    state
  end

  defp run_effect(state, {:ready, _remote_info}) do
    user_init(state)
  end

  defp run_effect(state, {:dispatch, method, id, params}) do
    dispatch(state, method, id, params)
  end

  defp run_effect(state, {:resolve, {:server_req, from}, id, outcome}) do
    {timer, out_timers} = Map.pop(state.out_timers, id)
    if timer, do: Process.cancel_timer(timer)
    GenServer.reply(from, outcome)
    %{state | out_timers: out_timers}
  end

  defp run_effect(state, {:cancel_in, id, _reason}) do
    case Map.pop(state.tasks, id) do
      {nil, _} ->
        state

      {entry, tasks} ->
        :atomics.put(entry.flag, 1, 1)
        Process.demonitor(entry.ref, [:flush])
        Process.exit(entry.pid, :kill)
        %{state | tasks: tasks, refs: Map.delete(state.refs, entry.ref)}
    end
  end

  defp run_effect(state, _other), do: state

  # ── dispatch ──────────────────────────────────────────────────────────────

  defp dispatch(state, "logging/setLevel", id, params) do
    level = parse_level((params || %{})["level"])

    case level do
      nil ->
        reply_result(state, id, {:error, Error.invalid_params("Invalid log level")})

      level ->
        reply_result(%{state | log_level: level}, id, {:ok, %{}})
    end
  end

  defp dispatch(state, "tools/list", id, params) do
    dispatch_feature(state, "tools/list", id, params, {:handle_list_tools, 2},
      run: &Features.Tools.list/3
    )
  end

  defp dispatch(state, "tools/call", id, params) do
    dispatch_feature(state, "tools/call", id, params, {:handle_call_tool, 3},
      run: &Features.Tools.call/3
    )
  end

  defp dispatch(state, "resources/list", id, params) do
    dispatch_feature(state, "resources/list", id, params, {:handle_list_resources, 2},
      run: &Features.Resources.list/3
    )
  end

  defp dispatch(state, "resources/templates/list", id, params) do
    cond do
      function_exported?(state.server, :handle_list_resource_templates, 2) ->
        spawn_task(state, "resources/templates/list", id, params, fn server, params, ctx ->
          Features.Resources.list_templates(server, params, ctx)
        end)

      # Resources capability without templates: an empty page, not an error.
      function_exported?(state.server, :handle_list_resources, 2) ->
        reply_result(state, id, {:ok, %{"resourceTemplates" => []}})

      true ->
        reply_result(state, id, {:error, Error.method_not_found("resources/templates/list")})
    end
  end

  defp dispatch(state, "resources/read", id, params) do
    dispatch_feature(state, "resources/read", id, params, {:handle_read_resource, 2},
      run: &Features.Resources.read/3
    )
  end

  defp dispatch(state, "resources/subscribe", id, params) do
    uri = (params || %{})["uri"]

    cond do
      not function_exported?(state.server, :handle_subscribe, 2) ->
        reply_result(state, id, {:error, Error.method_not_found("resources/subscribe")})

      not is_binary(uri) ->
        reply_result(
          state,
          id,
          {:error, Error.invalid_params("resources/subscribe requires a uri")}
        )

      true ->
        # Runs in the session process: subscribe handlers must be fast.
        case state.server.handle_subscribe(uri, build_ctx(state, id, nil, nil)) do
          :ok ->
            state = %{state | subscriptions: MapSet.put(state.subscriptions, uri)}
            reply_result(state, id, {:ok, %{}})

          {:error, %Error{} = error} ->
            reply_result(state, id, {:error, error})
        end
    end
  end

  defp dispatch(state, "resources/unsubscribe", id, params) do
    uri = (params || %{})["uri"]

    cond do
      not function_exported?(state.server, :handle_subscribe, 2) ->
        reply_result(state, id, {:error, Error.method_not_found("resources/unsubscribe")})

      not is_binary(uri) ->
        reply_result(
          state,
          id,
          {:error, Error.invalid_params("resources/unsubscribe requires a uri")}
        )

      true ->
        if function_exported?(state.server, :handle_unsubscribe, 2) do
          state.server.handle_unsubscribe(uri, build_ctx(state, id, nil, nil))
        end

        state = %{state | subscriptions: MapSet.delete(state.subscriptions, uri)}
        reply_result(state, id, {:ok, %{}})
    end
  end

  defp dispatch(state, "prompts/list", id, params) do
    dispatch_feature(state, "prompts/list", id, params, {:handle_list_prompts, 2},
      run: &Features.Prompts.list/3
    )
  end

  defp dispatch(state, "prompts/get", id, params) do
    dispatch_feature(state, "prompts/get", id, params, {:handle_get_prompt, 3},
      run: &Features.Prompts.get/3
    )
  end

  defp dispatch(state, "completion/complete", id, params) do
    dispatch_feature(state, "completion/complete", id, params, {:handle_complete, 3},
      run: &Features.Completion.complete/3
    )
  end

  defp dispatch(state, method, id, _params) do
    reply_result(state, id, {:error, Error.method_not_found(method)})
  end

  defp dispatch_feature(state, method, id, params, {callback, arity}, run: run) do
    if function_exported?(state.server, callback, arity) do
      spawn_task(state, method, id, params, fn server, params, ctx ->
        run.(server, params, ctx)
      end)
    else
      reply_result(state, id, {:error, Error.method_not_found(method)})
    end
  end

  defp spawn_task(state, method, id, params, fun) do
    flag = :atomics.new(1, [])
    ctx = build_ctx(state, id, progress_token(params), flag)
    server = state.server
    session_id = state.session_id
    started_at = System.monotonic_time()

    :telemetry.execute(
      [:noizu_mcp, :server, :request, :start],
      %{system_time: System.system_time()},
      %{server: server, method: method, session_id: session_id}
    )

    task =
      Task.Supervisor.async_nolink(Module.concat(server, TaskSupervisor), fn ->
        result = fun.(server, params, ctx)

        :telemetry.execute(
          [:noizu_mcp, :server, :request, :stop],
          %{duration: System.monotonic_time() - started_at},
          %{server: server, method: method, session_id: session_id}
        )

        {:mcp_task, id, result}
      end)

    entry = %{ref: task.ref, pid: task.pid, flag: flag, method: method, started_at: started_at}

    %{
      state
      | tasks: Map.put(state.tasks, id, entry),
        refs: Map.put(state.refs, task.ref, id)
    }
  end

  defp reply_result(state, id, result) do
    {peer, reply} =
      case result do
        {:ok, result_map} when is_map(result_map) ->
          Peer.respond(state.peer, id, result_map)

        {:error, %Error{} = error} ->
          Peer.respond_error(state.peer, id, error)
      end

    case reply do
      {:ok, message} -> send_out(state, message, %{related_request_id: id})
      :drop -> :ok
    end

    %{state | peer: peer}
  end

  defp user_init(state) do
    if function_exported?(state.server, :init, 2) do
      ctx = build_ctx(state, nil, nil, nil)

      init_params = %{
        client_info: state.peer.remote_info,
        client_capabilities: state.peer.remote_capabilities,
        protocol_version: state.peer.protocol_version
      }

      case state.server.init(ctx, init_params) do
        {:ok, %Ctx{} = ctx} ->
          %{state | assigns: ctx.assigns}

        {:error, reason} ->
          Logger.error("MCP server #{inspect(state.server)} init/2 failed: #{inspect(reason)}")
          %{state | halt: {:init_failed, reason}}
      end
    else
      state
    end
  end

  defp build_ctx(state, request_id, progress_token, flag) do
    %Ctx{
      server: state.server,
      session: self(),
      session_id: state.session_id,
      request_id: request_id,
      progress_token: progress_token,
      protocol_version: state.peer.protocol_version,
      client_info: state.peer.remote_info,
      client_capabilities: state.peer.remote_capabilities || %{},
      transport: state.transport,
      cancel_flag: flag,
      assigns: state.assigns
    }
  end

  defp progress_token(params) do
    case params do
      %{"_meta" => %{"progressToken" => token}} -> token
      _ -> nil
    end
  end

  defp send_out(state, message, routing \\ %{}) do
    {sink_module, sink} = state.sink
    sink_module.send_message(sink, JsonRpc.encode!(message), routing)
  end

  defp loggable?(nil, _level), do: true

  defp loggable?(min, level) do
    Map.fetch!(@log_severity, level) >= Map.fetch!(@log_severity, min)
  end

  defp parse_level(level) when is_binary(level) do
    found = Enum.find(@log_levels, fn atom -> Atom.to_string(atom) == level end)
    found
  end

  defp parse_level(_), do: nil

  defp rearm_idle_timer(%{idle_timeout: :infinity} = state), do: state

  defp rearm_idle_timer(state) do
    if state.idle_timer, do: Process.cancel_timer(state.idle_timer)
    %{state | idle_timer: Process.send_after(self(), :idle_timeout, state.idle_timeout)}
  end

  @impl true
  def terminate(_reason, state) do
    {sink_module, sink} = state.sink
    sink_module.close_session(sink)
    :ok
  catch
    _, _ -> :ok
  end

  defp generate_session_id do
    Base.url_encode64(:crypto.strong_rand_bytes(24), padding: false)
  end

  defp put_unless_nil(map, _key, nil), do: map
  defp put_unless_nil(map, key, value), do: Map.put(map, key, value)
end
