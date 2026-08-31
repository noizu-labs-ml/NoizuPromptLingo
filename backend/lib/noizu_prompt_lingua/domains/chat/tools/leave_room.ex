defmodule NoizuPromptLingua.Domains.Chat.Tools.LeaveRoom do
  use Noizu.MCP.Server.Tool,
    name: "Chat.LeaveRoom",
    description: "Mark a persona as having left a room.",
    hidden: true,
    category: "Chat"

  input do
    field :room_id, :string, required: true, description: "Room slug or UUID (slug preferred)"
    field :organization, :string,
      description: "Org slug or UUID (required when room is addressed by slug)"

    field :persona, :string, required: true, description: "Persona slug"
  end

  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.Domains.Chat.Tools.RoomResolver
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    with {:ok, room} <- RoomResolver.call(args) do
      persona = Args.get(args, :persona)

      case Chat.leave_room(room.id, persona) do
        {:ok, m} -> {:ok, %{room_id: m.room_id, persona: m.persona, left_at: m.left_at}}
        {:error, :not_found} -> {:error, "Persona is not a member of this room"}
        {:error, cs} -> {:error, "Failed: #{inspect(cs)}"}
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
