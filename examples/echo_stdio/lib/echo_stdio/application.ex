defmodule EchoStdio.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {EchoStdio.MCP, transport: :stdio}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: EchoStdio.Supervisor)
  end
end
