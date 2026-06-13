defmodule Noizu.MCP.ServerIntegrationTest do
  use ExUnit.Case, async: true

  import Noizu.MCP.Test
  alias Noizu.MCP.Fixtures

  describe "handshake" do
    test "initialize advertises serverInfo, capabilities, instructions" do
      client = connect(Fixtures.Server)

      assert client.server_info["name"] == "fixture"
      assert client.capabilities["tools"] == %{"listChanged" => true}
      assert client.capabilities["logging"] == %{}
      assert client.instructions == "Fixture server for tests."
    end

    test "version negotiation falls back to latest for unknown versions" do
      client = connect(Fixtures.Server, protocol_version: "2020-01-01")
      assert client.server_info["name"] == "fixture"
    end

    test "ping works" do
      client = connect(Fixtures.Server)
      assert {:ok, %{}} = request(client, "ping")
    end
  end

  describe "tools/list" do
    test "lists all registered tools" do
      client = connect(Fixtures.Server)
      assert {:ok, tools} = list_tools(client)

      names = Enum.map(tools, & &1.name)
      assert "echo" in names
      assert "get_weather" in names
      assert "echo_alias" in names
      assert length(tools) == 11
    end

    test "per-registration overrides apply" do
      client = connect(Fixtures.Server)
      {:ok, tools} = list_tools(client)

      alias_tool = Enum.find(tools, &(&1.name == "echo_alias"))
      assert alias_tool.description == "Echo under another name"
    end

    test "invalid cursor is invalid_params" do
      client = connect(Fixtures.Server)

      assert {:error, %{"code" => -32_602}} =
               request(client, "tools/list", %{"cursor" => "garbage"})
    end
  end

  describe "tools/call" do
    setup do
      %{client: connect(Fixtures.Server)}
    end

    test "happy path with defaults and enum casting", %{client: client} do
      assert {:ok, result} = call_tool(client, "echo", %{"message" => "hi"})
      assert result.is_error == false
      assert [%{type: :text, text: "hi"}] = result.content

      assert {:ok, result} =
               call_tool(client, "echo", %{"message" => "hi", "repeat" => 2, "mode" => "loud"})

      assert [%{text: "HIHI"}] = result.content
    end

    test "structured output with outputSchema", %{client: client} do
      assert {:ok, result} = call_tool(client, "get_weather", %{"location" => "NYC"})
      assert result.structured == %{"temperature" => 21.5, "conditions" => "clear"}
      assert [%{type: :text, text: text}] = result.content
      assert Jason.decode!(text)["temperature"] == 21.5
    end

    test "input validation failure is an isError result (SEP-1303)", %{client: client} do
      assert {:ok, result} = call_tool(client, "echo", %{})
      assert result.is_error == true
      assert [%{text: text}] = result.content
      assert text =~ "Invalid arguments"
      assert text =~ "message"
    end

    test "validation enforces constraints", %{client: client} do
      assert {:ok, %{is_error: true}} =
               call_tool(client, "echo", %{"message" => "hi", "repeat" => 99})

      assert {:ok, %{is_error: true}} =
               call_tool(client, "echo", %{"message" => "hi", "mode" => "whisper"})
    end

    test "raw schema tool receives string keys", %{client: client} do
      assert {:ok, result} = call_tool(client, "raw_schema", %{"query" => "ab"})
      assert [%{text: "raw:ab"}] = result.content

      assert {:ok, %{is_error: true}} = call_tool(client, "raw_schema", %{"query" => "a"})
    end

    test "unknown tool is a protocol error", %{client: client} do
      assert {:error, %{"code" => -32_602, "message" => message}} =
               call_tool(client, "nope", %{})

      assert message =~ "Unknown tool"
    end

    test "{:error, binary} becomes an isError result", %{client: client} do
      assert {:ok, result} = call_tool(client, "fail", %{})
      assert result.is_error == true
      assert [%{text: "it failed, try again with flag=true"}] = result.content
    end

    test "a crashing tool returns a sanitized isError result", %{client: client} do
      assert {:ok, result} = call_tool(client, "crash", %{})
      assert result.is_error == true
      assert [%{text: "Tool execution failed"}] = result.content
      refute inspect(result) =~ "boom"
    end

    test "session survives a tool crash", %{client: client} do
      {:ok, %{is_error: true}} = call_tool(client, "crash", %{})
      assert {:ok, %{is_error: false}} = call_tool(client, "echo", %{"message" => "still alive"})
    end
  end

  describe "progress and logging" do
    setup do
      %{client: connect(Fixtures.Server)}
    end

    test "progress notifications flow when a token is sent", %{client: client} do
      assert {:ok, _} =
               call_tool(client, "get_weather", %{"location" => "NYC"}, progress_token: "tok-9")

      params = assert_progress(client)
      assert params["progressToken"] == "tok-9"
      assert params["progress"] == 0.5
      assert params["message"] == "querying provider"
    end

    test "no progress without a token", %{client: client} do
      assert {:ok, _} = call_tool(client, "get_weather", %{"location" => "NYC"})
      refute_notification(client, "notifications/progress")
    end

    test "log messages flow and respect setLevel", %{client: client} do
      assert {:ok, _} = call_tool(client, "get_weather", %{"location" => "NYC"})
      params = assert_notification(client, "notifications/message")
      assert params["level"] == "info"
      assert params["data"] == "cache miss"

      assert {:ok, %{}} = set_log_level(client, :error)
      assert {:ok, _} = call_tool(client, "get_weather", %{"location" => "NYC"})
      refute_notification(client, "notifications/message")
    end

    test "invalid log level is rejected", %{client: client} do
      assert {:error, %{"code" => -32_602}} =
               request(client, "logging/setLevel", %{"level" => "loudest"})
    end
  end

  describe "cancellation" do
    test "cancelled request never gets a response and the task dies" do
      client = connect(Fixtures.Server)

      id =
        send_request(client, "tools/call", %{"name" => "slow", "arguments" => %{"ms" => 30_000}})

      Process.sleep(50)
      cancel(client, id, "user changed their mind")

      assert {:ok, %{is_error: false}} = call_tool(client, "echo", %{"message" => "next"})

      assert_raise ExUnit.AssertionError, ~r/Timed out/, fn ->
        await(client, id, timeout: 300)
      end
    end
  end

  describe "list_changed notifications" do
    test "notify_changed fans out to connected sessions" do
      client = connect(Fixtures.Server)
      Fixtures.Server.notify_changed(:tools)
      assert assert_notification(client, "notifications/tools/list_changed") == nil
    end
  end

  describe "session state" do
    test "init/2 seeds assigns and put_session persists across requests" do
      defmodule StatefulTool do
        use Noizu.MCP.Server.Tool, name: "stateful", description: "reads/writes session state"

        input do
          field :write, :string
        end

        @impl true
        def call(args, ctx) do
          if value = args[:write] do
            Noizu.MCP.Ctx.put_session(ctx, :written, value)
          end

          {:ok, "tenant=#{ctx.assigns[:tenant]} written=#{ctx.assigns[:written]}"}
        end
      end

      defmodule StatefulServer do
        use Noizu.MCP.Server, name: "stateful", version: "1.0.0"
        tool StatefulTool

        @impl Noizu.MCP.Server
        def init(ctx, _params), do: {:ok, Noizu.MCP.Ctx.assign(ctx, :tenant, :acme)}
      end

      client = connect(StatefulServer)

      assert {:ok, result} = call_tool(client, "stateful", %{"write" => "v1"})
      assert [%{text: "tenant=acme written="}] = result.content

      assert {:ok, result} = call_tool(client, "stateful", %{})
      assert [%{text: "tenant=acme written=v1"}] = result.content
    end
  end

  describe "behaviour-only server (escape hatch)" do
    test "hand-written callbacks work without the DSL" do
      client = connect(Fixtures.BareServer)

      assert client.capabilities["tools"] == %{"listChanged" => true}

      assert {:ok, [tool]} = list_tools(client)
      assert tool.name == "shout"

      assert {:ok, result} = call_tool(client, "shout", %{"text" => "quiet"})
      assert [%{text: "QUIET"}] = result.content
    end
  end

  describe "server without tools" do
    test "tools methods are method_not_found and capability is absent" do
      client = connect(Fixtures.EmptyServer)

      refute Map.has_key?(client.capabilities, "tools")
      assert {:error, %{"code" => -32_601}} = request(client, "tools/list")
    end
  end

  describe "protocol robustness" do
    test "malformed JSON gets a parse error response" do
      client = connect(Fixtures.Server)
      deliver_raw(client, "{not json")

      assert_receive {:mcp_out, _, binary, _}, 1_000
      assert %{"error" => %{"code" => -32_700}} = Jason.decode!(binary)
    end

    test "unknown notification is ignored" do
      client = connect(Fixtures.Server)
      notify(client, "notifications/whatever", %{"x" => 1})
      assert {:ok, %{}} = request(client, "ping")
    end
  end

  describe "pagination" do
    test "tools/list paginates with opaque cursors" do
      defmodule ManyToolsServer do
        use Noizu.MCP.Server, name: "many", version: "1.0.0"

        @impl Noizu.MCP.Server
        def handle_list_tools(cursor, _ctx) do
          tools = for i <- 1..120, do: %Noizu.MCP.Types.Tool{name: "tool_#{i}"}

          offset =
            case cursor do
              nil -> 0
              cursor -> String.to_integer(cursor)
            end

          page = Enum.slice(tools, offset, 50)
          next = if offset + 50 < 120, do: "#{offset + 50}", else: nil
          {:ok, page, next}
        end

        @impl Noizu.MCP.Server
        def handle_call_tool(_name, _args, _ctx), do: {:ok, "ok"}
      end

      client = connect(ManyToolsServer)

      assert {:ok, page} = request(client, "tools/list")
      assert length(page["tools"]) == 50
      assert page["nextCursor"] == "50"

      assert {:ok, tools} = list_tools(client)
      assert length(tools) == 120
    end
  end
end
