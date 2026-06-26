defmodule NoizuPromptLingua.Domains.Market.Tools.ReportGet do
  use Noizu.MCP.Server.Tool,
    name: "MarketReport.Get",
    description: "Fetch a market report by UUID or (org-scoped) slug.",
    annotations: [read_only_hint: true],
    hidden: true,
    category: "Market.Reports"

  input do
    field :organization, :string, description: "Organization slug or UUID (required for slug lookup)"
    field :id, :string, required: true, description: "Report UUID or slug"
  end

  alias NoizuPromptLingua.Domains.Market
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    id = Args.get(args, :id)
    org_id = Resolve.organization_id(Args.get(args, :organization))

    case Market.resolve_report(org_id, id) do
      nil -> {:error, "Market report '#{id}' not found"}
      r -> {:ok, %{id: r.id, slug: r.slug, title: r.title, report_type: r.report_type, summary: r.summary, artifact_id: r.artifact_id, status: r.status, parameters: r.parameters, organization_id: r.organization_id, project_id: r.project_id}}
    end
  end
end
