defmodule NoizuPromptLingua.Domains.Wiki.Tools.WikiComment do
  use Noizu.MCP.Server.Tool, name: "Wiki.Comment",
    description: "Add comment to a wiki page.", hidden: true, category: "Wiki"

  input do
    field :page_id, :string, required: true, description: "Page UUID"
    field :content, :string, required: true, description: "Comment body (markdown)"
    field :author, :string, required: true, description: "Persona slug"
    field :location, :string, description: "Inline location (line, heading, selection)"
    field :reply_to_id, :string, description: "Parent comment UUID"
  end

  alias NoizuPromptLingua.Services.Comment

  @impl true
  def call(args, _ctx) do
    page_id = args[:page_id] || args["page_id"]
    attrs = %{content: args[:content] || args["content"], author: args[:author] || args["author"],
              location: args[:location] || args["location"], reply_to_id: args[:reply_to_id] || args["reply_to_id"]}
    case Comment.add("wiki_page", page_id, attrs) do
      {:ok, c} -> {:ok, %{id: c.id, page_id: page_id, content: c.content}}
      {:error, cs} -> {:error, "Failed: #{inspect(cs)}"}
    end
  end
end
