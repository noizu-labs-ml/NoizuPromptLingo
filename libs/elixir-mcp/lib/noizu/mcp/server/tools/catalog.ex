defmodule Noizu.MCP.Server.Tools.Catalog do
  @moduledoc """
  Built-in catalog discovery tool.

  Lets agents discover all registered MCP items, including those hidden from
  normal listings. Register it on a server with:

      tool Noizu.MCP.Server.Tools.Catalog

  or, to keep the catalog itself out of `tools/list`:

      tool Noizu.MCP.Server.Tools.Catalog, hidden: true

  Hidden items never appear in `tools/list` / `prompts/list` / `resources/list`
  responses, but remain callable by name via `tools/call`, `prompts/get`, and
  `resources/read`. The catalog gives agents the full wire definitions
  (including input schemas) they need to do so.

  ## Arguments

    * `type` — `"tools"` | `"prompts"` | `"resources"` | `"resource_templates"`
      | `"all"` (default)
    * `query` — optional case-insensitive substring filter applied to name,
      description, and URI
    * `category` — optional exact (case-insensitive) match on the category
      label; applies only to entries that carry one (tools declared with
      `category:`), all others are dropped from the result
    * `include_hidden` — `true` (default) to include hidden items; `false` for
      visible-only

  ## Result

  Structured content with one key per requested section. Each entry is the
  item's full wire definition plus a `"hidden"` boolean; tool entries also
  carry a top-level `"category"` when one was declared:

      %{
        "tools" => [%{"name" => "echo", "inputSchema" => %{...}, "hidden" => false,
                      "category" => "Utility"}, ...],
        "prompts" => [...],
        "resources" => [...],
        "resource_templates" => [...]
      }

  Only works against servers whose registries come from the `tool`/`prompt`/
  `resource`/`resource_template` DSL macros (it reads `server.__mcp__/1`).
  """

  use Noizu.MCP.Server.Tool,
    name: "catalog",
    description:
      "Discover all registered MCP items including hidden tools, prompts, resources, and resource templates. Returns full definitions (with input schemas) plus a `hidden` flag per entry; hidden items are callable by name even though they are omitted from tools/list."

  input_schema %{
    "type" => "object",
    "properties" => %{
      "type" => %{
        "type" => "string",
        "enum" => ["tools", "prompts", "resources", "resource_templates", "all"],
        "default" => "all",
        "description" => "Which category of items to list"
      },
      "query" => %{
        "type" => "string",
        "description" => "Case-insensitive substring filter on name, description, and URI"
      },
      "category" => %{
        "type" => "string",
        "description" =>
          "Exact case-insensitive match on the category label; only entries that carry a category are matched"
      },
      "include_hidden" => %{
        "type" => "boolean",
        "default" => true,
        "description" => "When true (default), include items hidden from normal listings"
      }
    }
  }

  alias Noizu.MCP.Server.Features
  alias Noizu.MCP.Types

  @impl true
  def call(args, ctx) do
    type = args["type"] || "all"
    query = args["query"]
    category = args["category"]
    include_hidden = Map.get(args, "include_hidden", true)
    server = ctx.server

    sections =
      case type do
        "tools" ->
          %{"tools" => tools(server)}

        "prompts" ->
          %{"prompts" => prompts(server)}

        "resources" ->
          %{"resources" => resources(server)}

        "resource_templates" ->
          %{"resource_templates" => resource_templates(server)}

        _ ->
          %{
            "tools" => tools(server),
            "prompts" => prompts(server),
            "resources" => resources(server),
            "resource_templates" => resource_templates(server)
          }
      end

    sections =
      Map.new(sections, fn {key, items} ->
        items =
          items
          |> then(fn items ->
            if include_hidden, do: items, else: Enum.reject(items, & &1["hidden"])
          end)
          |> then(fn items ->
            if query,
              do: Enum.filter(items, &matches_query?(&1, String.downcase(query))),
              else: items
          end)
          |> then(fn items ->
            if category, do: Enum.filter(items, &matches_category?(&1, category)), else: items
          end)

        {key, items}
      end)

    {:ok, sections}
  end

  defp tools(server) do
    server.__mcp__(:tools)
    |> Features.Tools.expand()
    |> Enum.map(fn spec ->
      map =
        spec.definition
        |> Types.Tool.to_map()
        |> Map.put("hidden", spec.hidden)

      case spec.definition.meta && spec.definition.meta["category"] do
        nil -> map
        category -> Map.put(map, "category", category)
      end
    end)
  end

  defp prompts(server) do
    Enum.map(server.__mcp__(:prompts), fn {module, opts} = entry ->
      Features.Prompts.definition(module, opts)
      |> Types.Prompt.to_map()
      |> Map.put("hidden", Features.Prompts.hidden?(entry))
    end)
  end

  defp resources(server) do
    Enum.map(server.__mcp__(:resources), fn {module, opts} = entry ->
      Features.Resources.definition(module, opts)
      |> Types.Resource.to_map()
      |> Map.put("hidden", Features.Resources.hidden?(entry))
    end)
  end

  defp resource_templates(server) do
    Enum.map(server.__mcp__(:resource_templates), fn {module, _opts} = entry ->
      module.definition()
      |> Types.ResourceTemplate.to_map()
      |> Map.put("hidden", Features.Resources.hidden_template?(entry))
    end)
  end

  defp matches_query?(item, q) do
    ["name", "description", "uri", "uriTemplate"]
    |> Enum.any?(fn key ->
      case item[key] do
        value when is_binary(value) -> String.contains?(String.downcase(value), q)
        _ -> false
      end
    end)
  end

  defp matches_category?(item, category) do
    case item["category"] do
      value when is_binary(value) -> String.downcase(value) == String.downcase(category)
      _ -> false
    end
  end
end
