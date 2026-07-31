defmodule NoizuPromptLingua.Domains.Tickets.MCP do
  use Noizu.MCP.Server,
    name: "tobor_tickets",
    version: "0.1.0",
    instructions:
      "Ticket management domain — create and track tickets, queues, and custom field definitions."

  # Core CRUD
  tool(NoizuPromptLingua.Domains.Tickets.Tools.Overview, category: "Tickets")
  tool(NoizuPromptLingua.Domains.Tickets.Tools.TicketCreate, category: "Tickets")
  tool(NoizuPromptLingua.Domains.Tickets.Tools.TicketFromEntity, category: "Tickets")
  tool(NoizuPromptLingua.Domains.Tickets.Tools.TicketGet, category: "Tickets")
  tool(NoizuPromptLingua.Domains.Tickets.Tools.TicketUpdate, category: "Tickets")
  tool(NoizuPromptLingua.Domains.Tickets.Tools.TicketList, category: "Tickets")

  # Cross-cutting
  tool(NoizuPromptLingua.Domains.Tickets.Tools.TicketComment, category: "Tickets")
  tool(NoizuPromptLingua.Domains.Tickets.Tools.TicketWatch, category: "Tickets")
  tool(NoizuPromptLingua.Domains.Tickets.Tools.TicketAttach, category: "Tickets")
  tool(NoizuPromptLingua.Domains.Tickets.Tools.TicketFeed, category: "Tickets")

  # Links
  tool(NoizuPromptLingua.Domains.Tickets.Tools.TicketLink, category: "Tickets")
  tool(NoizuPromptLingua.Domains.Tickets.Tools.TicketUnlink, category: "Tickets")
  tool(NoizuPromptLingua.Domains.Tickets.Tools.TicketLinkEntity, category: "Tickets")
  tool(NoizuPromptLingua.Domains.Tickets.Tools.TicketUnlinkEntity, category: "Tickets")

  # Queues
  tool(NoizuPromptLingua.Domains.Tickets.Tools.QueueCreate, category: "Tickets.Queues")
  tool(NoizuPromptLingua.Domains.Tickets.Tools.QueueGet, category: "Tickets.Queues")
  tool(NoizuPromptLingua.Domains.Tickets.Tools.QueueList, category: "Tickets.Queues")
  tool(NoizuPromptLingua.Domains.Tickets.Tools.QueueFeed, category: "Tickets.Queues")

  # Type definitions
  tool(NoizuPromptLingua.Domains.Tickets.Tools.DefinitionCreate, category: "Tickets.Types")
  tool(NoizuPromptLingua.Domains.Tickets.Tools.DefinitionGet, category: "Tickets.Types")
  tool(NoizuPromptLingua.Domains.Tickets.Tools.DefinitionUpdate, category: "Tickets.Types")
  tool(NoizuPromptLingua.Domains.Tickets.Tools.DefinitionDelete, category: "Tickets.Types")

  # Field definitions
  tool(NoizuPromptLingua.Domains.Tickets.Tools.FieldDefinitionCreate, category: "Tickets.Fields")
  tool(NoizuPromptLingua.Domains.Tickets.Tools.FieldDefinitionUpdate, category: "Tickets.Fields")
  tool(NoizuPromptLingua.Domains.Tickets.Tools.FieldDefinitionDelete, category: "Tickets.Fields")

  # Discovery
  tool(NoizuPromptLingua.Tools.ToolSummary, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolSearch, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolDefinition, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolCall, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolHelp, category: "Discovery")
end
