defmodule Noizu.MCP.Inspector do
  @moduledoc """
  Interactive HTML inspector for MCP servers — the engine behind
  `mix mcp.client`. Starts a localhost-only Bandit endpoint serving a
  single-page UI plus a JSON/SSE bridge to `Noizu.MCP.Client` sessions.

      {:ok, _} =
        Noizu.MCP.Inspector.start_link(
          target: {:module, MyApp.MCP},
          port: 6274,
          token: token)

  Targets:

    * `{:module, server_module}` — in-process connection to a
      `use Noizu.MCP.Server` module in this VM
    * `{:stdio, command, opts}` — spawn a subprocess (`opts`: `:args`,
      `:env`, `:cd`)
    * `{:url, url, opts}` — remote Streamable HTTP server (`opts`: `:bearer`,
      `:headers`)

  Requires the optional `:bandit` and `:plug` dependencies.
  """

  use Supervisor

  @default_port 6274

  # ── lifecycle ──────────────────────────────────────────────────────────────

  @doc """
  Options: `:token` (required — bearer token every API call must present),
  `:target` (optional — without it the browser UI prompts for one), `:port`
  (default #{@default_port}; `0` for a random port), `:name`, `:client_info`.
  """
  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    Supervisor.start_link(__MODULE__, Keyword.put(opts, :name, name), name: name)
  end

  @impl true
  def init(opts) do
    name = Keyword.fetch!(opts, :name)
    target = Keyword.get(opts, :target)
    token = Keyword.get(opts, :token)
    port = Keyword.get(opts, :port, @default_port)

    registry = Module.concat(name, Registry)
    session_supervisor = Module.concat(name, SessionSupervisor)

    config = %{
      inspector: name,
      registry: registry,
      session_supervisor: session_supervisor,
      token: token,
      default_target: target,
      client_info: Keyword.get(opts, :client_info)
    }

    children = [
      {Registry, keys: :unique, name: registry},
      {DynamicSupervisor, name: session_supervisor, strategy: :one_for_one},
      {Bandit,
       plug: {Noizu.MCP.Inspector.Plug, config},
       ip: {127, 0, 0, 1},
       port: port,
       startup_log: false}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  @doc "The bound HTTP port (useful with `port: 0`)."
  def port(inspector \\ __MODULE__) do
    inspector
    |> Supervisor.which_children()
    |> Enum.find_value(fn
      {_id, pid, _type, [Bandit]} when is_pid(pid) -> pid
      _ -> nil
    end)
    |> then(fn pid ->
      {:ok, {_ip, port}} = ThousandIsland.listener_info(pid)
      port
    end)
  end

  @doc "The browser URL (without token)."
  def url(inspector \\ __MODULE__), do: "http://127.0.0.1:#{port(inspector)}/"

  # ── sessions ───────────────────────────────────────────────────────────────

  @doc "Start a session against `target` (`nil` uses the configured default)."
  def start_session(config, target \\ nil) do
    with {:ok, transport, descriptor} <- resolve_target(target || config.default_target) do
      ensure_module_target_started(transport)
      session_id = Base.url_encode64(:crypto.strong_rand_bytes(18), padding: false)

      child = {
        Noizu.MCP.Inspector.Session,
        id: session_id,
        transport: transport,
        descriptor: descriptor,
        client_info: config.client_info,
        name: {:via, Registry, {config.registry, {:session, session_id}}}
      }

      case DynamicSupervisor.start_child(config.session_supervisor, child) do
        {:ok, pid} -> {:ok, session_id, pid}
        {:error, {:shutdown, {:connect_failed, reason}}} -> {:error, {:connect_failed, reason}}
        {:error, reason} -> {:error, reason}
      end
    end
  end

  @doc "Look up a live session pid."
  def lookup_session(config, session_id) do
    case Registry.lookup(config.registry, {:session, session_id}) do
      [{pid, _} | _] -> {:ok, pid}
      [] -> {:error, :not_found}
    end
  end

  # In-process targets need the server's supervision tree running — a module
  # picked in the browser won't have been started by the mix task.
  defp ensure_module_target_started({Noizu.MCP.Transport.Test.Client, opts}) do
    Noizu.MCP.Test.ensure_server_started(Keyword.fetch!(opts, :server))
  end

  defp ensure_module_target_started(_transport), do: :ok

  @doc """
  MCP server modules loadable in this VM: modules exporting `__mcp__/1` from
  applications that depend on `:noizu_mcp` (candidates for in-process targets).
  """
  def discover_servers do
    for {app, _description, _vsn} <- Application.loaded_applications(),
        app == :noizu_mcp or :noizu_mcp in (Application.spec(app, :applications) || []),
        module <- Application.spec(app, :modules) || [],
        Code.ensure_loaded?(module),
        function_exported?(module, :__mcp__, 1),
        uniq: true,
        do: inspect(module)
  end

  # ── targets ────────────────────────────────────────────────────────────────

  @doc """
  Resolve a target tuple (or a JSON descriptor map from the browser) into
  `{:ok, {transport_module, opts}, descriptor_map}`.
  """
  def resolve_target({:module, module}) when is_atom(module) do
    if Code.ensure_loaded?(module) and function_exported?(module, :__mcp__, 1) do
      {:ok, {Noizu.MCP.Transport.Test.Client, server: module},
       %{"type" => "module", "module" => inspect(module)}}
    else
      {:error, {:not_an_mcp_server, module}}
    end
  end

  def resolve_target({:stdio, command, opts}) when is_binary(command) do
    transport_opts =
      [command: command]
      |> put_present(:args, opts[:args])
      |> put_present(:env, opts[:env])
      |> put_present(:cd, opts[:cd])

    descriptor =
      %{"type" => "stdio", "command" => command}
      |> put_present("args", opts[:args])
      |> put_present("env", opts[:env])
      |> put_present("cd", opts[:cd])

    {:ok, {Noizu.MCP.Transport.Stdio.Client, transport_opts}, descriptor}
  end

  def resolve_target({:url, url, opts}) when is_binary(url) do
    if Code.ensure_loaded?(Noizu.MCP.Transport.StreamableHTTP.Client) do
      headers =
        case opts[:bearer] do
          nil -> opts[:headers] || []
          token -> [{"authorization", "Bearer #{token}"} | opts[:headers] || []]
        end

      {:ok, {Noizu.MCP.Transport.StreamableHTTP.Client, url: url, headers: headers},
       %{"type" => "url", "url" => url}}
    else
      {:error, :req_not_available}
    end
  end

  # Browser-supplied descriptors (POST /api/connect overrides).
  def resolve_target(%{"type" => "module", "module" => name}) do
    # Only already-loaded modules are accepted — the inspector must not let a
    # browser request load arbitrary code or mint new atoms.
    module = String.to_existing_atom("Elixir." <> String.trim_leading(name, "Elixir."))

    if Code.ensure_loaded?(module) and function_exported?(module, :__mcp__, 1) do
      resolve_target({:module, module})
    else
      {:error, {:not_an_mcp_server, name}}
    end
  rescue
    ArgumentError -> {:error, {:not_an_mcp_server, name}}
  end

  def resolve_target(%{"type" => "stdio", "command" => command} = descriptor) do
    resolve_target(
      {:stdio, command,
       args: descriptor["args"] || [], env: descriptor["env"], cd: descriptor["cd"]}
    )
  end

  def resolve_target(%{"type" => "url", "url" => url} = descriptor) do
    resolve_target({:url, url, bearer: descriptor["bearer"]})
  end

  def resolve_target(nil), do: {:error, :no_target}
  def resolve_target(other), do: {:error, {:invalid_target, other}}

  defp put_present(collection, _key, nil), do: collection
  defp put_present(collection, _key, []), do: collection

  defp put_present(collection, key, value) when is_list(collection),
    do: [{key, value} | collection]

  defp put_present(collection, key, value) when is_map(collection),
    do: Map.put(collection, key, value)
end
