defmodule NoizuPromptLingua.Domains.Market.Tools.KeywordList do
  use Noizu.MCP.Server.Tool,
    name: "Keyword.List",
    description: "List keywords for an organization, optionally filtered by project, intent, or tag (ordered by volume).",
    annotations: [read_only_hint: true],
    hidden: true,
    category: "Market.Keywords"

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :project, :string, description: "Optional project slug or UUID filter"
    field :intent, :string, description: "Optional intent filter"
    field :tag, :string, description: "Optional tag filter"
    field :limit, :integer, description: "Max results (default 100)"
  end

  alias NoizuPromptLingua.Domains.Market
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    case Resolve.organization_id(Args.get(args, :organization)) do
      nil ->
        {:error, "Organization not found"}

      org_id ->
        {:ok, project_id} = Resolve.project_in_org(Args.get(args, :project), org_id)

        keywords =
          Market.list_keywords(
            organization_id: org_id,
            project_id: project_id,
            intent: Args.get(args, :intent),
            tag: Args.get(args, :tag),
            limit: Args.get(args, :limit) || 100
          )

        {:ok, %{count: length(keywords), keywords: Enum.map(keywords, &%{id: &1.id, term: &1.term, intent: &1.intent, volume: &1.volume, difficulty: &1.difficulty, cpc: &1.cpc})}}
    end
  end
end
