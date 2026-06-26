defmodule NoizuPromptLingua.Domains.Campaigns.Tools.CampaignUpdate do
  use Noizu.MCP.Server.Tool,
    name: "Campaign.Update",
    description: "Update fields on a campaign.",
    hidden: true,
    category: "Campaigns"

  input_schema %{
    "type" => "object",
    "properties" => %{
      "id" => %{"type" => "string", "description" => "Campaign UUID"},
      "name" => %{"type" => "string", "description" => "Name"},
      "channel" => %{"type" => "string", "description" => "seo, ppc, email, social, content, display"},
      "objective" => %{"type" => "string", "description" => "Objective"},
      "status" => %{"type" => "string", "description" => "draft, active, paused, completed, archived"},
      "budget_cents" => %{"type" => "integer", "description" => "Budget in cents"},
      "currency" => %{"type" => "string", "description" => "Currency code"},
      "start_date" => %{"type" => "string", "description" => "Start date (YYYY-MM-DD)"},
      "end_date" => %{"type" => "string", "description" => "End date (YYYY-MM-DD)"},
      "segment_id" => %{"type" => "string", "description" => "Target customer_segment UUID"},
      "targeting" => %{"type" => "object", "description" => "Targeting config"},
      "metadata" => %{"type" => "object", "description" => "Metadata"},
      "tags" => %{"type" => "array", "items" => %{"type" => "string"}, "description" => "Tags"}
    },
    "required" => ["id"]
  }

  alias NoizuPromptLingua.Domains.Campaigns
  alias NoizuPromptLingua.MCP.Args

  @fields ~w(name channel objective status budget_cents currency start_date end_date segment_id targeting metadata tags)a

  @impl true
  def call(args, _ctx) do
    id = Args.get(args, :id)

    case Campaigns.update_campaign(id, Args.take(args, @fields)) do
      {:ok, c} -> {:ok, %{id: c.id, slug: c.slug, name: c.name, status: c.status}}
      {:error, :not_found} -> {:error, "Campaign '#{id}' not found"}
      {:error, changeset} -> {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end
end
