defmodule NoizuPromptLingua.Domains.Assets.Tools.AssetOutputs do
  use Noizu.MCP.Server.Tool, name: "Asset.Outputs",
    description: "List outputs for an entry with scores.", hidden: true, category: "Assets.Outputs",
    annotations: [read_only_hint: true]

  input do
    field :entry_id, :string, required: true, description: "Asset entry UUID"
  end

  alias NoizuPromptLingua.Domains.Assets

  @impl true
  def call(args, _ctx) do
    entry_id = args[:entry_id] || args["entry_id"]
    outputs = Assets.list_outputs(entry_id)
    {:ok, %{entry_id: entry_id, outputs: Enum.map(outputs, fn o ->
      %{id: o.id, variant: o.variant_number, provider: o.provider, model: o.model,
        eval_score: o.eval_score, eval_status: o.eval_status, status: o.status, artifact_id: o.artifact_id}
    end), count: length(outputs)}}
  end
end
