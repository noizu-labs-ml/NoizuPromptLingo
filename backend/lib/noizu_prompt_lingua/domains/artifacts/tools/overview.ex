defmodule NoizuPromptLingua.Domains.Artifacts.Tools.Overview do
  use Noizu.MCP.Server.Tool,
    name: "Artifact.Overview",
    description: "List artifact tools and artifact counts by kind.",
    annotations: [read_only_hint: true],
    category: "Artifacts"

  input do
  end

  alias NoizuPromptLingua.Domains.Artifacts

  @impl true
  def call(_args, _ctx) do
    {:ok, %{
      domain: "Artifacts",
      subdomain: "artifacts.tobor.locker",
      counts_by_kind: Artifacts.count_by_kind(),
      kinds: NoizuPromptLingua.Schema.Artifact.kinds(),
      tools: [
        %{name: "Artifact.Create", description: "Create a versioned artifact with initial revision"},
        %{name: "Artifact.Get", description: "Fetch artifact with latest or specific revision"},
        %{name: "Artifact.List", description: "List artifacts filtered by kind"},
        %{name: "Artifact.AddRevision", description: "Append a new revision to an artifact"},
        %{name: "Artifact.ListRevisions", description: "List revision summaries"},
        %{name: "Artifact.GetBinary", description: "Fetch raw binary content as base64"}
      ]
    }}
  end
end
