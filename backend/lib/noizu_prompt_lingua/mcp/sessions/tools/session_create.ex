defmodule NoizuPromptLingua.MCP.Sessions.Tools.SessionCreate do
  use Noizu.MCP.Server.Tool,
    name: "Session.Create",
    description:
      "Create a new work session. Sessions group chat rooms, artifacts, and tickets under a " <>
        "shared context. An `organization` is required; use the optional `project` field to " <>
        "associate the session with a project by slug or UUID.",
    hidden: true,
    category: "Sessions"

  alias NoizuPromptLingua.MCP.{Args, Resolve}

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID (required)"
    field :title, :string, required: true, description: "Human-readable session title"
    field :description, :string, description: "Optional longer description of the session's purpose"
    field :status, :string, description: "Initial status (default \"active\")"
    field :project, :string, description: "Optional project slug or UUID to associate this session with"
    field :model, :string, description: "Optional model this session targets (e.g. \"5.4\"); tailors tool descriptions"
    field :runner, :string, description: "Optional harness/runner this session targets (e.g. \"codex\"); tailors tool descriptions"
    field :owner_id, :string, description: "Optional creating user UUID"
  end

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)
    project_ref = Args.get(args, :project)

    with {:org, org_id} when not is_nil(org_id) <- {:org, Resolve.organization_id(org_ref)},
         {:ok, project_id} <- resolve_project(project_ref, org_id) do
      attrs = %{
        organization_id: org_id,
        project_id: project_id,
        title: Args.get(args, :title),
        description: Args.get(args, :description),
        status: Args.get(args, :status) || "active",
        model: Args.get(args, :model),
        runner: Args.get(args, :runner)
      }

      case NoizuPromptLingua.Sessions.create(attrs, Args.get(args, :owner_id)) do
        {:ok, session} ->
          {:ok, %{
            id: session.id,
            title: session.title,
            status: session.status,
            organization_id: session.organization_id,
            project_id: session.project_id,
            model: session.model,
            runner: session.runner,
            created_at: session.inserted_at
          }}

        {:error, changeset} when is_struct(changeset, Ecto.Changeset) ->
          {:error, "Failed to create session: #{inspect(changeset.errors)}"}

        {:error, reason} ->
          {:error, "Failed to create session: #{inspect(reason)}"}
      end
    else
      {:org, nil} -> {:error, "Organization '#{org_ref}' not found"}
      {:error, :project_not_found} -> {:error, "Project '#{project_ref}' not found"}
      {:error, :project_not_in_org} -> {:error, "Project '#{project_ref}' does not belong to this organization"}
    end
  end

  # Project is optional. When supplied it must resolve and belong to the org.
  defp resolve_project(nil, _org_id), do: {:ok, nil}
  defp resolve_project("", _org_id), do: {:ok, nil}
  defp resolve_project(ref, org_id) do
    case Resolve.project(ref) do
      nil -> {:error, :project_not_found}
      %{organization_id: ^org_id} = project -> {:ok, project.id}
      _ -> {:error, :project_not_in_org}
    end
  end
end
