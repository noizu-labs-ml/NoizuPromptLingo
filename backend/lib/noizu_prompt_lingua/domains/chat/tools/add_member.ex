defmodule NoizuPromptLingua.Domains.Chat.Tools.AddMember do
  use Noizu.MCP.Server.Tool,
    name: "Chat.AddMember",
    description: "Add a persona to a room.",
    hidden: false,
    category: "Chat"

  input do
    field :room_id, :string, required: true, description: "Room slug or UUID (slug preferred)"
    field :organization, :string,
      description: "Org slug or UUID (required when room is addressed by slug)"

    field :persona, :string, required: true, description: "Persona slug"
    field :role, :string, description: "member (default) or admin"
  end

  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.Domains.Chat.Tools.RoomResolver

  @impl true
  def call(args, _ctx) do
    with {:ok, room} <- RoomResolver.call(args) do
      attrs = %{
        room_id: room.id,
        persona: args[:persona] || args["persona"],
        role: args[:role] || args["role"] || "member"
      }

      case Chat.add_member(attrs) do
        {:ok, m} -> {:ok, %{id: m.id, room_id: m.room_id, persona: m.persona, role: m.role}}
        {:error, cs} -> {:error, "Failed: #{inspect(cs.errors)}"}
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
