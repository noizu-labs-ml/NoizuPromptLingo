defmodule NoizuPromptLingua.Domains.Chat.Tools.CreateEvent do
  use Noizu.MCP.Server.Tool,
    name: "Chat.CreateEvent", description: "Create a structured event in a room.", hidden: true, category: "Chat"

  input_schema %{
    "type" => "object",
    "properties" => %{
      "room_id" => %{"type" => "string", "description" => "Room UUID"},
      "event_type" => %{"type" => "string", "description" => "action, todo, milestone, decision"},
      "content" => %{"type" => "string", "description" => "Event content"},
      "sender" => %{"type" => "string", "description" => "Persona slug"},
      "metadata" => %{"type" => "object", "description" => "Additional structured data"}
    },
    "required" => ["room_id", "event_type", "content", "sender"]
  }

  alias NoizuPromptLingua.Domains.Chat

  @impl true
  def call(args, _ctx) do
    attrs = %{room_id: args["room_id"], event_type: args["event_type"], content: args["content"], sender: args["sender"], metadata: args["metadata"]}
    case Chat.create_event(attrs) do
      {:ok, ev} -> {:ok, %{id: ev.id, event_type: ev.event_type, content: ev.content, sender: ev.sender, created_at: ev.inserted_at}}
      {:error, cs} -> {:error, "Failed: #{inspect(cs.errors)}"}
    end
  end
end
