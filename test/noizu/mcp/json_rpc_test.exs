defmodule Noizu.MCP.JsonRpcTest do
  use ExUnit.Case, async: true

  alias Noizu.MCP.JsonRpc
  alias Noizu.MCP.JsonRpc.{ErrorResponse, Notification, Request, Response}

  describe "decode/1" do
    test "request" do
      assert {:ok, %Request{id: 1, method: "tools/list", params: %{"cursor" => "x"}}} =
               JsonRpc.decode(
                 ~s({"jsonrpc":"2.0","id":1,"method":"tools/list","params":{"cursor":"x"}})
               )
    end

    test "request with string id" do
      assert {:ok, %Request{id: "a-1"}} =
               JsonRpc.decode(~s({"jsonrpc":"2.0","id":"a-1","method":"ping"}))
    end

    test "notification" do
      assert {:ok, %Notification{method: "notifications/initialized", params: nil}} =
               JsonRpc.decode(~s({"jsonrpc":"2.0","method":"notifications/initialized"}))
    end

    test "response" do
      assert {:ok, %Response{id: 7, result: %{"ok" => true}}} =
               JsonRpc.decode(~s({"jsonrpc":"2.0","id":7,"result":{"ok":true}}))
    end

    test "error response" do
      assert {:ok, %ErrorResponse{id: 7, error: error}} =
               JsonRpc.decode(
                 ~s({"jsonrpc":"2.0","id":7,"error":{"code":-32601,"message":"nope"}})
               )

      assert error.code == -32_601
      assert error.reason == :method_not_found
    end

    test "malformed JSON is a parse error" do
      assert {:error, %ErrorResponse{id: nil, error: %{reason: :parse_error}}} =
               JsonRpc.decode("{nope")
    end

    test "batch arrays are rejected" do
      assert {:error, %ErrorResponse{error: error}} = JsonRpc.decode(~s([{"jsonrpc":"2.0"}]))
      assert error.message =~ "batching"
    end

    test "missing jsonrpc version is invalid" do
      assert {:error, %ErrorResponse{error: %{reason: :invalid_request}}} =
               JsonRpc.decode(~s({"id":1,"method":"ping"}))
    end

    test "non-object params are invalid" do
      assert {:error, %ErrorResponse{id: 1, error: %{reason: :invalid_request}}} =
               JsonRpc.decode(~s({"jsonrpc":"2.0","id":1,"method":"x","params":[1]}))
    end

    test "fractional id is invalid" do
      assert {:error, %ErrorResponse{id: nil}} =
               JsonRpc.decode(~s({"jsonrpc":"2.0","id":1.5,"method":"x"}))
    end
  end

  describe "encode!/1 round-trip" do
    test "request" do
      message = %Request{id: 3, method: "tools/call", params: %{"name" => "echo"}}

      assert {:ok, ^message} =
               message |> JsonRpc.encode!() |> IO.iodata_to_binary() |> JsonRpc.decode()
    end

    test "notification without params omits the key" do
      encoded =
        %Notification{method: "notifications/initialized"}
        |> JsonRpc.encode!()
        |> IO.iodata_to_binary()

      refute encoded =~ "params"
    end

    test "error response" do
      message = %ErrorResponse{id: 9, error: Noizu.MCP.Error.method_not_found("x")}

      assert {:ok, decoded} =
               message |> JsonRpc.encode!() |> IO.iodata_to_binary() |> JsonRpc.decode()

      assert %ErrorResponse{id: 9, error: %{code: -32_601}} = decoded
    end
  end
end
