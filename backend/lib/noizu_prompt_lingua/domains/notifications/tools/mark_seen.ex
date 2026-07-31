defmodule NoizuPromptLingua.Domains.Notifications.Tools.MarkSeen do
  use Noizu.MCP.Server.Tool,
    name: "Notifications.MarkSeen",
    description:
      "Mark notifications seen for a recipient. Pass specific `ids`, or omit to mark all.",
    hidden: true,
    category: "Notifications"

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :recipient, :string, required: true, description: "Recipient agent handle"
    field :ids, {:array, :string}, description: "Notification ids to mark seen (omit for all)"
  end

  alias NoizuPromptLingua.Domains.Notifications
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    case Resolve.organization_id(Args.get(args, :organization)) do
      nil ->
        {:error, "Organization '#{Args.get(args, :organization)}' not found"}

      org_id ->
        ids = Args.get(args, :ids) || :all
        {:ok, count} = Notifications.mark_seen(org_id, Args.get(args, :recipient), ids)
        {:ok, %{marked_seen: count}}
    end
  end
end
