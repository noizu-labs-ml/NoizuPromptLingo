defmodule NoizuPromptLingua.Domains.Campaigns.Tools.LandingPageCreate do
  use Noizu.MCP.Server.Tool,
    name: "LandingPage.Create",
    description: "Create a landing page (body generated separately via LandingPage.Generate).",
    hidden: true,
    category: "Campaigns.LandingPages"

  input_schema(%{
    "type" => "object",
    "properties" => %{
      "organization" => %{
        "type" => "string",
        "description" => "Organization slug or UUID (required)"
      },
      "slug" => %{"type" => "string", "description" => "Page slug (unique per organization)"},
      "title" => %{"type" => "string", "description" => "Page title"},
      "project" => %{"type" => "string", "description" => "Optional project slug or UUID"},
      "path" => %{"type" => "string", "description" => "URL path"},
      "headline" => %{"type" => "string", "description" => "Hero headline"},
      "campaign_id" => %{"type" => "string", "description" => "Optional campaign UUID"},
      "domain_name_id" => %{"type" => "string", "description" => "Optional domain_name UUID"},
      "metadata" => %{"type" => "object", "description" => "Free-form metadata"},
      "tags" => %{"type" => "array", "items" => %{"type" => "string"}, "description" => "Tags"}
    },
    "required" => ["organization", "slug", "title"]
  })

  alias NoizuPromptLingua.Domains.Campaigns
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @fields ~w(slug title path headline campaign_id domain_name_id metadata tags)a

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

      case Campaigns.create_landing_page(attrs) do
        {:ok, p} -> {:ok, %{id: p.id, slug: p.slug, title: p.title, status: p.status}}
        {:error, changeset} -> {:error, "Failed: #{inspect(changeset.errors)}"}
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
