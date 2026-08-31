defmodule NoizuPromptLingua.Domains.Chat.Tools.ListMessages do
  use Noizu.MCP.Server.Tool,
    name: "Chat.ListMessages",
    description: "List messages in a room.",
    hidden: false,
    category: "Chat",
    annotations: [read_only_hint: true]

  input do
    field :room_id, :string, required: true, description: "Room slug or UUID (slug preferred)"
    field :organization, :string,
      description: "Org slug or UUID (required when room is addressed by slug)"

    field :limit, :integer, description: "Max messages (default 50)"
    field :before, :string, description: "ISO8601 — messages before this time"
    field :after, :string, description: "ISO8601 — messages after this time"
  end

  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.Domains.Chat.Tools.RoomResolver

  @impl true
  def call(args, _ctx) do
    with {:ok, room} <- RoomResolver.call(args) do
      opts =
        Enum.reduce([:limit, :before, :after], [], fn k, acc ->
          val = args[k] || args[Atom.to_string(k)]
          if val, do: [{k, val} | acc], else: acc
        end)

      msgs = Chat.list_messages(room.id, opts)

      {:ok,
       %{
         messages: Enum.map(msgs, &NoizuPromptLingua.Domains.Chat.Serialize.message/1),
         count: length(msgs)
       }}
    else
      {:error, :organization_required} ->
        {:error, "organization is required when the room is addressed by slug"}

      {:error, msg} when is_binary(msg) ->
        {:error, msg}

      {:error, _} ->
        {:error, "Room not found"}
    end
  end
end
