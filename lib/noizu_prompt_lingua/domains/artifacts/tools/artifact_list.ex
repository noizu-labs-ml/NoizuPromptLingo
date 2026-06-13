defmodule NoizuPromptLingua.Domains.Artifacts.Tools.ArtifactList do
  use Noizu.MCP.Server.Tool,
    name: "Artifact.List",
    description: "List artifacts, optionally filtered by kind or title search.",
    hidden: true,
    category: "Artifacts",
    annotations: [read_only_hint: true]

  input do
    field :kind, :string, description: "Filter by kind (code, document, image, wiki, config, binary)"
    field :search, :string, description: "Search in title"
    field :project_id, :string, description: "Filter by project UUID"
    field :limit, :integer, description: "Max results (default 50)"
    field :offset, :integer, description: "Pagination offset"
  end

  alias NoizuPromptLingua.Domains.Artifacts

  @impl true
  def call(args, _ctx) do
    opts =
      [:kind, :search, :project_id, :limit, :offset]
      |> Enum.reduce([], fn k, acc ->
        val = args[k] || args[Atom.to_string(k)]
        if val, do: [{k, val} | acc], else: acc
      end)

    artifacts = Artifacts.list(opts)

    {:ok, %{
      artifacts: Enum.map(artifacts, fn a ->
        %{id: a.id, kind: a.kind, title: a.title, mime_type: a.mime_type, created_at: a.inserted_at}
      end),
      count: length(artifacts)
    }}
  end
end
