defmodule DropboxMCP.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children =
      if Application.get_env(:dropbox_mcp, :start_stdio, true) do
        [{DropboxMCP.Server, transport: :stdio}]
      else
        []
      end

    opts = [strategy: :one_for_one, name: DropboxMCP.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
