defmodule NoizuPromptLingua.Domains.Market.Tools.ReportCreate do
  use Noizu.MCP.Server.Tool,
    name: "MarketReport.Create",
    description: "Create a market/competitor analysis report shell (body is generated separately via MarketReport.Generate).",
    hidden: true,
    category: "Market.Reports"

  input_schema %{
    "type" => "object",
    "properties" => %{
      "organization" => %{"type" => "string", "description" => "Organization slug or UUID (required)"},
      "slug" => %{"type" => "string", "description" => "Report slug (unique per organization)"},
      "title" => %{"type" => "string", "description" => "Report title"},
      "project" => %{"type" => "string", "description" => "Optional project slug or UUID"},
      "report_type" => %{"type" => "string", "description" => "market_analysis (default), competitor_analysis, swot, keyword_summary"},
      "summary" => %{"type" => "string", "description" => "Short abstract"},
      "competitor_id" => %{"type" => "string", "description" => "Optional competitor UUID for competitor-scoped reports"},
      "segment_id" => %{"type" => "string", "description" => "Optional customer_segment UUID"},
      "parameters" => %{"type" => "object", "description" => "Generation inputs / parameters"},
      "tags" => %{"type" => "array", "items" => %{"type" => "string"}, "description" => "Tags"}
    },
    "required" => ["organization", "slug", "title"]
  }

  alias NoizuPromptLingua.Domains.Market
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @fields ~w(slug title report_type summary competitor_id segment_id parameters tags)a

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)
    project_ref = Args.get(args, :project)

    with {:org, org_id} when not is_nil(org_id) <- {:org, Resolve.organization_id(org_ref)},
         {:ok, project_id} <- Resolve.project_in_org(project_ref, org_id) do
      attrs =
        Args.take(args, @fields)
        |> Map.put(:organization_id, org_id)
        |> Map.put(:project_id, project_id)
        |> Map.put_new(:report_type, "market_analysis")

      case Market.create_report(attrs) do
        {:ok, r} -> {:ok, %{id: r.id, slug: r.slug, title: r.title, report_type: r.report_type, status: r.status}}
        {:error, changeset} -> {:error, "Failed: #{inspect(changeset.errors)}"}
      end
    else
      {:org, nil} -> {:error, "Organization '#{org_ref}' not found"}
      {:error, :project_not_found} -> {:error, "Project '#{project_ref}' not found"}
      {:error, :project_not_in_org} -> {:error, "Project '#{project_ref}' does not belong to this organization"}
    end
  end
end
