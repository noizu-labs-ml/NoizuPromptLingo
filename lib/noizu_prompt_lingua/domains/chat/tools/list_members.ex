defmodule NoizuPromptLingua.Domains.Chat.Tools.ListMembers do
  use Noizu.MCP.Server.Tool,
    name: "Chat.ListMembers", description: "List room members.", hidden: true, category: "Chat",
    annotations: [read_only_hint: true]

  input do
    field :room_id, :string, required: true, description: "Room UUID"
  end

  alias NoizuPromptLingua.Domains.Chat

  @impl true
  def call(args, _ctx) do
    room_id = args[:room_id] || args["room_id"]
    members = Chat.list_members(room_id)
    {:ok, %{members: Enum.map(members, &%{id: &1.id, persona: &1.persona, role: &1.role}), count: length(members)}}
  end
end
