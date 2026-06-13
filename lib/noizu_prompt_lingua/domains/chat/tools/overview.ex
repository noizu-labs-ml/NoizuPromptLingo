defmodule NoizuPromptLingua.Domains.Chat.Tools.Overview do
  use Noizu.MCP.Server.Tool,
    name: "Chat.Overview",
    description: "List chat tools and active room counts.",
    annotations: [read_only_hint: true],
    category: "Chat"

  input do
  end

  @impl true
  def call(_args, _ctx) do
    {:ok, %{
      domain: "Chat",
      subdomain: "chat.tobor.locker",
      status: "stub",
      tools: [
        "Chat.CreateRoom", "Chat.GetRoom", "Chat.ListRooms",
        "Chat.SendMessage", "Chat.ListMessages",
        "Chat.CreateEvent", "Chat.ListEvents",
        "Chat.AddMember", "Chat.ListMembers",
        "Chat.Attach", "Chat.React",
        "Chat.Notifications", "Chat.Notification.Clear"
      ]
    }}
  end
end
