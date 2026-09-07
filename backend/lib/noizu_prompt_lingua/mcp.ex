defmodule NoizuPromptLingua.MCP do
  @moduledoc """
  Public NPL syntax MCP server.

  This host serves the Noizu Prompt Lingo convention tools only (`NPLLoad`,
  `NPLSpec`). Agent-kit work surfaces (sessions, tickets, chat, …) live in
  the agent-kit-mcp repo. Authentication is not required; an OAuth site-approval
  token is accepted when a client presents one.
  """
  use NoizuPromptLingua.MCP.Server,
    name: "noizu_prompt_lingua",
    version: "0.1.0",
    instructions:
      "Noizu Prompt Lingo syntax conventions. Use NPLLoad (expression DSL) or " <>
        "NPLSpec (structured spec generation) to retrieve convention text. " <>
        "No authentication is required."

  tool(NoizuPromptLingua.Tools.NPLLoad, category: "NPL")
  tool(NoizuPromptLingua.Tools.NPLSpec, category: "NPL")
end
