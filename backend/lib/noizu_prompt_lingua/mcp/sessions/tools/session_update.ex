defmodule NoizuPromptLingua.MCP.Sessions.Tools.SessionUpdate do
  use Noizu.MCP.Server.Tool,
    name: "Session.Update",
    description:
      "Update a session's title, description, status, project association, or the " <>
        "model/runner it targets. Pass `project` to (re)associate with a project, or an " <>
        "empty string to clear it. `model` and `runner` may change mid-session as the " <>
        "harness or model switches.",
    hidden: true,
    category: "Sessions"

  alias NoizuPromptLingua.MCP.{Args, Resolve}

  input do
    field :session, :string, required: true, description: "Session UUID"
    field :title, :string, description: "New title"
    field :description, :string, description: "New description"
    field :status, :string, description: "New status (active|archived|completed)"
    field :project, :string, description: "Project slug or UUID to associate (\"\" to clear)"

    field :model, :string,
      description: "Model this session targets (e.g. \"5.4\"); tailors tool descriptions"

    field :runner, :string,
      description:
        "Harness/runner this session targets (e.g. \"codex\"); tailors tool descriptions"
  end

  @impl true
  def call(args, _ctx) do
    id = Args.get(args, :session)

    case NoizuPromptLingua.Sessions.get_session(id) do
      nil ->
        {:error, "Session '#{id}' not found"}

      session ->
        with {:ok, project_attrs} <- project_attrs(args, session.organization_id) do
          attrs =
            args
            |> Args.take([:title, :description, :status, :model, :runner])
            |> Map.merge(project_attrs)

          case NoizuPromptLingua.Sessions.update_session(id, attrs) do
            {:ok, updated} ->
              {:ok,
               %{
                 id: updated.id,
                 title: updated.title,
                 status: updated.status,
                 organization_id: updated.organization_id,
                 project_id: updated.project_id,
                 model: updated.model,
                 runner: updated.runner
               }}

            {:error, :not_found} ->
              {:error, "Session '#{id}' not found"}

            {:error, changeset} ->
              {:error, "Failed: #{inspect(changeset.errors)}"}
          end
        end
    end
  end

  # `project` is only touched when the caller supplied the field. An empty
  # string clears the association; any other value must resolve and belong to
  # the session's organization.
  defp project_attrs(args, org_id) do
    case Args.get(args, :project) do
      nil ->
        {:ok, %{}}

      "" ->
        {:ok, %{project_id: nil}}

      ref ->
        case Resolve.project(ref) do
          nil -> {:error, "Project '#{ref}' not found"}
          %{organization_id: ^org_id} = project -> {:ok, %{project_id: project.id}}
          _ -> {:error, "Project '#{ref}' does not belong to this organization"}
        end
    end
  end
end
