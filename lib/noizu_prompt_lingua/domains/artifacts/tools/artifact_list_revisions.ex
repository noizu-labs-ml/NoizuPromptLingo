defmodule NoizuPromptLingua.Domains.Artifacts.Tools.ArtifactListRevisions do
  use Noizu.MCP.Server.Tool,
    name: "Artifact.ListRevisions",
    description: "List revision summaries for an artifact, newest first.",
    hidden: true,
    category: "Artifacts",
    annotations: [read_only_hint: true]

  input do
    field :artifact_id, :string, required: true, description: "Artifact UUID"
    field :limit, :integer, description: "Max results (default 50)"
  end

  alias NoizuPromptLingua.Domains.Artifacts

  @impl true
  def call(args, _ctx) do
    artifact_id = args[:artifact_id] || args["artifact_id"]
    limit = args[:limit] || args["limit"]
    opts = if limit, do: [limit: limit], else: []

    revisions = Artifacts.list_revisions(artifact_id, opts)
    {:ok, %{artifact_id: artifact_id, revisions: revisions, count: length(revisions)}}
  end
end
