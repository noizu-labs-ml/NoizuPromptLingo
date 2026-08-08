defmodule NoizuPromptLingua.Domains.Customers.MCP do
  use NoizuPromptLingua.MCP.Server,
    name: "tobor_customers",
    version: "0.1.0",
    instructions:
      "Customers domain — customer/user personas (ICPs) and market segments, with ticket linking. Distinct from the agent personas domain."

  tool(NoizuPromptLingua.Domains.Customers.Tools.Overview, category: "Customers")
  tool(NoizuPromptLingua.Domains.Customers.Tools.PersonaCreate, category: "Customers")
  tool(NoizuPromptLingua.Domains.Customers.Tools.PersonaGet, category: "Customers")
  tool(NoizuPromptLingua.Domains.Customers.Tools.PersonaUpdate, category: "Customers")
  tool(NoizuPromptLingua.Domains.Customers.Tools.PersonaList, category: "Customers")
  tool(NoizuPromptLingua.Domains.Customers.Tools.PersonaDraft, category: "Customers")
  tool(NoizuPromptLingua.Domains.Customers.Tools.PersonaLinkTicket, category: "Customers.Links")
  tool(NoizuPromptLingua.Domains.Customers.Tools.PersonaUnlinkTicket, category: "Customers.Links")

  tool(NoizuPromptLingua.Domains.Customers.Tools.SegmentCreate, category: "Customers.Segments")
  tool(NoizuPromptLingua.Domains.Customers.Tools.SegmentGet, category: "Customers.Segments")
  tool(NoizuPromptLingua.Domains.Customers.Tools.SegmentUpdate, category: "Customers.Segments")
  tool(NoizuPromptLingua.Domains.Customers.Tools.SegmentList, category: "Customers.Segments")

  tool(NoizuPromptLingua.Tools.ToolSummary, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolSearch, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolDefinition, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolCall, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolHelp, category: "Discovery")
end
