defmodule NoizuPromptLingua.Domains.Memory.Tools.RecallByEmotion do
  @moduledoc false
  use Noizu.MCP.Server.Tool,
    name: "Memory.RecallByEmotion",
    description:
      "Emotional-resonance recall: returns the memories whose emotional state is closest to the " <>
      "given mood (valence/arousal/dominance) for an agent scope.",
    annotations: [read_only_hint: true],
    category: "Memory"

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID (required)"
    field :scope_type, :string, required: true, description: "persona | weego | team_member"
    field :agent, :string, description: "Persona slug/uuid or agent call sign (omit for the org weego)"
    field :valence, :number, description: "Target valence -1.0 .. 1.0"
    field :arousal, :number, description: "Target arousal 0.0 .. 1.0"
    field :dominance, :number, description: "Target dominance 0.0 .. 1.0"
    field :limit, :number, description: "Max results (default 12)"
  end

  alias NoizuPromptLingua.MCP.Args
  alias NoizuPromptLingua.Domains.Memory
  alias NoizuPromptLingua.Domains.Memory.Tools.Scope

  @impl true
  def call(args, _ctx) do
    with {:ok, context} <- Scope.resolve(args) do
      limit = trunc(Args.get(args, :limit) || 12)
      mood = %{
        valence: Args.get(args, :valence) || 0.0,
        arousal: Args.get(args, :arousal) || 0.5,
        dominance: Args.get(args, :dominance) || 0.5
      }

      case Memory.recall_by_emotion(%{mood: mood}, [limit: limit], context) do
        {:ok, %{results: results, xml: xml}} ->
          {:ok, %{count: length(results), results: Enum.map(results, &Scope.memory_view/1), xml: xml}}

        {:error, reason} ->
          {:error, "recall_by_emotion failed: #{inspect(reason)}"}
      end
    end
  end
end
