defmodule NoizuPromptLingua.Domains.Market.Tools.CompetitorCreate do
  use Noizu.MCP.Server.Tool,
    name: "Competitor.Create",
    description: "Create a tracked competitor.",
    hidden: true,
    category: "Market.Competitors"

  input_schema %{
    "type" => "object",
    "properties" => %{
      "organization" => %{"type" => "string", "description" => "Organization slug or UUID (required)"},
      "slug" => %{"type" => "string", "description" => "Competitor slug (unique per organization)"},
      "name" => %{"type" => "string", "description" => "Competitor name"},
      "project" => %{"type" => "string", "description" => "Optional project slug or UUID"},
      "website" => %{"type" => "string", "description" => "Website URL"},
      "description" => %{"type" => "string", "description" => "Description"},
      "tier" => %{"type" => "string", "description" => "direct, indirect, or aspirational"},
      "strengths" => %{"type" => "array", "items" => %{"type" => "string"}, "description" => "Strengths"},
      "weaknesses" => %{"type" => "array", "items" => %{"type" => "string"}, "description" => "Weaknesses"},
      "metadata" => %{"type" => "object", "description" => "Free-form metadata"},
      "tags" => %{"type" => "array", "items" => %{"type" => "string"}, "description" => "Tags"}
    },
    "required" => ["organization", "slug", "name"]
  }

  alias NoizuPromptLingua.Domains.Market
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @fields ~w(slug name website description tier strengths weaknesses metadata tags)a

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

      case Market.create_competitor(attrs) do
        {:ok, c} -> {:ok, %{id: c.id, slug: c.slug, name: c.name, tier: c.tier}}
        {:error, changeset} -> {:error, "Failed: #{inspect(changeset.errors)}"}
      end
    else
      {:org, nil} -> {:error, "Organization '#{org_ref}' not found"}
      {:error, :project_not_found} -> {:error, "Project '#{project_ref}' not found"}
      {:error, :project_not_in_org} -> {:error, "Project '#{project_ref}' does not belong to this organization"}
    end
  end
end
