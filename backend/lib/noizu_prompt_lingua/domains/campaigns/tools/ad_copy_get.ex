defmodule NoizuPromptLingua.Domains.Campaigns.Tools.AdCopyGet do
  use Noizu.MCP.Server.Tool,
    name: "AdCopy.Get",
    description: "Fetch an ad-copy variant by UUID.",
    annotations: [read_only_hint: true],
    hidden: true,
    category: "Campaigns.AdCopy"

  input do
    field :id, :string, required: true, description: "Ad copy UUID"
  end

  alias NoizuPromptLingua.Domains.Campaigns
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    case Campaigns.get_ad_copy(Args.get(args, :id)) do
      nil -> {:error, "Ad copy not found"}
      a -> {:ok, %{id: a.id, campaign_id: a.campaign_id, ad_group_id: a.ad_group_id, variant_number: a.variant_number, headline: a.headline, body: a.body, cta: a.cta, format: a.format, artifact_id: a.artifact_id, llm_generated: a.llm_generated, status: a.status}}
    end
  end
end
