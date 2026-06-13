defmodule Noizu.MCP.Error do
  @moduledoc """
  Protocol-level MCP / JSON-RPC error.

  Returned as `{:error, %Noizu.MCP.Error{}}` from handlers to produce a JSON-RPC
  error response. Distinct from *tool execution errors* — return
  `{:error, "message"}` from a tool handler to produce an `isError: true` tool
  result the model can read and self-correct from.

  Use the constructors (`invalid_params/2`, `resource_not_found/1`, `custom/3`, …)
  rather than building the struct by hand so spec error codes stay consistent.
  """

  @type t :: %__MODULE__{
          code: integer(),
          message: String.t(),
          data: term(),
          reason: atom() | nil
        }

  defexception [:code, :message, :data, :reason]

  # JSON-RPC reserved codes
  @parse_error -32_700
  @invalid_request -32_600
  @method_not_found -32_601
  @invalid_params -32_602
  @internal_error -32_603
  # MCP server-specific codes
  @resource_not_found -32_002

  @impl Exception
  def message(%__MODULE__{message: message, code: code}), do: "MCP error #{code}: #{message}"

  @spec parse_error(String.t()) :: t()
  def parse_error(message \\ "Parse error"),
    do: %__MODULE__{code: @parse_error, message: message, reason: :parse_error}

  @spec invalid_request(String.t()) :: t()
  def invalid_request(message \\ "Invalid request"),
    do: %__MODULE__{code: @invalid_request, message: message, reason: :invalid_request}

  @spec method_not_found(String.t()) :: t()
  def method_not_found(method) when is_binary(method) do
    %__MODULE__{
      code: @method_not_found,
      message: "Method not found: #{method}",
      reason: :method_not_found
    }
  end

  @spec invalid_params(String.t(), term()) :: t()
  def invalid_params(message \\ "Invalid params", data \\ nil),
    do: %__MODULE__{code: @invalid_params, message: message, data: data, reason: :invalid_params}

  @spec internal(String.t(), term()) :: t()
  def internal(message \\ "Internal error", data \\ nil),
    do: %__MODULE__{code: @internal_error, message: message, data: data, reason: :internal}

  @spec resource_not_found(String.t()) :: t()
  def resource_not_found(uri) do
    %__MODULE__{
      code: @resource_not_found,
      message: "Resource not found",
      data: %{"uri" => uri},
      reason: :resource_not_found
    }
  end

  @spec capability_not_supported(atom() | String.t()) :: t()
  def capability_not_supported(capability) do
    %__MODULE__{
      code: @invalid_request,
      message: "Capability not supported: #{capability}",
      reason: :capability_not_supported
    }
  end

  @doc "Application-defined error. Codes above -32000 are reserved for the protocol."
  @spec custom(integer(), String.t(), term()) :: t()
  def custom(code, message, data \\ nil) when is_integer(code) and is_binary(message),
    do: %__MODULE__{code: code, message: message, data: data, reason: :custom}

  @doc "Build from a decoded JSON-RPC error object."
  @spec from_map(map()) :: t()
  def from_map(%{} = map) do
    %__MODULE__{
      code: map["code"],
      message: map["message"] || "",
      data: map["data"],
      reason: reason_for_code(map["code"])
    }
  end

  @doc "Render as a JSON-RPC error object map."
  @spec to_map(t()) :: map()
  def to_map(%__MODULE__{} = error) do
    %{"code" => error.code, "message" => error.message}
    |> then(fn map ->
      if is_nil(error.data), do: map, else: Map.put(map, "data", error.data)
    end)
  end

  defp reason_for_code(@parse_error), do: :parse_error
  defp reason_for_code(@invalid_request), do: :invalid_request
  defp reason_for_code(@method_not_found), do: :method_not_found
  defp reason_for_code(@invalid_params), do: :invalid_params
  defp reason_for_code(@internal_error), do: :internal
  defp reason_for_code(@resource_not_found), do: :resource_not_found
  defp reason_for_code(_), do: :custom
end
