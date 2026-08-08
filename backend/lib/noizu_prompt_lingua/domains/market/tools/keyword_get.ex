defmodule NoizuPromptLingua.Domains.Market.Tools.KeywordGet do
  use Noizu.MCP.Server.Tool,
    name: "Keyword.Get",
    description: "Fetch a keyword by UUID or (org-scoped) slug.",
    annotations: [read_only_hint: true],
    hidden: true,
    category: "Market.Keywords"

  input do
    field :organization, :string,
      description: "Organization slug or UUID (required for slug lookup)"

    field :id, :string, required: true, description: "Keyword UUID or slug"
  end

  alias NoizuPromptLingua.Domains.Market
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    id = Args.get(args, :id)
    org_id = Resolve.organization_id(Args.get(args, :organization))

    case Market.resolve_keyword(org_id, id) do
      nil ->
        {:error, "Keyword '#{id}' not found"}

      k ->
        {:ok,
         %{
           id: k.id,
           slug: k.slug,
           term: k.term,
           intent: k.intent,
           volume: k.volume,
           difficulty: k.difficulty,
           cpc: k.cpc,
           competition: k.competition,
           source: k.source,
           tags: k.tags,
           organization_id: k.organization_id,
           project_id: k.project_id
         }}
    end
  end
end
