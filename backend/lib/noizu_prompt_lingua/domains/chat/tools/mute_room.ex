defmodule NoizuPromptLingua.Domains.Chat.Tools.MuteRoom do
  use Noizu.MCP.Server.Tool,
    name: "Chat.MuteRoom",
    description: "Set mute preferences for a persona in a room (muted / mute unless mentioned).",
    hidden: true, category: "Chat"

  input do
    field :room_id, :string, required: true, description: "Room UUID"
    field :persona, :string, required: true, description: "Persona slug"
    field :muted, :boolean, description: "Silence all notifications from this room"
    field :mute_unless_mentioned, :boolean, description: "Only notify when this persona is mentioned"
  end

  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    room_id = Args.get(args, :room_id)
    persona = Args.get(args, :persona)

    settings =
      %{}
      |> put_if(:muted, Args.get(args, :muted))
      |> put_if(:mute_unless_mentioned, Args.get(args, :mute_unless_mentioned))

    case Chat.mute_room(room_id, persona, settings) do
      {:ok, m} ->
        {:ok, %{room_id: m.room_id, persona: m.persona, muted: m.muted, mute_unless_mentioned: m.mute_unless_mentioned}}
      {:error, cs} -> {:error, "Failed: #{inspect(cs)}"}
    end
  end

  defp put_if(map, _k, nil), do: map
  defp put_if(map, k, v), do: Map.put(map, k, v)
end
