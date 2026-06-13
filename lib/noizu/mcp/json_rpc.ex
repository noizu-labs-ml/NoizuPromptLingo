defmodule Noizu.MCP.JsonRpc do
  @moduledoc """
  JSON-RPC 2.0 framing for MCP.

  Pure data layer: decodes a wire binary into one of four message structs and
  encodes them back. Per MCP 2025-06-18+ JSON-RPC batching is **not** supported —
  arrays are rejected as invalid requests.
  """

  alias Noizu.MCP.Error

  defmodule Request do
    @moduledoc "An inbound or outbound JSON-RPC request (expects a response)."
    @type t :: %__MODULE__{id: integer() | String.t(), method: String.t(), params: map() | nil}
    @enforce_keys [:id, :method]
    defstruct [:id, :method, params: nil]
  end

  defmodule Notification do
    @moduledoc "A JSON-RPC notification (no response expected)."
    @type t :: %__MODULE__{method: String.t(), params: map() | nil}
    @enforce_keys [:method]
    defstruct [:method, params: nil]
  end

  defmodule Response do
    @moduledoc "A successful JSON-RPC response."
    @type t :: %__MODULE__{id: integer() | String.t(), result: map()}
    @enforce_keys [:id]
    defstruct [:id, result: %{}]
  end

  defmodule ErrorResponse do
    @moduledoc "A JSON-RPC error response."
    @type t :: %__MODULE__{id: integer() | String.t() | nil, error: Noizu.MCP.Error.t()}
    @enforce_keys [:error]
    defstruct [:id, :error]
  end

  @type id :: integer() | String.t()
  @type message :: Request.t() | Notification.t() | Response.t() | ErrorResponse.t()

  @doc """
  Decode a wire binary into a message struct.

  Returns `{:error, %ErrorResponse{}}` pre-shaped for replying to the sender when
  the payload is malformed (parse error / invalid request).
  """
  @spec decode(binary()) :: {:ok, message()} | {:error, ErrorResponse.t()}
  def decode(binary) when is_binary(binary) do
    case Jason.decode(binary) do
      {:ok, decoded} -> classify(decoded)
      {:error, _} -> {:error, %ErrorResponse{id: nil, error: Error.parse_error()}}
    end
  end

  defp classify(list) when is_list(list) do
    {:error,
     %ErrorResponse{
       id: nil,
       error: Error.invalid_request("JSON-RPC batching is not supported by MCP")
     }}
  end

  defp classify(%{"jsonrpc" => "2.0"} = map), do: classify_message(map)

  defp classify(_other) do
    {:error,
     %ErrorResponse{id: nil, error: Error.invalid_request("Expected a JSON-RPC 2.0 object")}}
  end

  defp classify_message(%{"method" => method} = map) when is_binary(method) do
    params = validate_params(map["params"])

    case {Map.fetch(map, "id"), params} do
      {_, :invalid} ->
        {:error,
         %ErrorResponse{
           id: valid_id(map["id"]),
           error: Error.invalid_request("params must be an object")
         }}

      {{:ok, id}, params} when is_integer(id) or is_binary(id) ->
        {:ok, %Request{id: id, method: method, params: params}}

      {{:ok, _bad_id}, _} ->
        {:error,
         %ErrorResponse{id: nil, error: Error.invalid_request("id must be a string or integer")}}

      {:error, params} ->
        {:ok, %Notification{method: method, params: params}}
    end
  end

  defp classify_message(%{"id" => id, "error" => %{} = error})
       when is_integer(id) or is_binary(id) do
    {:ok, %ErrorResponse{id: id, error: Error.from_map(error)}}
  end

  defp classify_message(%{"id" => id, "result" => result})
       when (is_integer(id) or is_binary(id)) and is_map(result) do
    {:ok, %Response{id: id, result: result}}
  end

  defp classify_message(map) do
    {:error,
     %ErrorResponse{
       id: valid_id(map["id"]),
       error: Error.invalid_request("Not a valid JSON-RPC request, notification, or response")
     }}
  end

  defp validate_params(nil), do: nil
  defp validate_params(%{} = params), do: params
  defp validate_params(_), do: :invalid

  defp valid_id(id) when is_integer(id) or is_binary(id), do: id
  defp valid_id(_), do: nil

  @doc "Encode a message struct to wire iodata."
  @spec encode!(message()) :: iodata()
  def encode!(message), do: Jason.encode_to_iodata!(to_map(message))

  @doc "Render a message struct as a plain map (without JSON encoding)."
  @spec to_map(message()) :: map()
  def to_map(%Request{id: id, method: method, params: params}) do
    %{"jsonrpc" => "2.0", "id" => id, "method" => method}
    |> put_unless_nil("params", params)
  end

  def to_map(%Notification{method: method, params: params}) do
    %{"jsonrpc" => "2.0", "method" => method}
    |> put_unless_nil("params", params)
  end

  def to_map(%Response{id: id, result: result}) do
    %{"jsonrpc" => "2.0", "id" => id, "result" => result || %{}}
  end

  def to_map(%ErrorResponse{id: id, error: error}) do
    %{"jsonrpc" => "2.0", "id" => id, "error" => Error.to_map(error)}
  end

  defp put_unless_nil(map, _key, nil), do: map
  defp put_unless_nil(map, key, value), do: Map.put(map, key, value)
end
