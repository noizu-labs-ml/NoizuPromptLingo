defmodule NoizuPromptLingua.Domains.Wiki.Tools.ListPages do
  use Noizu.MCP.Server.Tool, name: "Wiki.ListPages",
    description: "List pages with filters.", hidden: true, category: "Wiki",
    annotations: [read_only_hint: true]

  input do
    field :space_id, :string, description: "Filter by space UUID"
    field :tag, :string, description: "Filter by tag"
    field :parent_page_id, :string, description: "Filter by parent page"
    field :search, :string, description: "Search in title"
    field :limit, :integer, description: "Max results (default 50)"
    field :offset, :integer, description: "Pagination offset"
  end

  alias NoizuPromptLingua.Domains.Wiki

  @impl true
  def call(args, _ctx) do
    opts = Enum.reduce([:space_id, :tag, :parent_page_id, :search, :limit, :offset], [], fn k, acc ->
      val = args[k] || args[Atom.to_string(k)]
      if val, do: [{k, val} | acc], else: acc
    end)
    pages = Wiki.list_pages(opts)
    {:ok, %{pages: Enum.map(pages, &%{id: &1.id, title: &1.title, slug: &1.slug, tags: &1.tags, updated_at: &1.updated_at}), count: length(pages)}}
  end
end
