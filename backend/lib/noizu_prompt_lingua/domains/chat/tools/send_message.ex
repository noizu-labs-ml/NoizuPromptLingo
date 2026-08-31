defmodule NoizuPromptLingua.Domains.Chat.Tools.SendMessage do
  use Noizu.MCP.Server.Tool,
    name: "Chat.SendMessage",
    description: "Post a message to a chat room.",
    hidden: false,
    category: "Chat"

  input do
    field :room_id, :string, required: true, description: "Room slug or UUID (slug preferred)"
    field :organization, :string,
      description: "Org slug or UUID (required when room is addressed by slug)"

    field :content, :string, required: true, description: "Message body (markdown)"
    field :sender, :string, required: true, description: "Persona slug"
    field :parent_id, :string, description: "Parent message UUID to thread this reply under"
  end

  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.Domains.Chat.Tools.RoomResolver
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    with {:ok, room} <- RoomResolver.call(args) do
      attrs =
        %{
          room_id: room.id,
          content: Args.get(args, :content),
          sender: Args.get(args, :sender)
        }
        |> maybe_put(:parent_message_id, Args.get(args, :parent_id))

      case Chat.send_message(attrs) do
        {:ok, msg} -> {:ok, NoizuPromptLingua.Domains.Chat.Serialize.message(msg)}
        {:error, cs} -> {:error, "Failed: #{inspect(cs.errors)}"}
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

  defp maybe_put(map, _k, nil), do: map
  defp maybe_put(map, k, v), do: Map.put(map, k, v)
end
