defmodule NoizuPromptLingua.Domains.PubSub.Tools.Unfollow do
  use Noizu.MCP.Server.Tool,
    name: "PubSub.Unfollow",
    description: "Stop following an org-scoped channel as a persona.",
    hidden: true,
    category: "PubSub",
    annotations: [idempotent_hint: true]

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :channel, :string, required: true, description: "Channel slug or UUID"
    field :persona, :string, required: true, description: "Persona / agent handle that will unfollow"
  end

  alias NoizuPromptLingua.Domains.PubSub
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)
    channel_ref = Args.get(args, :channel)
    persona = Args.get(args, :persona)

    with {:org, org_id} when not is_nil(org_id) <- {:org, Resolve.organization_id(org_ref)},
         {:chan, %{} = channel} <- {:chan, PubSub.get_channel(org_id, channel_ref)},
         {:ok, count} <- PubSub.unfollow(channel.id, persona) do
      {:ok, %{channel: %{id: channel.id, slug: channel.slug}, persona: persona, removed: count, following: false}}
    else
      {:org, nil} -> {:error, "Organization '#{org_ref}' not found"}
      {:chan, nil} -> {:error, "Channel '#{channel_ref}' not found"}
    end
  end
end
