defmodule Noizu.MCP.ConformanceTest do
  @moduledoc """
  Validates the wire shapes this library produces against the official MCP
  2025-11-25 `schema.json` (vendored in `priv/spec/`).
  """
  use ExUnit.Case, async: true

  import Noizu.MCP.Test
  alias Noizu.MCP.Fixtures

  @schema_path Path.join([:code.priv_dir(:noizu_mcp), "spec", "2025-11-25", "schema.json"])
  @external_resource @schema_path
  @spec_defs Jason.decode!(File.read!(@schema_path))["$defs"]

  defp validate!(definition, data) do
    wrapper = %{
      "$schema" => "https://json-schema.org/draft/2020-12/schema",
      "$ref" => "#/$defs/#{definition}",
      "$defs" => @spec_defs
    }

    case Noizu.MCP.Schema.validate(wrapper, data) do
      :ok ->
        :ok

      {:error, message} ->
        flunk("#{definition} conformance failure: #{message}\n\ndata: #{inspect(data)}")
    end
  end

  defp response_for(client, method, params) do
    id = send_request(client, method, params)

    receive do
      {:mcp_out, _, binary, _} -> Jason.decode!(binary)
    after
      1_000 -> flunk("no response to #{method}")
    end
    |> case do
      %{"id" => ^id} = envelope -> envelope
      _other -> response_for_drain(id)
    end
  end

  defp response_for_drain(id) do
    receive do
      {:mcp_out, _, binary, _} ->
        case Jason.decode!(binary) do
          %{"id" => ^id} = envelope -> envelope
          _ -> response_for_drain(id)
        end
    after
      1_000 -> flunk("no response for request #{id}")
    end
  end

  setup do
    %{client: connect(Fixtures.Server)}
  end

  test "InitializeResult", _ctx do
    # Re-run the raw handshake to capture the full envelope.
    {:ok, session} =
      Noizu.MCP.Server.Supervisor.start_session(Fixtures.Server,
        sink: {Noizu.MCP.Transport.Test, self()},
        transport: :test
      )

    request = %{
      "jsonrpc" => "2.0",
      "id" => 1,
      "method" => "initialize",
      "params" => %{
        "protocolVersion" => "2025-11-25",
        "capabilities" => %{},
        "clientInfo" => %{"name" => "conformance", "version" => "1.0.0"}
      }
    }

    Noizu.MCP.Server.Session.deliver(session, Jason.encode!(request))
    assert_receive {:mcp_out, _, binary, _}, 1_000

    envelope = Jason.decode!(binary)
    validate!("JSONRPCResponse", envelope)
    validate!("InitializeResult", envelope["result"])
  end

  test "ListToolsResult", %{client: client} do
    envelope = response_for(client, "tools/list", nil)
    validate!("JSONRPCResponse", envelope)
    validate!("ListToolsResult", envelope["result"])
  end

  test "CallToolResult (text)", %{client: client} do
    envelope =
      response_for(client, "tools/call", %{
        "name" => "echo",
        "arguments" => %{"message" => "hi"}
      })

    validate!("CallToolResult", envelope["result"])
  end

  test "CallToolResult (structured + outputSchema)", %{client: client} do
    envelope =
      response_for(client, "tools/call", %{
        "name" => "get_weather",
        "arguments" => %{"location" => "NYC"}
      })

    validate!("CallToolResult", envelope["result"])
    assert envelope["result"]["structuredContent"]
  end

  test "CallToolResult (isError from validation failure)", %{client: client} do
    envelope = response_for(client, "tools/call", %{"name" => "echo", "arguments" => %{}})
    validate!("CallToolResult", envelope["result"])
    assert envelope["result"]["isError"] == true
  end

  test "JSONRPCErrorResponse for unknown method", %{client: client} do
    envelope = response_for(client, "bogus/method", nil)
    validate!("JSONRPCErrorResponse", envelope)
  end

  test "ProgressNotification", %{client: client} do
    id =
      send_request(client, "tools/call", %{
        "name" => "get_weather",
        "arguments" => %{"location" => "NYC"},
        "_meta" => %{"progressToken" => "tok"}
      })

    envelope = drain_until_notification("notifications/progress")
    validate!("ProgressNotification", envelope)

    # Drain the call response so the mailbox is clean.
    response_for_drain(id)
  end

  test "LoggingMessageNotification", %{client: client} do
    id =
      send_request(client, "tools/call", %{
        "name" => "get_weather",
        "arguments" => %{"location" => "NYC"}
      })

    envelope = drain_until_notification("notifications/message")
    validate!("LoggingMessageNotification", envelope)
    response_for_drain(id)
  end

  test "Tool definitions in tools/list conform individually", %{client: client} do
    envelope = response_for(client, "tools/list", nil)

    for tool <- envelope["result"]["tools"] do
      validate!("Tool", tool)
    end
  end

  test "ListResourcesResult", %{client: client} do
    envelope = response_for(client, "resources/list", nil)
    validate!("ListResourcesResult", envelope["result"])
  end

  test "ListResourceTemplatesResult", %{client: client} do
    envelope = response_for(client, "resources/templates/list", nil)
    validate!("ListResourceTemplatesResult", envelope["result"])
  end

  test "ReadResourceResult (text and blob)", %{client: client} do
    envelope = response_for(client, "resources/read", %{"uri" => "config://app"})
    validate!("ReadResourceResult", envelope["result"])

    envelope = response_for(client, "resources/read", %{"uri" => "asset://logo"})
    validate!("ReadResourceResult", envelope["result"])
  end

  test "ListPromptsResult", %{client: client} do
    envelope = response_for(client, "prompts/list", nil)
    validate!("ListPromptsResult", envelope["result"])
  end

  test "GetPromptResult", %{client: client} do
    envelope =
      response_for(client, "prompts/get", %{
        "name" => "code_review",
        "arguments" => %{"code" => "1 + 1"}
      })

    validate!("GetPromptResult", envelope["result"])
  end

  test "CompleteResult", %{client: client} do
    envelope =
      response_for(client, "completion/complete", %{
        "ref" => %{"type" => "ref/prompt", "name" => "code_review"},
        "argument" => %{"name" => "style", "value" => ""}
      })

    validate!("CompleteResult", envelope["result"])
  end

  test "ResourceUpdatedNotification", %{client: _client} do
    client = connect(Fixtures.Server)
    {:ok, %{}} = Noizu.MCP.Test.subscribe(client, "config://app")
    Fixtures.Server.notify_resource_updated("config://app")

    envelope = drain_until_notification("notifications/resources/updated")
    validate!("ResourceUpdatedNotification", envelope)
  end

  defp drain_until_notification(method) do
    receive do
      {:mcp_out, _, binary, _} ->
        case Jason.decode!(binary) do
          %{"method" => ^method} = envelope -> envelope
          _ -> drain_until_notification(method)
        end
    after
      1_000 -> flunk("no #{method} notification observed")
    end
  end
end
