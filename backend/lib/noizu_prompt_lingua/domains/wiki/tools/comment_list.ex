defmodule NoizuPromptLingua.Domains.Wiki.Tools.CommentList do
  use Noizu.MCP.Server.Tool,
    name: "Wiki.CommentList",
    description: "List comments on a wiki page.",
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
    page_id = Args.get(args, :page)

    case Wiki.get_page(page_id) do
      nil ->
        {:error, "Page '#{page_id}' not found"}

      page ->
        comments = Wiki.list_comments(page.id)

        {:ok, %{
          comments: Enum.map(comments, fn c ->
            %{id: c.id, author: c.author, body: c.body, parent_id: c.parent_id, created_at: c.inserted_at}
          end),
          count: length(comments)
        }}
    end
  end
end
