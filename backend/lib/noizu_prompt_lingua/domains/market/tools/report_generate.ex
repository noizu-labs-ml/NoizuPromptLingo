defmodule NoizuPromptLingua.Domains.Market.Tools.ReportGenerate do
  use Noizu.MCP.Server.Tool,
    name: "MarketReport.Generate",
    description:
      "Generate a market report body via LLM, store it as an artifact, and set the report's summary + artifact_id (status → ready).",
    hidden: true,
    category: "Market.Reports"

  input do
    field :id, :string, required: true, description: "Report UUID"

    field :prompt, :string,
      description:
        "Optional custom generation prompt (defaults to a prompt built from the report type/title)"

    field :provider, :string, description: "Override LLM provider"
    field :model, :string, description: "Override LLM model"

    field :llm_generate, :boolean,
      description: "Call the LLM (default true). Set false to echo the prompt with no provider."
  end

  alias NoizuPromptLingua.Domains.Market
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    id = Args.get(args, :id)
    llm_generate = Args.get(args, :llm_generate) not in [false, "false"]

    opts = [
      prompt: Args.get(args, :prompt),
      provider: Args.get(args, :provider),
      model: Args.get(args, :model),
      llm_generate: llm_generate
    ]

    case Market.generate_report(id, opts) do
      {:ok, r} ->
        {:ok,
         %{
           id: r.id,
           slug: r.slug,
           artifact_id: r.artifact_id,
           status: r.status,
           llm_generated: llm_generate
         }}

      {:error, :not_found} ->
        {:error, "Market report '#{id}' not found"}

      {:error, reason} ->
        {:error, "Generation failed: #{inspect(reason)}"}
    end
  end
end
