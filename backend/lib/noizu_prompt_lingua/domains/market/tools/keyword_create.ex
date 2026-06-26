defmodule NoizuPromptLingua.Domains.Market.Tools.KeywordCreate do
  use Noizu.MCP.Server.Tool,
    name: "Keyword.Create",
    description: "Create a keyword-research row with optional SEO metrics.",
    hidden: true,
    category: "Market.Keywords"

  input_schema %{
    "type" => "object",
    "properties" => %{
      "organization" => %{"type" => "string", "description" => "Organization slug or UUID (required)"},
      "slug" => %{"type" => "string", "description" => "Keyword slug (unique per organization)"},
      "term" => %{"type" => "string", "description" => "The keyword term/phrase"},
      "project" => %{"type" => "string", "description" => "Optional project slug or UUID"},
      "intent" => %{"type" => "string", "description" => "informational, commercial, transactional, navigational"},
      "volume" => %{"type" => "integer", "description" => "Monthly search volume"},
      "difficulty" => %{"type" => "integer", "description" => "Difficulty 0-100"},
      "cpc" => %{"type" => "number", "description" => "Cost per click"},
      "competition" => %{"type" => "number", "description" => "Competition index"},
      "competitor_id" => %{"type" => "string", "description" => "Optional competitor UUID this term is associated with"},
      "source" => %{"type" => "string", "description" => "manual, llm, import"},
      "metadata" => %{"type" => "object", "description" => "Free-form metadata"},
      "tags" => %{"type" => "array", "items" => %{"type" => "string"}, "description" => "Tags"}
    },
    "required" => ["organization", "slug", "term"]
  }

  alias NoizuPromptLingua.Domains.Market
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @fields ~w(slug term intent volume difficulty cpc competition competitor_id source metadata tags)a

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)
    project_ref = Args.get(args, :project)

    with {:org, org_id} when not is_nil(org_id) <- {:org, Resolve.organization_id(org_ref)},
         {:ok, project_id} <- Resolve.project_in_org(project_ref, org_id) do
      attrs =
        Args.take(args, @fields)
        |> Map.put(:organization_id, org_id)
        |> Map.put(:project_id, project_id)
        |> Map.put_new(:source, "manual")

      case Market.create_keyword(attrs) do
        {:ok, k} -> {:ok, %{id: k.id, slug: k.slug, term: k.term, intent: k.intent, volume: k.volume, difficulty: k.difficulty}}
        {:error, changeset} -> {:error, "Failed: #{inspect(changeset.errors)}"}
      end
    else
      {:org, nil} -> {:error, "Organization '#{org_ref}' not found"}
      {:error, :project_not_found} -> {:error, "Project '#{project_ref}' not found"}
      {:error, :project_not_in_org} -> {:error, "Project '#{project_ref}' does not belong to this organization"}
    end
  end
end
