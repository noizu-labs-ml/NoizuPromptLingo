defmodule Noizu.MCP.Types.Prompt do
  @moduledoc "An MCP prompt definition as advertised by `prompts/list`."

  defmodule Argument do
    @moduledoc "A prompt argument (protocol-level string key/value)."

    @type t :: %__MODULE__{
            name: String.t(),
            title: String.t() | nil,
            description: String.t() | nil,
            required: boolean()
          }

    @enforce_keys [:name]
    defstruct [:name, :title, :description, required: false]

    @spec to_map(t()) :: map()
    def to_map(%__MODULE__{} = argument) do
      %{"name" => argument.name}
      |> then(&if argument.title, do: Map.put(&1, "title", argument.title), else: &1)
      |> then(
        &if argument.description, do: Map.put(&1, "description", argument.description), else: &1
      )
      |> then(&if argument.required, do: Map.put(&1, "required", true), else: &1)
    end

    @spec from_map(map()) :: t()
    def from_map(%{"name" => name} = map) do
      %__MODULE__{
        name: name,
        title: map["title"],
        description: map["description"],
        required: map["required"] == true
      }
    end
  end

  @type t :: %__MODULE__{
          name: String.t(),
          title: String.t() | nil,
          description: String.t() | nil,
          arguments: [Argument.t()],
          icons: [map()] | nil,
          meta: map() | nil
        }

  @enforce_keys [:name]
  defstruct [:name, :title, :description, :icons, :meta, arguments: []]

  @spec to_map(t()) :: map()
  def to_map(%__MODULE__{} = prompt) do
    %{"name" => prompt.name}
    |> put_unless_nil("title", prompt.title)
    |> put_unless_nil("description", prompt.description)
    |> then(fn map ->
      case prompt.arguments do
        [] -> map
        arguments -> Map.put(map, "arguments", Enum.map(arguments, &Argument.to_map/1))
      end
    end)
    |> put_unless_nil("icons", prompt.icons)
    |> put_unless_nil("_meta", prompt.meta)
  end

  @spec from_map(map()) :: t()
  def from_map(%{"name" => name} = map) do
    %__MODULE__{
      name: name,
      title: map["title"],
      description: map["description"],
      arguments: Enum.map(map["arguments"] || [], &Argument.from_map/1),
      icons: map["icons"],
      meta: map["_meta"]
    }
  end

  defp put_unless_nil(map, _key, nil), do: map
  defp put_unless_nil(map, key, value), do: Map.put(map, key, value)
end
