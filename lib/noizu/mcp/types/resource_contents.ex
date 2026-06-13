defmodule Noizu.MCP.Types.ResourceContents do
  @moduledoc """
  The contents of a read resource. Text resources carry `:text`; binary
  resources carry `:blob` (raw binary, base64-encoded on the wire).
  """

  @type t :: %__MODULE__{
          uri: String.t(),
          mime_type: String.t() | nil,
          text: String.t() | nil,
          blob: binary() | nil,
          meta: map() | nil
        }

  @enforce_keys [:uri]
  defstruct [:uri, :mime_type, :text, :blob, :meta]

  @spec text(String.t(), String.t(), keyword()) :: t()
  def text(uri, text, opts \\ []) do
    %__MODULE__{uri: uri, text: text, mime_type: opts[:mime_type], meta: opts[:meta]}
  end

  @spec blob(String.t(), binary(), keyword()) :: t()
  def blob(uri, blob, opts \\ []) do
    %__MODULE__{uri: uri, blob: blob, mime_type: opts[:mime_type], meta: opts[:meta]}
  end

  @spec to_map(t()) :: map()
  def to_map(%__MODULE__{} = contents) do
    %{"uri" => contents.uri}
    |> put_unless_nil("mimeType", contents.mime_type)
    |> put_unless_nil("text", contents.text)
    |> put_unless_nil("blob", contents.blob && Base.encode64(contents.blob))
    |> put_unless_nil("_meta", contents.meta)
  end

  @spec from_map(map()) :: t()
  def from_map(%{"uri" => uri} = map) do
    %__MODULE__{
      uri: uri,
      mime_type: map["mimeType"],
      text: map["text"],
      blob: decode_blob(map["blob"]),
      meta: map["_meta"]
    }
  end

  defp decode_blob(nil), do: nil

  defp decode_blob(blob) when is_binary(blob) do
    case Base.decode64(blob) do
      {:ok, decoded} -> decoded
      :error -> blob
    end
  end

  defp put_unless_nil(map, _key, nil), do: map
  defp put_unless_nil(map, key, value), do: Map.put(map, key, value)
end
