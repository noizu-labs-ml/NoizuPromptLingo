defmodule NoizuPromptLingua.Domains.Notifications.Tools.Overview do
  use Noizu.MCP.Server.Tool,
    name: "Notifications.Overview",
    description:
      "List the notification tools and current notification count for an organization.",
    annotations: [read_only_hint: true],
    category: "Notifications"

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
  end

  alias NoizuPromptLingua.Domains.Notifications
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)

    case Resolve.organization_id(org_ref) do
      nil ->
        {:error, "Organization '#{org_ref}' not found"}

      org_id ->
        {:ok,
         %{
           domain: "Notifications",
           subdomain: "notifications",
           organization_id: org_id,
           stats: Notifications.stats(org_id),
           tools: [
             %{name: "Notify", description: "Send a short DM (<=128 chars) to user(s)/group(s)"},
             %{name: "Notifications.Get", description: "Cursor pull of new notifications"},
             %{
               name: "Notifications.Poll",
               description: "Monitor — block until a notification arrives"
             },
             %{name: "Notifications.MarkRead", description: "Mark notifications read"},
             %{name: "Notifications.MarkSeen", description: "Mark notifications seen"},
             %{name: "Notifications.Ack", description: "Dismiss (ack) notifications"},
             %{name: "Notifications.Clear", description: "Clear (mark read) notifications"}
           ]
         }}
    end
  end
end
