defmodule NoizuPromptLingua.Domains.Tickets.Tools.TicketComment do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Comment",
    description: "Add a comment to a ticket or list existing comments.",
    hidden: false,
    category: "Tickets"

  input do
    field :ticket_id, :string, required: true, description: "Ticket UUID"
    field :action, :string, description: "\"add\" (default) or \"list\""
    field :content, :string, description: "Comment content (markdown) — required for add"
    field :author, :string, description: "Author persona slug"
    field :reply_to_id, :string, description: "UUID of comment to reply to (threading)"
  end

  alias NoizuPromptLingua.Services.Comment

  @impl true
  def call(args, _ctx) do
    ticket_id = args[:ticket_id] || args["ticket_id"]
    action = args[:action] || args["action"] || "add"

    case action do
      "list" ->
        comments = Comment.list("ticket", ticket_id)

        {:ok,
         %{
           ticket_id: ticket_id,
           comments:
             Enum.map(comments, fn c ->
               %{
                 id: c.id,
                 content: c.content,
                 author: c.author,
                 reply_to_id: c.reply_to_id,
                 created_at: c.inserted_at
               }
             end)
         }}

      _ ->
        attrs = %{
          content: args[:content] || args["content"],
          author: args[:author] || args["author"],
          reply_to_id: args[:reply_to_id] || args["reply_to_id"]
        }

        case Comment.add("ticket", ticket_id, attrs) do
          {:ok, comment} ->
            {:ok, %{id: comment.id, ticket_id: ticket_id, content: comment.content}}

          {:error, changeset} ->
            {:error, "Failed: #{inspect(changeset.errors)}"}
        end
    end
  end
end
