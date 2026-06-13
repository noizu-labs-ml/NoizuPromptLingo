defmodule NPLWeb.API.ChatAPIController do
  use NPLWeb, :controller

  alias NoizuPromptLingua.Domains.Chat

  def rooms(conn, _params) do
    rooms = Chat.list_rooms()
    json(conn, %{
      rooms: Enum.map(rooms, fn r ->
        %{id: r.id, name: r.name, slug: r.slug, topic: r.topic, created_at: r.inserted_at}
      end)
    })
  end

  def messages(conn, %{"room_id" => room_id} = params) do
    opts = if params["before"], do: [before: params["before"]], else: []
    messages = Chat.list_messages(room_id, opts)
    json(conn, %{
      messages: Enum.map(messages, fn m ->
        %{id: m.id, room_id: m.room_id, sender: m.sender, content: m.content, at: m.inserted_at}
      end)
    })
  end
end
