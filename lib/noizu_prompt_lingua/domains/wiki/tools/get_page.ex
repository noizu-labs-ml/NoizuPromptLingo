defmodule NoizuPromptLingua.Domains.Wiki.Tools.GetPage do
  use Noizu.MCP.Server.Tool, name: "Wiki.GetPage",
    description: "Get page with current content.", hidden: true, category: "Wiki",
    annotations: [read_only_hint: true]

  input do
    field :page_id, :string, required: true, description: "Page UUID"
    field :revision_id, :string, description: "Specific revision UUID"
  end

  alias NoizuPromptLingua.Domains.Wiki

  @impl true
  def call(args, _ctx) do
    page_id = args[:page_id] || args["page_id"]
    revision_id = args[:revision_id] || args["revision_id"]
    case Wiki.get_page(page_id, revision_id) do
      nil -> {:error, "Page not found"}
      {_page, nil} -> {:error, "Revision not found"}
      {page, rev} ->
        {:ok, %{id: page.id, title: page.title, slug: page.slug, tags: page.tags,
                content: rev.content, revision_id: rev.id, revision_number: rev.revision_number,
                updated_at: page.updated_at}}
    end
  end
end
