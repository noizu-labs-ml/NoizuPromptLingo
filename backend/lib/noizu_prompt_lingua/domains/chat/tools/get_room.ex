defmodule NoizuPromptLingua.Domains.Chat.Tools.GetRoom do
  use Noizu.MCP.Server.Tool,
    name: "Chat.GetRoom", description: "Get room details.", hidden: true, category: "Chat",
    annotations: [read_only_hint: true]

  input do
    field :room_id, :string, required: true, description: "Room UUID"
  end

  alias NoizuPromptLingua.Domains.Chat

  @impl true
  def call(args, _ctx) do
    room_id = args[:room_id] || args["room_id"]
    case Chat.get_room(room_id) do
      nil -> {:error, "Room not found"}
      room ->
        members = Chat.list_members(room_id)
        attachments = Chat.room_attachments(room_id)
        {:ok, %{id: room.id, name: room.name, slug: room.slug, kind: room.kind,
                organization_id: room.organization_id, project_id: room.project_id,
                description: room.description, session_id: room.session_id,
                member_count: length(members),
                attachments: Enum.map(attachments, &NoizuPromptLingua.Domains.Chat.Serialize.attachment/1),
                created_at: room.inserted_at}}
    end
  end
end
