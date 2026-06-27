defmodule NoizuPromptLingua.Domains.Chat.Tools.SendMessage do
  use Noizu.MCP.Server.Tool,
    name: "Chat.SendMessage", description: "Post a message to a chat room.", hidden: true, category: "Chat"

  input do
    field :room_id, :string, required: true, description: "Room UUID"
    field :content, :string, required: true, description: "Message body (markdown)"
    field :sender, :string, required: true, description: "Persona slug"
    field :parent_id, :string, description: "Parent message UUID to thread this reply under"
  end

  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    attrs =
      %{
        room_id: Args.get(args, :room_id),
        content: Args.get(args, :content),
        sender: Args.get(args, :sender)
      }
      |> maybe_put(:parent_message_id, Args.get(args, :parent_id))

    case Chat.send_message(attrs) do
      {:ok, msg} -> {:ok, NoizuPromptLingua.Domains.Chat.Serialize.message(msg)}
      {:error, cs} -> {:error, "Failed: #{inspect(cs.errors)}"}
    end
  end

  defp maybe_put(map, _k, nil), do: map
  defp maybe_put(map, k, v), do: Map.put(map, k, v)
end
