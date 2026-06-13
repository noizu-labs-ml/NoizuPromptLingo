defmodule NoizuPromptLingua.Domains.Assets.Tools.AssetSetActive do
  use Noizu.MCP.Server.Tool, name: "Asset.SetActive",
    description: "Mark a specific output as the active version.", hidden: true, category: "Assets"

  input do
    field :entry_id, :string, required: true, description: "Asset entry UUID"
    field :output_id, :string, required: true, description: "Output UUID to activate"
    field :actor, :string, description: "Actor persona"
  end

  alias NoizuPromptLingua.Domains.Assets

  @impl true
  def call(args, _ctx) do
    entry_id = args[:entry_id] || args["entry_id"]
    output_id = args[:output_id] || args["output_id"]
    case Assets.set_active(entry_id, output_id, actor: args[:actor] || args["actor"]) do
      {:ok, e} -> {:ok, %{id: e.id, active_output_id: e.active_output_id}}
      {:error, :not_found} -> {:error, "Entry not found"}
    end
  end
end
