defmodule NoizuPromptLingua.Domains.Assets.Tools.AssetGet do
  use Noizu.MCP.Server.Tool, name: "Asset.Get",
    description: "Get asset entry with outputs and active output.", hidden: true, category: "Assets",
    annotations: [read_only_hint: true]

  input do
    field :asset, :string, required: true, description: "Slug or UUID"
  end

  alias NoizuPromptLingua.Domains.Assets

  @impl true
  def call(args, _ctx) do
    key = args[:asset] || args["asset"]
    case Assets.get(key) do
      nil -> {:error, "Asset '#{key}' not found"}
      entry ->
        outputs = Assets.list_outputs(entry.id)
        {:ok, %{
          id: entry.id, slug: entry.slug, title: entry.title, asset_type: entry.asset_type,
          status: entry.status, quality: entry.quality, tags: entry.tags,
          product_targets: entry.product_targets, project_id: entry.project_id,
          active_output_id: entry.active_output_id,
          outputs: Enum.map(outputs, fn o ->
            %{id: o.id, variant: o.variant_number, provider: o.provider, model: o.model,
              eval_score: o.eval_score, eval_status: o.eval_status, status: o.status,
              artifact_id: o.artifact_id}
          end),
          created_at: entry.inserted_at}}
    end
  end
end
