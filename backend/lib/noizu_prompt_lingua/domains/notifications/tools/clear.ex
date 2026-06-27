defmodule NoizuPromptLingua.Domains.Notifications.Tools.Clear do
  use Noizu.MCP.Server.Tool,
    name: "Notifications.Clear",
    description: "Clear (mark read) notifications for a recipient. Pass specific `ids`, or omit to clear all.",
    hidden: true,
    category: "Notifications"

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :recipient, :string, required: true, description: "Recipient agent handle"
    field :ids, {:array, :string}, description: "Notification ids to clear (omit for all)"
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
        {:ok, count} = Notifications.clear(org_id, Args.get(args, :recipient), ids)
        {:ok, %{cleared: count}}
    end
  end
end
