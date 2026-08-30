defmodule NoizuPromptLingua.Domains.Chat.Tools.AddMember do
  use Noizu.MCP.Server.Tool,
    name: "Chat.AddMember",
    description: "Add a persona to a room.",
    hidden: false,
    category: "Chat"

  input do
    field :room_id, :string, required: true, description: "Room UUID"
    field :persona, :string, required: true, description: "Persona slug"
    field :role, :string, description: "member (default) or admin"
  end

  alias NoizuPromptLingua.Domains.Chat

  @impl true
  def call(args, _ctx) do
    attrs = %{
      room_id: args[:room_id] || args["room_id"],
      persona: args[:persona] || args["persona"],
      role: args[:role] || args["role"] || "member"
    }

    case Chat.add_member(attrs) do
      {:ok, m} -> {:ok, %{id: m.id, room_id: m.room_id, persona: m.persona, role: m.role}}
      {:error, cs} -> {:error, "Failed: #{inspect(cs.errors)}"}
    end
  end
end
