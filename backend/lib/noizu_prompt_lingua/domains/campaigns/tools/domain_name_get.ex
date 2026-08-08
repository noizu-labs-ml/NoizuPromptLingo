defmodule NoizuPromptLingua.Domains.Campaigns.Tools.DomainNameGet do
  use Noizu.MCP.Server.Tool,
    name: "DomainName.Get",
    description: "Fetch a domain name by UUID or (org-scoped) slug.",
    annotations: [read_only_hint: true],
    hidden: true,
    category: "Campaigns.Domains"

  input do
    field :organization, :string,
      description: "Organization slug or UUID (required for slug lookup)"

    field :id, :string, required: true, description: "Domain name UUID or slug"
  end

  alias NoizuPromptLingua.Domains.Campaigns
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    id = Args.get(args, :id)
    org_id = Resolve.organization_id(Args.get(args, :organization))

    case Campaigns.resolve_domain_name(org_id, id) do
      nil ->
        {:error, "Domain name '#{id}' not found"}

      d ->
        {:ok,
         %{
           id: d.id,
           slug: d.slug,
           name: d.name,
           status: d.status,
           registrar: d.registrar,
           registered_at: d.registered_at,
           expires_at: d.expires_at,
           campaign_id: d.campaign_id,
           tags: d.tags,
           organization_id: d.organization_id,
           project_id: d.project_id
         }}
    end
  end
end
