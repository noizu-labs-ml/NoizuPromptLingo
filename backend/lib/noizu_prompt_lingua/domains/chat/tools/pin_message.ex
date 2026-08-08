defmodule NoizuPromptLingua.Domains.Chat.Tools.PinMessage do
  use Noizu.MCP.Server.Tool,
    name: "Chat.PinMessage",
    description: "Toggle (or set) the pinned flag on a message.",
    hidden: true,
    category: "Chat"

  input do
    field :message_id, :string, required: true, description: "Message UUID"
    field :pinned, :boolean, description: "Explicit value; omit to toggle"
  end

  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    case Chat.pin_message(Args.get(args, :message_id), Args.get(args, :pinned)) do
      {:ok, msg} -> {:ok, %{id: msg.id, pinned: msg.pinned}}
      {:error, :not_found} -> {:error, "Message not found"}
      {:error, cs} -> {:error, "Failed: #{inspect(cs)}"}
    end
  end
end
