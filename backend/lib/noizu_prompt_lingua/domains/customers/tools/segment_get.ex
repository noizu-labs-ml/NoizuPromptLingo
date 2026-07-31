defmodule NoizuPromptLingua.Domains.Customers.Tools.SegmentGet do
  use Noizu.MCP.Server.Tool,
    name: "CustomerSegment.Get",
    description: "Fetch a customer segment by UUID or (org-scoped) slug.",
    annotations: [read_only_hint: true],
    hidden: true,
    category: "Customers.Segments"

  input do
    field :organization, :string,
      description: "Organization slug or UUID (required for slug lookup)"

    field :id, :string, required: true, description: "Segment UUID or slug"
  end

  alias NoizuPromptLingua.Domains.Customers
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    id = Args.get(args, :id)
    org_id = Resolve.organization_id(Args.get(args, :organization))

    case Customers.resolve_segment(org_id, id) do
      nil ->
        {:error, "Customer segment '#{id}' not found"}

      s ->
        {:ok,
         %{
           id: s.id,
           slug: s.slug,
           name: s.name,
           description: s.description,
           criteria: s.criteria,
           tags: s.tags,
           status: s.status,
           organization_id: s.organization_id,
           project_id: s.project_id
         }}
    end
  end
end
