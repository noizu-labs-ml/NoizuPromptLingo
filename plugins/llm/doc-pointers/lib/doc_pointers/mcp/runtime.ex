defmodule DocPointers.MCP.Runtime do
  @moduledoc false

  @default_port 4242
  @loopback {127, 0, 0, 1}

  def parse(args) do
    {opts, _rest, _invalid} =
      OptionParser.parse(args,
        strict: [root: :string, port: :integer, write: :boolean],
        aliases: [w: :write]
      )

    opts
  end

  def configure!(opts) do
    if root = opts[:root] do
      DocPointers.Store.set_root(root)
    end

    Application.put_env(:doc_pointers, :mcp_writes, writes_enabled?(opts))
    :ok
  end

  def writes_enabled?(opts) do
    opts[:write] == true or env_flag?("DOC_POINTERS_MCP_WRITES")
  end

  def env_flag?(name) do
    System.get_env(name) in ["1", "true", "TRUE", "yes", "YES"]
  end

  def port(opts) do
    cond do
      is_integer(opts[:port]) -> opts[:port]
      p = System.get_env("DOC_POINTERS_PORT") -> String.to_integer(p)
      true -> @default_port
    end
  end

  def start_stdio! do
    Logger.configure(level: :warning)

    {:ok, _pid} =
      Supervisor.start_link([{DocPointers.MCP, transport: :stdio}],
        strategy: :one_for_one,
        name: DocPointers.MCP.Supervisor
      )

    :ok
  end

  def start_http!(port) do
    children = [
      DocPointers.MCP,
      {Bandit,
       plug: {Noizu.MCP.Transport.StreamableHTTP.Plug, server: DocPointers.MCP},
       scheme: :http,
       port: port,
       ip: @loopback}
    ]

    {:ok, _pid} =
      Supervisor.start_link(children,
        strategy: :one_for_one,
        name: DocPointers.MCP.Supervisor
      )

    :ok
  end
end
