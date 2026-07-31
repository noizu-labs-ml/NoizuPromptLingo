defmodule NoizuPromptLingua.Domains.Campaigns.Tools.LandingPageGenerate do
  use Noizu.MCP.Server.Tool,
    name: "LandingPage.Generate",
    description:
      "LLM-generate a landing page body (HTML), store it as an artifact, and set the page's artifact_id.",
    hidden: true,
    category: "Campaigns.LandingPages"

  input do
    field :id, :string, required: true, description: "Landing page UUID"
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
    id = Args.get(args, :id)
    llm_generate = Args.get(args, :llm_generate) not in [false, "false"]

    opts = [
      prompt: Args.get(args, :prompt),
      provider: Args.get(args, :provider),
      model: Args.get(args, :model),
      llm_generate: llm_generate
    ]

    case Campaigns.generate_landing_page(id, opts) do
      {:ok, p} ->
        {:ok, %{id: p.id, slug: p.slug, artifact_id: p.artifact_id, llm_generated: llm_generate}}

      {:error, :not_found} ->
        {:error, "Landing page '#{id}' not found"}

      {:error, reason} ->
        {:error, "Generation failed: #{inspect(reason)}"}
    end
  end
end
