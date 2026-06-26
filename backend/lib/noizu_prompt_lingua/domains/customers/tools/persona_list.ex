defmodule NoizuPromptLingua.Domains.Customers.Tools.PersonaList do
  use Noizu.MCP.Server.Tool,
    name: "CustomerPersona.List",
    description: "List customer personas for an organization, optionally filtered by project, segment, status, or tag.",
    annotations: [read_only_hint: true],
    hidden: true,
    category: "Customers"

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :project, :string, description: "Optional project slug or UUID filter"
    field :segment_id, :string, description: "Optional customer_segment UUID filter"
    field :status, :string, description: "Optional status filter"
    field :tag, :string, description: "Optional tag filter"
    field :limit, :integer, description: "Max results (default 100)"
  end

  alias NoizuPromptLingua.Domains.Customers
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    case Resolve.organization_id(Args.get(args, :organization)) do
      nil ->
        {:error, "Organization not found"}

      org_id ->
        {:ok, project_id} = Resolve.project_in_org(Args.get(args, :project), org_id)

        personas =
          Customers.list_personas(
            organization_id: org_id,
            project_id: project_id,
            segment_id: Args.get(args, :segment_id),
            status: Args.get(args, :status),
            tag: Args.get(args, :tag),
            limit: Args.get(args, :limit) || 100
          )

        {:ok, %{count: length(personas), personas: Enum.map(personas, &%{id: &1.id, slug: &1.slug, name: &1.name, archetype: &1.archetype, segment_id: &1.segment_id, status: &1.status})}}
    end
  end
end
