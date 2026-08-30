defmodule NoizuPromptLingua.Domains.Tickets.Tools.TicketUpdate do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Update",
    description: "Update ticket fields (partial update, custom_fields are merged).",
    hidden: false,
    category: "Tickets"

  input_schema(%{
    "type" => "object",
    "properties" => %{
      "ticket_id" => %{"type" => "string", "description" => "Ticket UUID"},
      "title" => %{"type" => "string", "description" => "New title"},
      "description" => %{"type" => "string", "description" => "New description"},
      "status" => %{"type" => "string", "description" => "New status"},
      "priority" => %{"type" => "string", "description" => "New priority"},
      "assignee" => %{"type" => "string", "description" => "New assignee"},
      "project_id" => %{"type" => "string", "description" => "New project UUID"},
      "queue_id" => %{"type" => "string", "description" => "New queue UUID"},
      "parent_id" => %{"type" => "string", "description" => "New parent UUID"},
      "custom_fields" => %{
        "type" => "object",
        "description" => "Fields to merge into existing custom_fields"
      }
    },
    "required" => ["ticket_id"]
  })

  alias NoizuPromptLingua.Domains.Tickets

  @impl true
  def call(args, _ctx) do
    ticket_id = args["ticket_id"]

    attrs =
      extract(
        args,
        ~w(title description status priority assignee project_id queue_id parent_id custom_fields)
      )

    case Tickets.update(ticket_id, attrs) do
      {:ok, ticket} ->
        {:ok,
         %{
           id: ticket.id,
           title: ticket.title,
           status: ticket.status,
           priority: ticket.priority,
           updated_at: ticket.updated_at
         }}

      {:error, :not_found} ->
        {:error, "Ticket '#{ticket_id}' not found"}

      {:error, changeset} ->
        {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end

  defp extract(args, keys) do
    Enum.reduce(keys, %{}, fn k, acc ->
      val = args[k]
      if val, do: Map.put(acc, String.to_atom(k), val), else: acc
    end)
  end
end
