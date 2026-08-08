defmodule NoizuPromptLingua.Domains.Chat.Tools.NotificationClear do
  use Noizu.MCP.Server.Tool,
    name: "Chat.Notification.Clear",
    description: "Mark notifications as read.",
    hidden: true,
    category: "Chat"

  input do
    field :persona, :string, required: true, description: "Persona slug"
    field :notification_id, :string, description: "Specific notification UUID (omit to clear all)"
  end

  alias NoizuPromptLingua.Domains.Chat

  @impl true
  def call(args, _ctx) do
    persona = args[:persona] || args["persona"]
    notif_id = args[:notification_id] || args["notification_id"]

    if notif_id do
      case Chat.clear_notification(persona, notif_id) do
        {:ok, _} -> {:ok, %{cleared: 1}}
        {:error, :not_found} -> {:error, "Notification not found"}
      end
    else
      {:ok, count} = Chat.clear_all_notifications(persona)
      {:ok, %{cleared: count}}
    end
  end
end
