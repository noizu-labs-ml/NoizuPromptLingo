defmodule NoizuPromptLingua.Domains.Customers.Tools.PersonaCreate do
  use Noizu.MCP.Server.Tool,
    name: "CustomerPersona.Create",
    description:
      "Create a customer/user persona (ICP) — the marketing audience model, distinct from agent personas.",
    hidden: true,
    category: "Customers"

  input_schema(%{
    "type" => "object",
    "properties" => %{
      "organization" => %{
        "type" => "string",
        "description" => "Organization slug or UUID (required)"
      },
      "slug" => %{"type" => "string", "description" => "Persona slug (unique per organization)"},
      "name" => %{"type" => "string", "description" => "Persona name"},
      "project" => %{
        "type" => "string",
        "description" => "Optional project slug or UUID to scope this persona"
      },
      "archetype" => %{"type" => "string", "description" => "Archetype, e.g. 'Technical Buyer'"},
      "segment_id" => %{"type" => "string", "description" => "Optional customer_segment UUID"},
      "demographics" => %{
        "type" => "object",
        "description" => "Demographics (age/role/income/location/company size)"
      },
      "goals" => %{"type" => "array", "items" => %{"type" => "string"}, "description" => "Goals"},
      "pains" => %{
        "type" => "array",
        "items" => %{"type" => "string"},
        "description" => "Pain points"
      },
      "channels" => %{
        "type" => "array",
        "items" => %{"type" => "string"},
        "description" => "Channels to reach this persona"
      },
      "motivations" => %{"type" => "string", "description" => "Motivations"},
      "objections" => %{"type" => "string", "description" => "Common objections"},
      "summary" => %{"type" => "string", "description" => "Short summary/bio"},
      "tags" => %{"type" => "array", "items" => %{"type" => "string"}, "description" => "Tags"}
    },
    "required" => ["organization", "slug", "name"]
  })

  alias NoizuPromptLingua.Domains.Customers
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @fields ~w(slug name archetype segment_id demographics goals pains channels motivations objections summary tags)a

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

      case Customers.create_persona(attrs) do
        {:ok, p} ->
          {:ok,
           %{
             id: p.id,
             slug: p.slug,
             name: p.name,
             organization_id: p.organization_id,
             project_id: p.project_id,
             status: p.status
           }}

        {:error, changeset} ->
          {:error, "Failed: #{inspect(changeset.errors)}"}
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
