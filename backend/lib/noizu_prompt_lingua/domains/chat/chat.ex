defmodule NoizuPromptLingua.Domains.Chat do
  import Ecto.Query, except: [update: 2]
  require Logger
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{ChatRoom, ChatMessage, ChatEvent, ChatMember, ChatNotification}
  alias NoizuPromptLingua.Domains.Pipes

  # ── Rooms ─────────────────────────────────────────────────────

  def create_room(attrs) do
    %ChatRoom{} |> ChatRoom.changeset(attrs) |> Repo.insert()
  end

  def get_room(room_id) do
    Repo.get(ChatRoom, room_id)
  end

  def list_rooms(opts \\ []) do
    ChatRoom
    |> maybe_filter_organization(opts[:organization_id])
    |> maybe_filter_project(opts[:project_id])
    |> maybe_filter_session(opts[:session_id])
    |> order_by([r], desc: r.updated_at)
    |> limit(^(opts[:limit] || 50))
    |> offset(^(opts[:offset] || 0))
    |> Repo.all()
  end

  def room_count do
    Repo.aggregate(ChatRoom, :count)
  end

  # ── Messages ──────────────────────────────────────────────────

  def send_message(attrs) do
    case %ChatMessage{} |> ChatMessage.changeset(attrs) |> Repo.insert() do
      {:ok, msg} = ok ->
        bridge_to_pipes(:message, msg)
        ok

      error ->
        error
    end
  end

  def list_messages(room_id, opts \\ []) do
    ChatMessage
    |> where([m], m.room_id == ^room_id)
    |> maybe_before(opts[:before])
    |> maybe_after(opts[:after])
    |> order_by([m], desc: m.inserted_at)
    |> limit(^(opts[:limit] || 50))
    |> Repo.all()
  end

  # ── Events ────────────────────────────────────────────────────

  def create_event(attrs) do
    case %ChatEvent{} |> ChatEvent.changeset(attrs) |> Repo.insert() do
      {:ok, event} = ok ->
        bridge_to_pipes(:event, event)
        ok

      error ->
        error
    end
  end

  def list_events(room_id, opts \\ []) do
    ChatEvent
    |> where([e], e.room_id == ^room_id)
    |> maybe_filter_event_type(opts[:event_type])
    |> maybe_since(opts[:since])
    |> order_by([e], desc: e.inserted_at)
    |> limit(^(opts[:limit] || 50))
    |> Repo.all()
  end

  # ── Members ───────────────────────────────────────────────────

  def add_member(attrs) do
    %ChatMember{}
    |> ChatMember.changeset(attrs)
    |> Repo.insert(on_conflict: :nothing)
  end

  def list_members(room_id) do
    ChatMember
    |> where([m], m.room_id == ^room_id)
    |> order_by([m], asc: m.inserted_at)
    |> Repo.all()
  end

  # ── Notifications ─────────────────────────────────────────────

  def list_notifications(persona, opts \\ []) do
    ChatNotification
    |> where([n], n.persona == ^persona and n.read == false)
    |> order_by([n], desc: n.inserted_at)
    |> limit(^(opts[:limit] || 50))
    |> preload(:room)
    |> Repo.all()
  end

  def clear_notification(persona, notification_id) do
    case Repo.get(ChatNotification, notification_id) do
      %{persona: ^persona} = notif ->
        notif |> Ecto.Changeset.change(read: true) |> Repo.update()
      _ -> {:error, :not_found}
    end
  end

  def clear_all_notifications(persona) do
    {count, _} =
      ChatNotification
      |> where([n], n.persona == ^persona and n.read == false)
      |> Repo.update_all(set: [read: true])
    {:ok, count}
  end

  # ── Pipe bridge ───────────────────────────────────────────────
  #
  # Fan a chat message/event out into each room member's agent pipe so a member
  # can poll ONE inbox (Pipe.Input) for everything addressed to them. One pipe
  # entry per member where member.persona != sender. The message_name embeds the
  # row id so it is unique per event — pipe upsert never collapses chat history.
  #
  # Chat rows don't carry organization_id; we read it (and the room name) from
  # the room. The whole fan-out is best-effort: a failure here must never roll
  # back or fail the chat write.

  defp bridge_to_pipes(kind, row) do
    case get_room(row.room_id) do
      %ChatRoom{} = room ->
        members = list_members(row.room_id)
        body = bridge_body(kind, row, room)
        message_name = bridge_message_name(kind, row.id)

        for %ChatMember{persona: persona} <- members, persona != row.sender, persona not in [nil, ""] do
          push_pipe(room.organization_id, row.sender, persona, message_name, body)
        end

      _ ->
        Logger.warning("chat→pipe bridge: room #{inspect(row.room_id)} not found; skipping fan-out")
        :ok
    end
  rescue
    e ->
      Logger.error("chat→pipe bridge failed: #{Exception.message(e)}")
      :ok
  end

  defp push_pipe(org_id, sender, persona, message_name, body) do
    case Pipes.push(%{
           organization_id: org_id,
           sender_handle: sender,
           message_name: message_name,
           target_agent_handle: persona,
           body: body
         }) do
      {:ok, _} -> :ok
      {:error, reason} ->
        Logger.error("chat→pipe push to #{persona} failed: #{inspect(reason)}")
        :ok
    end
  end

  defp bridge_message_name(:message, id), do: "chat.message:" <> to_string(id)
  defp bridge_message_name(:event, id), do: "chat.event:" <> to_string(id)

  defp bridge_body(:message, msg, room) do
    Jason.encode!(%{
      type: "chat.message",
      room_id: msg.room_id,
      room_name: room.name,
      message_id: msg.id,
      sender: msg.sender,
      content: msg.content,
      ts: msg.inserted_at
    })
  end

  defp bridge_body(:event, event, room) do
    Jason.encode!(%{
      type: "chat.event",
      room_id: event.room_id,
      room_name: room.name,
      event_id: event.id,
      sender: event.sender,
      content: event.content,
      event_type: event.event_type,
      ts: event.inserted_at
    })
  end

  # ── Private ───────────────────────────────────────────────────

  defp maybe_filter_organization(q, nil), do: q
  defp maybe_filter_organization(q, org_id), do: where(q, [r], r.organization_id == ^org_id)

  defp maybe_filter_project(q, nil), do: q
  defp maybe_filter_project(q, project_id), do: where(q, [r], r.project_id == ^project_id)

  defp maybe_filter_session(q, nil), do: q
  defp maybe_filter_session(q, sid), do: where(q, [r], r.session_id == ^sid)

  defp maybe_filter_event_type(q, nil), do: q
  defp maybe_filter_event_type(q, t), do: where(q, [e], e.event_type == ^t)

  defp maybe_before(q, nil), do: q
  defp maybe_before(q, ts) do
    {:ok, dt, _} = DateTime.from_iso8601(ts)
    where(q, [m], m.inserted_at < ^dt)
  end

  defp maybe_after(q, nil), do: q
  defp maybe_after(q, ts) do
    {:ok, dt, _} = DateTime.from_iso8601(ts)
    where(q, [m], m.inserted_at > ^dt)
  end

  defp maybe_since(q, nil), do: q
  defp maybe_since(q, ts) do
    {:ok, dt, _} = DateTime.from_iso8601(ts)
    where(q, [e], e.inserted_at > ^dt)
  end
end
