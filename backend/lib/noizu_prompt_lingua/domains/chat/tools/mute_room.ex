defmodule NoizuPromptLingua.Domains.Chat.Tools.MuteRoom do
  use Noizu.MCP.Server.Tool,
    name: "Chat.MuteRoom",
    description: "Set mute preferences for a persona in a room (muted / mute unless mentioned).",
    hidden: true,
    category: "Chat"

  input do
    field :room_id, :string, required: true, description: "Room slug or UUID (slug preferred)"
    field :organization, :string,
      description: "Org slug or UUID (required when room is addressed by slug)"

    field :persona, :string, required: true, description: "Persona slug"
    field :muted, :boolean, description: "Silence all notifications from this room"

    field :mute_unless_mentioned, :boolean,
      description: "Only notify when this persona is mentioned"
  end

  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.Domains.Chat.Tools.RoomResolver
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    with {:ok, room} <- RoomResolver.call(args) do
      persona = Args.get(args, :persona)

      settings =
        %{}
        |> put_if(:muted, Args.get(args, :muted))
        |> put_if(:mute_unless_mentioned, Args.get(args, :mute_unless_mentioned))

      case Chat.mute_room(room.id, persona, settings) do
        {:ok, m} ->
          {:ok,
           %{
             room_id: m.room_id,
             persona: m.persona,
             muted: m.muted,
             mute_unless_mentioned: m.mute_unless_mentioned
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

  defp put_if(map, _k, nil), do: map
  defp put_if(map, k, v), do: Map.put(map, k, v)
end
