defmodule NoizuPromptLingua.Domains.PubSub.Tools.Ack do
  use Noizu.MCP.Server.Tool,
    name: "PubSub.Ack",
    description:
      "Acknowledge a channel as caught-up: advances your follow cursor to the channel head and clears the channel's `pubsub_available` availability pointer from your notification inbox.",
    hidden: true,
    category: "PubSub",
    annotations: [idempotent_hint: true]

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :channel, :string, required: true, description: "Channel slug or UUID"
    field :persona, :string, required: true, description: "Persona / agent handle acknowledging"
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
         {:ok, result} <- PubSub.ack(org_id, channel.id, persona) do
      {:ok, %{channel: %{id: channel.id, slug: channel.slug}, persona: persona, last_acked_seq: result.last_acked_seq}}
    else
      {:org, nil} -> {:error, "Organization '#{org_ref}' not found"}
      {:chan, nil} -> {:error, "Channel '#{channel_ref}' not found"}
      {:error, :not_following} -> {:error, "Persona '#{persona}' is not following this channel"}
    end
  end
end
