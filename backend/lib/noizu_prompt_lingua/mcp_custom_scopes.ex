defmodule NoizuPromptLingua.MCPCustomScopes do
  @moduledoc """
  CRUD and config helpers for custom MCP include scopes.
  """
  import Ecto.Query, only: [order_by: 3]

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.MCPCustomScope
  alias NoizuPromptLingua.Tools.Catalog

  def list do
    MCPCustomScope
    |> order_by([s], asc: s.name)
    |> Repo.all()
  end

  def get_by_slug(slug) when is_binary(slug) do
    Repo.get_by(MCPCustomScope, slug: normalize_slug(slug))
  end

  def create(attrs) do
    %MCPCustomScope{}
    |> MCPCustomScope.changeset(normalize_attrs(attrs))
    |> Repo.insert()
  end

  def update(%MCPCustomScope{} = scope, attrs) do
    scope
    |> MCPCustomScope.changeset(normalize_attrs(attrs))
    |> Repo.update()
  end

  def update(slug, attrs) when is_binary(slug) do
    case get_by_slug(slug) do
      nil -> {:error, :not_found}
      scope -> update(scope, attrs)
    end
  end

  def delete(%MCPCustomScope{} = scope), do: Repo.delete(scope)

  def delete(slug) when is_binary(slug) do
    case get_by_slug(slug) do
      nil -> {:error, :not_found}
      scope -> Repo.delete(scope)
    end
  end

  def normalize_config(config) when is_map(config) do
    groups = Map.get(config, "groups") || Map.get(config, :groups) || %{}

    groups =
      groups
      |> Enum.reduce(%{}, fn {group_id, group_cfg}, acc ->
        group_id = to_string(group_id)

        if NoizuPromptLingua.MCPServers.server_module(group_id) do
          Map.put(acc, group_id, normalize_group_config(group_cfg || %{}))
        else
          acc
        end
      end)

    %{"groups" => groups}
  end

  def normalize_config(_), do: %{"groups" => %{}}

  def catalog do
    NoizuPromptLingua.MCPServers.customizable()
    |> Enum.map(fn server ->
      module = NoizuPromptLingua.MCPServers.server_module(server.id)

      %{
        id: server.id,
        label: server.label,
        desc: server.desc,
        tools: Catalog.build(module) |> Enum.reject(&(&1.category == "Discovery"))
      }
    end)
  end

  def scope_json(%MCPCustomScope{} = scope, host \\ nil) do
    %{
      id: scope.id,
      slug: scope.slug,
      name: scope.name,
      description: scope.description,
      config: normalize_config(scope.config || %{}),
      url: host && NoizuPromptLingua.MCPServers.custom_url(scope.slug, host),
      inserted_at: scope.inserted_at,
      updated_at: scope.updated_at
    }
  end

  defp normalize_attrs(attrs) when is_map(attrs) do
    attrs =
      attrs
      |> Map.take(["slug", "name", "description", "config", :slug, :name, :description, :config])
      |> stringify_keys()

    case Map.fetch(attrs, "config") do
      {:ok, config} -> Map.put(attrs, "config", normalize_config(config))
      :error -> attrs
    end
  end

  defp normalize_attrs(_), do: %{}

  defp stringify_keys(map) do
    Map.new(map, fn {key, value} -> {to_string(key), value} end)
  end

  defp normalize_group_config(config) when is_map(config) do
    tools = Map.get(config, "tools") || Map.get(config, :tools) || %{}

    base =
      %{}
      |> put_bool("disabled", Map.get(config, "disabled", Map.get(config, :disabled)))
      |> put_bool("hidden", Map.get(config, "hidden", Map.get(config, :hidden)))

    Map.put(base, "tools", normalize_tools_config(tools))
  end

  defp normalize_group_config(_), do: %{"tools" => %{}}

  defp normalize_tools_config(tools) when is_map(tools) do
    Map.new(tools, fn {tool_name, cfg} ->
      {to_string(tool_name), normalize_tool_config(cfg || %{})}
    end)
  end

  defp normalize_tools_config(_), do: %{}

  defp normalize_tool_config(config) when is_map(config) do
    %{}
    |> put_bool("disabled", Map.get(config, "disabled", Map.get(config, :disabled)))
    |> put_bool("hidden", Map.get(config, "hidden", Map.get(config, :hidden)))
  end

  defp normalize_tool_config(_), do: %{}

  defp put_bool(map, _key, nil), do: map
  defp put_bool(map, key, value) when is_boolean(value), do: Map.put(map, key, value)
  defp put_bool(map, _key, _value), do: map

  defp normalize_slug(slug) do
    slug
    |> String.trim()
    |> String.downcase()
  end
end
