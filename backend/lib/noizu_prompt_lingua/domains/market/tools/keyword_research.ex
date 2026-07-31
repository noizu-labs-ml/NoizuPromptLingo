defmodule NoizuPromptLingua.Domains.Market.Tools.KeywordResearch do
  use Noizu.MCP.Server.Tool,
    name: "Keyword.Research",
    description:
      "LLM-generate a set of candidate keywords (term/intent/volume/difficulty/cpc) for a topic and bulk-insert them.",
    hidden: true,
    category: "Market.Keywords"

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"

    field :topic, :string,
      required: true,
      description: "Topic / seed phrase to research keywords for"

    field :project, :string, description: "Optional project slug or UUID"
    field :count, :integer, description: "Max keywords to generate (default 15)"
    field :provider, :string, description: "Override LLM provider"
    field :model, :string, description: "Override LLM model"
  end

  alias NoizuPromptLingua.Domains.Market
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)
    project_ref = Args.get(args, :project)

    with {:org, org_id} when not is_nil(org_id) <- {:org, Resolve.organization_id(org_ref)},
         {:ok, project_id} <- Resolve.project_in_org(project_ref, org_id) do
      opts = [
        count: Args.get(args, :count) || 15,
        provider: Args.get(args, :provider),
        model: Args.get(args, :model)
      ]

      case Market.research_keywords(org_id, project_id, Args.get(args, :topic), opts) do
        {:ok, keywords} ->
          {:ok,
           %{
             created: length(keywords),
             keywords:
               Enum.map(
                 keywords,
                 &%{
                   id: &1.id,
                   term: &1.term,
                   intent: &1.intent,
                   volume: &1.volume,
                   difficulty: &1.difficulty
                 }
               )
           }}

        {:error, reason} ->
          {:error, "Research failed: #{inspect(reason)}"}
      end
    else
      {:org, nil} ->
        {:error, "Organization '#{org_ref}' not found"}

      {:error, :project_not_found} ->
        {:error, "Project '#{project_ref}' not found"}

      {:error, :project_not_in_org} ->
        {:error, "Project '#{project_ref}' does not belong to this organization"}
    end
  end
end
