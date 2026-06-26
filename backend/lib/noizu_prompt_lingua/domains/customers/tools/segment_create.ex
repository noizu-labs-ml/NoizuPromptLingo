defmodule NoizuPromptLingua.Domains.Customers.Tools.SegmentCreate do
  use Noizu.MCP.Server.Tool,
    name: "CustomerSegment.Create",
    description: "Create a customer/market segment.",
    hidden: true,
    category: "Customers.Segments"

  input_schema %{
    "type" => "object",
    "properties" => %{
      "organization" => %{"type" => "string", "description" => "Organization slug or UUID (required)"},
      "slug" => %{"type" => "string", "description" => "Segment slug (unique per organization)"},
      "name" => %{"type" => "string", "description" => "Segment name"},
      "project" => %{"type" => "string", "description" => "Optional project slug or UUID"},
      "description" => %{"type" => "string", "description" => "Description"},
      "criteria" => %{"type" => "object", "description" => "Firmographic/demographic filter criteria"},
      "tags" => %{"type" => "array", "items" => %{"type" => "string"}, "description" => "Tags"}
    },
    "required" => ["organization", "slug", "name"]
  }

  alias NoizuPromptLingua.Domains.Customers
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @fields ~w(slug name description criteria tags)a

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

      case Customers.create_segment(attrs) do
        {:ok, s} -> {:ok, %{id: s.id, slug: s.slug, name: s.name, organization_id: s.organization_id, project_id: s.project_id}}
        {:error, changeset} -> {:error, "Failed: #{inspect(changeset.errors)}"}
      end
    else
      {:org, nil} -> {:error, "Organization '#{org_ref}' not found"}
      {:error, :project_not_found} -> {:error, "Project '#{project_ref}' not found"}
      {:error, :project_not_in_org} -> {:error, "Project '#{project_ref}' does not belong to this organization"}
    end
  end
end
