defmodule NoizuPromptLingua.Domains.Chat.Tools.Notifications do
  use Noizu.MCP.Server.Tool,
    name: "Chat.Notifications", description: "List unread notifications for a persona.", hidden: true, category: "Chat",
    annotations: [read_only_hint: true]

  input do
    field :persona, :string, required: true, description: "Persona slug"
    field :limit, :integer, description: "Max notifications (default 50)"
  end

  alias NoizuPromptLingua.Domains.Chat

  @impl true
  def call(args, _ctx) do
    persona = args[:persona] || args["persona"]
    limit = args[:limit] || args["limit"]
    opts = if limit, do: [limit: limit], else: []
    notifs = Chat.list_notifications(persona, opts)
    {:ok, %{notifications: Enum.map(notifs, &%{id: &1.id, room_id: &1.room_id, message: &1.message, created_at: &1.inserted_at}), count: length(notifs)}}
  end
end
