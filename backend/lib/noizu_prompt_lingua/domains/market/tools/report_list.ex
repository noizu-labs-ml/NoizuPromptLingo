defmodule NoizuPromptLingua.Domains.Market.Tools.ReportList do
  use Noizu.MCP.Server.Tool,
    name: "MarketReport.List",
    description:
      "List market reports for an organization, optionally filtered by project, report_type, status, or tag.",
    annotations: [read_only_hint: true],
    hidden: true,
    category: "Market.Reports"

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :project, :string, description: "Optional project slug or UUID filter"
    field :report_type, :string, description: "Optional report_type filter"
    field :status, :string, description: "Optional status filter"
    field :tag, :string, description: "Optional tag filter"
    field :limit, :integer, description: "Max results (default 100)"
  end

  alias NoizuPromptLingua.Domains.Market
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    case Resolve.organization_id(Args.get(args, :organization)) do
      nil ->
        {:error, "Organization not found"}

      org_id ->
        {:ok, project_id} = Resolve.project_in_org(Args.get(args, :project), org_id)

        reports =
          Market.list_reports(
            organization_id: org_id,
            project_id: project_id,
            report_type: Args.get(args, :report_type),
            status: Args.get(args, :status),
            tag: Args.get(args, :tag),
            limit: Args.get(args, :limit) || 100
          )

        {:ok,
         %{
           count: length(reports),
           reports:
             Enum.map(
               reports,
               &%{
                 id: &1.id,
                 slug: &1.slug,
                 title: &1.title,
                 report_type: &1.report_type,
                 status: &1.status
               }
             )
         }}
    end
  end
end
