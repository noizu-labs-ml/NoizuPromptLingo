defmodule NoizuPromptLingua.Domains.Chat.Tools.Overview do
  use Noizu.MCP.Server.Tool,
    name: "Chat.Overview",
    description: "List chat tools and room activity summary.",
    annotations: [read_only_hint: true],
    category: "Chat"

  input do
  end

  alias NoizuPromptLingua.Domains.Chat

  @impl true
  def call(_args, _ctx) do
    {:ok,
     %{
       domain: "Chat",
       subdomain: "chat.tobor.locker",
       room_count: Chat.room_count(),
       tools: %{
         rooms: ["Chat.CreateRoom", "Chat.GetRoom", "Chat.ListRooms", "Chat.DM"],
         messages: [
           "Chat.SendMessage",
           "Chat.ListMessages",
           "Chat.PinMessage",
           "Chat.HighlightMessage",
           "Chat.ScheduleMessage",
           "Chat.ForwardReplies"
         ],
         events: ["Chat.CreateEvent", "Chat.ListEvents"],
         members: [
           "Chat.AddMember",
           "Chat.ListMembers",
           "Chat.JoinRoom",
           "Chat.LeaveRoom",
           "Chat.MuteRoom"
         ],
         interactions: ["Chat.Attach", "Chat.React", "Chat.AttachWiki"],
         notifications: ["Chat.Notifications", "Chat.Notification.Clear"]
       }
     }}
  end
end
