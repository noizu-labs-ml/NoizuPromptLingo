defmodule NoizuPromptLingua.Domains.UnicodeCodex.MCP do
  use NoizuPromptLingua.MCP.Server,
    name: "tobor_unicode",
    version: "0.1.0",
    instructions:
      "Unicode Codex domain — layered global/org/project Unicode glyph, control-code, invisible-character, and NPL special-usage browsing."

  tool(NoizuPromptLingua.Domains.UnicodeCodex.Tools.Overview, category: "Unicode")
  tool(NoizuPromptLingua.Domains.UnicodeCodex.Tools.Search, category: "Unicode")
  tool(NoizuPromptLingua.Domains.UnicodeCodex.Tools.Get, category: "Unicode")

  tool(NoizuPromptLingua.Domains.UnicodeCodex.Tools.SpecialUsageList,
    category: "Unicode.SpecialUsage"
  )

  tool(NoizuPromptLingua.Domains.UnicodeCodex.Tools.SpecialUsageGet,
    category: "Unicode.SpecialUsage"
  )

  tool(NoizuPromptLingua.Domains.UnicodeCodex.Tools.Related, category: "Unicode")

  tool(NoizuPromptLingua.Tools.ToolSummary, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolSearch, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolDefinition, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolCall, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolHelp, category: "Discovery")
end
