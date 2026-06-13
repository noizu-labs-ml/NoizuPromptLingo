defmodule Mix.Tasks.Mcp.Client do
  @shortdoc "Launch the interactive MCP inspector web client"

  @moduledoc """
  Start `Noizu.MCP.Inspector` — a rich interactive HTML client for exploring
  and exercising MCP servers (tools, resources, prompts, sampling,
  elicitation, raw JSON-RPC history) — and open it in your browser.

      # no target: pick/change the target inside the app
      mix mcp.client

      # in-process server module
      mix mcp.client MyApp.MCP

      # spawn an external stdio server
      mix mcp.client --stdio "npx -y @modelcontextprotocol/server-everything"

      # connect to a remote Streamable HTTP server
      mix mcp.client --url http://localhost:4040/mcp --bearer TOKEN

  ## Options

    * `--port PORT` — HTTP port (default 6274; `0` picks a random free port)
    * `--no-open` — don't auto-open the browser
    * `--stdio CMD` — spawn `CMD` (shell-split) as a stdio MCP server
    * `--cd DIR` / `--env K=V` (repeatable) — stdio subprocess options
    * `--url URL` / `--bearer TOKEN` — Streamable HTTP target
    * `--name NAME` / `--version VSN` — advertised client info

  Requires the optional `:bandit` and `:plug` dependencies (and `:req` for
  `--url` targets).
  """

  use Mix.Task

  @switches [
    port: :integer,
    open: :boolean,
    stdio: :string,
    cd: :string,
    env: :keep,
    url: :string,
    bearer: :string,
    name: :string,
    version: :string
  ]

  @impl Mix.Task
  def run(argv) do
    {target, opts} = parse_args!(argv)
    ensure_deps!()

    Mix.Task.run("app.start")

    target = validate_target!(target)
    token = nil

    client_info =
      if opts[:name] || opts[:version] do
        %{name: opts[:name] || "noizu-mcp-inspector", version: opts[:version] || "0.0.0"}
      end

    {:ok, _pid} =
      Noizu.MCP.Inspector.start_link(
        target: target,
        token: token,
        port: Keyword.get(opts, :port, 6274),
        client_info: client_info
      )

    url = Noizu.MCP.Inspector.url()

    Mix.shell().info("""

    MCP inspector running at:

        #{url}

    Target: #{describe_target(target)}
    Press Ctrl-C to stop.
    """)

    if Keyword.get(opts, :open, true), do: open_browser(url)

    Process.sleep(:infinity)
  end

  @doc false
  def parse_args!(argv) do
    {opts, positional, invalid} = OptionParser.parse(argv, strict: @switches)

    if invalid != [] do
      Mix.raise("Invalid options: #{inspect(invalid)}")
    end

    env =
      opts
      |> Keyword.get_values(:env)
      |> Map.new(fn pair ->
        case String.split(pair, "=", parts: 2) do
          [key, value] -> {key, value}
          _ -> Mix.raise("--env expects K=V, got: #{pair}")
        end
      end)

    target =
      case {positional, opts[:stdio], opts[:url]} do
        {[module], nil, nil} ->
          {:module, Module.concat([module])}

        {[], command, nil} when is_binary(command) ->
          case OptionParser.split(command) do
            [executable | args] ->
              {:stdio, executable, args: args, env: map_or_nil(env), cd: opts[:cd]}

            [] ->
              Mix.raise("--stdio expects a command")
          end

        {[], nil, url} when is_binary(url) ->
          {:url, url, bearer: opts[:bearer]}

        {[], nil, nil} ->
          # No target: the user picks one in the browser.
          nil

        _ ->
          Mix.raise("Give exactly one of: a server module, --stdio, or --url")
      end

    {target, opts}
  end

  defp map_or_nil(map) when map_size(map) == 0, do: nil
  defp map_or_nil(map), do: map

  defp ensure_deps! do
    unless Code.ensure_loaded?(Bandit) and Code.ensure_loaded?(Plug.Conn) do
      Mix.raise("""
      mix mcp.client needs the optional :bandit and :plug dependencies. Add to mix.exs:

          {:bandit, "~> 1.5", only: :dev},
          {:plug, "~> 1.16", only: :dev}
      """)
    end
  end

  defp validate_target!({:module, module} = target) do
    unless Code.ensure_loaded?(module) and function_exported?(module, :__mcp__, 1) do
      Mix.raise(
        "#{inspect(module)} is not a Noizu.MCP.Server module (missing __mcp__/1). " <>
          "Did you mean a fully-qualified module name?"
      )
    end

    Noizu.MCP.Test.ensure_server_started(module)
    target
  end

  defp validate_target!({:url, _url, _opts} = target) do
    unless Code.ensure_loaded?(Noizu.MCP.Transport.StreamableHTTP.Client) do
      Mix.raise("--url targets need the optional :req dependency: {:req, \"~> 0.5\"}")
    end

    target
  end

  defp validate_target!(target), do: target

  defp describe_target(nil), do: "none — choose one in the browser"
  defp describe_target({:module, module}), do: "in-process #{inspect(module)}"
  defp describe_target({:stdio, command, _opts}), do: "stdio: #{command}"
  defp describe_target({:url, url, _opts}), do: url

  defp open_browser(url) do
    {command, args} =
      case :os.type() do
        {:unix, :darwin} -> {"open", [url]}
        {:unix, _} -> {"xdg-open", [url]}
        {:win32, _} -> {"cmd", ["/c", "start", "", url]}
      end

    System.cmd(command, args, stderr_to_stdout: true)
  rescue
    _ -> :ok
  end
end
