defmodule NoizuPromptLingua.Domains.Tickets.Tools.TicketLinkEntity do
  use Noizu.MCP.Server.Tool,
    name: "Ticket.LinkEntity",
    description:
      "Link a ticket to a non-ticket entity (customer_persona, customer_segment, campaign, keyword, competitor, market_report, landing_page, domain_name, ad_group, ad_copy).",
    hidden: true,
    category: "Tickets"

  input_schema(%{
    "type" => "object",
    "properties" => %{
      "ticket_id" => %{"type" => "string", "description" => "Ticket UUID"},
      "entity_type" => %{
        "type" => "string",
        "description" =>
          "Entity type: customer_persona, customer_segment, campaign, keyword, competitor, market_report, landing_page, domain_name, ad_group, ad_copy"
      },
      "entity_id" => %{"type" => "string", "description" => "UUID of the linked entity"},
      "link_type" => %{
        "type" => "string",
        "description" =>
          "relates_to (default), targets, derived_from, addresses, blocks, references"
      },
      "metadata" => %{"type" => "object", "description" => "Optional metadata for the link"}
    },
    "required" => ["ticket_id", "entity_type", "entity_id"]
  })

  alias NoizuPromptLingua.Domains.Links
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    ticket_id = Args.get(args, :ticket_id)
    entity_type = Args.get(args, :entity_type)
    entity_id = Args.get(args, :entity_id)

    opts = [
      link_type: Args.get(args, :link_type) || "relates_to",
      metadata: Args.get(args, :metadata) || %{}
    ]

    case Links.link_entity(ticket_id, entity_type, entity_id, opts) do
      {:ok, link} ->
        {:ok,
         %{
           id: link.id,
           ticket_id: ticket_id,
           entity_type: link.entity_type,
           entity_id: entity_id,
           link_type: link.link_type
         }}

      {:error, :ticket_not_found} ->
        {:error, "Ticket '#{ticket_id}' not found"}

      {:error, changeset} ->
        {:error, "Failed: #{inspect(changeset.errors)}"}
    end
  end
end
