defmodule NoizuPromptLingua.Domains.Artifacts.Tools.ArtifactGet do
  use Noizu.MCP.Server.Tool,
    name: "Artifact.Get",
    description: "Fetch an artifact with its content. Returns latest revision by default.",
    hidden: true,
    category: "Artifacts",
    annotations: [read_only_hint: true]

  input do
    field :artifact_id, :string, required: true, description: "Artifact UUID"
    field :revision_id, :string, description: "Specific revision UUID (omit for latest)"
  end

  alias NoizuPromptLingua.Domains.Artifacts

  @impl true
  def call(args, _ctx) do
    artifact_id = args[:artifact_id] || args["artifact_id"]
    revision_id = args[:revision_id] || args["revision_id"]

    case Artifacts.get(artifact_id, revision_id) do
      nil ->
        {:error, "Artifact '#{artifact_id}' not found"}

      {_artifact, nil} ->
        {:error, "Revision not found"}

      {artifact, revision} ->
        {:ok,
         %{
           id: artifact.id,
           kind: artifact.kind,
           title: artifact.title,
           mime_type: artifact.mime_type,
           revision: %{
             id: revision.id,
             revision_number: revision.revision_number,
             content: revision.content,
             note: revision.note,
             created_at: revision.inserted_at
           },
           created_at: artifact.inserted_at
         }}
    end
  end
end
