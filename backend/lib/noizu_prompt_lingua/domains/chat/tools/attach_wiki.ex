defmodule NoizuPromptLingua.Domains.Chat.Tools.AttachWiki do
  use Noizu.MCP.Server.Tool,
    name: "Chat.AttachWiki",
    description: "Attach a wiki space/page or URL reference to a chat room.",
    hidden: true, category: "Chat"

  input do
    field :room_id, :string, required: true, description: "Room UUID"
    field :url, :string, required: true, description: "Wiki/space URL or reference"
    field :sender, :string, required: true, description: "Persona slug attaching it"
    field :artifact_type, :string, description: "wiki (default) or url"
    field :description, :string, description: "Optional label/description"
  end

  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.Services.Attach
  alias NoizuPromptLingua.MCP.Args

  @impl true
  def call(args, _ctx) do
    room_id = Args.get(args, :room_id)
    sender = Args.get(args, :sender)
    artifact_type = Args.get(args, :artifact_type) || "wiki"

    case Chat.get_room(room_id) do
      nil ->
        {:error, "Room not found"}

      _room ->
        attrs = %{
          artifact_type: artifact_type,
          url: Args.get(args, :url),
          description: Args.get(args, :description),
          created_by: sender
        }

        case Attach.add("chat_room", room_id, attrs) do
          {:ok, att} ->
            {:ok, %{attachment_id: att.id, room_id: room_id, artifact_type: att.artifact_type, url: att.url}}
          {:error, cs} -> {:error, "Failed: #{inspect(cs.errors)}"}
        end
    end
  end
end
