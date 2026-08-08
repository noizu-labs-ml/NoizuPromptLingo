defmodule NoizuPromptLingua.Domains.Campaigns.Tools.AdCopyCreate do
  use Noizu.MCP.Server.Tool,
    name: "AdCopy.Create",
    description: "Create an ad-copy variant (manual entry).",
    hidden: true,
    category: "Campaigns.AdCopy"

  input_schema(%{
    "type" => "object",
    "properties" => %{
      "campaign_id" => %{"type" => "string", "description" => "Parent campaign UUID (required)"},
      "ad_group_id" => %{"type" => "string", "description" => "Optional ad group UUID"},
      "headline" => %{"type" => "string", "description" => "Headline"},
      "body" => %{"type" => "string", "description" => "Body copy"},
      "cta" => %{"type" => "string", "description" => "Call to action"},
      "format" => %{"type" => "string", "description" => "search, display, social"},
      "metadata" => %{"type" => "object", "description" => "Free-form metadata"}
    },
    "required" => ["campaign_id"]
  })

  alias NoizuPromptLingua.Domains.Campaigns
  alias NoizuPromptLingua.MCP.Args

  @fields ~w(campaign_id ad_group_id headline body cta format metadata)a

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

        case Campaigns.create_ad_copy(attrs) do
          {:ok, a} ->
            {:ok,
             %{id: a.id, variant_number: a.variant_number, headline: a.headline, status: a.status}}

          {:error, changeset} ->
            {:error, "Failed: #{inspect(changeset.errors)}"}
        end
    end
  end
end
