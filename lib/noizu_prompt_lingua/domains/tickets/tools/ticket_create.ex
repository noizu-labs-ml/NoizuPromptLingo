defmodule NoizuPromptLingua.Domains.Tickets.Tools.TicketCreate do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Create",
    description: "Create a new ticket with typed fields.",
    hidden: true,
    category: "Tickets"

  input_schema %{
    "type" => "object",
    "properties" => %{
      "title" => %{"type" => "string", "description" => "Ticket title"},
      "description" => %{"type" => "string", "description" => "Ticket description (markdown)"},
      "ticket_type" => %{"type" => "string", "description" => "Type slug: epic, user_story, prd, bug, task, documentation, research, subtask (default: task)"},
      "status" => %{"type" => "string", "description" => "Initial status (default: first in type workflow)"},
      "priority" => %{"type" => "string", "description" => "low, medium, high, critical"},
      "assignee" => %{"type" => "string", "description" => "Assignee persona slug"},
      "reporter" => %{"type" => "string", "description" => "Reporter persona slug"},
      "queue_id" => %{"type" => "string", "description" => "Queue UUID"},
      "parent_id" => %{"type" => "string", "description" => "Parent ticket UUID"},
      "custom_fields" => %{"type" => "object", "description" => "Type-specific field values as {slug: value}"}
    },
    "required" => ["title"]
  }

  alias NoizuPromptLingua.Domains.Tickets

  @impl true
  def call(args, _ctx) do
    attrs = extract(args, ~w(title description ticket_type status priority assignee reporter queue_id parent_id custom_fields))
    attrs = Map.put_new(attrs, :ticket_type, "task")

    case Tickets.create(attrs) do
      {:ok, ticket} ->
        {:ok, %{
          id: ticket.id, title: ticket.title, ticket_type: ticket.ticket_type,
          status: ticket.status, priority: ticket.priority, created_at: ticket.inserted_at
        }}
      {:error, changeset} ->
        {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end

  defp extract(args, keys) do
    Enum.reduce(keys, %{}, fn k, acc ->
      atom_key = String.to_atom(k)
      val = args[atom_key] || args[k]
      if val, do: Map.put(acc, atom_key, val), else: acc
    end)
  end
end
