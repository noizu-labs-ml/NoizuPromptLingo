defmodule NoizuPromptLingua.Domains.Campaigns.Tools.AdGroupGet do
  use Noizu.MCP.Server.Tool,
    name: "AdGroup.Get",
    description: "Fetch an ad group by UUID.",
    annotations: [read_only_hint: true],
    hidden: true,
    category: "Campaigns.AdGroups"

  input do
    field :id, :string, required: true, description: "Ad group UUID"
  end

  alias NoizuPromptLingua.Domains.Campaigns
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    case Campaigns.get_ad_group(Args.get(args, :id)) do
      nil ->
        {:error, "Ad group not found"}

      g ->
        {:ok,
         %{
           id: g.id,
           slug: g.slug,
           name: g.name,
           theme: g.theme,
           keywords: g.keywords,
           bid_cents: g.bid_cents,
           status: g.status,
           campaign_id: g.campaign_id
         }}
    end
  end
end
