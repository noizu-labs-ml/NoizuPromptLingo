defmodule NoizuPromptLingua.Domains.Personas.Tools.KnowledgeDelete do
  use Noizu.MCP.Server.Tool,
    name: "Persona.Knowledge.Delete",
    description: "Delete a persona knowledge-base article by its id.",
    hidden: true,
    category: "Personas.Knowledge",
    annotations: [destructive_hint: true]

  input do
    field :id, :string, required: true, description: "Knowledge entry UUID"
  end

  alias NoizuPromptLingua.Domains.Personas
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    case Personas.delete_knowledge(Args.get(args, :id)) do
      {:ok, _} -> {:ok, %{deleted: true}}
      {:error, :not_found} -> {:error, "Knowledge entry not found"}
      {:error, _} -> {:error, "Failed to delete"}
    end
  end
end
