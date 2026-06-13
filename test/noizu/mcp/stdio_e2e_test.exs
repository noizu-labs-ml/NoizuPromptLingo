defmodule Noizu.MCP.StdioE2ETest do
  @moduledoc """
  Runs the `examples/echo_stdio` server as a real OS subprocess and speaks MCP
  to it over stdin/stdout.

  Excluded by default (compiles the example on first run). Run with:

      mix test --include e2e
  """
  use ExUnit.Case

  @moduletag :e2e
  @moduletag timeout: 120_000

  @example_dir Path.expand("../../../examples/echo_stdio", __DIR__)

  setup_all do
    {_, 0} = System.cmd("mix", ["deps.get"], cd: @example_dir, stderr_to_stdout: true)
    {_, 0} = System.cmd("mix", ["compile"], cd: @example_dir, stderr_to_stdout: true)
    :ok
  end

  test "handshake, tools/list, tools/call over a real subprocess" do
    port =
      Port.open({:spawn_executable, System.find_executable("mix")}, [
        :binary,
        :exit_status,
        :hide,
        {:line, 65_536},
        {:args, ["run", "--no-halt"]},
        {:cd, @example_dir},
        {:env, [{~c"MIX_ENV", ~c"dev"}]}
      ])

    send_msg(port, %{
      "jsonrpc" => "2.0",
      "id" => 1,
      "method" => "initialize",
      "params" => %{
        "protocolVersion" => "2025-11-25",
        "capabilities" => %{},
        "clientInfo" => %{"name" => "e2e", "version" => "1.0.0"}
      }
    })

    assert %{"id" => 1, "result" => init} = recv_msg(port)
    assert init["protocolVersion"] == "2025-11-25"
    assert init["serverInfo"]["name"] == "echo_stdio"
    assert init["capabilities"]["tools"] == %{"listChanged" => true}

    send_msg(port, %{"jsonrpc" => "2.0", "method" => "notifications/initialized"})

    send_msg(port, %{"jsonrpc" => "2.0", "id" => 2, "method" => "tools/list"})
    assert %{"id" => 2, "result" => %{"tools" => tools}} = recv_msg(port)
    assert Enum.map(tools, & &1["name"]) |> Enum.sort() == ["echo", "system_time"]

    send_msg(port, %{
      "jsonrpc" => "2.0",
      "id" => 3,
      "method" => "tools/call",
      "params" => %{
        "name" => "echo",
        "arguments" => %{"message" => "hello", "mode" => "loud", "repeat" => 2},
        "_meta" => %{"progressToken" => "e2e-tok"}
      }
    })

    assert %{"method" => "notifications/progress", "params" => progress} = recv_msg(port)
    assert progress["progressToken"] == "e2e-tok"

    assert %{"id" => 3, "result" => result} = recv_msg(port)
    assert [%{"type" => "text", "text" => "HELLO HELLO"}] = result["content"]

    Port.close(port)
  end

  test "Noizu.MCP.Client over the stdio transport against a real subprocess" do
    client =
      start_supervised!(
        {Noizu.MCP.Client,
         transport: {:stdio, command: "mix", args: ["run", "--no-halt"], cd: @example_dir},
         client_info: %{name: "e2e_client", version: "1.0.0"},
         request_timeout: 60_000}
      )

    assert :ok = Noizu.MCP.Client.await_ready(client, 60_000)
    assert Noizu.MCP.Client.server_info(client).name == "echo_stdio"

    assert {:ok, tools} = Noizu.MCP.Client.list_tools(client)
    assert Enum.map(tools, & &1.name) |> Enum.sort() == ["echo", "system_time"]

    me = self()

    assert {:ok, result} =
             Noizu.MCP.Client.call_tool(
               client,
               "echo",
               %{"message" => "round trip", "mode" => "loud"},
               progress: fn params -> send(me, {:progress, params}) end
             )

    assert [%{type: :text, text: "ROUND TRIP"}] = result.content
    assert_receive {:progress, %{"progress" => 0.5}}, 5_000

    assert {:ok, %{structured: %{"utc" => utc}}} =
             Noizu.MCP.Client.call_tool(client, "system_time", %{})

    assert {:ok, _, _} = DateTime.from_iso8601(utc)
  end

  defp send_msg(port, map), do: Port.command(port, [Jason.encode!(map), "\n"])

  defp recv_msg(port, timeout \\ 60_000) do
    receive do
      {^port, {:data, {:eol, line}}} ->
        Jason.decode!(line)

      {^port, {:exit_status, status}} ->
        flunk("server subprocess exited with status #{status}")
    after
      timeout -> flunk("timed out waiting for server output")
    end
  end
end
