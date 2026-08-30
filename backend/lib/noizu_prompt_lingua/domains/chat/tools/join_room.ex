defmodule NoizuPromptLingua.Domains.Chat.Tools.JoinRoom do
  use Noizu.MCP.Server.Tool,
    name: "Chat.JoinRoom",
    description:
      "Join (or rejoin) a room. Returns only the recent backlog (last few minutes), not full history.",
    hidden: false,
    category: "Chat"

  input do
    field :room_id, :string, required: true, description: "Room UUID"
    field :persona, :string, required: true, description: "Persona slug"
    field :minutes, :integer, description: "Backlog window in minutes (default 5)"
  end

  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    room_id = Args.get(args, :room_id)
    persona = Args.get(args, :persona)
    minutes = Args.get(args, :minutes) || 5

    case Chat.join_room(room_id, persona) do
      {:ok, m} ->
        backlog = Chat.recent_messages(room_id, minutes)

        {:ok,
         %{
           room_id: m.room_id,
           persona: m.persona,
           backlog_minutes: minutes,
           recent_messages:
             Enum.map(backlog, &NoizuPromptLingua.Domains.Chat.Serialize.message/1),
           count: length(backlog)
         }}

      {:error, cs} ->
        {:error, "Failed: #{inspect(cs)}"}
    end
  end
end
