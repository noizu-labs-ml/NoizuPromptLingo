defmodule NoizuPromptLingua.Domains.Chat.MCP do
  use NoizuPromptLingua.MCP.Server,
    name: "tobor_chat",
    version: "0.1.0",
    instructions: "Chat domain — manage rooms, messages, events, members, and notifications."

  tool(NoizuPromptLingua.Domains.Chat.Tools.Overview, category: "Chat")
  tool(NoizuPromptLingua.Domains.Chat.Tools.CreateRoom, category: "Chat")
  tool(NoizuPromptLingua.Domains.Chat.Tools.GetRoom, category: "Chat")
  tool(NoizuPromptLingua.Domains.Chat.Tools.DeleteRoom, category: "Chat")
  tool(NoizuPromptLingua.Domains.Chat.Tools.ListRooms, category: "Chat")
  tool(NoizuPromptLingua.Domains.Chat.Tools.SendMessage, category: "Chat")
  tool(NoizuPromptLingua.Domains.Chat.Tools.ListMessages, category: "Chat")
  tool(NoizuPromptLingua.Domains.Chat.Tools.CreateEvent, category: "Chat")
  tool(NoizuPromptLingua.Domains.Chat.Tools.ListEvents, category: "Chat")
  tool(NoizuPromptLingua.Domains.Chat.Tools.AddMember, category: "Chat")
  tool(NoizuPromptLingua.Domains.Chat.Tools.ListMembers, category: "Chat")
  tool(NoizuPromptLingua.Domains.Chat.Tools.ChatAttach, category: "Chat")
  tool(NoizuPromptLingua.Domains.Chat.Tools.ChatReact, category: "Chat")
  tool(NoizuPromptLingua.Domains.Chat.Tools.Notifications, category: "Chat")
  tool(NoizuPromptLingua.Domains.Chat.Tools.NotificationClear, category: "Chat")

  # Stream D — DMs, membership, pins/highlights, scheduling, threading
  tool(NoizuPromptLingua.Domains.Chat.Tools.DM, category: "Chat")
  tool(NoizuPromptLingua.Domains.Chat.Tools.MuteRoom, category: "Chat")
  tool(NoizuPromptLingua.Domains.Chat.Tools.LeaveRoom, category: "Chat")
  tool(NoizuPromptLingua.Domains.Chat.Tools.JoinRoom, category: "Chat")
  tool(NoizuPromptLingua.Domains.Chat.Tools.AttachWiki, category: "Chat")
  tool(NoizuPromptLingua.Domains.Chat.Tools.PinMessage, category: "Chat")
  tool(NoizuPromptLingua.Domains.Chat.Tools.HighlightMessage, category: "Chat")
  tool(NoizuPromptLingua.Domains.Chat.Tools.ScheduleMessage, category: "Chat")
  tool(NoizuPromptLingua.Domains.Chat.Tools.ForwardReplies, category: "Chat")

  tool(NoizuPromptLingua.Tools.ToolSummary, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolSearch, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolDefinition, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolCall, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolHelp, category: "Discovery")
end
