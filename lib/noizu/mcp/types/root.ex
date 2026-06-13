defmodule Noizu.MCP.Types.Root do
  @moduledoc "A filesystem root exposed by an MCP client (`roots/list`)."

  @type t :: %__MODULE__{uri: String.t(), name: String.t() | nil, meta: map() | nil}

  @enforce_keys [:uri]
  defstruct [:uri, :name, :meta]

  @spec new(String.t(), keyword()) :: t()
  def new(uri, opts \\ []) when is_binary(uri) do
    %__MODULE__{uri: uri, name: opts[:name], meta: opts[:meta]}
  end

  @spec to_map(t()) :: map()
  def to_map(%__MODULE__{} = root) do
    %{"uri" => root.uri}
    |> then(&if root.name, do: Map.put(&1, "name", root.name), else: &1)
    |> then(&if root.meta, do: Map.put(&1, "_meta", root.meta), else: &1)
  end

  @spec from_map(map()) :: t()
  def from_map(%{"uri" => uri} = map) do
    %__MODULE__{uri: uri, name: map["name"], meta: map["_meta"]}
  end
end
