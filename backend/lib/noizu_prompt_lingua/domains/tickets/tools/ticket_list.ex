defmodule NoizuPromptLingua.Domains.Tickets.Tools.TicketList do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.List",
    description:
      "List tickets within an organization (all projects when `project` is omitted), " <>
        "with optional filters by status, type, priority, assignee, queue, parent, tag, " <>
        "and an updated_at date range, plus sorting and pagination.",
    hidden: true,
    category: "Tickets",
    annotations: [read_only_hint: true]

  input do
    field :organization, :string,
      required: true,
      description: "Organization slug or UUID (required)"

    field :status, :string, description: "Filter by status"
    field :ticket_type, :string, description: "Filter by type slug"
    field :item_type, :string, description: "Alias of ticket_type (ignored when both are given)"
    field :priority, :string, description: "Filter by priority"
    field :assignee, :string, description: "Filter by assignee"
    field :project, :string, description: "Filter by project slug or UUID (omit for org-wide)"
    field :queue_id, :string, description: "Filter by queue UUID"
    field :parent_id, :string, description: "Filter by parent ticket UUID"
    field :tag, :string, description: "Filter by tag; comma-separated values match any (OR)"

    field :updated_after, :string,
      description: "Only tickets updated at/after this ISO8601 timestamp (inclusive)"

    field :updated_before, :string,
      description: "Only tickets updated at/before this ISO8601 timestamp (inclusive)"

    field :sort, :string,
      description:
        "Sort field: updated_at|created_at|priority|status|title|id (default: created_at desc)"

    field :sort_dir, :string, description: "Sort direction: asc|desc (default desc)"
    field :limit, :integer, description: "Max results (default 50)"
    field :offset, :integer, description: "Pagination offset (default 0)"
  end

  alias NoizuPromptLingua.Domains.Tickets
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)

    case Resolve.organization_id(org_ref) do
      nil ->
        {:error, "Organization '#{org_ref}' not found"}

      org_id ->
        project = Resolve.project(Args.get(args, :project))

        opts =
          [
            :status,
            :ticket_type,
            :item_type,
            :priority,
            :assignee,
            :queue_id,
            :parent_id,
            :tag,
            :updated_after,
            :updated_before,
            :sort,
            :sort_dir,
            :limit,
            :offset
          ]
          |> Enum.reduce([organization_id: org_id], fn key, acc ->
            val = args[key] || args[Atom.to_string(key)]
            if val, do: [{key, val} | acc], else: acc
          end)
          |> then(fn opts -> if project, do: [{:project_id, project.id} | opts], else: opts end)
          # ticket_type stays the canonical opt (PMBridge aliases → item_type);
          # an explicit item_type arg is honored only when ticket_type is absent.
          |> normalize_type_alias()
          # Documented default, enforced on both the server-paged and the
          # client-side (filtered/sorted) paths.
          |> Keyword.put_new(:limit, 50)

        tickets = Tickets.list(opts)

        case tickets do
          rows when is_list(rows) ->
            {:ok,
             %{
               tickets:
                 Enum.map(rows, fn t ->
                   %{
                     id: t.id,
                     key: t.key,
                     title: t.title,
                     ticket_type: t.ticket_type,
                     status: t.status,
                     priority: t.priority,
                     assignee: t.assignee,
                     tags: t.tags || [],
                     project_id: t.project_id,
                     created_at: t.inserted_at,
                     updated_at: t.updated_at
                   }
                 end),
               count: length(rows)
             }}

          {:error, _} = err ->
            err
        end
    end
  end

  defp normalize_type_alias(opts) do
    case {Keyword.get(opts, :ticket_type), Keyword.get(opts, :item_type)} do
      {nil, alias_type} when alias_type != nil ->
        opts |> Keyword.delete(:item_type) |> Keyword.put(:ticket_type, alias_type)

      _ ->
        Keyword.delete(opts, :item_type)
    end
  end
end
