defmodule NoizuPromptLingua.Domains.Wiki.Tools.CommentCreate do
  use Noizu.MCP.Server.Tool,
    name: "Wiki.CommentCreate",
    description: "Add a comment to a wiki page (optionally as a reply to another comment).",
    hidden: true,
    category: "Wiki"

  input do
    field :page, :string, required: true, description: "Page UUID"
    field :body, :string, required: true, description: "Comment body"
    field :author, :string, description: "Author label (defaults to \"mcp\")"
    field :parent, :string, description: "Optional parent comment UUID (reply)"
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
        attrs = %{
          page_id: page.id,
          parent_id: Args.get(args, :parent),
          author: Args.get(args, :author) || "mcp",
          body: Args.get(args, :body)
        }

        case Wiki.create_comment(attrs) do
          {:ok, comment} ->
            {:ok, %{id: comment.id, page_id: comment.page_id, author: comment.author, body: comment.body}}

          {:error, changeset} ->
            {:error, "Failed: #{inspect(changeset.errors)}"}
        end
    end
  end
end
