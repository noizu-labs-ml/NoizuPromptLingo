defmodule NoizuPromptLingua.Tools.ToolSummary do
  use Noizu.MCP.Server.Tool,
    name: "ToolSummary",
    description:
      "Browse the tool catalog grouped by domain. Supports drilling into a specific " <>
        "domain or category, and inspecting individual tool details. " <>
        "Use ToolSummary() for all tools, ToolSummary(filter=\"Domain\") to drill in, " <>
        "or ToolSummary(filter=\"Domain#ToolName\") for a single tool's full definition.",
    annotations: [read_only_hint: true],
    category: "Discovery"

  input do
    field :filter, :string,
      description:
        "Domain, category, or Category#ToolName to drill into. " <>
          "Comma-separated for multiple. Empty returns all domains."
  end

  alias NoizuPromptLingua.Tools.Catalog

  @impl true
  def call(args, ctx) do
    filter = Map.get(args, :filter) || Map.get(args, "filter")
    server = (ctx && ctx.server) || NoizuPromptLingua.MCP
    {:ok, summary(filter, server, ctx)}
  end

  defp summary(nil, server, ctx), do: all_tools(server, ctx)

  defp summary(filter, server, ctx) do
    parts =
      filter
      |> String.split(",")
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))

    case parts do
      [single] -> resolve_single(single, server, ctx)
      multiple -> %{results: Enum.map(multiple, &resolve_single(&1, server, ctx))}
    end
  end

  defp resolve_single(value, server, ctx) do
    if String.contains?(value, "#") do
      get_tool(value, server, ctx)
    else
      expand_category(value, server, ctx)
    end
  end

  defp all_tools(server, ctx) do
    catalog = Catalog.build(server, ctx)
    tools = Enum.reject(catalog, &(&1.category == "Discovery"))

    by_cat =
      tools
      |> Enum.group_by(& &1.category)
      |> Enum.sort_by(&elem(&1, 0))
      |> Enum.map(fn {cat_name, cat_tools} ->
        %{
          category: cat_name,
          tools:
            Enum.map(cat_tools, fn t ->
              %{name: t.name, description: t.description}
            end)
        }
      end)

    %{
      total_tools: length(tools),
      categories: by_cat,
      hint:
        "Use ToolSummary(filter='CategoryName') to explore, or ToolDefinition for full parameter info."
    }
  end

  defp get_tool(path, server, ctx) do
    [cat_path, tool_name] = String.split(path, "#", parts: 2)
    catalog = Catalog.build(server, ctx)

    entry =
      Enum.find(catalog, fn t -> t.name == tool_name and t.category == cat_path end) ||
        Enum.find(catalog, fn t -> t.name == tool_name end)

    case entry do
      nil ->
        %{error: "Tool '#{tool_name}' not found in category '#{cat_path}'."}

      t ->
        %{
          name: t.name,
          category: t.category,
          description: t.description,
          parameters: t.parameters
        }
    end
  end

  defp expand_category(category, server, ctx) do
    catalog = Catalog.build(server, ctx)
    prefix = category <> "."

    direct = Enum.filter(catalog, &(&1.category == category))
    sub = Enum.filter(catalog, &String.starts_with?(&1.category, prefix))

    if direct == [] and sub == [] do
      %{error: "Category '#{category}' not found."}
    else
      result = %{
        category: category,
        tool_count: length(direct) + length(sub)
      }

      result =
        if direct != [] do
          Map.put(
            result,
            :tools,
            Enum.map(direct, &%{name: &1.name, description: &1.description})
          )
        else
          result
        end

      subcats = collect_subcategories(category, sub)

      if subcats != [] do
        Map.put(result, :subcategories, subcats)
      else
        result
      end
    end
  end

  defp collect_subcategories(parent, tools) do
    depth = length(String.split(parent, "."))

    tools
    |> Enum.group_by(fn tool ->
      parts = String.split(tool.category, ".")
      Enum.take(parts, depth + 1) |> Enum.join(".")
    end)
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map(fn {sub_name, sub_tools} ->
      %{name: sub_name, tool_count: length(sub_tools)}
    end)
  end
end
