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

  def create_room(conn, params) do
    attrs = Map.take(params, ~w(name slug topic session_id))
    case Chat.create_room(attrs) do
      {:ok, room} ->
        conn |> put_status(201) |> json(%{room: room_json(room)})
      {:error, cs} ->
        conn |> put_status(422) |> json(%{errors: format_errors(cs)})
    end
  end

  def send_message(conn, %{"room_id" => room_id} = params) do
    attrs = Map.take(params, ~w(sender content metadata)) |> Map.put("room_id", room_id)
    case Chat.send_message(attrs) do
      {:ok, msg} ->
        conn |> put_status(201) |> json(%{message: %{id: msg.id, room_id: msg.room_id, sender: msg.sender, content: msg.content, at: msg.inserted_at}})
      {:error, cs} ->
        conn |> put_status(422) |> json(%{errors: format_errors(cs)})
    end
  end

  defp room_json(r) do
    %{id: r.id, name: r.name, slug: r.slug, topic: r.topic, created_at: r.inserted_at}
  end

  defp format_errors(%Ecto.Changeset{} = cs) do
    Ecto.Changeset.traverse_errors(cs, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
  defp format_errors(other), do: inspect(other)
end
