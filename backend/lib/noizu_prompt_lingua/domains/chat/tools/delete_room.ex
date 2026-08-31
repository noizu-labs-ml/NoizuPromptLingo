defmodule NoizuPromptLingua.Domains.Chat.Tools.DeleteRoom do
  use Noizu.MCP.Server.Tool,
    name: "Chat.DeleteRoom",
    description:
      "Delete a chat room and its messages/events/members/notifications (cascade). Irreversible.",
    hidden: true,
    category: "Chat",
    annotations: [destructive_hint: true]

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
      case Chat.delete_room(room.id) do
        {:ok, deleted} -> {:ok, %{deleted: true, id: deleted.id, slug: deleted.slug}}
        {:error, :not_found} -> {:error, "Room not found"}
        {:error, reason} -> {:error, "Delete failed: #{inspect(reason)}"}
      end
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
