defmodule NoizuPromptLingua.Domains.Browser.MCP do
  use Noizu.MCP.Server,
    name: "tobor_browser",
    version: "0.1.0",
    instructions:
      "Browser domain — drive a Playwright browser running on the user's local machine, relayed over a websocket."

  tool NoizuPromptLingua.Domains.Browser.Tools.Overview, category: "Browser"

  tool NoizuPromptLingua.Domains.Browser.Tools.Navigate, category: "Browser"
  tool NoizuPromptLingua.Domains.Browser.Tools.Screenshot, category: "Browser"
  tool NoizuPromptLingua.Domains.Browser.Tools.Click, category: "Browser"
  tool NoizuPromptLingua.Domains.Browser.Tools.Fill, category: "Browser"
  tool NoizuPromptLingua.Domains.Browser.Tools.GetState, category: "Browser"

  tool NoizuPromptLingua.Tools.ToolSummary, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolSearch, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolDefinition, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolCall, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolHelp, category: "Discovery"
end
