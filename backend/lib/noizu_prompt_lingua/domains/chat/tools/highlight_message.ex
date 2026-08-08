defmodule NoizuPromptLingua.Domains.Chat.Tools.HighlightMessage do
  use Noizu.MCP.Server.Tool,
    name: "Chat.HighlightMessage",
    description:
      "Toggle (or set) the highlighted flag on a message (front-end renders a gold border; payload carries important: true).",
    hidden: true,
    category: "Chat"

  input do
    field :message_id, :string, required: true, description: "Message UUID"
    field :highlighted, :boolean, description: "Explicit value; omit to toggle"
  end

  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    case Chat.highlight_message(Args.get(args, :message_id), Args.get(args, :highlighted)) do
      {:ok, msg} -> {:ok, %{id: msg.id, highlighted: msg.highlighted, important: msg.highlighted}}
      {:error, :not_found} -> {:error, "Message not found"}
      {:error, cs} -> {:error, "Failed: #{inspect(cs)}"}
    end
  end
end
