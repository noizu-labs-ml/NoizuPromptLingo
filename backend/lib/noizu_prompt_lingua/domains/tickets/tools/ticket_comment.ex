defmodule NoizuPromptLingua.Domains.Tickets.Tools.TicketComment do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Comment",
    description: "Add a comment to a ticket or list existing comments.",
    hidden: false,
    category: "Tickets"

  input do
    field :ticket_id, :string, required: true, description: "Ticket UUID or human key (PREFIX-NNN)"
    field :organization, :string,
      description: "Org slug or UUID (required when ticket_id is a human key)"

    field :action, :string, description: "\"add\" (default) or \"list\""
    field :content, :string, description: "Comment content (markdown) — required for add"
    field :author, :string, description: "Author persona slug"
    field :reply_to_id, :string, description: "UUID of comment to reply to (threading)"
  end

  alias NoizuPromptLingua.Domains.Tickets.Tools.TicketResolver
  alias NoizuPromptLingua.Services.Comment

  @impl true
  def call(args, _ctx) do
    ticket_ref = args[:ticket_id] || args["ticket_id"]
    action = args[:action] || args["action"] || "add"

    with {:ok, ticket} <- TicketResolver.call(args) do
      case action do
        "list" ->
          comments = Comment.list("ticket", ticket.id)

          {:ok,
           %{
             ticket_id: ticket.id,
             key: ticket.key,
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

          case Comment.add("ticket", ticket.id, attrs) do
            {:ok, comment} ->
              {:ok, %{id: comment.id, ticket_id: ticket.id, key: ticket.key, content: comment.content}}

            {:error, changeset} ->
              {:error, "Failed: #{inspect(changeset.errors)}"}
          end
      end
    else
      {:error, :organization_required} ->
        {:error, "organization is required when ticket_id is a human key (PREFIX-NNN)"}

      {:error, msg} when is_binary(msg) ->
        {:error, msg}

      {:error, _} ->
        {:error, "Ticket '#{ticket_ref}' not found"}
    end
  end
end
