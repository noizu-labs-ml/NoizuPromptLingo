defmodule NoizuPromptLingua.Domains.Campaigns.Tools.CampaignCreate do
  use Noizu.MCP.Server.Tool,
    name: "Campaign.Create",
    description: "Create a marketing campaign (seo, ppc, email, social, content, display).",
    hidden: true,
    category: "Campaigns"

  input_schema %{
    "type" => "object",
    "properties" => %{
      "organization" => %{"type" => "string", "description" => "Organization slug or UUID (required)"},
      "slug" => %{"type" => "string", "description" => "Campaign slug (unique per organization)"},
      "name" => %{"type" => "string", "description" => "Campaign name"},
      "channel" => %{"type" => "string", "description" => "seo, ppc, email, social, content, display"},
      "project" => %{"type" => "string", "description" => "Optional project slug or UUID"},
      "objective" => %{"type" => "string", "description" => "Campaign objective"},
      "status" => %{"type" => "string", "description" => "draft (default), active, paused, completed, archived"},
      "budget_cents" => %{"type" => "integer", "description" => "Budget in cents"},
      "currency" => %{"type" => "string", "description" => "Currency code (default USD)"},
      "start_date" => %{"type" => "string", "description" => "Start date (YYYY-MM-DD)"},
      "end_date" => %{"type" => "string", "description" => "End date (YYYY-MM-DD)"},
      "segment_id" => %{"type" => "string", "description" => "Optional target customer_segment UUID"},
      "targeting" => %{"type" => "object", "description" => "Targeting config (audiences/geo/keywords)"},
      "metadata" => %{"type" => "object", "description" => "Free-form metadata"},
      "tags" => %{"type" => "array", "items" => %{"type" => "string"}, "description" => "Tags"}
    },
    "required" => ["organization", "slug", "name", "channel"]
  }

  alias NoizuPromptLingua.Domains.Campaigns
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @fields ~w(slug name channel objective status budget_cents currency start_date end_date segment_id targeting metadata tags)a

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

      case Campaigns.create_campaign(attrs) do
        {:ok, c} -> {:ok, %{id: c.id, slug: c.slug, name: c.name, channel: c.channel, status: c.status}}
        {:error, changeset} -> {:error, "Failed: #{inspect(changeset.errors)}"}
      end
    else
      {:org, nil} -> {:error, "Organization '#{org_ref}' not found"}
      {:error, :project_not_found} -> {:error, "Project '#{project_ref}' not found"}
      {:error, :project_not_in_org} -> {:error, "Project '#{project_ref}' does not belong to this organization"}
    end
  end
end
