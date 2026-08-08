defmodule NoizuPromptLingua.Domains.Memory.Tools.Recall do
  @moduledoc false
  use Noizu.MCP.Server.Tool,
    name: "Memory.Recall",
    description:
      "Active multi-path recall by a text query (semantic + emotional + association-graph, RRF-fused) " <>
        "for an agent scope. Returns ranked memories with their four facets and mood.",
    annotations: [read_only_hint: true],
    category: "Memory"

  input do
    field :organization, :string,
      required: true,
      description: "Organization slug or UUID (required)"

    field :scope_type, :string, required: true, description: "persona | weego | team_member"

    field :agent, :string,
      description: "Persona slug/uuid or agent call sign (omit for the org weego)"

    field :query, :string, required: true, description: "The recall query text"
    field :limit, :number, description: "Max results (default 12)"
  end

  alias NoizuPromptLingua.MCP.Args
  alias NoizuPromptLingua.Domains.Memory
  alias NoizuPromptLingua.Domains.Memory.Tools.Scope

  @impl true
  def call(args, _ctx) do
    with {:ok, context} <- Scope.resolve(args) do
      query = Args.get(args, :query)
      limit = trunc(Args.get(args, :limit) || 12)

      case Memory.recall(query, [limit: limit], context) do
        {:ok, %{results: results, xml: xml}} ->
          {:ok,
           %{count: length(results), results: Enum.map(results, &Scope.memory_view/1), xml: xml}}

        {:error, reason} ->
          {:error, "recall failed: #{inspect(reason)}"}
      end
    end
  end
end
