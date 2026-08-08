defmodule NoizuPromptLingua.Domains.Memory.Tools.Remember do
  @moduledoc false
  use Noizu.MCP.Server.Tool,
    name: "Memory.Remember",
    description:
      "Capture a memory for an agent scope. `organization`, `scope_type` (persona|weego|team_member) " <>
        "and `content` are required; `agent` identifies the persona slug / call sign (omit for the " <>
        "org's weego). Optionally add `context` (what you were doing), `reflection` (thoughts/feelings/" <>
        "mood in words), and `tangent` (what else it makes you think of) — each is embedded for search; " <>
        "the tangent also seeds an association. Supply `valence`/`arousal`/`dominance` for mood.",
    category: "Memory"

  input do
    field :organization, :string,
      required: true,
      description: "Organization slug or UUID (required)"

    field :scope_type, :string, required: true, description: "persona | weego | team_member"

    field :agent, :string,
      description: "Persona slug/uuid or agent call sign (omit for the org weego)"

    field :content, :string, required: true, description: "The memory / event itself (required)"
    field :context, :string, description: "What you were doing when this happened (situational)"
    field :reflection, :string, description: "Your thoughts / feelings / mood, in words"
    field :tangent, :string, description: "What else this memory makes you think of"
    field :summary, :string, description: "Optional short summary for injection"

    field :content_type, :string,
      description: "episodic | semantic | procedural (default episodic)"

    field :valence, :number, description: "Mood valence -1.0 (negative) .. 1.0 (positive)"
    field :arousal, :number, description: "Mood arousal 0.0 (calm) .. 1.0 (excited)"
    field :dominance, :number, description: "Mood dominance 0.0 (helpless) .. 1.0 (in control)"
    field :domain, :string, description: "e.g. debugging, design, ops"
    field :topic, :string, description: "Conversation topic"
    field :collaborators, :string, description: "Comma-separated collaborator ids/names"
    field :compartment, :string, description: "Access compartment (default \"default\")"
    field :classification, :string, description: "open | restricted | sealed (default open)"
  end

  alias NoizuPromptLingua.MCP.Args
  alias NoizuPromptLingua.Domains.Memory
  alias NoizuPromptLingua.Domains.Memory.Tools.Scope

  @impl true
  def call(args, _ctx) do
    with {:ok, context} <- Scope.resolve(args) do
      attrs = %{
        content: Args.get(args, :content),
        context: Args.get(args, :context),
        reflection: Args.get(args, :reflection),
        tangent: Args.get(args, :tangent),
        summary: Args.get(args, :summary),
        content_type: Args.get(args, :content_type) || "episodic",
        mood: mood(args),
        domain: Args.get(args, :domain),
        topic: Args.get(args, :topic),
        collaborators: split(Args.get(args, :collaborators)),
        compartment: Args.get(args, :compartment) || "default",
        classification: Args.get(args, :classification) || "open"
      }

      case Memory.remember(attrs, context) do
        {:ok, %{id: id, status: status, confidence: conf}} ->
          {:ok, %{id: id, status: to_string(status), confidence: conf}}

        {:error, reason} ->
          {:error, "remember failed: #{inspect(reason)}"}
      end
    end
  end

  defp mood(args) do
    vals =
      [:valence, :arousal, :dominance]
      |> Enum.reduce(%{}, fn k, acc ->
        case Args.get(args, k) do
          nil -> acc
          v -> Map.put(acc, k, v)
        end
      end)

    if vals == %{}, do: nil, else: vals
  end

  defp split(nil), do: []
  defp split(""), do: []

  defp split(s) when is_binary(s),
    do: s |> String.split(",", trim: true) |> Enum.map(&String.trim/1)
end
