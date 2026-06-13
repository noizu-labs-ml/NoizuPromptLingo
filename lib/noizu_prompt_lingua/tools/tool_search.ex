defmodule NoizuPromptLingua.Tools.ToolSearch do
  use Noizu.MCP.Server.Tool,
    name: "ToolSearch",
    description:
      "Search the tool catalog by substring match or LLM-powered intent matching. " <>
        "Returns ranked results with name, description, and category.",
    annotations: [read_only_hint: true],
    category: "Discovery"

  input do
    field :query, :string,
      required: true,
      description: "Search term or natural-language intent"

    field :mode, :enum,
      values: [:text, :intent],
      default: :text,
      description: "\"text\" for substring matching (default), \"intent\" for LLM-powered semantic search"

    field :limit, :integer,
      default: 10,
      description: "Max results to return (default 10)"
  end

  alias NoizuPromptLingua.Tools.Catalog

  @impl true
  def call(args, ctx) do
    query = args.query
    mode = Map.get(args, :mode, :text)
    limit = Map.get(args, :limit, 10)
    server = (ctx && ctx.server) || NoizuPromptLingua.MCP

    result =
      case mode do
        :intent -> intent_search(query, limit, server)
        _ -> text_search(query, limit, server)
      end

    {:ok, result}
  end

  defp text_search(query, limit, server) do
    catalog = Catalog.build(server)
    q = String.downcase(query)

    {exact, name_match, desc_match} =
      Enum.reduce(catalog, {[], [], []}, fn tool, {exact, names, descs} ->
        name_lower = String.downcase(tool.name)
        desc_lower = String.downcase(tool.description)

        cond do
          name_lower == q -> {[tool | exact], names, descs}
          String.contains?(name_lower, q) -> {exact, [tool | names], descs}
          String.contains?(desc_lower, q) -> {exact, names, [tool | descs]}
          true -> {exact, names, descs}
        end
      end)

    all = Enum.reverse(exact) ++ Enum.reverse(name_match) ++ Enum.reverse(desc_match)
    matches = Enum.take(all, limit)

    %{
      mode: "text",
      query: query,
      total_matches: length(all),
      matches:
        Enum.map(matches, fn t ->
          %{name: t.name, category: t.category, description: t.description}
        end)
    }
  end

  defp intent_search(query, limit, server) do
    case text_search(query, limit, server) do
      result ->
        Map.merge(result, %{
          mode: "intent",
          fallback: true,
          fallback_reason: "LLM intent search not yet configured — using text search"
        })
    end
  end
end
