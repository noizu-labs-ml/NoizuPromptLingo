defmodule NoizuPromptLingua.Domains.Assets.Tools.AssetGenerate do
  use Noizu.MCP.Server.Tool, name: "Asset.Generate",
    description: "Generate content from prompt YAML using LLM with format-specific references. Creates artifact with generated content.",
    hidden: true, category: "Assets"

  input do
    field :entry_id, :string, required: true, description: "Asset entry UUID"
    field :provider, :string, description: "Override LLM provider (openai, anthropic, z.ai, local)"
    field :model, :string, description: "Override LLM model"
    field :llm_generate, :boolean, description: "Call LLM to generate content (default true). Set false for placeholder only."
    field :actor, :string, description: "Actor persona"
  end

  alias NoizuPromptLingua.Domains.Assets

  @impl true
  def call(args, _ctx) do
    entry_id = args[:entry_id] || args["entry_id"]
    llm_generate = case args[:llm_generate] || args["llm_generate"] do
      false -> false
      "false" -> false
      _ -> true
    end
    opts = [
      provider: args[:provider] || args["provider"],
      model: args[:model] || args["model"],
      actor: args[:actor] || args["actor"],
      llm_generate: llm_generate
    ]
    case Assets.generate(entry_id, opts) do
      {:ok, output} -> {:ok, %{output_id: output.id, variant: output.variant_number, artifact_id: output.artifact_id, llm_generated: llm_generate}}
      {:error, reason} -> {:error, "Failed: #{inspect(reason)}"}
    end
  end
end
