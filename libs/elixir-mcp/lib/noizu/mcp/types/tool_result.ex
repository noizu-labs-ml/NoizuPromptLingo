defmodule Noizu.MCP.Types.ToolResult do
  @moduledoc """
  The result of a `tools/call` — content blocks, optional structured content,
  and the `isError` execution-error flag.
  """

  alias Noizu.MCP.Types.Content

  @type t :: %__MODULE__{
          content: [Content.t()],
          structured: map() | nil,
          is_error: boolean(),
          meta: map() | nil
        }

  defstruct content: [], structured: nil, is_error: false, meta: nil

  @doc "Successful result from content blocks, a binary, or a structured map."
  @spec ok([Content.t()] | Content.t() | String.t()) :: t()
  def ok(%Content{} = content), do: %__MODULE__{content: [content]}
  def ok(content) when is_list(content), do: %__MODULE__{content: content}
  def ok(text) when is_binary(text), do: %__MODULE__{content: [Content.text(text)]}

  @doc """
  Successful structured result. Includes a JSON-serialized text block alongside
  `structuredContent` for backward compatibility, as the spec requires.
  """
  @spec structured(map()) :: t()
  def structured(%{} = value) do
    %__MODULE__{content: [Content.text(Jason.encode!(value))], structured: value}
  end

  @doc "Tool *execution* error (`isError: true`) — visible to the model."
  @spec error([Content.t()] | Content.t() | String.t()) :: t()
  def error(content), do: %{ok(content) | is_error: true}

  @spec ok?(t()) :: boolean()
  def ok?(%__MODULE__{is_error: is_error}), do: not is_error

  @spec to_map(t()) :: map()
  def to_map(%__MODULE__{} = result) do
    %{"content" => Enum.map(result.content, &Content.to_map/1)}
    |> put_unless_nil("structuredContent", result.structured)
    |> put_unless_nil("_meta", result.meta)
    |> then(fn map ->
      if result.is_error, do: Map.put(map, "isError", true), else: map
    end)
  end

  @spec from_map(map()) :: t()
  def from_map(%{} = map) do
    %__MODULE__{
      content: Enum.map(map["content"] || [], &Content.from_map/1),
      structured: map["structuredContent"],
      is_error: map["isError"] == true,
      meta: map["_meta"]
    }
  end

  defp put_unless_nil(map, _key, nil), do: map
  defp put_unless_nil(map, key, value), do: Map.put(map, key, value)
end
