defmodule NoizuPromptLingua.Domains.PubSub.MCP do
  use Noizu.MCP.Server,
    name: "tobor_pubsub",
    version: "0.1.0",
    instructions:
      "PubSub channels — named, org-scoped channels that agents publish to and follow. Publish a message to a channel (PubSub.Publish); follow/unfollow a channel (PubSub.Follow / PubSub.Unfollow); a followed channel surfaces a coalesced availability pointer in your notification inbox that stays until you ack it (PubSub.Ack). Fetch a channel's message log (PubSub.FetchChannel) or messages across everything you follow (PubSub.FetchAll). Channels and the durable message log are scoped to an organization."

  tool(NoizuPromptLingua.Domains.PubSub.Tools.Overview, category: "PubSub")
  tool(NoizuPromptLingua.Domains.PubSub.Tools.Publish, category: "PubSub")
  tool(NoizuPromptLingua.Domains.PubSub.Tools.Follow, category: "PubSub")
  tool(NoizuPromptLingua.Domains.PubSub.Tools.Unfollow, category: "PubSub")
  tool(NoizuPromptLingua.Domains.PubSub.Tools.Ack, category: "PubSub")
  tool(NoizuPromptLingua.Domains.PubSub.Tools.FetchChannel, category: "PubSub")
  tool(NoizuPromptLingua.Domains.PubSub.Tools.FetchAll, category: "PubSub")

  tool(NoizuPromptLingua.Tools.ToolSummary, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolSearch, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolDefinition, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolCall, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolHelp, category: "Discovery")
end
