defmodule NoizuPromptLingua.Domains.Campaigns.Tools.AdGroupCreate do
  use Noizu.MCP.Server.Tool,
    name: "AdGroup.Create",
    description: "Create an ad group within a campaign.",
    hidden: true,
    category: "Campaigns.AdGroups"

  input_schema %{
    "type" => "object",
    "properties" => %{
      "campaign_id" => %{"type" => "string", "description" => "Parent campaign UUID (required)"},
      "slug" => %{"type" => "string", "description" => "Ad group slug (unique per campaign)"},
      "name" => %{"type" => "string", "description" => "Ad group name"},
      "theme" => %{"type" => "string", "description" => "Theme / focus"},
      "keywords" => %{"type" => "array", "items" => %{"type" => "string"}, "description" => "Keyword terms"},
      "bid_cents" => %{"type" => "integer", "description" => "Default bid in cents"},
      "metadata" => %{"type" => "object", "description" => "Free-form metadata"}
    },
    "required" => ["campaign_id", "slug", "name"]
  }

  alias NoizuPromptLingua.Domains.Campaigns
  alias NoizuPromptLingua.MCP.Args

  @fields ~w(campaign_id slug name theme keywords bid_cents metadata)a

  @impl true
  def call(args, _ctx) do
    campaign_id = Args.get(args, :campaign_id)

    case Campaigns.get_campaign(campaign_id) do
      nil ->
        {:error, "Campaign '#{campaign_id}' not found"}

      campaign ->
        attrs =
          Args.take(args, @fields)
          |> Map.put(:organization_id, campaign.organization_id)
          |> Map.put(:project_id, campaign.project_id)

        case Campaigns.create_ad_group(attrs) do
          {:ok, g} -> {:ok, %{id: g.id, slug: g.slug, name: g.name, campaign_id: g.campaign_id}}
          {:error, changeset} -> {:error, "Failed: #{inspect(changeset.errors)}"}
        end
    end
  end
end
