defmodule NoizuPromptLingua.Domains.Chat.Tools.JoinRoom do
  use Noizu.MCP.Server.Tool,
    name: "Chat.JoinRoom",
    description:
      "Join (or rejoin) a room. Returns only the recent backlog (last few minutes), not full history.",
    hidden: false,
    category: "Chat"

  input do
    field :room_id, :string, required: true, description: "Room slug or UUID (slug preferred)"
    field :organization, :string,
      description: "Org slug or UUID (required when room is addressed by slug)"

    field :persona, :string, required: true, description: "Persona slug"
    field :minutes, :integer, description: "Backlog window in minutes (default 5)"
  end

  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.Domains.Chat.Tools.RoomResolver
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    with {:ok, room} <- RoomResolver.call(args) do
      persona = Args.get(args, :persona)
      minutes = Args.get(args, :minutes) || 5

      case Chat.join_room(room.id, persona) do
        {:ok, m} ->
          backlog = Chat.recent_messages(room.id, minutes)

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
