defmodule NoizuPromptLingua.Domains.Sessions.Tools.SessionList do
  use Noizu.MCP.Server.Tool,
    name: "Session.List",
    description: "List sessions with optional filtering by status and/or project.",
    hidden: true,
    category: "Sessions"

  input do
    field :status, :string, description: "Filter by status (e.g., \"active\", \"archived\")"
    field :project, :string, description: "Filter by project slug or UUID"
    field :limit, :integer, description: "Max results (default 50)"
    field :offset, :integer, description: "Pagination offset"
  end

  @impl true
  def call(args, _ctx) do
    project_ref = args[:project] || args["project"]

    with {:ok, project_id} <- NoizuPromptLingua.Domains.Sessions.resolve_project_id(project_ref) do
      opts =
        []
        |> maybe_opt(:status, args[:status] || args["status"])
        |> maybe_opt(:project_id, project_id)
        |> maybe_opt(:limit, args[:limit] || args["limit"])
        |> maybe_opt(:offset, args[:offset] || args["offset"])

      sessions = NoizuPromptLingua.Domains.Sessions.list(opts)

      {:ok, %{
        sessions: Enum.map(sessions, fn s ->
          %{id: s.id, title: s.title, status: s.status, project_id: s.project_id, created_at: s.inserted_at}
        end),
        count: length(sessions)
      }}
    else
      {:error, :project_not_found} ->
        {:error, "Project '#{project_ref}' not found"}
    end
  end

  defp maybe_opt(opts, _key, nil), do: opts
  defp maybe_opt(opts, key, val), do: Keyword.put(opts, key, val)
end
