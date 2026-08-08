defmodule NoizuPromptLingua.Domains.Campaigns.Tools.DomainNameCreate do
  use Noizu.MCP.Server.Tool,
    name: "DomainName.Create",
    description: "Create a domain-name candidate or registration record.",
    hidden: true,
    category: "Campaigns.Domains"

  input_schema(%{
    "type" => "object",
    "properties" => %{
      "organization" => %{
        "type" => "string",
        "description" => "Organization slug or UUID (required)"
      },
      "slug" => %{"type" => "string", "description" => "Slug (unique per organization)"},
      "name" => %{"type" => "string", "description" => "The FQDN, e.g. example.com"},
      "project" => %{"type" => "string", "description" => "Optional project slug or UUID"},
      "status" => %{
        "type" => "string",
        "description" => "candidate (default), available, registered, in_use, expired"
      },
      "registrar" => %{"type" => "string", "description" => "Registrar"},
      "registered_at" => %{"type" => "string", "description" => "Registration date (YYYY-MM-DD)"},
      "expires_at" => %{"type" => "string", "description" => "Expiry date (YYYY-MM-DD)"},
      "campaign_id" => %{"type" => "string", "description" => "Optional campaign UUID"},
      "metadata" => %{"type" => "object", "description" => "Free-form metadata"},
      "tags" => %{"type" => "array", "items" => %{"type" => "string"}, "description" => "Tags"}
    },
    "required" => ["organization", "slug", "name"]
  })

  alias NoizuPromptLingua.Domains.Campaigns
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @fields ~w(slug name status registrar registered_at expires_at campaign_id metadata tags)a

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

      case Campaigns.create_domain_name(attrs) do
        {:ok, d} -> {:ok, %{id: d.id, slug: d.slug, name: d.name, status: d.status}}
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
