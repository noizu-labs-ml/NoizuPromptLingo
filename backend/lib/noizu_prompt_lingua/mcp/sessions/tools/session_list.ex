defmodule NoizuPromptLingua.MCP.Sessions.Tools.SessionList do
  use Noizu.MCP.Server.Tool,
    name: "Session.List",
    description:
      "List sessions for an organization, with optional filtering by status and/or project.",
    hidden: true,
    category: "Sessions",
    annotations: [read_only_hint: true]

  alias NoizuPromptLingua.MCP.{Args, Resolve}

  input do
    field :organization, :string,
      required: true,
      description: "Organization slug or UUID (required)"

    field :status, :string, description: "Filter by status (active|archived|completed)"
    field :project, :string, description: "Filter by project slug or UUID"
    field :limit, :integer, description: "Max results (default 50)"
    field :offset, :integer, description: "Pagination offset"
  end

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)
    project_ref = Args.get(args, :project)

    case Resolve.organization_id(org_ref) do
      nil ->
        {:error, "Organization '#{org_ref}' not found"}

      org_id ->
        project_id =
          case Resolve.project(project_ref) do
            nil -> nil
            project -> project.id
          end

        opts =
          []
          |> put_opt(:status, Args.get(args, :status))
          |> put_opt(:project_id, project_id)
          |> put_opt(:limit, Args.get(args, :limit))
          |> put_opt(:offset, Args.get(args, :offset))

        sessions = NoizuPromptLingua.Sessions.list_for_org(org_id, opts)

        {:ok,
         %{
           sessions:
             Enum.map(
               sessions,
               &%{
                 id: &1.id,
                 title: &1.title,
                 status: &1.status,
                 organization_id: &1.organization_id,
                 project_id: &1.project_id,
                 created_at: &1.inserted_at
               }
             ),
           count: length(sessions)
         }}
    end
  end

  defp put_opt(opts, _key, nil), do: opts
  defp put_opt(opts, key, val), do: Keyword.put(opts, key, val)
end
