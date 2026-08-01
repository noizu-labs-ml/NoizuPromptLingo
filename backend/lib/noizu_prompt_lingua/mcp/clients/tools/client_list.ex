defmodule NoizuPromptLingua.MCP.Clients.Tools.ClientList do
  use Noizu.MCP.Server.Tool,
    name: "Client.List",
    description: "List clients for an organization.",
    hidden: true,
    category: "Clients",
    annotations: [read_only_hint: true]

  alias NoizuPromptLingua.MCP.{Args, Resolve}

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :status, :string, description: "active|archived|deleted|all (default active)"
  end

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)
    status = Args.get(args, :status) || "active"

    case Resolve.organization_id(org_ref) do
      nil ->
        {:error, "Organization '#{org_ref}' not found"}

      org_id ->
        clients = NoizuPromptLingua.Clients.list_for_org(org_id, status: status)

        {:ok,
         %{
           clients:
             Enum.map(clients, fn c ->
               %{
                 id: c.id,
                 name: c.name,
                 slug: c.slug,
                 status: c.status,
                 organization_id: c.organization_id,
                 currency: c.currency
               }
             end),
           count: length(clients)
         }}
    end
  end
end
