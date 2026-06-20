defmodule NoizuPromptLingua.Domains.Review.Tools.ReviewCreate do
  use Noizu.MCP.Server.Tool,
    name: "Review.Create", description: "Start a review for an artifact revision.", hidden: true, category: "Review"

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID (required)"
    field :artifact_id, :string, required: true, description: "Artifact UUID"
    field :revision_id, :string, required: true, description: "Revision UUID"
    field :reviewer_persona, :string, required: true, description: "Reviewer persona slug"
    field :title, :string, description: "Review title"
    field :project, :string, description: "Optional project slug or UUID to scope this review to"
  end

  alias NoizuPromptLingua.Domains.Reviews
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)
    project_ref = Args.get(args, :project)
    artifact_id = Args.get(args, :artifact_id)

    with {:org, org_id} when not is_nil(org_id) <- {:org, Resolve.organization_id(org_ref)},
         {:ok, project_id} <- Resolve.project_in_org(project_ref, org_id),
         :ok <- verify_artifact(artifact_id, org_id) do
      attrs = %{
        organization_id: org_id,
        project_id: project_id,
        artifact_id: artifact_id,
        revision_id: Args.get(args, :revision_id),
        reviewer_persona: Args.get(args, :reviewer_persona),
        title: Args.get(args, :title)
      }

      case Reviews.create(attrs) do
        {:ok, review} -> {:ok, %{id: review.id, artifact_id: review.artifact_id, revision_id: review.revision_id, organization_id: review.organization_id, project_id: review.project_id, status: review.status, created_at: review.inserted_at}}
        {:error, cs} -> {:error, "Failed: #{inspect(cs.errors)}"}
      end
    else
      {:org, nil} -> {:error, "Organization '#{org_ref}' not found"}
      {:error, :project_not_found} -> {:error, "Project '#{project_ref}' not found"}
      {:error, :project_not_in_org} -> {:error, "Project '#{project_ref}' does not belong to this organization"}
      {:error, :artifact_not_found} -> {:error, "Artifact '#{artifact_id}' not found"}
      {:error, :artifact_not_in_org} -> {:error, "Artifact '#{artifact_id}' does not belong to this organization"}
    end
  end

  # The artifact under review must belong to the same organization.
  defp verify_artifact(artifact_id, org_id) do
    case NoizuPromptLingua.Repo.get(NoizuPromptLingua.Schema.Artifact, artifact_id) do
      nil -> {:error, :artifact_not_found}
      %{organization_id: ^org_id} -> :ok
      _ -> {:error, :artifact_not_in_org}
    end
  end
end
