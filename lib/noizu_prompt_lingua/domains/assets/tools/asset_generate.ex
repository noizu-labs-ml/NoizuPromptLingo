defmodule NoizuPromptLingua.Domains.Assets.Tools.AssetGenerate do
  use Noizu.MCP.Server.Tool, name: "Asset.Generate",
    description: "Trigger generation — creates output record with placeholder artifact.", hidden: true, category: "Assets"

  input do
    field :entry_id, :string, required: true, description: "Asset entry UUID"
    field :provider, :string, description: "Override provider"
    field :model, :string, description: "Override model"
    field :actor, :string, description: "Actor persona"
  end

  alias NoizuPromptLingua.Domains.Assets

  @impl true
  def call(args, _ctx) do
    entry_id = args[:entry_id] || args["entry_id"]
    opts = [provider: args[:provider] || args["provider"], model: args[:model] || args["model"], actor: args[:actor] || args["actor"]]
    case Assets.generate(entry_id, opts) do
      {:ok, output} -> {:ok, %{output_id: output.id, variant: output.variant_number, artifact_id: output.artifact_id}}
      {:error, reason} -> {:error, "Failed: #{inspect(reason)}"}
    end
  end
end
