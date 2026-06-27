defmodule NoizuPromptLingua.Domains.PubSub.Tools.Publish do
  use Noizu.MCP.Server.Tool,
    name: "PubSub.Publish",
    description:
      "Publish a message to an org-scoped channel (referenced by slug or UUID). Creates the channel on first publish if it does not yet exist. Every follower gets a coalesced `pubsub_available` pointer resurfaced in their notification inbox.",
    hidden: true,
    category: "PubSub"

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :channel, :string, required: true, description: "Channel slug or UUID"
    field :sender, :string, required: true, description: "Publishing agent handle"
    field :body, :string, required: true, description: "Message body"
    field :name, :string, description: "Channel display name (used only when creating the channel)"
    field :project, :string, description: "Project slug or UUID (used only when creating the channel)"
  end

  alias NoizuPromptLingua.Domains.PubSub
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)
    channel_ref = Args.get(args, :channel)

    with {:org, org_id} when not is_nil(org_id) <- {:org, Resolve.organization_id(org_ref)},
         {:ok, project_id} <- Resolve.project_in_org(Args.get(args, :project), org_id),
         {:ok, channel} <- ensure_channel(org_id, channel_ref, Args.get(args, :name), project_id),
         {:ok, message} <-
           PubSub.publish(%{
             channel_id: channel.id,
             sender: Args.get(args, :sender),
             body: Args.get(args, :body)
           }) do
      {:ok,
       %{
         channel: %{id: channel.id, slug: channel.slug},
         message: %{id: message.id, seq: message.seq, sender: message.sender, inserted_at: message.inserted_at}
       }}
    else
      {:org, nil} -> {:error, "Organization '#{org_ref}' not found"}
      {:error, :project_not_found} -> {:error, "Project not found"}
      {:error, :project_not_in_org} -> {:error, "Project does not belong to this organization"}
      {:error, %Ecto.Changeset{} = cs} -> {:error, "Failed: #{inspect(cs.errors)}"}
      {:error, other} -> {:error, "Failed: #{inspect(other)}"}
    end
  end

  defp ensure_channel(org_id, ref, name, project_id) do
    case PubSub.get_channel(org_id, ref) do
      nil ->
        PubSub.create_channel(%{
          organization_id: org_id,
          project_id: project_id,
          slug: ref,
          name: name || ref
        })

      channel ->
        {:ok, channel}
    end
  end
end
