defmodule NoizuPromptLingua.Domains.Artifacts.Tools.ArtifactList do
  use Noizu.MCP.Server.Tool,
    name: "Artifact.List",
    description: "List artifacts, optionally filtered by kind or title search.",
    hidden: true,
    category: "Artifacts",
    annotations: [read_only_hint: true]

  input do
    field :organization, :string,
      required: true,
      description: "Organization slug or UUID (required)"

    field :kind, :string,
      description: "Filter by kind (code, document, image, wiki, config, binary)"

    field :search, :string, description: "Search in title"
    field :project, :string, description: "Filter by project slug or UUID"
    field :limit, :integer, description: "Max results (default 50)"
    field :offset, :integer, description: "Pagination offset"
  end

  alias NoizuPromptLingua.Domains.Artifacts
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)

    case Resolve.organization_id(org_ref) do
      nil ->
        {:error, "Organization '#{org_ref}' not found"}

      org_id ->
        project = Resolve.project(Args.get(args, :project))

        opts =
          [:kind, :search, :limit, :offset]
          |> Enum.reduce([organization_id: org_id], fn k, acc ->
            val = args[k] || args[Atom.to_string(k)]
            if val, do: [{k, val} | acc], else: acc
          end)
          |> then(fn opts -> if project, do: [{:project_id, project.id} | opts], else: opts end)

        artifacts = Artifacts.list(opts)

        {:ok,
         %{
           artifacts:
             Enum.map(artifacts, fn a ->
               %{
                 id: a.id,
                 kind: a.kind,
                 title: a.title,
                 mime_type: a.mime_type,
                 created_at: a.inserted_at
               }
             end),
           count: length(artifacts)
         }}
    end
  end
end
