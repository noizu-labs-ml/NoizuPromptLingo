defmodule NoizuPromptLingua.Domains.Chat.Tools.ForwardReplies do
  use Noizu.MCP.Server.Tool,
    name: "Chat.ForwardReplies",
    description: "Forward the reply list under a parent message into a target room as a thread.",
    hidden: true, category: "Chat"

  input do
    field :parent_message_id, :string, required: true, description: "Source message whose replies are forwarded"
    field :target_room_id, :string, required: true, description: "Destination room UUID"
    field :sender, :string, required: true, description: "Persona slug forwarding the thread"
    field :target_parent_id, :string, description: "Existing message in the target to thread under; omit to create a header"
  end

  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    parent_id = Args.get(args, :parent_message_id)
    target_room_id = Args.get(args, :target_room_id)
    sender = Args.get(args, :sender)
    target_parent_id = Args.get(args, :target_parent_id)

    replies = Chat.list_replies(parent_id)

    if replies == [] do
      {:error, "No replies to forward under that message"}
    else
      with {:ok, thread_parent_id} <- ensure_thread_parent(target_parent_id, target_room_id, sender, parent_id) do
        forwarded =
          Enum.reduce(replies, [], fn reply, acc ->
            case Chat.send_message(%{
                   room_id: target_room_id,
                   content: reply.content,
                   sender: reply.sender,
                   parent_message_id: thread_parent_id
                 }) do
              {:ok, msg} -> [msg.id | acc]
              _ -> acc
            end
          end)
          |> Enum.reverse()

        {:ok, %{thread_parent_id: thread_parent_id, forwarded_count: length(forwarded), forwarded_ids: forwarded}}
      else
        {:error, cs} -> {:error, "Failed: #{inspect(cs)}"}
      end
    end
  end

  defp ensure_thread_parent(nil, target_room_id, sender, source_parent_id) do
    case Chat.send_message(%{
           room_id: target_room_id,
           content: "Forwarded thread (#{length_label(source_parent_id)})",
           sender: sender
         }) do
      {:ok, header} -> {:ok, header.id}
      err -> err
    end
  end

  defp ensure_thread_parent(target_parent_id, _room, _sender, _source), do: {:ok, target_parent_id}

  defp length_label(source_parent_id), do: "from message #{source_parent_id}"
end
