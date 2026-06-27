defmodule NoizuPromptLingua.Domains.Notifications.MCP do
  use Noizu.MCP.Server,
    name: "tobor_notifications",
    version: "0.1.0",
    instructions:
      "Notifications domain — a per-recipient inbox that replaces the agent pipe bus. Notify sends a short DM (<=128 chars) to a user, list of users, group, or list of groups. Run a Monitor on Notifications.Poll to be woken the instant a notification arrives instead of polling on a timer; Notifications.Get is the immediate cursor pull. Mark items seen/read/ack and clear. Notifications are also generated automatically by mentions, channel digests, reactions/comments, ticket assignment, follow-ups, pings, watches, and pubsub channel availability."

  tool NoizuPromptLingua.Domains.Notifications.Tools.Overview, category: "Notifications"
  tool NoizuPromptLingua.Domains.Notifications.Tools.Notify, category: "Notifications"
  tool NoizuPromptLingua.Domains.Notifications.Tools.Get, category: "Notifications"
  tool NoizuPromptLingua.Domains.Notifications.Tools.Poll, category: "Notifications"
  tool NoizuPromptLingua.Domains.Notifications.Tools.MarkRead, category: "Notifications"
  tool NoizuPromptLingua.Domains.Notifications.Tools.MarkSeen, category: "Notifications"
  tool NoizuPromptLingua.Domains.Notifications.Tools.Ack, category: "Notifications"
  tool NoizuPromptLingua.Domains.Notifications.Tools.Clear, category: "Notifications"

  tool NoizuPromptLingua.Tools.ToolSummary, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolSearch, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolDefinition, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolCall, category: "Discovery"
  tool NoizuPromptLingua.Tools.ToolHelp, category: "Discovery"
end
