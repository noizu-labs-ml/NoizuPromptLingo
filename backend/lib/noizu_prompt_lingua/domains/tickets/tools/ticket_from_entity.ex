defmodule NoizuPromptLingua.Domains.Tickets.Tools.TicketFromEntity do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.FromEntity",
    description:
      "Convert a source entity (e.g. chat_message, wiki_page, artifact, asset, review) into a ticket. Creates a ticket whose description embeds a pointer back to the source plus a short summary, then links the ticket to the source via a `references` entity link.",
    hidden: true,
    category: "Tickets"

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :project, :string, description: "Optional project slug or UUID to scope the ticket to"

    field :subject_type, :string,
      required: true,
      description: "Source entity type (e.g. chat_message, wiki_page, artifact, asset, review)"

    field :subject_id, :string, required: true, description: "Source entity id"

    field :title, :string,
      description: "Ticket title (defaults to a summary derived from the source)"

    field :summary, :string,
      description: "Short summary of the source to embed in the description"

    field :ticket_type, :string, description: "Type slug (default: task)"
    field :priority, :string, description: "low, medium, high, critical"
    field :assignee, :string, description: "Assignee persona slug"
    field :reporter, :string, description: "Reporter persona slug"
  end

  alias NoizuPromptLingua.Domains.{Tickets, Links}
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)
    project_ref = Args.get(args, :project)
    subject_type = Args.get(args, :subject_type)
    subject_id = Args.get(args, :subject_id)
    summary = Args.get(args, :summary)
    title = Args.get(args, :title) || default_title(subject_type, summary)

    with {:org, org_id} when not is_nil(org_id) <- {:org, Resolve.organization_id(org_ref)},
         {:ok, project_id} <- Resolve.project_in_org(project_ref, org_id) do
      attrs =
        %{
          organization_id: org_id,
          project_id: project_id,
          title: title,
          description: description(subject_type, subject_id, summary),
          ticket_type: Args.get(args, :ticket_type) || "task",
          priority: Args.get(args, :priority),
          assignee: Args.get(args, :assignee),
          reporter: Args.get(args, :reporter)
        }
        |> drop_nils()

      case Tickets.create(attrs) do
        {:ok, ticket} ->
          link = link_source(ticket.id, subject_type, subject_id)

          {:ok,
           %{
             id: ticket.id,
             key: ticket.key,
             title: ticket.title,
             ticket_type: ticket.ticket_type,
             source: %{entity_type: subject_type, entity_id: subject_id},
             link: link
           }}

        {:error, changeset} ->
          {:error, "Failed to create ticket: #{inspect(changeset.errors)}"}
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

  defp link_source(ticket_id, subject_type, subject_id) do
    case Links.link_entity(ticket_id, subject_type, subject_id, link_type: "references") do
      {:ok, link} ->
        %{
          id: link.id,
          entity_type: link.entity_type,
          entity_id: link.entity_id,
          link_type: link.link_type
        }

      error ->
        require Logger
        Logger.error("TicketFromEntity link_source failed: #{inspect(error)}")
        nil
    end
  end

  defp default_title(subject_type, summary) do
    base = "Follow up on #{subject_type}"
    if summary in [nil, ""], do: base, else: "#{base}: #{String.slice(summary, 0, 80)}"
  end

  defp description(subject_type, subject_id, summary) do
    pointer =
      "Converted from #{subject_type} `#{subject_id}` (npl://#{subject_type}/#{subject_id})."

    case summary do
      s when is_binary(s) and s != "" -> pointer <> "\n\n" <> s
      _ -> pointer
    end
  end

  defp drop_nils(map), do: :maps.filter(fn _k, v -> not is_nil(v) end, map)
end
