defmodule AgentClient do
  @moduledoc """
  Demo `Noizu.MCP.Client` flow: spawn the sibling `echo_stdio` example as a
  subprocess over the stdio transport, inspect the server, list its tools,
  call them, and shut down.

  Run with:

      mix run -e AgentClient.main
      # or
      mix agent.demo
  """

  alias Noizu.MCP.Client
  alias Noizu.MCP.Types.{Content, ToolResult}

  # Resolved at compile time relative to this file, so the demo works no
  # matter where `mix run` is invoked from.
  @server_dir Path.expand("../../echo_stdio", __DIR__)

  def main do
    {:ok, client} =
      Client.start_link(
        transport: {:stdio, command: "mix", args: ["run", "--no-halt"], cd: @server_dir},
        client_info: %{name: "agent_client", version: "0.1.0"},
        handler: AgentClient.Handler
      )

    # First start may compile echo_stdio — give the handshake plenty of time.
    :ok = Client.await_ready(client, 120_000)

    info = Client.server_info(client)
    IO.puts("connected to: #{info.name} v#{info.version}")
    IO.puts("instructions: #{Client.instructions(client) || "(none)"}")

    {:ok, tools} = Client.list_tools(client)
    IO.puts("\ntools (#{length(tools)}):")
    Enum.each(tools, fn tool -> IO.puts("  - #{tool.name}: #{tool.description}") end)

    IO.puts("\ncalling echo(message: \"hello mcp\", repeat: 2, mode: loud)…")

    {:ok, result} =
      Client.call_tool(
        client,
        "echo",
        %{"message" => "hello mcp", "repeat" => 2, "mode" => "loud"},
        progress: fn params -> IO.puts(:stderr, "[progress] #{inspect(params)}") end
      )

    IO.puts("echo -> #{render(result)}")

    IO.puts("\ncalling system_time()…")
    {:ok, result} = Client.call_tool(client, "system_time", %{})
    IO.puts("system_time -> #{render(result)}")
    IO.puts("structured  -> #{inspect(result.structured)}")

    :ok = Client.close(client)
    IO.puts("\nclosed.")
  end

  defp render(%ToolResult{is_error: true} = result) do
    "ERROR: " <> Enum.map_join(result.content, " ", &content_text/1)
  end

  defp render(%ToolResult{} = result) do
    Enum.map_join(result.content, " ", &content_text/1)
  end

  defp content_text(%Content{type: :text, text: text}), do: text
  defp content_text(%Content{type: type}), do: "<#{type}>"
end
