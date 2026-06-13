defmodule Noizu.MCP.Types.Resource do
  @moduledoc "An MCP resource definition as advertised by `resources/list`."

  @type t :: %__MODULE__{
          uri: String.t(),
          name: String.t() | nil,
          title: String.t() | nil,
          description: String.t() | nil,
          mime_type: String.t() | nil,
          size: non_neg_integer() | nil,
          annotations: map() | nil,
          icons: [map()] | nil,
          meta: map() | nil
        }

  @enforce_keys [:uri]
  defstruct [:uri, :name, :title, :description, :mime_type, :size, :annotations, :icons, :meta]

  @spec to_map(t()) :: map()
  def to_map(%__MODULE__{} = resource) do
    %{"uri" => resource.uri, "name" => resource.name || resource.uri}
    |> put_unless_nil("title", resource.title)
    |> put_unless_nil("description", resource.description)
    |> put_unless_nil("mimeType", resource.mime_type)
    |> put_unless_nil("size", resource.size)
    |> put_unless_nil("annotations", resource.annotations)
    |> put_unless_nil("icons", resource.icons)
    |> put_unless_nil("_meta", resource.meta)
  end

  @spec from_map(map()) :: t()
  def from_map(%{"uri" => uri} = map) do
    %__MODULE__{
      uri: uri,
      name: map["name"],
      title: map["title"],
      description: map["description"],
      mime_type: map["mimeType"],
      size: map["size"],
      annotations: map["annotations"],
      icons: map["icons"],
      meta: map["_meta"]
    }
  end

  defp put_unless_nil(map, _key, nil), do: map
  defp put_unless_nil(map, key, value), do: Map.put(map, key, value)
end
