defmodule NoizuPromptLingua.Domains.Chat.Tools.CreateRoom do
  use Noizu.MCP.Server.Tool,
    name: "Chat.CreateRoom",
    description: "Create a new chat room.",
    hidden: true, category: "Chat"

  input do
    field :name, :string, required: true, description: "Room name"
    field :description, :string, description: "Room description/topic"
    field :session_id, :string, description: "Session UUID to associate with"
  end

  alias NoizuPromptLingua.Domains.Chat

  @impl true
  def call(args, _ctx) do
    attrs = %{name: args[:name] || args["name"], description: args[:description] || args["description"], session_id: args[:session_id] || args["session_id"]}
    case Chat.create_room(attrs) do
      {:ok, room} -> {:ok, %{id: room.id, name: room.name, created_at: room.inserted_at}}
      {:error, cs} -> {:error, "Failed: #{inspect(cs.errors)}"}
    end
  end
end
