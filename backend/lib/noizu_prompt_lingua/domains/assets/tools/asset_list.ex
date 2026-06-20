defmodule NoizuPromptLingua.Domains.Assets.Tools.AssetList do
  use Noizu.MCP.Server.Tool, name: "Asset.List",
    description: "List assets filtered by type, status, tag, project.", hidden: true, category: "Assets",
    annotations: [read_only_hint: true]

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID (required)"
    field :project, :string, description: "Filter by project slug or UUID"
    field :asset_type, :string, description: "Filter by asset type"
    field :status, :string, description: "Filter by status"
    field :tag, :string, description: "Filter by tag"
    field :limit, :integer, description: "Max results (default 50)"
    field :offset, :integer, description: "Pagination offset"
  end

  alias NoizuPromptLingua.Domains.Assets
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    case Resolve.organization_id(Args.get(args, :organization)) do
      nil ->
        {:error, "Organization not found"}

      org_id ->
        project = Resolve.project(Args.get(args, :project))

        opts =
          [:asset_type, :status, :tag, :limit, :offset]
          |> Enum.reduce([organization_id: org_id], fn k, acc ->
            val = args[k] || args[Atom.to_string(k)]
            if val, do: [{k, val} | acc], else: acc
          end)
          |> then(fn opts -> if project, do: [{:project_id, project.id} | opts], else: opts end)

        entries = Assets.list(opts)
        {:ok, %{assets: Enum.map(entries, &%{id: &1.id, slug: &1.slug, title: &1.title, asset_type: &1.asset_type, status: &1.status, quality: &1.quality}), count: length(entries)}}
    end
  end
end
