defmodule NoizuPromptLingua.Domains.Wiki.Tools.PageGet do
  use Noizu.MCP.Server.Tool,
    name: "Wiki.PageGet",
    description:
      "Get a wiki page by UUID, including content, comments, attachments, and reactions.",
    hidden: true,
    category: "Wiki",
    annotations: [read_only_hint: true]

  input do
    field :page, :string, required: true, description: "Page UUID"
  end

  alias NoizuPromptLingua.Domains.Wiki
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    id = Args.get(args, :page)

    case Wiki.get_page(id) do
      nil ->
        {:error, "Page '#{id}' not found"}

      page ->
        {:ok,
         %{
           id: page.id,
           space_id: page.space_id,
           parent_id: page.parent_id,
           slug: page.slug,
           title: page.title,
           content: page.content,
           comments:
             Enum.map(Wiki.list_comments(page.id), fn c ->
               %{
                 id: c.id,
                 author: c.author,
                 body: c.body,
                 parent_id: c.parent_id,
                 created_at: c.inserted_at
               }
             end),
           attachments:
             Enum.map(Wiki.list_attachments(page.id), fn a ->
               %{id: a.id, filename: a.filename, mime_type: a.mime_type, url: a.url}
             end),
           reactions:
             Enum.map(Wiki.list_reactions("page", page.id), fn r ->
               %{id: r.id, emoji: r.emoji, actor: r.actor}
             end)
         }}
    end
  end
end
