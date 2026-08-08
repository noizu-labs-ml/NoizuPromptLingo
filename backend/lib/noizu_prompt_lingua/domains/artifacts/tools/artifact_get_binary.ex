defmodule NoizuPromptLingua.Domains.Artifacts.Tools.ArtifactGetBinary do
  use Noizu.MCP.Server.Tool,
    name: "Artifact.GetBinary",
    description: "Fetch the raw binary content of an artifact revision encoded as base64.",
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
        content_b64 = Base.encode64(revision.content || "")

        {:ok,
         %{
           content_base64: content_b64,
           mime_type: artifact.mime_type,
           size_bytes: byte_size(revision.content || "")
         }}
    end
  end
end
