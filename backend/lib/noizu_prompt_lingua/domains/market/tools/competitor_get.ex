defmodule NoizuPromptLingua.Domains.Market.Tools.CompetitorGet do
  use Noizu.MCP.Server.Tool,
    name: "Competitor.Get",
    description: "Fetch a competitor by UUID or (org-scoped) slug.",
    annotations: [read_only_hint: true],
    hidden: true,
    category: "Market.Competitors"

  input do
    field :organization, :string, description: "Organization slug or UUID (required for slug lookup)"
    field :id, :string, required: true, description: "Competitor UUID or slug"
  end

  alias NoizuPromptLingua.Domains.Market
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    id = Args.get(args, :id)
    org_id = Resolve.organization_id(Args.get(args, :organization))

    case Market.resolve_competitor(org_id, id) do
      nil -> {:error, "Competitor '#{id}' not found"}
      c -> {:ok, %{id: c.id, slug: c.slug, name: c.name, website: c.website, description: c.description, tier: c.tier, strengths: c.strengths, weaknesses: c.weaknesses, tags: c.tags, status: c.status, organization_id: c.organization_id, project_id: c.project_id}}
    end
  end
end
