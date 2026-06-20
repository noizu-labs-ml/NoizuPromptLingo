defmodule NoizuPromptLingua.Domains.Chat.Tools.ChatAttach do
  use Noizu.MCP.Server.Tool,
    name: "Chat.Attach", description: "Share an artifact in a chat room.", hidden: true, category: "Chat"

  input do
    field :room_id, :string, required: true, description: "Room UUID"
    field :artifact_id, :string, required: true, description: "Artifact UUID"
    field :sender, :string, required: true, description: "Persona slug"
    field :comment, :string, description: "Optional message"
  end

  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.Services.Attach

  @impl true
  def call(args, _ctx) do
    room_id = args[:room_id] || args["room_id"]
    sender = args[:sender] || args["sender"]
    comment = args[:comment] || args["comment"]

    with {:ok, event} <- Chat.create_event(%{room_id: room_id, event_type: "action", content: comment || "Shared an artifact", sender: sender}),
         {:ok, att} <- Attach.add("chat_event", event.id, %{artifact_type: "artifact", created_by: sender, description: comment}) do
      {:ok, %{event_id: event.id, attachment_id: att.id}}
    else
      {:error, cs} -> {:error, "Failed: #{inspect(cs)}"}
    end
  end
end
