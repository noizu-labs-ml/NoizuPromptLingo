defmodule NoizuPromptLingua.Domains.Chat.Tools.DeleteRoom do
  use Noizu.MCP.Server.Tool,
    name: "Chat.DeleteRoom",
    description:
      "Delete a chat room and its messages/events/members/notifications (cascade). Irreversible.",
    hidden: true,
    category: "Chat",
    annotations: [destructive_hint: true]

  input do
    field :room_id, :string, required: true, description: "Room UUID"
  end

  alias NoizuPromptLingua.Domains.Chat

  @impl true
  def call(args, _ctx) do
    room_id = args[:room_id] || args["room_id"]

    case Chat.delete_room(room_id) do
      {:ok, room} -> {:ok, %{deleted: true, id: room.id, slug: room.slug}}
      {:error, :not_found} -> {:error, "Room not found"}
      {:error, reason} -> {:error, "Delete failed: #{inspect(reason)}"}
    end
  end
end
