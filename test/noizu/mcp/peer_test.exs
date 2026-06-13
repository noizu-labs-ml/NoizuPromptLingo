defmodule Noizu.MCP.PeerTest do
  use ExUnit.Case, async: true

  alias Noizu.MCP.Peer
  alias Noizu.MCP.JsonRpc.{ErrorResponse, Notification, Request, Response}
  alias Noizu.MCP.Types.Implementation

  defp server_peer do
    Peer.new(
      role: :server,
      info: %Implementation{name: "test", version: "1.0.0"},
      capabilities: %{"tools" => %{"listChanged" => true}},
      instructions: "hello"
    )
  end

  defp initialize_request(version \\ "2025-11-25") do
    %Request{
      id: 1,
      method: "initialize",
      params: %{
        "protocolVersion" => version,
        "capabilities" => %{},
        "clientInfo" => %{"name" => "c", "version" => "1"}
      }
    }
  end

  defp ready_server do
    {peer, _} = Peer.ingest(server_peer(), initialize_request())
    {peer, _} = Peer.ingest(peer, %Notification{method: "notifications/initialized"})
    peer
  end

  describe "server handshake" do
    test "initialize negotiates the requested supported version" do
      {peer, effects} = Peer.ingest(server_peer(), initialize_request("2025-06-18"))

      assert peer.phase == :initializing
      assert peer.protocol_version == "2025-06-18"
      assert [{:send, %Response{id: 1, result: result}}] = effects
      assert result["protocolVersion"] == "2025-06-18"
      assert result["serverInfo"]["name"] == "test"
      assert result["instructions"] == "hello"
    end

    test "unsupported requested version falls back to our latest" do
      {_peer, [{:send, %Response{result: result}}]} =
        Peer.ingest(server_peer(), initialize_request("2024-11-05"))

      assert result["protocolVersion"] == "2025-11-25"
    end

    test "initialized completes the handshake" do
      {peer, _} = Peer.ingest(server_peer(), initialize_request())
      {peer, effects} = Peer.ingest(peer, %Notification{method: "notifications/initialized"})

      assert peer.phase == :ready
      assert [{:ready, %Implementation{name: "c"}}] = effects
    end

    test "requests before ready are rejected (except ping)" do
      {_peer, effects} = Peer.ingest(server_peer(), %Request{id: 5, method: "tools/list"})
      assert [{:send, %ErrorResponse{id: 5}}] = effects

      {_peer, effects} = Peer.ingest(server_peer(), %Request{id: 6, method: "ping"})
      assert [{:send, %Response{id: 6}}] = effects
    end

    test "double initialize is rejected" do
      {peer, _} = Peer.ingest(server_peer(), initialize_request())
      {_peer, effects} = Peer.ingest(peer, initialize_request())
      assert [{:send, %ErrorResponse{}}] = effects
    end
  end

  describe "inbound requests" do
    test "valid request is dispatched and tracked" do
      peer = ready_server()
      {peer, effects} = Peer.ingest(peer, %Request{id: 2, method: "tools/list", params: %{}})

      assert [{:dispatch, "tools/list", 2, %{}}] = effects
      assert Map.has_key?(peer.pending_in, 2)
    end

    test "unknown method gets method_not_found" do
      {_peer, effects} = Peer.ingest(ready_server(), %Request{id: 2, method: "bogus/method"})
      assert [{:send, %ErrorResponse{error: %{code: -32_601}}}] = effects
    end

    test "wrong-direction method gets method_not_found" do
      {_peer, effects} =
        Peer.ingest(ready_server(), %Request{id: 2, method: "sampling/createMessage"})

      assert [{:send, %ErrorResponse{error: %{code: -32_601}}}] = effects
    end

    test "duplicate in-flight id is rejected" do
      peer = ready_server()
      {peer, _} = Peer.ingest(peer, %Request{id: 2, method: "tools/list"})
      {_peer, effects} = Peer.ingest(peer, %Request{id: 2, method: "tools/list"})
      assert [{:send, %ErrorResponse{error: %{reason: :invalid_request}}}] = effects
    end

    test "respond clears tracking and answers once" do
      peer = ready_server()
      {peer, _} = Peer.ingest(peer, %Request{id: 2, method: "tools/list"})

      {peer, {:ok, %Response{id: 2}}} = Peer.respond(peer, 2, %{"tools" => []})
      assert {_peer, :drop} = Peer.respond(peer, 2, %{"tools" => []})
    end
  end

  describe "cancellation" do
    test "cancelling an in-flight request drops the eventual response" do
      peer = ready_server()
      {peer, _} = Peer.ingest(peer, %Request{id: 2, method: "tools/call"})

      cancel = %Notification{
        method: "notifications/cancelled",
        params: %{"requestId" => 2, "reason" => "user"}
      }

      {peer, effects} = Peer.ingest(peer, cancel)
      assert [{:cancel_in, 2, "user"}] = effects

      assert {_peer, :drop} = Peer.respond(peer, 2, %{})
    end

    test "cancelling an unknown request is ignored" do
      cancel = %Notification{method: "notifications/cancelled", params: %{"requestId" => 99}}
      assert {_peer, []} = Peer.ingest(ready_server(), cancel)
    end
  end

  describe "outbound requests" do
    test "request/resolve round-trip" do
      peer = ready_server()
      {peer, id, request} = Peer.request(peer, "roots/list", nil, tag: :roots)

      assert %Request{method: "roots/list", id: ^id} = request

      {peer, effects} = Peer.ingest(peer, %Response{id: id, result: %{"roots" => []}})
      assert [{:resolve, :roots, ^id, {:ok, %{"roots" => []}}}] = effects
      assert peer.pending_out == %{}
    end

    test "error responses resolve as errors" do
      peer = ready_server()
      {peer, id, _request} = Peer.request(peer, "roots/list", nil, tag: :roots)

      error_response = %ErrorResponse{id: id, error: Noizu.MCP.Error.internal("x")}
      {_peer, effects} = Peer.ingest(peer, error_response)
      assert [{:resolve, :roots, ^id, {:error, %{code: -32_603}}}] = effects
    end

    test "late response after cancel_out is ignored" do
      peer = ready_server()
      {peer, id, _request} = Peer.request(peer, "roots/list", nil, tag: :roots)
      {peer, %Notification{method: "notifications/cancelled"}, :roots} = Peer.cancel_out(peer, id)

      assert {_peer, []} = Peer.ingest(peer, %Response{id: id, result: %{}})
    end

    test "unknown response id is ignored" do
      assert {_peer, []} = Peer.ingest(ready_server(), %Response{id: 12_345, result: %{}})
    end

    test "progress notifications route by token" do
      peer = ready_server()
      {peer, id, request} = Peer.request(peer, "x/y", %{}, tag: :t, progress_token: "tok-1")

      assert request.params["_meta"]["progressToken"] == "tok-1"

      progress = %Notification{
        method: "notifications/progress",
        params: %{"progressToken" => "tok-1", "progress" => 0.5}
      }

      {_peer, effects} = Peer.ingest(peer, progress)
      assert [{:progress, :t, ^id, %{"progress" => 0.5}}] = effects
    end

    test "unknown progress token is ignored" do
      progress = %Notification{
        method: "notifications/progress",
        params: %{"progressToken" => "nope", "progress" => 0.5}
      }

      assert {_peer, []} = Peer.ingest(ready_server(), progress)
    end
  end

  describe "client handshake" do
    defp client_peer do
      Peer.new(role: :client, info: %Implementation{name: "client", version: "1.0.0"})
    end

    test "full handshake" do
      {peer, request} = Peer.init_request(client_peer())
      assert request.method == "initialize"
      assert peer.phase == :initializing

      response = %Response{
        id: request.id,
        result: %{
          "protocolVersion" => "2025-11-25",
          "capabilities" => %{"tools" => %{}},
          "serverInfo" => %{"name" => "s", "version" => "2"}
        }
      }

      {peer, effects} = Peer.ingest(peer, response)
      assert [{:initialize_result, _}] = effects
      assert peer.protocol_version == "2025-11-25"
      assert peer.remote_info.name == "s"

      {peer, notification, effects} = Peer.initialized(peer)
      assert notification.method == "notifications/initialized"
      assert peer.phase == :ready
      assert [{:ready, _}] = effects
    end

    test "unsupported negotiated version fails initialization" do
      {peer, request} = Peer.init_request(client_peer())

      response = %Response{id: request.id, result: %{"protocolVersion" => "1999-01-01"}}
      {peer, effects} = Peer.ingest(peer, response)

      assert [{:initialize_failed, {:unsupported_version, "1999-01-01"}}] = effects
      assert peer.phase == :closing
    end
  end
end
