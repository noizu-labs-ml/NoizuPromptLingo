defmodule NoizuPromptLingua.Domains.Chat.Tools.ChatReact do
  use Noizu.MCP.Server.Tool,
    name: "Chat.React", description: "Add emoji reaction to a chat event.", hidden: true, category: "Chat"

  input do
    field :event_id, :string, required: true, description: "Chat event UUID"
    field :persona, :string, required: true, description: "Persona slug"
    field :emoji, :string, required: true, description: "Emoji character or shortcode"
  end

  @impl true
  def call(args, _ctx) do
    event_id = args[:event_id] || args["event_id"]
    persona = args[:persona] || args["persona"]
    emoji = args[:emoji] || args["emoji"]

    reaction = %{entity_type: "chat_event", entity_id: event_id, persona: persona, emoji: emoji}

    case NoizuPromptLingua.Repo.insert(
      %NoizuPromptLingua.Schema.Reaction{}
      |> NoizuPromptLingua.Schema.Reaction.changeset(reaction),
      on_conflict: :nothing
    ) do
      {:ok, r} -> {:ok, %{id: r.id, event_id: event_id, persona: persona, emoji: emoji}}
      {:error, cs} -> {:error, "Failed: #{inspect(cs.errors)}"}
    end
  end
end
