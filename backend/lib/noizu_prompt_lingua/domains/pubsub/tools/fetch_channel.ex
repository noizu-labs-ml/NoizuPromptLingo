defmodule NoizuPromptLingua.Domains.PubSub.Tools.FetchChannel do
  use Noizu.MCP.Server.Tool,
    name: "PubSub.FetchChannel",
    description:
      "Fetch a channel's message log in seq ASC order. Use `since` (a seq cursor) to page forward and `limit` to cap the number of rows.",
    hidden: true,
    category: "PubSub",
    annotations: [read_only_hint: true]

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :channel, :string, required: true, description: "Channel slug or UUID"
    field :limit, :integer, default: 50, description: "Max messages to return (default 50)"
    field :since, :integer, description: "Only messages with seq greater than this cursor"
  end

  alias NoizuPromptLingua.Domains.PubSub
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)
    channel_ref = Args.get(args, :channel)

    with {:org, org_id} when not is_nil(org_id) <- {:org, Resolve.organization_id(org_ref)},
         {:chan, %{} = channel} <- {:chan, PubSub.get_channel(org_id, channel_ref)} do
      opts = [limit: Args.get(args, :limit) || 50, since: Args.get(args, :since)]
      messages = PubSub.fetch_channel(channel.id, opts) |> Enum.map(&serialize/1)

      {:ok, %{channel: %{id: channel.id, slug: channel.slug}, count: length(messages), messages: messages}}
    else
      {:org, nil} -> {:error, "Organization '#{org_ref}' not found"}
      {:chan, nil} -> {:error, "Channel '#{channel_ref}' not found"}
    end
  end

  defp serialize(m) do
    %{id: m.id, seq: m.seq, sender: m.sender, body: m.body, channel_id: m.channel_id, inserted_at: m.inserted_at}
  end
end
