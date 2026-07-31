defmodule NoizuPromptLingua.Domains.Customers.Tools.PersonaGet do
  use Noizu.MCP.Server.Tool,
    name: "CustomerPersona.Get",
    description: "Fetch a customer persona by UUID or (org-scoped) slug.",
    annotations: [read_only_hint: true],
    hidden: true,
    category: "Customers"

  input do
    field :organization, :string,
      description: "Organization slug or UUID (required for slug lookup)"

    field :id, :string, required: true, description: "Persona UUID or slug"
  end

  alias NoizuPromptLingua.Domains.Customers
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    id = Args.get(args, :id)
    org_id = Resolve.organization_id(Args.get(args, :organization))

    case Customers.resolve_persona(org_id, id) do
      nil -> {:error, "Customer persona '#{id}' not found"}
      p -> {:ok, persona_view(p)}
    end
  end

  defp persona_view(p) do
    %{
      id: p.id,
      slug: p.slug,
      name: p.name,
      archetype: p.archetype,
      segment_id: p.segment_id,
      demographics: p.demographics,
      goals: p.goals,
      pains: p.pains,
      channels: p.channels,
      motivations: p.motivations,
      objections: p.objections,
      summary: p.summary,
      artifact_id: p.artifact_id,
      tags: p.tags,
      status: p.status,
      organization_id: p.organization_id,
      project_id: p.project_id
    }
  end
end
