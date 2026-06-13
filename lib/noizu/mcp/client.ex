defmodule Noizu.MCP.Client do
  @moduledoc """
  MCP client: connect to an MCP server over a transport and call its tools,
  resources, and prompts.

      children = [
        {Noizu.MCP.Client,
         name: MyApp.FS,
         transport:
           {:stdio,
            command: "npx",
            args: ["-y", "@modelcontextprotocol/server-filesystem", "/tmp"]},
         client_info: %{name: "my_app", version: "1.0.0"},
         handler: MyApp.MCPHandler,
         roots: [Noizu.MCP.Types.Root.new("file:///workspace", name: "Workspace")]}
      ]

      {:ok, tools} = Noizu.MCP.Client.list_tools(MyApp.FS)
      {:ok, result} = Noizu.MCP.Client.call_tool(MyApp.FS, "read_file", %{"path" => "/tmp/a"})

  ## Options

    * `:transport` (required) —
      `{:stdio, command: "...", args: [...], env: %{}, cd: "..."}` to spawn a
      subprocess, `{:test, server: MyServer}` for an in-memory connection to a
      `Noizu.MCP.Server` in the same VM, or `{module, opts}` for a custom
      `Noizu.MCP.Transport.Client` implementation
    * `:name` — optional registered name
    * `:client_info` — `%{name: _, version: _}` advertised to the server
    * `:handler` — `module` or `{module, arg}` implementing
      `Noizu.MCP.Client.Handler`; implemented callbacks advertise the
      `sampling`/`elicitation` capabilities
    * `:roots` — initial `Noizu.MCP.Types.Root` list (advertises the `roots`
      capability); update later with `set_roots/2`
    * `:on_notification` — pid mirrored every server notification as
      `{:mcp_notification, method, params}`
    * `:request_timeout` — default per-request timeout in ms (30_000)

  Calls made before the handshake completes are queued and dispatched once the
  connection is ready. Per-call `:timeout` overrides auto-cancel the request
  (`notifications/cancelled`) on expiry. Pass `progress: fun/1` to receive
  progress notifications for a call.
  """

  use GenServer
  require Logger

  alias Noizu.MCP.{Error, JsonRpc, Peer}
  alias Noizu.MCP.Types.{Implementation, Prompt, PromptMessage, Resource, ResourceContents}
  alias Noizu.MCP.Types.{ResourceTemplate, Root, Tool, ToolResult}

  @default_request_timeout 30_000

  # ── lifecycle ─────────────────────────────────────────────────────────────

  def start_link(opts) do
    case Keyword.fetch(opts, :name) do
      {:ok, name} -> GenServer.start_link(__MODULE__, opts, name: name)
      :error -> GenServer.start_link(__MODULE__, opts)
    end
  end

  def child_spec(opts) do
    %{id: Keyword.get(opts, :name, __MODULE__), start: {__MODULE__, :start_link, [opts]}}
  end

  @doc "Block until the initialize handshake completes."
  @spec await_ready(GenServer.server(), timeout()) :: :ok | {:error, term()}
  def await_ready(client, timeout \\ 10_000) do
    GenServer.call(client, :await_ready, timeout)
  end

  @doc "Close the connection."
  @spec close(GenServer.server()) :: :ok
  def close(client), do: GenServer.stop(client, :normal)

  # ── introspection ─────────────────────────────────────────────────────────

  @doc "The server's `Implementation` info (after ready)."
  @spec server_info(GenServer.server()) :: Implementation.t() | nil
  def server_info(client), do: GenServer.call(client, :server_info)

  @doc "The server's negotiated capabilities (wire-format map)."
  @spec server_capabilities(GenServer.server()) :: map() | nil
  def server_capabilities(client), do: GenServer.call(client, :server_capabilities)

  @doc "The server's `instructions` string, if any."
  @spec instructions(GenServer.server()) :: String.t() | nil
  def instructions(client), do: GenServer.call(client, :instructions)

  # ── generic request ───────────────────────────────────────────────────────

  @doc """
  Issue a raw MCP request. Returns `{:ok, result_map} | {:error, reason}`
  where reason is a `Noizu.MCP.Error`, `:timeout`, or `:closed`.
  """
  @spec request(GenServer.server(), String.t(), map() | nil, keyword()) ::
          {:ok, map()} | {:error, term()}
  def request(client, method, params \\ nil, opts \\ []) do
    GenServer.call(client, {:request, method, params, opts}, :infinity)
  end

  @doc "Send a one-way notification to the server."
  @spec notify(GenServer.server(), String.t(), map() | nil) :: :ok
  def notify(client, method, params \\ nil) do
    GenServer.cast(client, {:notify, method, params})
  end

  @doc "Issue a request without blocking; returns a reference for `await/3` / `cancel/3`."
  @spec async(GenServer.server(), String.t(), map() | nil, keyword()) :: {:ok, term()}
  def async(client, method, params \\ nil, opts \\ []) do
    GenServer.call(client, {:async, method, params, opts}, :infinity)
  end

  @doc "Await an `async/4` request."
  @spec await(GenServer.server(), term(), timeout()) :: {:ok, map()} | {:error, term()}
  def await(client, ref, timeout \\ :infinity) do
    GenServer.call(client, {:await, ref}, timeout)
  end

  @doc "Cancel an `async/4` request (`notifications/cancelled`)."
  @spec cancel(GenServer.server(), term(), String.t() | nil) :: :ok
  def cancel(client, ref, reason \\ nil) do
    GenServer.cast(client, {:cancel, ref, reason})
  end

  # ── features ──────────────────────────────────────────────────────────────

  @doc "Ping the server."
  @spec ping(GenServer.server()) :: :ok | {:error, term()}
  def ping(client) do
    case request(client, "ping") do
      {:ok, _} -> :ok
      error -> error
    end
  end

  @doc "Call a tool. Returns `{:ok, %ToolResult{}}`. Args use string keys."
  @spec call_tool(GenServer.server(), String.t(), map(), keyword()) ::
          {:ok, ToolResult.t()} | {:error, term()}
  def call_tool(client, name, args \\ %{}, opts \\ []) do
    params = %{"name" => name, "arguments" => args}

    case request(client, "tools/call", params, opts) do
      {:ok, result} -> {:ok, ToolResult.from_map(result)}
      error -> error
    end
  end

  @doc "List all tools (auto-paginates; pass `page: cursor` for manual paging)."
  @spec list_tools(GenServer.server(), keyword()) :: {:ok, [Tool.t()]} | {:error, term()}
  def list_tools(client, opts \\ []),
    do: paged(client, "tools/list", "tools", &Tool.from_map/1, opts)

  @doc "List all resources (auto-paginates)."
  @spec list_resources(GenServer.server(), keyword()) ::
          {:ok, [Resource.t()]} | {:error, term()}
  def list_resources(client, opts \\ []),
    do: paged(client, "resources/list", "resources", &Resource.from_map/1, opts)

  @doc "List all resource templates (auto-paginates)."
  @spec list_resource_templates(GenServer.server(), keyword()) ::
          {:ok, [ResourceTemplate.t()]} | {:error, term()}
  def list_resource_templates(client, opts \\ []),
    do:
      paged(
        client,
        "resources/templates/list",
        "resourceTemplates",
        &ResourceTemplate.from_map/1,
        opts
      )

  @doc "Read a resource. Returns `{:ok, [%ResourceContents{}]}`."
  @spec read_resource(GenServer.server(), String.t(), keyword()) ::
          {:ok, [ResourceContents.t()]} | {:error, term()}
  def read_resource(client, uri, opts \\ []) do
    case request(client, "resources/read", %{"uri" => uri}, opts) do
      {:ok, result} ->
        {:ok, Enum.map(result["contents"] || [], &ResourceContents.from_map/1)}

      error ->
        error
    end
  end

  @doc "Subscribe to update notifications for a resource URI."
  @spec subscribe_resource(GenServer.server(), String.t()) :: :ok | {:error, term()}
  def subscribe_resource(client, uri) do
    case request(client, "resources/subscribe", %{"uri" => uri}) do
      {:ok, _} -> :ok
      error -> error
    end
  end

  @doc "Unsubscribe from update notifications for a resource URI."
  @spec unsubscribe_resource(GenServer.server(), String.t()) :: :ok | {:error, term()}
  def unsubscribe_resource(client, uri) do
    case request(client, "resources/unsubscribe", %{"uri" => uri}) do
      {:ok, _} -> :ok
      error -> error
    end
  end

  @doc "List all prompts (auto-paginates)."
  @spec list_prompts(GenServer.server(), keyword()) :: {:ok, [Prompt.t()]} | {:error, term()}
  def list_prompts(client, opts \\ []),
    do: paged(client, "prompts/list", "prompts", &Prompt.from_map/1, opts)

  @doc "Get a prompt. Returns `{:ok, %{description: _, messages: [%PromptMessage{}]}}`."
  @spec get_prompt(GenServer.server(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, term()}
  def get_prompt(client, name, args \\ %{}, opts \\ []) do
    case request(client, "prompts/get", %{"name" => name, "arguments" => args}, opts) do
      {:ok, result} ->
        {:ok,
         %{
           description: result["description"],
           messages: Enum.map(result["messages"] || [], &PromptMessage.from_map/1)
         }}

      error ->
        error
    end
  end

  @doc """
  Request completion values. `ref` is `{:prompt, name}` or
  `{:resource_template, uri_template}`.
  """
  @spec complete(GenServer.server(), tuple(), String.t(), String.t()) ::
          {:ok, map()} | {:error, term()}
  def complete(client, ref, arg_name, value) do
    ref_map =
      case ref do
        {:prompt, name} -> %{"type" => "ref/prompt", "name" => name}
        {:resource_template, uri} -> %{"type" => "ref/resource", "uri" => uri}
      end

    params = %{"ref" => ref_map, "argument" => %{"name" => arg_name, "value" => value}}

    case request(client, "completion/complete", params) do
      {:ok, %{"completion" => completion}} ->
        {:ok,
         %{
           values: completion["values"] || [],
           total: completion["total"],
           has_more: completion["hasMore"] == true
         }}

      error ->
        error
    end
  end

  @doc "Set the server's log level for this session."
  @spec set_log_level(GenServer.server(), atom() | String.t()) :: :ok | {:error, term()}
  def set_log_level(client, level) do
    case request(client, "logging/setLevel", %{"level" => to_string(level)}) do
      {:ok, _} -> :ok
      error -> error
    end
  end

  @doc "Replace the advertised roots and emit `notifications/roots/list_changed`."
  @spec set_roots(GenServer.server(), [Root.t()]) :: :ok
  def set_roots(client, roots) when is_list(roots) do
    GenServer.call(client, {:set_roots, roots})
  end

  defp paged(client, method, key, decoder, opts) do
    case Keyword.fetch(opts, :page) do
      {:ok, cursor} ->
        params = if cursor in [nil, :first], do: nil, else: %{"cursor" => cursor}

        case request(client, method, params, opts) do
          {:ok, result} ->
            {:ok, %{items: Enum.map(result[key] || [], decoder), next: result["nextCursor"]}}

          error ->
            error
        end

      :error ->
        collect_pages(client, method, key, decoder, nil, [], opts)
    end
  end

  defp collect_pages(client, method, key, decoder, cursor, acc, opts) do
    params = if cursor, do: %{"cursor" => cursor}, else: nil

    case request(client, method, params, opts) do
      {:ok, result} ->
        acc = acc ++ Enum.map(result[key] || [], decoder)

        case result["nextCursor"] do
          nil -> {:ok, acc}
          next -> collect_pages(client, method, key, decoder, next, acc, opts)
        end

      error ->
        error
    end
  end

  # ── GenServer ─────────────────────────────────────────────────────────────

  @impl true
  def init(opts) do
    Process.flag(:trap_exit, true)

    handler = normalize_handler(Keyword.get(opts, :handler))
    roots = Keyword.get(opts, :roots, []) |> Enum.map(&normalize_root/1)
    roots_capability? = roots != [] or handler_exports?(handler, :list_roots, 1)

    info =
      case Keyword.get(opts, :client_info) do
        %Implementation{} = implementation ->
          implementation

        %{} = map ->
          %Implementation{
            name: map[:name] || map["name"] || "noizu_mcp",
            version: map[:version] || map["version"] || "0.0.0"
          }

        nil ->
          %Implementation{name: "noizu_mcp", version: "0.0.0"}
      end

    capabilities =
      %{}
      |> then(
        &if handler_exports?(handler, :handle_sampling, 2),
          do: Map.put(&1, "sampling", %{}),
          else: &1
      )
      |> then(
        &if handler_exports?(handler, :handle_elicitation, 2),
          do: Map.put(&1, "elicitation", %{}),
          else: &1
      )
      |> then(&if roots_capability?, do: Map.put(&1, "roots", %{"listChanged" => true}), else: &1)

    peer = Peer.new(role: :client, info: info, capabilities: capabilities)

    {:ok, task_sup} = Task.Supervisor.start_link()

    state = %{
      opts: opts,
      peer: peer,
      transport: nil,
      status: :connecting,
      pending: %{},
      waiters: [],
      queued: [],
      handler: handler,
      roots: roots,
      on_notification: Keyword.get(opts, :on_notification),
      request_timeout: Keyword.get(opts, :request_timeout, @default_request_timeout),
      task_sup: task_sup,
      tasks: %{},
      refs: %{},
      instructions: nil
    }

    {:ok, state, {:continue, :connect}}
  end

  @impl true
  def handle_continue(:connect, state) do
    {module, transport_opts} = transport_spec(Keyword.fetch!(state.opts, :transport))

    case module.start_link(self(), transport_opts) do
      {:ok, pid} ->
        {:noreply, %{state | transport: {module, pid}}}

      {:error, reason} ->
        {:stop, {:shutdown, {:transport_start_failed, reason}}, state}
    end
  end

  defp transport_spec({:stdio, opts}), do: {Noizu.MCP.Transport.Stdio.Client, opts}
  defp transport_spec({:test, opts}), do: {Noizu.MCP.Transport.Test.Client, opts}

  defp transport_spec({:streamable_http, opts}),
    do: {Noizu.MCP.Transport.StreamableHTTP.Client, opts}

  defp transport_spec({module, opts}) when is_atom(module), do: {module, opts}

  @impl true
  def handle_call(:await_ready, from, state) do
    case state.status do
      :ready -> {:reply, :ok, state}
      {:failed, reason} -> {:reply, {:error, reason}, state}
      :connecting -> {:noreply, %{state | waiters: [from | state.waiters]}}
    end
  end

  def handle_call(:server_info, _from, state), do: {:reply, state.peer.remote_info, state}

  def handle_call(:server_capabilities, _from, state),
    do: {:reply, state.peer.remote_capabilities, state}

  def handle_call(:instructions, _from, state), do: {:reply, state.instructions, state}

  def handle_call({:request, method, params, opts}, from, state) do
    case state.status do
      :ready -> {:noreply, issue_request(state, from, method, params, opts)}
      :connecting -> {:noreply, %{state | queued: state.queued ++ [{from, method, params, opts}]}}
      {:failed, reason} -> {:reply, {:error, {:connection_failed, reason}}, state}
    end
  end

  def handle_call({:async, method, params, opts}, _from, state) do
    case state.status do
      :ready ->
        state = issue_request(state, nil, method, params, opts)
        # The id just issued is next_id - 1.
        {:reply, {:ok, state.peer.next_id - 1}, state}

      _ ->
        {:reply, {:error, :not_ready}, state}
    end
  end

  def handle_call({:await, id}, from, state) do
    case Map.fetch(state.pending, id) do
      :error ->
        {:reply, {:error, :unknown_request}, state}

      {:ok, %{result: nil} = entry} ->
        {:noreply, put_in(state.pending[id], %{entry | from: from})}

      {:ok, %{result: result}} ->
        {_, state} = pop_in(state.pending[id])
        {:reply, result, state}
    end
  end

  def handle_call({:set_roots, roots}, _from, state) do
    state = %{state | roots: Enum.map(roots, &normalize_root/1)}

    if state.status == :ready do
      send_message(state, Peer.notification("notifications/roots/list_changed", nil))
    end

    {:reply, :ok, state}
  end

  @impl true
  def handle_cast({:notify, method, params}, state) do
    if state.status == :ready do
      send_message(state, Peer.notification(method, params))
    end

    {:noreply, state}
  end

  def handle_cast({:cancel, id, reason}, state) do
    case Map.pop(state.pending, id) do
      {nil, _} ->
        {:noreply, state}

      {entry, pending} ->
        {peer, notification, _tag} = Peer.cancel_out(state.peer, id, reason)
        if notification, do: send_message(state, notification)
        cancel_timer(entry)
        if entry.from, do: GenServer.reply(entry.from, {:error, :cancelled})
        {:noreply, %{state | peer: peer, pending: pending}}
    end
  end

  # ── transport events ──────────────────────────────────────────────────────

  @impl true
  def handle_info({:mcp_transport, _pid, {:up, _info}}, state) do
    {peer, request} = Peer.init_request(state.peer)
    state = %{state | peer: peer}
    send_message(state, request)
    {:noreply, state}
  end

  def handle_info({:mcp_transport, _pid, {:message, binary, _meta}}, state) do
    case JsonRpc.decode(binary) do
      {:ok, message} ->
        {peer, effects} = Peer.ingest(state.peer, message)
        {:noreply, Enum.reduce(effects, %{state | peer: peer}, &run_effect(&2, &1))}

      {:error, error_response} ->
        send_message(state, error_response)
        {:noreply, state}
    end
  end

  def handle_info({:mcp_transport, _pid, {:down, reason}}, state) do
    state = fail_all(state, {:closed, reason})
    {:stop, {:shutdown, {:transport_down, reason}}, state}
  end

  def handle_info({:request_timeout, id}, state) do
    case Map.pop(state.pending, id) do
      {nil, _} ->
        {:noreply, state}

      {entry, pending} ->
        {peer, notification, _tag} = Peer.cancel_out(state.peer, id, "timeout")
        if notification, do: send_message(state, notification)
        if entry.from, do: GenServer.reply(entry.from, {:error, :timeout})
        {:noreply, %{state | peer: peer, pending: pending}}
    end
  end

  def handle_info({ref, {:client_task, id, result}}, state) when is_reference(ref) do
    Process.demonitor(ref, [:flush])

    case Map.pop(state.refs, ref) do
      {nil, _} -> {:noreply, state}
      {^id, refs} -> {:noreply, respond_inbound(%{state | refs: refs}, id, result)}
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, reason}, state) do
    case Map.pop(state.refs, ref) do
      {nil, _} ->
        {:noreply, state}

      {id, refs} ->
        Logger.error("MCP client handler task crashed: #{Exception.format_exit(reason)}")

        {:noreply,
         respond_inbound(%{state | refs: refs}, id, {:error, Error.internal("Handler failed")})}
    end
  end

  def handle_info({:EXIT, pid, reason}, state) do
    case state.transport do
      {_mod, ^pid} ->
        state = fail_all(state, {:closed, reason})
        {:stop, {:shutdown, {:transport_down, reason}}, state}

      _ ->
        {:noreply, state}
    end
  end

  def handle_info(_other, state), do: {:noreply, state}

  # ── effects ───────────────────────────────────────────────────────────────

  defp run_effect(state, {:send, message}) do
    send_message(state, message)
    state
  end

  defp run_effect(state, {:initialize_result, result}) do
    {peer, notification, effects} = Peer.initialized(state.peer)
    state = %{state | peer: peer, instructions: result["instructions"]}
    send_message(state, notification)
    Enum.reduce(effects, state, &run_effect(&2, &1))
  end

  defp run_effect(state, {:initialize_failed, reason}) do
    fail_all(%{state | status: {:failed, reason}}, {:initialize_failed, reason})
  end

  defp run_effect(state, {:ready, _info}) do
    for waiter <- state.waiters, do: GenServer.reply(waiter, :ok)

    state = %{state | status: :ready, waiters: []}

    Enum.reduce(state.queued, %{state | queued: []}, fn {from, method, params, opts}, acc ->
      issue_request(acc, from, method, params, opts)
    end)
  end

  defp run_effect(state, {:resolve, _tag, id, outcome}) do
    case Map.pop(state.pending, id) do
      {nil, _} ->
        state

      {entry, pending} ->
        cancel_timer(entry)
        result = normalize_outcome(outcome)

        if entry.from do
          GenServer.reply(entry.from, result)
          %{state | pending: pending}
        else
          # async request: hold the result for await/3
          put_in(%{state | pending: pending}.pending[id], %{entry | result: result})
        end
    end
  end

  defp run_effect(state, {:progress, _tag, id, params}) do
    with %{on_progress: fun} when is_function(fun, 1) <- Map.get(state.pending, id) do
      Task.Supervisor.start_child(state.task_sup, fn -> fun.(params) end)
    end

    mirror(state, "notifications/progress", params)
    state
  end

  defp run_effect(state, {:dispatch, method, id, params}) do
    dispatch_inbound(state, method, id, params)
  end

  defp run_effect(state, {:notice, method, params}) do
    if handler_exports?(state.handler, :handle_notification, 3) do
      {module, arg} = state.handler

      Task.Supervisor.start_child(state.task_sup, fn ->
        module.handle_notification(method, params, arg)
      end)
    end

    mirror(state, method, params)
    state
  end

  defp run_effect(state, {:cancel_in, id, _reason}) do
    case Enum.find(state.refs, fn {_ref, task_id} -> task_id == id end) do
      nil ->
        state

      {ref, _} ->
        case Map.pop(state.tasks, ref) do
          {nil, _} ->
            state

          {pid, tasks} ->
            Process.demonitor(ref, [:flush])
            Process.exit(pid, :kill)
            %{state | tasks: tasks, refs: Map.delete(state.refs, ref)}
        end
    end
  end

  defp run_effect(state, _other), do: state

  # ── inbound server requests ───────────────────────────────────────────────

  defp dispatch_inbound(state, "roots/list", id, _params) do
    roots =
      if handler_exports?(state.handler, :list_roots, 1) do
        {module, arg} = state.handler

        case module.list_roots(arg) do
          {:ok, roots} -> Enum.map(roots, &normalize_root/1)
        end
      else
        state.roots
      end

    respond_inbound(state, id, {:ok, %{"roots" => Enum.map(roots, &Root.to_map/1)}})
  end

  defp dispatch_inbound(state, "sampling/createMessage", id, params) do
    run_handler_task(state, id, :handle_sampling, params, fn
      {:ok, %{} = result} -> {:ok, result}
      {:error, reason} -> handler_error(reason)
    end)
  end

  defp dispatch_inbound(state, "elicitation/create", id, params) do
    run_handler_task(state, id, :handle_elicitation, params, fn
      {:ok, :accept, %{} = content} -> {:ok, %{"action" => "accept", "content" => content}}
      {:ok, :decline} -> {:ok, %{"action" => "decline"}}
      {:ok, :cancel} -> {:ok, %{"action" => "cancel"}}
      {:error, reason} -> handler_error(reason)
    end)
  end

  defp dispatch_inbound(state, method, id, _params) do
    respond_inbound(state, id, {:error, Error.method_not_found(method)})
  end

  defp run_handler_task(state, id, callback, params, normalize) do
    if handler_exports?(state.handler, callback, 2) do
      {module, arg} = state.handler

      task =
        Task.Supervisor.async_nolink(state.task_sup, fn ->
          {:client_task, id, normalize.(apply(module, callback, [params, arg]))}
        end)

      %{
        state
        | tasks: Map.put(state.tasks, task.ref, task.pid),
          refs: Map.put(state.refs, task.ref, id)
      }
    else
      respond_inbound(state, id, {:error, Error.method_not_found(to_string(callback))})
    end
  end

  defp handler_error(%Error{} = error), do: {:error, error}
  defp handler_error(reason) when is_binary(reason), do: {:error, Error.custom(-1, reason)}
  defp handler_error(reason), do: {:error, Error.internal(inspect(reason))}

  defp respond_inbound(state, id, result) do
    {peer, reply} =
      case result do
        {:ok, map} -> Peer.respond(state.peer, id, map)
        {:error, %Error{} = error} -> Peer.respond_error(state.peer, id, error)
      end

    case reply do
      {:ok, message} -> send_message(state, message, %{related_request_id: id})
      :drop -> :ok
    end

    %{state | peer: peer}
  end

  # ── internals ─────────────────────────────────────────────────────────────

  defp issue_request(state, from, method, params, opts) do
    progress = Keyword.get(opts, :progress)
    progress_token = if progress, do: "pt-#{state.peer.next_id}"

    {peer, id, request} =
      Peer.request(state.peer, method, params, progress_token: progress_token)

    timeout = Keyword.get(opts, :timeout, state.request_timeout)

    timer =
      if timeout != :infinity, do: Process.send_after(self(), {:request_timeout, id}, timeout)

    entry = %{from: from, timer: timer, on_progress: progress, result: nil}
    state = %{state | peer: peer, pending: Map.put(state.pending, id, entry)}
    send_message(state, request)
    state
  end

  defp normalize_outcome({:ok, result}), do: {:ok, result}
  defp normalize_outcome({:error, %Error{} = error}), do: {:error, error}

  defp fail_all(state, reason) do
    for {_id, entry} <- state.pending do
      cancel_timer(entry)
      if entry.from, do: GenServer.reply(entry.from, {:error, reason})
    end

    for waiter <- state.waiters, do: GenServer.reply(waiter, {:error, reason})
    for {from, _, _, _} <- state.queued, do: GenServer.reply(from, {:error, reason})

    %{state | pending: %{}, waiters: [], queued: [], status: {:failed, reason}}
  end

  defp cancel_timer(%{timer: nil}), do: :ok
  defp cancel_timer(%{timer: timer}), do: Process.cancel_timer(timer)

  defp send_message(state, message, routing \\ %{}) do
    {module, pid} = state.transport
    module.send_message(pid, JsonRpc.encode!(message), routing)
  end

  defp mirror(%{on_notification: nil}, _method, _params), do: :ok

  defp mirror(%{on_notification: pid}, method, params) do
    send(pid, {:mcp_notification, method, params})
    :ok
  end

  defp normalize_handler(nil), do: nil
  defp normalize_handler({module, arg}), do: {module, arg}
  defp normalize_handler(module) when is_atom(module), do: {module, nil}

  defp handler_exports?(nil, _fun, _arity), do: false

  defp handler_exports?({module, _arg}, fun, arity) do
    Code.ensure_loaded?(module) and function_exported?(module, fun, arity)
  end

  defp normalize_root(%Root{} = root), do: root
  defp normalize_root(%{} = map), do: Root.from_map(map)
  defp normalize_root(uri) when is_binary(uri), do: Root.new(uri)
end
