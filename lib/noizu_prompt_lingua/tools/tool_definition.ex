defmodule NoizuPromptLingua.Tools.ToolDefinition do
  use Noizu.MCP.Server.Tool,
    name: "ToolDefinition",
    description:
      "Get the full parameter schema for one or more tools by name. " <>
        "Returns parameter names, types, required flags, and descriptions.",
    annotations: [read_only_hint: true],
    category: "Discovery"

  input do
    field :tool, :string,
      required: true,
      description: "Tool name or comma-separated list of tool names"
  end

  alias NoizuPromptLingua.Tools.Catalog

  @impl true
  def call(args, ctx) do
    tool_input = args.tool
    names = tool_input |> String.split(",") |> Enum.map(&String.trim/1)
    server = (ctx && ctx.server) || NoizuPromptLingua.MCP
    catalog = Catalog.build(server)
    by_name = Map.new(catalog, &{&1.name, &1})

    {definitions, not_found} =
      Enum.reduce(names, {[], []}, fn name, {defs, missing} ->
        resolved = Catalog.resolve_alias(name)

        case Map.get(by_name, resolved) do
          nil ->
            {defs, [name | missing]}

          entry ->
            defn = %{
              name: entry.name,
              category: entry.category,
              description: entry.description,
              parameters: entry.parameters
            }

            {[defn | defs], missing}
        end
      end)

    result = %{definitions: Enum.reverse(definitions)}

    case Enum.reverse(not_found) do
      [] -> {:ok, result}
      nf -> {:ok, Map.put(result, :not_found, nf)}
    end
  end
end
