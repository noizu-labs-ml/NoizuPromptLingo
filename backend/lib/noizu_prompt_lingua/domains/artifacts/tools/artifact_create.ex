defmodule NoizuPromptLingua.Domains.Artifacts.Tools.ArtifactCreate do
  use Noizu.MCP.Server.Tool,
    name: "Artifact.Create",
    description: "Create a new artifact with its initial revision.",
    hidden: false,
    category: "Artifacts"

  input_schema(%{
    "type" => "object",
    "properties" => %{
      "organization" => %{
        "type" => "string",
        "description" => "Organization slug or UUID (required)"
      },
      "kind" => %{
        "type" => "string",
        "description" => "Artifact kind: code, document, image, wiki, config, binary"
      },
      "title" => %{"type" => "string", "description" => "Artifact title"},
      "content" => %{
        "type" => "string",
        "description" => "Initial content (text or base64 for binary)"
      },
      "mime_type" => %{
        "type" => "string",
        "description" => "MIME type (e.g. text/markdown, image/png)"
      },
      "project" => %{
        "type" => "string",
        "description" => "Optional project slug or UUID to scope this artifact to"
      },
      "metadata" => %{"type" => "object", "description" => "Additional metadata"}
    },
    "required" => ["organization", "kind", "title", "content"]
  })

  alias NoizuPromptLingua.Domains.Artifacts
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)
    project_ref = Args.get(args, :project) || Args.get(args, :project_id)

    with {:org, org_id} when not is_nil(org_id) <- {:org, Resolve.organization_id(org_ref)},
         {:ok, project_id} <- Resolve.project_in_org(project_ref, org_id) do
      attrs = %{
        organization_id: org_id,
        project_id: project_id,
        kind: Args.get(args, :kind),
        title: Args.get(args, :title),
        content: Args.get(args, :content),
        mime_type: Args.get(args, :mime_type)
      }

      case Artifacts.create(attrs) do
        {:ok, artifact} ->
          rev = hd(artifact.revisions)

          {:ok,
           %{
             id: artifact.id,
             revision_id: rev.id,
             kind: artifact.kind,
             title: artifact.title,
             organization_id: artifact.organization_id,
             project_id: artifact.project_id,
             created_at: artifact.inserted_at
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
end
