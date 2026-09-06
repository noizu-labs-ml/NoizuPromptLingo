defmodule NoizuPromptLingua.Domains.Tickets.Tools.TicketCreate do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.Create",
    description: "Create a new ticket with typed fields.",
    hidden: false,
    category: "Tickets"

  input_schema(%{
    "type" => "object",
    "properties" => %{
      "organization" => %{
        "type" => "string",
        "description" => "Organization slug or UUID (required)"
      },
      "title" => %{"type" => "string", "description" => "Ticket title"},
      "description" => %{"type" => "string", "description" => "Ticket description (markdown)"},
      "ticket_type" => %{
        "type" => "string",
        "description" =>
          "Type slug: epic, user_story, prd, bug, task, documentation, research, subtask (default: task)"
      },
      "status" => %{
        "type" => "string",
        "description" => "Initial status (default: first in type workflow)"
      },
      "priority" => %{"type" => "string", "description" => "low, medium, high, critical"},
      "assignee" => %{"type" => "string", "description" => "Assignee persona slug"},
      "reporter" => %{"type" => "string", "description" => "Reporter persona slug"},
      "project" => %{
        "type" => "string",
        "description" => "Optional project slug or UUID to scope this ticket to"
      },
      "queue_id" => %{"type" => "string", "description" => "Queue UUID"},
      "parent_id" => %{"type" => "string", "description" => "Parent ticket UUID"},
      "custom_fields" => %{
        "type" => "object",
        "description" => "Type-specific field values as {slug: value}"
      }
    },
    "required" => ["organization", "title"]
  })

  alias NoizuPromptLingua.Domains.Tickets
  alias NoizuPromptLingua.MCP.{Args, Resolve, Urls}

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)
    project_ref = Args.get(args, :project) || Args.get(args, :project_id)

    with {:org, org_id} when not is_nil(org_id) <- {:org, Resolve.organization_id(org_ref)},
         {:ok, project_id} <- Resolve.project_in_org(project_ref, org_id) do
      attrs =
        extract(
          args,
          ~w(title description ticket_type status priority assignee reporter queue_id parent_id custom_fields)
        )
        |> Map.put(:organization_id, org_id)
        |> Map.put(:project_id, project_id)
        |> Map.put_new(:ticket_type, "task")

      case Tickets.create(attrs) do
        {:ok, ticket} ->
          {:ok,
           %{
             id: ticket.id,
             ticket_url: Urls.ticket_url(ticket),
             title: ticket.title,
             ticket_type: ticket.ticket_type,
             status: ticket.status,
             priority: ticket.priority,
             organization_id: ticket.organization_id,
             project_id: ticket.project_id,
             created_at: ticket.inserted_at
           }}

        {:error, changeset} ->
          {:error, "Failed: #{inspect(changeset.errors)}"}
      end
    else
      {:org, nil} ->
        {:error, "Organization '#{org_ref}' not found"}

      {:error, :project_not_found} ->
        {:error, "Project '#{project_ref}' not found"}

      {:error, :project_not_in_org} ->
        {:error, "Project '#{project_ref}' does not belong to this organization"}
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
