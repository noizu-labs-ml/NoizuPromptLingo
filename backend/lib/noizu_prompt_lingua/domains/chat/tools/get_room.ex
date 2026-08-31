defmodule NoizuPromptLingua.Domains.Chat.Tools.GetRoom do
  use Noizu.MCP.Server.Tool,
    name: "Chat.GetRoom",
    description: "Get room details.",
    hidden: false,
    category: "Chat",
    annotations: [read_only_hint: true]

  input do
    field :room_id, :string, required: true, description: "Room slug or UUID (slug preferred)"
    field :organization, :string,
      description: "Org slug or UUID (required when room is addressed by slug)"
  end

  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.Domains.Chat.Tools.RoomResolver

  @impl true
  def call(args, _ctx) do
    with {:ok, room} <- RoomResolver.call(args) do
      members = Chat.list_members(room.id)
      attachments = Chat.room_attachments(room.id)

      {:ok,
       %{
         id: room.id,
         name: room.name,
         slug: room.slug,
         kind: room.kind,
         organization_id: room.organization_id,
         project_id: room.project_id,
         description: room.description,
         session_id: room.session_id,
         member_count: length(members),
         attachments:
           Enum.map(attachments, &NoizuPromptLingua.Domains.Chat.Serialize.attachment/1),
         created_at: room.inserted_at
       }}
    else
      {:error, :organization_required} ->
        {:error, "organization is required when the room is addressed by slug"}

      {:error, msg} when is_binary(msg) ->
        {:error, msg}

      {:error, _} ->
        {:error, "Room not found"}
    end
  end
end
