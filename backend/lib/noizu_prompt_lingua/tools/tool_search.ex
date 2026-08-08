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
      description:
        "\"text\" for substring matching (default), \"intent\" for LLM-powered semantic search"

    field :limit, :integer,
      default: 10,
      description: "Max results to return (default 10)"
  end

  alias NoizuPromptLingua.Tools.Catalog
  alias NoizuPromptLingua.Domains.Memory.Embeddings
  alias NoizuPromptLingua.Domains.MCPOverview.{Store, Indexer}

  @impl true
  def call(args, ctx) do
    query = args.query
    mode = Map.get(args, :mode, :text)
    limit = Map.get(args, :limit, 10)
    server = (ctx && ctx.server) || NoizuPromptLingua.MCP

    result =
      case mode do
        :intent -> intent_search(query, limit, server, ctx)
        _ -> text_search(query, limit, server, ctx)
      end

    {:ok, result}
  end

  defp text_search(query, limit, server, ctx) do
    catalog = Catalog.build(server, ctx)
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

  # Embedding-proximity intent search over `mcp_tool_vectors` for the current scope.
  # Falls back (tagged) to substring search when embeddings are not configured.
  defp intent_search(query, limit, server, ctx) do
    if Embeddings.configured?() do
      embedding_search(query, limit, server, ctx)
    else
      text_fallback(query, limit, server, ctx)
    end
  end

  defp embedding_search(query, limit, server, ctx) do
    catalog = Catalog.build(server, ctx)
    specs = Enum.reject(catalog, &(&1.category == "Discovery"))
    scope = scope_slug(ctx)

    # Best-effort: ensure this scope's tool vectors exist / are current before ranking.
    Indexer.refresh(scope, specs)

    with {:ok, vec} <- Embeddings.embed_one(query),
         ranked when ranked != [] <- Store.nearest_tool_vectors(scope, vec, limit: limit) do
      by_name = Map.new(catalog, &{&1.name, &1})

      matches =
        ranked
        |> Enum.map(fn r -> {Map.get(by_name, r.tool_name), r.distance} end)
        |> Enum.reject(fn {tool, _} -> is_nil(tool) end)
        |> Enum.map(fn {t, dist} ->
          %{name: t.name, category: t.category, description: t.description, distance: dist}
        end)

      %{mode: "intent", query: query, total_matches: length(matches), matches: matches}
    else
      # No vectors yet (scope unindexed / embed failed) → tagged text fallback.
      _ -> text_fallback(query, limit, server, ctx)
    end
  end

  defp text_fallback(query, limit, server, ctx) do
    Map.merge(text_search(query, limit, server, ctx), %{
      mode: "intent",
      fallback: true,
      fallback_reason: "embedding intent search unavailable — using text search"
    })
  end

  defp scope_slug(%Noizu.MCP.Ctx{assigns: assigns}) do
    assigns[:custom_scope_slug] || assigns["custom_scope_slug"] || "root"
  end

  defp scope_slug(_), do: "root"
end
