defmodule NoizuPromptLingua.Domains.Campaigns.Tools.AdGroupList do
  use Noizu.MCP.Server.Tool,
    name: "AdGroup.List",
    description: "List ad groups within a campaign.",
    annotations: [read_only_hint: true],
    hidden: true,
    category: "Campaigns.AdGroups"

  input do
    field :campaign_id, :string, required: true, description: "Campaign UUID"
    field :status, :string, description: "Optional status filter"
    field :limit, :integer, description: "Max results (default 100)"
  end

  alias NoizuPromptLingua.Domains.Campaigns
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    groups =
      Campaigns.list_ad_groups(Args.get(args, :campaign_id),
        status: Args.get(args, :status),
        limit: Args.get(args, :limit) || 100
      )

    {:ok, %{count: length(groups), ad_groups: Enum.map(groups, &%{id: &1.id, slug: &1.slug, name: &1.name, status: &1.status})}}
  end
end
