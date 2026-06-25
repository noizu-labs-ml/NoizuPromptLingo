defmodule NoizuPromptLingua.Domains.Chat do
  import Ecto.Query, except: [update: 2]
  require Logger
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{ChatRoom, ChatMessage, ChatEvent, ChatMember, ChatNotification, Reaction}
  alias NoizuPromptLingua.Domains.Pipes

  # ── Rooms ─────────────────────────────────────────────────────

  alias NoizuPromptLingua.Domains.Chat.Slug

  # Retry budget for the insert/backfill collision loop. Suffix is assigned under
  # the partial unique index via 23505 retry — never select-then-insert (TOCTOU-safe).
  @max_slug_attempts 50

  def create_room(attrs) do
    attrs |> put_base_slug() |> insert_room_with_slug(0)
  end

  def get_room(room_id) do
    Repo.get(ChatRoom, room_id)
  end

  # Edit a room's name/description only (0c93ddd4). slug stays immutable — see
  # ChatRoom.update_changeset/2 (no slug re-derivation on rename).
  def update_room(%ChatRoom{} = room, attrs) do
    room |> ChatRoom.update_changeset(attrs) |> Repo.update()
  end

  # Resolve a room by slug within its uniqueness bucket. The predicate MUST match
  # the partial-index predicate (ADR-013 A3): project rooms vs the NULL-project
  # (org-level) bucket are distinct namespaces.
  def get_room_by_slug(org_id, project_id \\ nil, slug)

  def get_room_by_slug(org_id, nil, slug) do
    Repo.one(
      from r in ChatRoom,
        where: r.organization_id == ^org_id and is_nil(r.project_id) and r.slug == ^slug
    )
  end

  def get_room_by_slug(org_id, project_id, slug) do
    Repo.one(
      from r in ChatRoom,
        where:
          r.organization_id == ^org_id and r.project_id == ^project_id and r.slug == ^slug
    )
  end

  @doc """
  Backfill slugs for pre-existing rooms (Liquibase 052 deploy step). Idempotent:
  only fills NULL slugs, re-runnable, suffix assigned via 23505 retry against the
  live partial unique index (TOCTOU-safe). Returns the count of rooms filled.
  """
  def backfill_slugs(batch_size \\ 500) do
    rooms =
      ChatRoom
      |> where([r], is_nil(r.slug))
      |> limit(^batch_size)
      |> Repo.all()

    case rooms do
      [] ->
        0

      _ ->
        filled =
          Enum.reduce(rooms, 0, fn room, acc ->
            case update_room_slug(room, Slug.slugify(room.name), 0) do
              {:ok, _} -> acc + 1
              {:error, _} -> acc
            end
          end)

        filled + backfill_slugs(batch_size)
    end
  end

  # Set the BASE slug only — no uniqueness probe (the DB index is the source of
  # truth; uniqueness is resolved at insert time via conflict-retry).
  defp put_base_slug(attrs) do
    name = attrs[:name] || attrs["name"]

    cond do
      (attrs[:slug] || attrs["slug"]) not in [nil, ""] -> attrs
      is_nil(name) -> attrs
      true -> Map.put(attrs, :slug, Slug.slugify(name))
    end
  end

  # Insert; on a slug unique-violation (23505 -> changeset :slug error), bump the
  # suffix and retry. No read-before-write, so two concurrent same-name rooms can't
  # both land the same slug (TOCTOU-safe).
  defp insert_room_with_slug(attrs, attempt) when attempt >= @max_slug_attempts do
    %ChatRoom{} |> ChatRoom.changeset(bump_slug(attrs, attempt)) |> Repo.insert()
  end

  defp insert_room_with_slug(attrs, attempt) do
    case %ChatRoom{} |> ChatRoom.changeset(bump_slug(attrs, attempt)) |> Repo.insert() do
      {:error, %Ecto.Changeset{errors: errors}} = err ->
        if Keyword.has_key?(errors, :slug),
          do: insert_room_with_slug(attrs, attempt + 1),
          else: err

      ok ->
        ok
    end
  end

  defp update_room_slug(_room, _base, attempt) when attempt >= @max_slug_attempts do
    {:error, :too_many_slug_attempts}
  end

  defp update_room_slug(room, base, attempt) do
    case room |> ChatRoom.changeset(%{slug: Slug.with_suffix(base, attempt + 1)}) |> Repo.update() do
      {:error, %Ecto.Changeset{errors: errors}} = err ->
        if Keyword.has_key?(errors, :slug),
          do: update_room_slug(room, base, attempt + 1),
          else: err

      ok ->
        ok
    end
  end

  # attempt 0 -> Slug.with_suffix(base, 1) == base (bare slug for the first room of a
  # name); attempt n -> "<base>-<n+1>", whole result <= 80 per ADR-013 H1.
  defp bump_slug(attrs, attempt) do
    base = attrs[:slug] || attrs["slug"]
    Map.put(attrs, :slug, Slug.with_suffix(base, attempt + 1))
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

  def get_message(message_id) do
    Repo.get(ChatMessage, message_id)
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

  # ── Reactions ─────────────────────────────────────────────────
  #
  # Emoji reactions over the polymorphic npl_reactions table (entity_type +
  # entity_id). Chat uses entity_type "chat_message" (and "chat_event" for the
  # Chat.React MCP tool). Idempotent: re-adding the same (entity, persona, emoji)
  # is a no-op that returns the existing row. Mirrors the wiki reactions pattern.

  def add_reaction(attrs) do
    entity_type = attrs[:entity_type] || attrs["entity_type"]
    entity_id = attrs[:entity_id] || attrs["entity_id"]
    persona = attrs[:persona] || attrs["persona"]
    emoji = attrs[:emoji] || attrs["emoji"]

    %Reaction{}
    |> Reaction.changeset(attrs)
    |> Repo.insert(
      on_conflict: :nothing,
      conflict_target: [:entity_type, :entity_id, :persona, :emoji]
    )
    |> case do
      {:ok, _} ->
        # Re-fetch by the unique key so we return the persisted row whether it
        # was just inserted or already existed (on_conflict :nothing may return
        # a struct that does not reflect the stored row).
        {:ok,
         Repo.get_by(Reaction,
           entity_type: entity_type,
           entity_id: entity_id,
           persona: persona,
           emoji: emoji
         )}

      error ->
        error
    end
  end

  def remove_reaction(entity_type, entity_id, persona, emoji) do
    {count, _} =
      Reaction
      |> where(
        [r],
        r.entity_type == ^entity_type and r.entity_id == ^entity_id and
          r.persona == ^persona and r.emoji == ^emoji
      )
      |> Repo.delete_all()

    if count > 0, do: :ok, else: {:error, :not_found}
  end

  def list_reactions(entity_type, entity_id) do
    Reaction
    |> where([r], r.entity_type == ^entity_type and r.entity_id == ^entity_id)
    |> order_by([r], asc: r.inserted_at)
    |> Repo.all()
  end

  def reaction_counts(entity_type, entity_id) do
    Reaction
    |> where([r], r.entity_type == ^entity_type and r.entity_id == ^entity_id)
    |> group_by([r], r.emoji)
    |> select([r], {r.emoji, count(r.id)})
    |> Repo.all()
    |> Map.new()
  end

  @doc """
  Batched reaction summaries for many messages at once (avoids N+1 when rendering a
  message list). Returns `%{message_id => [%{emoji, count, me}]}` where `me` is true
  when `persona` reacted with that emoji. Messages with no reactions are absent from
  the map (caller defaults to []).
  """
  def message_reaction_summaries(message_ids, persona) when is_list(message_ids) do
    counts =
      Reaction
      |> where([r], r.entity_type == "chat_message" and r.entity_id in ^message_ids)
      |> group_by([r], [r.entity_id, r.emoji])
      |> select([r], {r.entity_id, r.emoji, count(r.id)})
      |> Repo.all()

    mine =
      Reaction
      |> where(
        [r],
        r.entity_type == "chat_message" and r.entity_id in ^message_ids and r.persona == ^persona
      )
      |> select([r], {r.entity_id, r.emoji})
      |> Repo.all()
      |> MapSet.new()

    Enum.group_by(
      counts,
      fn {mid, _emoji, _count} -> mid end,
      fn {mid, emoji, count} -> %{emoji: emoji, count: count, me: MapSet.member?(mine, {mid, emoji})} end
    )
  end

  @doc """
  Single-message reaction summary for `persona` — the same `[%{emoji, count, me}]`
  shape the message list embeds (FE `ChatReactionSummary[]`), so the dedicated
  reaction endpoints and the message list speak one shape. Delegates to the batched
  query for one source of truth; `[]` when the message has no reactions.
  """
  def message_reaction_summary(message_id, persona) do
    message_reaction_summaries([message_id], persona) |> Map.get(message_id, [])
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
