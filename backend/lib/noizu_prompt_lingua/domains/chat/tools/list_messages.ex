defmodule NoizuPromptLingua.Domains.Chat.Tools.ListMessages do
  use Noizu.MCP.Server.Tool,
    name: "Chat.ListMessages", description: "List messages in a room.", hidden: true, category: "Chat",
    annotations: [read_only_hint: true]

  input do
    field :room_id, :string, required: true, description: "Room UUID"
    field :limit, :integer, description: "Max messages (default 50)"
    field :before, :string, description: "ISO8601 — messages before this time"
    field :after, :string, description: "ISO8601 — messages after this time"
  end

  alias NoizuPromptLingua.Domains.Chat

  @impl true
  def call(args, _ctx) do
    room_id = args[:room_id] || args["room_id"]
    opts = Enum.reduce([:limit, :before, :after], [], fn k, acc ->
      val = args[k] || args[Atom.to_string(k)]
      if val, do: [{k, val} | acc], else: acc
    end)
    msgs = Chat.list_messages(room_id, opts)
    {:ok, %{messages: Enum.map(msgs, &NoizuPromptLingua.Domains.Chat.Serialize.message/1), count: length(msgs)}}
  end
end
