defmodule NoizuPromptLingua.Domains.Campaigns.Tools.Overview do
  use Noizu.MCP.Server.Tool, name: "Campaigns.Overview",
    description: "List campaign-domain tools and the campaign count for an organization.",
    annotations: [read_only_hint: true], category: "Campaigns"

  input do
    field :organization, :string, description: "Organization slug or UUID — scopes the count"
  end

  alias NoizuPromptLingua.Domains.Campaigns
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    count =
      case Resolve.organization_id(Args.get(args, :organization)) do
        nil -> 0
        org_id -> Campaigns.count_campaigns(org_id)
      end

    {:ok, %{domain: "Campaigns", subdomain: "campaigns.tobor.locker",
      campaign_count: count,
      tools: %{
        campaigns: ~w(Campaign.Create Campaign.Get Campaign.Update Campaign.List),
        ad_groups: ~w(AdGroup.Create AdGroup.Get AdGroup.Update AdGroup.List),
        ad_copy: ~w(AdCopy.Create AdCopy.Get AdCopy.List AdCopy.Generate AdCopy.Approve AdCopy.Reject),
        landing_pages: ~w(LandingPage.Create LandingPage.Get LandingPage.Update LandingPage.List LandingPage.Generate),
        domain_names: ~w(DomainName.Create DomainName.Get DomainName.Update DomainName.List)
      }}}
  end
end
