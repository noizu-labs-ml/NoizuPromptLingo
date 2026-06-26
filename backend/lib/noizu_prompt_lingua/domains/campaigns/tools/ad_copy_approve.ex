defmodule NoizuPromptLingua.Domains.Campaigns.Tools.AdCopyApprove do
  use Noizu.MCP.Server.Tool,
    name: "AdCopy.Approve",
    description: "Mark an ad-copy variant approved.",
    hidden: true,
    category: "Campaigns.AdCopy"

  input do
    field :id, :string, required: true, description: "Ad copy UUID"
  end

  alias NoizuPromptLingua.Domains.Campaigns
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    case Campaigns.approve_ad_copy(Args.get(args, :id)) do
      {:ok, a} -> {:ok, %{id: a.id, status: a.status}}
      {:error, :not_found} -> {:error, "Ad copy not found"}
      {:error, changeset} -> {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end
end
