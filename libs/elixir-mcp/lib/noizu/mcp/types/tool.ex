defmodule Noizu.MCP.Types.Tool do
  @moduledoc """
  An MCP tool definition as advertised by `tools/list`.

  `annotations` accepts snake_case atom keys (`:read_only_hint`,
  `:destructive_hint`, `:idempotent_hint`, `:open_world_hint`, `:title`) and
  renders them in the camelCase wire format.
  """

  @type t :: %__MODULE__{
          name: String.t(),
          title: String.t() | nil,
          description: String.t() | nil,
          input_schema: map(),
          output_schema: map() | nil,
          annotations: map() | keyword() | nil,
          icons: [map()] | nil,
          meta: map() | nil
        }

  @enforce_keys [:name]
  defstruct [
    :name,
    :title,
    :description,
    :output_schema,
    :annotations,
    :icons,
    :meta,
    input_schema: %{"type" => "object"}
  ]

  @annotation_keys %{
    title: "title",
    read_only_hint: "readOnlyHint",
    destructive_hint: "destructiveHint",
    idempotent_hint: "idempotentHint",
    open_world_hint: "openWorldHint"
  }

  @spec to_map(t()) :: map()
  def to_map(%__MODULE__{} = tool) do
    %{"name" => tool.name, "inputSchema" => tool.input_schema}
    |> put_unless_nil("title", tool.title)
    |> put_unless_nil("description", tool.description)
    |> put_unless_nil("outputSchema", tool.output_schema)
    |> put_unless_nil("annotations", encode_annotations(tool.annotations))
    |> put_unless_nil("icons", tool.icons)
    |> put_unless_nil("_meta", tool.meta)
  end

  @spec from_map(map()) :: t()
  def from_map(%{"name" => name} = map) do
    %__MODULE__{
      name: name,
      title: map["title"],
      description: map["description"],
      input_schema: map["inputSchema"] || %{"type" => "object"},
      output_schema: map["outputSchema"],
      annotations: map["annotations"],
      icons: map["icons"],
      meta: map["_meta"]
    }
  end

  defp encode_annotations(nil), do: nil
  defp encode_annotations(%{} = annotations), do: annotations

  defp encode_annotations(annotations) when is_list(annotations) do
    Map.new(annotations, fn {key, value} ->
      case Map.fetch(@annotation_keys, key) do
        {:ok, wire_key} -> {wire_key, value}
        :error -> raise ArgumentError, "unknown tool annotation: #{inspect(key)}"
      end
    end)
  end

  defp put_unless_nil(map, _key, nil), do: map
  defp put_unless_nil(map, key, value), do: Map.put(map, key, value)
end
