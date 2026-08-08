defmodule NoizuPromptLingua.Domains.Chat.Serialize do
  @moduledoc """
  Shared serialization for chat payloads returned by MCP tools, so every tool
  emits the same message shape. `important: true` is the field the front-end
  reads to render a gold border for highlighted messages.
  """

  alias NoizuPromptLingua.Schema.ChatMessage

  def message(%ChatMessage{} = m) do
    base = %{
      id: m.id,
      content: m.content,
      sender: m.sender,
      created_at: m.inserted_at,
      pinned: m.pinned,
      parent_id: m.parent_message_id
    }

    if m.highlighted, do: Map.put(base, :important, true), else: base
  end

  def attachment(att) do
    %{
      id: att.id,
      artifact_type: att.artifact_type,
      url: att.url,
      description: att.description,
      created_by: att.created_by
    }
  end
end
