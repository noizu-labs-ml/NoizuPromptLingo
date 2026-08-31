defmodule Noizu.Google.MCP.Application do
  @moduledoc """
  OTP application for `:noizu_google_mcp`.

  Starts `{Noizu.Google.MCP, transport: :stdio}` unless
  `config :noizu_google_mcp, start_stdio: false`.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children =
      if Application.get_env(:noizu_google_mcp, :start_stdio, true) do
        [{Noizu.Google.MCP, transport: :stdio}]
      else
        []
      end

    Supervisor.start_link(children, strategy: :one_for_one, name: Noizu.Google.MCP.Supervisor)
  end
end
