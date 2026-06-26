defmodule NoizuPromptLingua.Domains.Market.MCP do
  use Noizu.MCP.Server,
    name: "tobor_market",
    version: "0.1.0",
    instructions: "Market domain — competitors, keyword research, and market/competitor analysis reports (LLM-generated bodies stored as artifacts)."

  tool NoizuPromptLingua.Domains.Market.Tools.Overview, category: "Market"

  tool NoizuPromptLingua.Domains.Market.Tools.CompetitorCreate, category: "Market.Competitors"
  tool NoizuPromptLingua.Domains.Market.Tools.CompetitorGet, category: "Market.Competitors"
  tool NoizuPromptLingua.Domains.Market.Tools.CompetitorUpdate, category: "Market.Competitors"
  tool NoizuPromptLingua.Domains.Market.Tools.CompetitorList, category: "Market.Competitors"

  tool NoizuPromptLingua.Domains.Market.Tools.KeywordCreate, category: "Market.Keywords"
  tool NoizuPromptLingua.Domains.Market.Tools.KeywordGet, category: "Market.Keywords"
  tool NoizuPromptLingua.Domains.Market.Tools.KeywordUpdate, category: "Market.Keywords"
  tool NoizuPromptLingua.Domains.Market.Tools.KeywordList, category: "Market.Keywords"
  tool NoizuPromptLingua.Domains.Market.Tools.KeywordResearch, category: "Market.Keywords"

  tool NoizuPromptLingua.Domains.Market.Tools.ReportCreate, category: "Market.Reports"
  tool NoizuPromptLingua.Domains.Market.Tools.ReportGet, category: "Market.Reports"
  tool NoizuPromptLingua.Domains.Market.Tools.ReportList, category: "Market.Reports"
  tool NoizuPromptLingua.Domains.Market.Tools.ReportGenerate, category: "Market.Reports"

  tool NoizuPromptLingua.Tools.ToolSummary, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolSearch, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolDefinition, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolCall, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolHelp, category: "Discovery"
end
