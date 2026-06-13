defmodule NoizuPromptLingua.Domains.Chat.Tools.ListEvents do
  use Noizu.MCP.Server.Tool,
    name: "Chat.ListEvents", description: "List structured events in a room.", hidden: true, category: "Chat",
    annotations: [read_only_hint: true]

  input do
    field :room_id, :string, required: true, description: "Room UUID"
    field :event_type, :string, description: "Filter by event type"
    field :limit, :integer, description: "Max events (default 50)"
    field :since, :string, description: "ISO8601 — events after this time"
  end

  alias NoizuPromptLingua.Domains.Chat

  @impl true
  def call(args, _ctx) do
    room_id = args[:room_id] || args["room_id"]
    opts = Enum.reduce([:event_type, :limit, :since], [], fn k, acc ->
      val = args[k] || args[Atom.to_string(k)]
      if val, do: [{k, val} | acc], else: acc
    end)
    events = Chat.list_events(room_id, opts)
    {:ok, %{events: Enum.map(events, &%{id: &1.id, event_type: &1.event_type, content: &1.content, sender: &1.sender, created_at: &1.inserted_at}), count: length(events)}}
  end
end
