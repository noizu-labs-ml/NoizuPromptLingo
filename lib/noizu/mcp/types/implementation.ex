defmodule Noizu.MCP.Types.Implementation do
  @moduledoc "Identity of an MCP client or server (`clientInfo` / `serverInfo`)."

  @type t :: %__MODULE__{
          name: String.t(),
          version: String.t(),
          title: String.t() | nil,
          description: String.t() | nil,
          website_url: String.t() | nil,
          icons: [map()] | nil
        }

  @enforce_keys [:name, :version]
  defstruct [:name, :version, :title, :description, :website_url, :icons]

  @spec to_map(t()) :: map()
  def to_map(%__MODULE__{} = impl) do
    %{"name" => impl.name, "version" => impl.version}
    |> put_unless_nil("title", impl.title)
    |> put_unless_nil("description", impl.description)
    |> put_unless_nil("websiteUrl", impl.website_url)
    |> put_unless_nil("icons", impl.icons)
  end

  @spec from_map(map()) :: t()
  def from_map(%{} = map) do
    %__MODULE__{
      name: map["name"] || "unknown",
      version: map["version"] || "0.0.0",
      title: map["title"],
      description: map["description"],
      website_url: map["websiteUrl"],
      icons: map["icons"]
    }
  end

  defp put_unless_nil(map, _key, nil), do: map
  defp put_unless_nil(map, key, value), do: Map.put(map, key, value)
end
