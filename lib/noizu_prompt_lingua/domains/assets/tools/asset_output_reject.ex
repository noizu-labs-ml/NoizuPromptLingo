defmodule NoizuPromptLingua.Domains.Assets.Tools.AssetOutputReject do
  use Noizu.MCP.Server.Tool, name: "Asset.Output.Reject",
    description: "Mark an output as rejected.", hidden: true, category: "Assets.Outputs"

  input do
    field :output_id, :string, required: true, description: "Output UUID"
  end

  alias NoizuPromptLingua.Domains.Assets

  @impl true
  def call(args, _ctx) do
    output_id = args[:output_id] || args["output_id"]
    case Assets.reject_output(output_id) do
      {:ok, o} -> {:ok, %{id: o.id, status: "rejected"}}
      {:error, :not_found} -> {:error, "Output not found"}
    end
  end
end
