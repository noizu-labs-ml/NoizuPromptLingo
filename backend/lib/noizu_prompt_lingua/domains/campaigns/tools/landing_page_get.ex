defmodule NoizuPromptLingua.Domains.Campaigns.Tools.LandingPageGet do
  use Noizu.MCP.Server.Tool,
    name: "LandingPage.Get",
    description: "Fetch a landing page by UUID or (org-scoped) slug.",
    annotations: [read_only_hint: true],
    hidden: true,
    category: "Campaigns.LandingPages"

  input do
    field :organization, :string,
      description: "Organization slug or UUID (required for slug lookup)"

    field :id, :string, required: true, description: "Landing page UUID or slug"
  end

  alias NoizuPromptLingua.Domains.Campaigns
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    id = Args.get(args, :id)
    org_id = Resolve.organization_id(Args.get(args, :organization))

    case Campaigns.resolve_landing_page(org_id, id) do
      nil ->
        {:error, "Landing page '#{id}' not found"}

      p ->
        {:ok,
         %{
           id: p.id,
           slug: p.slug,
           title: p.title,
           path: p.path,
           headline: p.headline,
           campaign_id: p.campaign_id,
           domain_name_id: p.domain_name_id,
           artifact_id: p.artifact_id,
           status: p.status,
           organization_id: p.organization_id,
           project_id: p.project_id
         }}
    end
  end
end
