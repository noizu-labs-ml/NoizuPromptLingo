defmodule NoizuPromptLingua.Domains.Customers.Tools.Overview do
  use Noizu.MCP.Server.Tool, name: "Customers.Overview",
    description: "List customer-domain tools and the customer-persona count for an organization.",
    annotations: [read_only_hint: true], category: "Customers"

  input do
    field :organization, :string, description: "Organization slug or UUID — scopes the count"
  end

  alias NoizuPromptLingua.Domains.Customers
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    count =
      case Resolve.organization_id(Args.get(args, :organization)) do
        nil -> 0
        org_id -> Customers.count_personas(org_id)
      end

    {:ok, %{domain: "Customers", subdomain: "customers.tobor.locker",
      customer_persona_count: count,
      tools: %{
        personas: ~w(CustomerPersona.Create CustomerPersona.Get CustomerPersona.Update
                     CustomerPersona.List CustomerPersona.Draft CustomerPersona.LinkTicket
                     CustomerPersona.UnlinkTicket),
        segments: ~w(CustomerSegment.Create CustomerSegment.Get CustomerSegment.Update CustomerSegment.List)
      }}}
  end
end
