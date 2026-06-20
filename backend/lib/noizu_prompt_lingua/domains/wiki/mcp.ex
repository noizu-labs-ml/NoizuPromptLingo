defmodule NoizuPromptLingua.Domains.Wiki.MCP do
  use Noizu.MCP.Server,
    name: "tobor_wiki",
    version: "0.1.0",
    instructions: "Wiki domain — manage spaces, pages, comments, attachments, and reactions."

  tool NoizuPromptLingua.Domains.Wiki.Tools.Overview, category: "Wiki"

  tool NoizuPromptLingua.Domains.Wiki.Tools.SpaceList, category: "Wiki"
  tool NoizuPromptLingua.Domains.Wiki.Tools.SpaceGet, category: "Wiki"
  tool NoizuPromptLingua.Domains.Wiki.Tools.SpaceCreate, category: "Wiki"
  tool NoizuPromptLingua.Domains.Wiki.Tools.SpaceUpdate, category: "Wiki"
  tool NoizuPromptLingua.Domains.Wiki.Tools.SpaceDelete, category: "Wiki"

  tool NoizuPromptLingua.Domains.Wiki.Tools.PageList, category: "Wiki"
  tool NoizuPromptLingua.Domains.Wiki.Tools.PageGet, category: "Wiki"
  tool NoizuPromptLingua.Domains.Wiki.Tools.PageCreate, category: "Wiki"
  tool NoizuPromptLingua.Domains.Wiki.Tools.PageUpdate, category: "Wiki"
  tool NoizuPromptLingua.Domains.Wiki.Tools.PageDelete, category: "Wiki"

  tool NoizuPromptLingua.Domains.Wiki.Tools.CommentList, category: "Wiki"
  tool NoizuPromptLingua.Domains.Wiki.Tools.CommentCreate, category: "Wiki"
  tool NoizuPromptLingua.Domains.Wiki.Tools.CommentDelete, category: "Wiki"

  tool NoizuPromptLingua.Domains.Wiki.Tools.AttachmentList, category: "Wiki"
  tool NoizuPromptLingua.Domains.Wiki.Tools.AttachmentCreate, category: "Wiki"
  tool NoizuPromptLingua.Domains.Wiki.Tools.AttachmentDelete, category: "Wiki"

  tool NoizuPromptLingua.Domains.Wiki.Tools.ReactionList, category: "Wiki"
  tool NoizuPromptLingua.Domains.Wiki.Tools.ReactionAdd, category: "Wiki"
  tool NoizuPromptLingua.Domains.Wiki.Tools.ReactionRemove, category: "Wiki"

  tool NoizuPromptLingua.Tools.ToolSummary, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolSearch, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolDefinition, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolCall, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolHelp, category: "Discovery"
end
