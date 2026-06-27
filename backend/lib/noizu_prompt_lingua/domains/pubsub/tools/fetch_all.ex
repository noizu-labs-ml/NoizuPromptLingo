defmodule NoizuPromptLingua.Domains.PubSub.Tools.FetchAll do
  use Noizu.MCP.Server.Tool,
    name: "PubSub.FetchAll",
    description:
      "Fetch the most recent messages across every channel a persona follows, newest first. Use `limit` to cap the number of rows.",
    hidden: true,
    category: "PubSub",
    annotations: [read_only_hint: true]

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :persona, :string, required: true, description: "Persona / agent handle whose follows to scan"
    field :limit, :integer, default: 50, description: "Max messages to return (default 50)"
  end

  alias NoizuPromptLingua.Domains.PubSub
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)
    persona = Args.get(args, :persona)

    case Resolve.organization_id(org_ref) do
      nil ->
        {:error, "Organization '#{org_ref}' not found"}

      _org_id ->
        messages =
          PubSub.fetch_all(persona, limit: Args.get(args, :limit) || 50)
          |> Enum.map(fn m ->
            %{id: m.id, seq: m.seq, sender: m.sender, body: m.body, channel_id: m.channel_id, inserted_at: m.inserted_at}
          end)

        {:ok, %{persona: persona, count: length(messages), messages: messages}}
    end
  end
end
