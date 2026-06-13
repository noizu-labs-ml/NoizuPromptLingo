defmodule Mix.Tasks.Agent.Demo do
  @shortdoc "Run the MCP client demo against examples/echo_stdio"

  @moduledoc """
  Spawns the sibling `echo_stdio` MCP server as a subprocess and drives it:
  server info, tool listing, `echo` and `system_time` calls.

      mix agent.demo
  """

  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start")
    AgentClient.main()
  end
end
