defmodule NoizuPromptLingua.Domains.Chat.Tools.ListRooms do
  use Noizu.MCP.Server.Tool,
    name: "Chat.ListRooms", description: "List chat rooms.", hidden: true, category: "Chat",
    annotations: [read_only_hint: true]

  input do
    field :session_id, :string, description: "Filter by session UUID"
    field :limit, :integer, description: "Max results (default 50)"
    field :offset, :integer, description: "Pagination offset"
  end

  alias NoizuPromptLingua.Domains.Chat

  @impl true
  def call(args, _ctx) do
    opts = Enum.reduce([:session_id, :limit, :offset], [], fn k, acc ->
      val = args[k] || args[Atom.to_string(k)]
      if val, do: [{k, val} | acc], else: acc
    end)
    rooms = Chat.list_rooms(opts)
    {:ok, %{rooms: Enum.map(rooms, &%{id: &1.id, name: &1.name, created_at: &1.inserted_at}), count: length(rooms)}}
  end
end
