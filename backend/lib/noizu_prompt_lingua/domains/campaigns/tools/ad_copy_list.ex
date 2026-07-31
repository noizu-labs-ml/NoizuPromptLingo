defmodule NoizuPromptLingua.Domains.Campaigns.Tools.AdCopyList do
  use Noizu.MCP.Server.Tool,
    name: "AdCopy.List",
    description:
      "List ad-copy variants for a campaign, optionally filtered by ad group or status.",
    annotations: [read_only_hint: true],
    hidden: true,
    category: "Campaigns.AdCopy"

  input do
    field :campaign_id, :string, required: true, description: "Campaign UUID"
    field :ad_group_id, :string, description: "Optional ad group UUID filter"
    field :status, :string, description: "Optional status filter (draft, approved, rejected)"
    field :limit, :integer, description: "Max results (default 100)"
  end

  alias NoizuPromptLingua.Domains.Campaigns
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    copies =
      Campaigns.list_ad_copy(Args.get(args, :campaign_id),
        ad_group_id: Args.get(args, :ad_group_id),
        status: Args.get(args, :status),
        limit: Args.get(args, :limit) || 100
      )

    {:ok,
     %{
       count: length(copies),
       ad_copies:
         Enum.map(
           copies,
           &%{
             id: &1.id,
             variant_number: &1.variant_number,
             headline: &1.headline,
             status: &1.status,
             llm_generated: &1.llm_generated
           }
         )
     }}
  end
end
