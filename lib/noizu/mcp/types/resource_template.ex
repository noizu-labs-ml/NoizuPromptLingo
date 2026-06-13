defmodule Noizu.MCP.Types.ResourceTemplate do
  @moduledoc "An MCP resource template (`resources/templates/list`), RFC 6570 URI template."

  @type t :: %__MODULE__{
          uri_template: String.t(),
          name: String.t() | nil,
          title: String.t() | nil,
          description: String.t() | nil,
          mime_type: String.t() | nil,
          annotations: map() | nil,
          icons: [map()] | nil,
          meta: map() | nil
        }

  @enforce_keys [:uri_template]
  defstruct [:uri_template, :name, :title, :description, :mime_type, :annotations, :icons, :meta]

  @spec to_map(t()) :: map()
  def to_map(%__MODULE__{} = template) do
    %{"uriTemplate" => template.uri_template, "name" => template.name || template.uri_template}
    |> put_unless_nil("title", template.title)
    |> put_unless_nil("description", template.description)
    |> put_unless_nil("mimeType", template.mime_type)
    |> put_unless_nil("annotations", template.annotations)
    |> put_unless_nil("icons", template.icons)
    |> put_unless_nil("_meta", template.meta)
  end

  @spec from_map(map()) :: t()
  def from_map(%{"uriTemplate" => uri_template} = map) do
    %__MODULE__{
      uri_template: uri_template,
      name: map["name"],
      title: map["title"],
      description: map["description"],
      mime_type: map["mimeType"],
      annotations: map["annotations"],
      icons: map["icons"],
      meta: map["_meta"]
    }
  end

  defp put_unless_nil(map, _key, nil), do: map
  defp put_unless_nil(map, key, value), do: Map.put(map, key, value)
end
