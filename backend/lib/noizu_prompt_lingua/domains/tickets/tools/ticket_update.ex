defmodule NoizuPromptLingua.Domains.Tickets.Tools.TicketUpdate do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Update",
    description: "Update ticket fields (partial update, custom_fields are merged).",
    hidden: false,
    category: "Tickets"

  input_schema(%{
    "type" => "object",
    "properties" => %{
      "ticket_id" => %{"type" => "string", "description" => "Ticket UUID or human key (PREFIX-NNN)"},
      "organization" => %{
        "type" => "string",
        "description" => "Org slug or UUID (required when ticket_id is a human key)"
      },
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
  alias NoizuPromptLingua.Domains.Tickets.Tools.TicketResolver

  @impl true
  def call(args, _ctx) do
    ticket_ref = args["ticket_id"]

    attrs =
      extract(
        args,
        ~w(title description status priority assignee project_id queue_id parent_id custom_fields)
      )

    with {:ok, ticket} <- TicketResolver.call(args),
         {:ok, ticket} <- Tickets.update(ticket.id, attrs) do
      {:ok,
       %{
         id: ticket.id,
         ticket_url: NoizuPromptLingua.MCP.Urls.ticket_url(ticket),
         key: ticket.key,
         title: ticket.title,
         status: ticket.status,
         priority: ticket.priority,
         updated_at: ticket.updated_at
       }}
    else
      {:error, :organization_required} ->
        {:error, "organization is required when ticket_id is a human key (PREFIX-NNN)"}

      {:error, msg} when is_binary(msg) ->
        {:error, msg}

      {:error, :not_found} ->
        {:error, "Ticket '#{ticket_ref}' not found"}

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
