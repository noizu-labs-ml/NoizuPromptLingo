defmodule NoizuPromptLingua.Domains.Chat.Tools.LeaveRoom do
  use Noizu.MCP.Server.Tool,
    name: "Chat.LeaveRoom",
    description: "Mark a persona as having left a room.",
    hidden: true, category: "Chat"

  input do
    field :room_id, :string, required: true, description: "Room UUID"
    field :persona, :string, required: true, description: "Persona slug"
  end

  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    room_id = Args.get(args, :room_id)
    persona = Args.get(args, :persona)

    case Chat.leave_room(room_id, persona) do
      {:ok, m} -> {:ok, %{room_id: m.room_id, persona: m.persona, left_at: m.left_at}}
      {:error, :not_found} -> {:error, "Persona is not a member of this room"}
      {:error, cs} -> {:error, "Failed: #{inspect(cs)}"}
    end
  end
end
