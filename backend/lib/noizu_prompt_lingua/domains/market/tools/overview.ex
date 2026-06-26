defmodule NoizuPromptLingua.Domains.Market.Tools.Overview do
  use Noizu.MCP.Server.Tool, name: "Market.Overview",
    description: "List market-domain tools and the keyword count for an organization.",
    annotations: [read_only_hint: true], category: "Market"

  input do
    field :organization, :string, description: "Organization slug or UUID — scopes the count"
  end

  alias NoizuPromptLingua.Domains.Market
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    count =
      case Resolve.organization_id(Args.get(args, :organization)) do
        nil -> 0
        org_id -> Market.count_keywords(org_id)
      end

    {:ok, %{domain: "Market", subdomain: "market.tobor.locker",
      keyword_count: count,
      tools: %{
        competitors: ~w(Competitor.Create Competitor.Get Competitor.Update Competitor.List),
        keywords: ~w(Keyword.Create Keyword.Get Keyword.Update Keyword.List Keyword.Research),
        reports: ~w(MarketReport.Create MarketReport.Get MarketReport.List MarketReport.Generate)
      }}}
  end
end
