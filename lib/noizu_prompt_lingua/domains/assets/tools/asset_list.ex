defmodule NoizuPromptLingua.Domains.Assets.Tools.AssetList do
  use Noizu.MCP.Server.Tool, name: "Asset.List",
    description: "List assets filtered by type, status, tag, project.", hidden: true, category: "Assets",
    annotations: [read_only_hint: true]

  input do
    field :asset_type, :string, description: "Filter by asset type"
    field :status, :string, description: "Filter by status"
    field :tag, :string, description: "Filter by tag"
    field :project_id, :string, description: "Filter by project UUID"
    field :limit, :integer, description: "Max results (default 50)"
    field :offset, :integer, description: "Pagination offset"
  end

  alias NoizuPromptLingua.Domains.Assets

  @impl true
  def call(args, _ctx) do
    opts = Enum.reduce([:asset_type, :status, :tag, :project_id, :limit, :offset], [], fn k, acc ->
      val = args[k] || args[Atom.to_string(k)]
      if val, do: [{k, val} | acc], else: acc
    end)
    entries = Assets.list(opts)
    {:ok, %{assets: Enum.map(entries, &%{id: &1.id, slug: &1.slug, title: &1.title, asset_type: &1.asset_type, status: &1.status, quality: &1.quality}), count: length(entries)}}
  end
end
