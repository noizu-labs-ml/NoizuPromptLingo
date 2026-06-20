defmodule NoizuPromptLingua.Domains.Chat.Tools.SendMessage do
  use Noizu.MCP.Server.Tool,
    name: "Chat.SendMessage", description: "Post a message to a chat room.", hidden: true, category: "Chat"

  input do
    field :room_id, :string, required: true, description: "Room UUID"
    field :content, :string, required: true, description: "Message body (markdown)"
    field :sender, :string, required: true, description: "Persona slug"
  end

  alias NoizuPromptLingua.Domains.Chat

  @impl true
  def call(args, _ctx) do
    attrs = %{room_id: args[:room_id] || args["room_id"], content: args[:content] || args["content"], sender: args[:sender] || args["sender"]}
    case Chat.send_message(attrs) do
      {:ok, msg} -> {:ok, %{id: msg.id, content: msg.content, sender: msg.sender, created_at: msg.inserted_at}}
      {:error, cs} -> {:error, "Failed: #{inspect(cs.errors)}"}
    end
  end
end
