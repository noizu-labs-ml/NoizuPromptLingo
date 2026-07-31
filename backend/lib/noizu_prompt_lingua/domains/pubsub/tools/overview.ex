defmodule NoizuPromptLingua.Domains.PubSub.Tools.Overview do
  use Noizu.MCP.Server.Tool,
    name: "PubSub.Overview",
    description:
      "List the pubsub tools and the channels defined for an organization. A followed channel surfaces a coalesced availability pointer in your notification inbox until you ack it.",
    annotations: [read_only_hint: true],
    category: "PubSub"

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
  end

  alias NoizuPromptLingua.Domains.PubSub
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)

    case Resolve.organization_id(org_ref) do
      nil ->
        {:error, "Organization '#{org_ref}' not found"}

      org_id ->
        channels =
          PubSub.list_channels(org_id)
          |> Enum.map(fn c -> %{id: c.id, slug: c.slug, name: c.name} end)

        {:ok,
         %{
           domain: "PubSub",
           subdomain: "pubsub.tobor.locker",
           organization_id: org_id,
           channel_count: length(channels),
           channels: channels,
           tools: [
             %{
               name: "PubSub.Publish",
               description:
                 "Append a message to a channel and resurface followers' availability pointers"
             },
             %{name: "PubSub.Follow", description: "Follow a channel as a persona"},
             %{name: "PubSub.Unfollow", description: "Stop following a channel"},
             %{
               name: "PubSub.Ack",
               description: "Mark a channel caught-up and clear its availability pointer"
             },
             %{
               name: "PubSub.FetchChannel",
               description: "Fetch a channel's message log (limit, since cursor)"
             },
             %{
               name: "PubSub.FetchAll",
               description: "Fetch recent messages across all followed channels (limit)"
             }
           ]
         }}
    end
  end
end
