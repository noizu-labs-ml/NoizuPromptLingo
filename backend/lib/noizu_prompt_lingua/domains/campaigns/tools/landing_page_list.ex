defmodule NoizuPromptLingua.Domains.Campaigns.Tools.LandingPageList do
  use Noizu.MCP.Server.Tool,
    name: "LandingPage.List",
    description:
      "List landing pages for an organization, optionally filtered by project, campaign, status, or tag.",
    annotations: [read_only_hint: true],
    hidden: true,
    category: "Campaigns.LandingPages"

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :project, :string, description: "Optional project slug or UUID filter"
    field :campaign_id, :string, description: "Optional campaign UUID filter"
    field :status, :string, description: "Optional status filter"
    field :tag, :string, description: "Optional tag filter"
    field :limit, :integer, description: "Max results (default 100)"
  end

  alias NoizuPromptLingua.Domains.Campaigns
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    case Resolve.organization_id(Args.get(args, :organization)) do
      nil ->
        {:error, "Organization not found"}

      org_id ->
        {:ok, project_id} = Resolve.project_in_org(Args.get(args, :project), org_id)

        pages =
          Campaigns.list_landing_pages(
            organization_id: org_id,
            project_id: project_id,
            campaign_id: Args.get(args, :campaign_id),
            status: Args.get(args, :status),
            tag: Args.get(args, :tag),
            limit: Args.get(args, :limit) || 100
          )

        {:ok,
         %{
           count: length(pages),
           landing_pages:
             Enum.map(pages, &%{id: &1.id, slug: &1.slug, title: &1.title, status: &1.status})
         }}
    end
  end
end
