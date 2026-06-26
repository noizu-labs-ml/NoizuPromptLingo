defmodule NoizuPromptLingua.Domains.Customers.Tools.SegmentList do
  use Noizu.MCP.Server.Tool,
    name: "CustomerSegment.List",
    description: "List customer segments for an organization, optionally filtered by project, status, or tag.",
    annotations: [read_only_hint: true],
    hidden: true,
    category: "Customers.Segments"

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :project, :string, description: "Optional project slug or UUID filter"
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

        segments =
          Customers.list_segments(
            organization_id: org_id,
            project_id: project_id,
            status: Args.get(args, :status),
            tag: Args.get(args, :tag),
            limit: Args.get(args, :limit) || 100
          )

        {:ok, %{count: length(segments), segments: Enum.map(segments, &%{id: &1.id, slug: &1.slug, name: &1.name, status: &1.status})}}
    end
  end
end
