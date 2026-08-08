defmodule NoizuPromptLingua.Domains.Campaigns.Tools.CampaignGet do
  use Noizu.MCP.Server.Tool,
    name: "Campaign.Get",
    description: "Fetch a campaign by UUID or (org-scoped) slug.",
    annotations: [read_only_hint: true],
    hidden: true,
    category: "Campaigns"

  input do
    field :organization, :string,
      description: "Organization slug or UUID (required for slug lookup)"

    field :id, :string, required: true, description: "Campaign UUID or slug"
  end

  alias NoizuPromptLingua.Domains.Campaigns
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    id = Args.get(args, :id)
    org_id = Resolve.organization_id(Args.get(args, :organization))

    case Campaigns.resolve_campaign(org_id, id) do
      nil ->
        {:error, "Campaign '#{id}' not found"}

      c ->
        {:ok,
         %{
           id: c.id,
           slug: c.slug,
           name: c.name,
           channel: c.channel,
           objective: c.objective,
           status: c.status,
           budget_cents: c.budget_cents,
           currency: c.currency,
           start_date: c.start_date,
           end_date: c.end_date,
           segment_id: c.segment_id,
           targeting: c.targeting,
           tags: c.tags,
           organization_id: c.organization_id,
           project_id: c.project_id
         }}
    end
  end
end
