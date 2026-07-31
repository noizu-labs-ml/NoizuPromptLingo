defmodule NoizuPromptLingua.Domains.Customers.Tools.PersonaDraft do
  use Noizu.MCP.Server.Tool,
    name: "CustomerPersona.Draft",
    description:
      "Generate a long-form customer persona profile via LLM, store it as an artifact, and set the persona's summary + artifact_id.",
    hidden: true,
    category: "Customers"

  input do
    field :id, :string, required: true, description: "Persona UUID"

    field :prompt, :string,
      description:
        "Optional custom generation prompt (defaults to a profile prompt built from the persona's fields)"

    field :provider, :string,
      description: "Override LLM provider (openai, anthropic, z.ai, local)"

    field :model, :string, description: "Override LLM model"

    field :llm_generate, :boolean,
      description: "Call the LLM (default true). Set false to echo the prompt with no provider."
  end

  alias NoizuPromptLingua.Domains.Customers
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

    case Customers.draft_persona(id, opts) do
      {:ok, p} ->
        {:ok, %{id: p.id, slug: p.slug, artifact_id: p.artifact_id, llm_generated: llm_generate}}

      {:error, :not_found} ->
        {:error, "Customer persona '#{id}' not found"}

      {:error, reason} ->
        {:error, "Generation failed: #{inspect(reason)}"}
    end
  end
end
