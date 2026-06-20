defmodule NoizuPromptLingua.Domains.Artifacts.Tools.ArtifactAddRevision do
  use Noizu.MCP.Server.Tool,
    name: "Artifact.AddRevision",
    description: "Append a new revision to an existing artifact.",
    hidden: true,
    category: "Artifacts"

  input do
    field :artifact_id, :string, required: true, description: "Artifact UUID"
    field :content, :string, required: true, description: "New content"
    field :note, :string, description: "Revision note describing changes"
  end

  alias NoizuPromptLingua.Domains.Artifacts

  @impl true
  def call(args, _ctx) do
    artifact_id = args[:artifact_id] || args["artifact_id"]
    content = args[:content] || args["content"]
    note = args[:note] || args["note"]

    case Artifacts.add_revision(artifact_id, content, note) do
      {:ok, revision} ->
        {:ok, %{
          revision_id: revision.id,
          revision_number: revision.revision_number,
          created_at: revision.inserted_at
        }}
      {:error, changeset} ->
        {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end
end
