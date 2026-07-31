defmodule NoizuPromptLingua.Domains.Campaigns.Tools.AdCopyGenerate do
  use Noizu.MCP.Server.Tool,
    name: "AdCopy.Generate",
    description:
      "LLM-generate N ad-copy variants for a campaign (optionally an ad group), store the copy as an artifact, and insert one row per variant.",
    hidden: true,
    category: "Campaigns.AdCopy"

  input do
    field :campaign_id, :string, required: true, description: "Campaign UUID"
    field :ad_group_id, :string, description: "Optional ad group UUID"
    field :count, :integer, description: "Number of variants (default 3)"
    field :format, :string, description: "search (default), display, social"
    field :prompt, :string, description: "Optional custom generation prompt"
    field :provider, :string, description: "Override LLM provider"
    field :model, :string, description: "Override LLM model"

    field :llm_generate, :boolean,
      description: "Call the LLM (default true). Set false to echo the prompt with no provider."
  end

  alias NoizuPromptLingua.Domains.Campaigns
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    campaign_id = Args.get(args, :campaign_id)
    llm_generate = Args.get(args, :llm_generate) not in [false, "false"]

    opts = [
      ad_group_id: Args.get(args, :ad_group_id),
      count: Args.get(args, :count) || 3,
      format: Args.get(args, :format) || "search",
      prompt: Args.get(args, :prompt),
      provider: Args.get(args, :provider),
      model: Args.get(args, :model),
      llm_generate: llm_generate
    ]

    case Campaigns.generate_ad_copy(campaign_id, opts) do
      {:ok, rows} ->
        {:ok,
         %{
           created: length(rows),
           llm_generated: llm_generate,
           ad_copies:
             Enum.map(
               rows,
               &%{id: &1.id, variant_number: &1.variant_number, artifact_id: &1.artifact_id}
             )
         }}

      {:error, :not_found} ->
        {:error, "Campaign '#{campaign_id}' not found"}

      {:error, reason} ->
        {:error, "Generation failed: #{inspect(reason)}"}
    end
  end
end
