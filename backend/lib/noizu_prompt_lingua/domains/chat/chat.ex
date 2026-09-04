defmodule NoizuPromptLingua.Domains.Chat do
  import Ecto.Query, except: [update: 2]
  require Logger
  alias NoizuPromptLingua.Repo

  alias NoizuPromptLingua.Schema.{
    ChatRoom,
    ChatMessage,
    ChatEvent,
    ChatMember,
    ChatNotification,
    Reaction
  }

  # Notifications dispatch (Stream B). Resolved at runtime via apply/3 so the
  # chat domain never hard-fails or fails to compile if Dispatch is absent.
  @dispatch NoizuPromptLingua.Domains.Notifications.Dispatch

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

  # Delete a room and everything under it (76338b44). chat_messages/events/members/
  # notifications cascade via ON DELETE CASCADE (032-chat). npl_reactions is polymorphic
  # (no FK), so we sweep reactions on this room's messages + events FIRST, before the
  # cascade removes the rows they reference — otherwise they'd orphan. Hard delete (the
  # console-delete + smoke-room-cleanup use cases need actual removal); no soft-archive
  # column today. Returns {:ok, room} | {:error, :not_found} | {:error, changeset}.
  def delete_room(room_id) when is_binary(room_id) do
    case get_room(room_id) do
      nil -> {:error, :not_found}
      room -> delete_room(room)
    end
  end

  def delete_room(%ChatRoom{} = room) do
    Repo.transaction(fn ->
      msg_ids =
        ChatMessage |> where([m], m.room_id == ^room.id) |> select([m], m.id) |> Repo.all()

      event_ids =
        ChatEvent |> where([e], e.room_id == ^room.id) |> select([e], e.id) |> Repo.all()

      sweep_reactions("chat_message", msg_ids)
      sweep_reactions("chat_event", event_ids)

      case Repo.delete(room) do
        {:ok, deleted} -> deleted
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)
  end

  defp sweep_reactions(_entity_type, []), do: :ok

  defp sweep_reactions(entity_type, ids) do
    Reaction
    |> where([r], r.entity_type == ^entity_type and r.entity_id in ^ids)
    |> Repo.delete_all()
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
        where: r.organization_id == ^org_id and r.project_id == ^project_id and r.slug == ^slug
    )
  end

  # Resolve a room for MCP tool addressing: UUID args keep the legacy id lookup,
  # anything else is treated as the room's immutable slug. Slugs are unique per
  # (org, project) bucket (ADR-013 A3), so slug lookup requires org scope — callers
  # resolve the org ref via MCP.Resolve first. Returns {:ok, room} |
  # {:error, :organization_required} | {:error, :not_found}.
  def resolve_room(ref, org_id \\ nil)

  def resolve_room(ref, org_id) do
    case NoizuPromptLingua.UUID.cast(ref) do
      {:ok, uuid} ->
        case get_room(uuid) do
          nil -> {:error, :not_found}
          room -> {:ok, room}
        end

      :error when is_nil(org_id) ->
        {:error, :organization_required}

      :error ->
        case get_room_by_slug(org_id, nil, ref) do
          nil -> {:error, :not_found}
          room -> {:ok, room}
        end
    end
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
    case room
         |> ChatRoom.changeset(%{slug: Slug.with_suffix(base, attempt + 1)})
         |> Repo.update() do
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
    |> maybe_filter_kind(opts[:kind])
    |> order_by([r], desc: r.updated_at)
    |> limit(^(opts[:limit] || 50))
    |> offset(^(opts[:offset] || 0))
    |> Repo.all()
  end

  def room_count do
    Repo.aggregate(ChatRoom, :count)
  end

  # ── DMs ───────────────────────────────────────────────────────

  @doc """
  Create (or reuse) a direct-message room. A DM is a `kind: "dm"` room with
  2+ members; a multi-user DM simply has N members. When an existing DM in the
  same org/project already has exactly the same member set it is reused.

  `members` is a list of persona slugs.
  """
  def create_dm(org_id, project_id, members) when is_list(members) do
    members = members |> Enum.map(&to_string/1) |> Enum.uniq()

    case find_existing_dm(org_id, project_id, members) do
      %ChatRoom{} = room ->
        {:ok, room}

      nil ->
        attrs = %{
          organization_id: org_id,
          project_id: project_id,
          kind: "dm",
          name: dm_name(members)
        }

        with {:ok, room} <- create_room(attrs) do
          Enum.each(members, fn persona ->
            add_member(%{room_id: room.id, persona: persona})
          end)

          {:ok, room}
        end
    end
  end

  defp dm_name(members) do
    ("DM: " <> (members |> Enum.sort() |> Enum.join(", "))) |> String.slice(0, 255)
  end

  defp find_existing_dm(org_id, project_id, members) do
    target = MapSet.new(members)

    ChatRoom
    |> where([r], r.organization_id == ^org_id and r.kind == "dm")
    |> maybe_filter_project(project_id)
    |> Repo.all()
    |> Enum.find(fn room ->
      room_members =
        room.id
        |> list_members()
        |> Enum.map(& &1.persona)
        |> MapSet.new()

      MapSet.equal?(room_members, target)
    end)
  end

  # ── Messages ──────────────────────────────────────────────────

  def send_message(attrs) do
    with {:ok, msg} <- %ChatMessage{} |> ChatMessage.changeset(attrs) |> Repo.insert() do
      touch_session_activity(msg.room_id)
      dispatch_chat_message(msg)
      {:ok, msg}
    end
  end

  # A message posted to a session-linked room counts as session activity for the
  # inactivity sweep. Best-effort: a failed touch never fails the message post.
  defp touch_session_activity(room_id) do
    session_id =
      Repo.one(from r in ChatRoom, where: r.id == ^room_id, select: r.session_id)

    if session_id, do: NoizuPromptLingua.Sessions.touch_activity(session_id)
  rescue
    e ->
      Logger.warning("[Chat] session activity touch failed for room #{room_id}: #{inspect(e)}")
      :ok
  end

  def list_messages(room_id, opts \\ []) do
    ChatMessage
    |> where([m], m.room_id == ^room_id)
    |> maybe_top_level(opts[:top_level])
    |> exclude_pending_scheduled()
    |> maybe_before(opts[:before])
    |> maybe_after(opts[:after])
    |> order_by([m], desc: m.inserted_at)
    |> limit(^(opts[:limit] || 50))
    |> Repo.all()
  end

  # Slack-style channel view (ffa2d2f6): top-level messages only; replies live under
  # their parent in the thread view (list_replies/1), not inline in the channel.
  defp maybe_top_level(query, true), do: where(query, [m], is_nil(m.parent_message_id))
  defp maybe_top_level(query, _), do: query

  def get_message(message_id), do: Repo.get(ChatMessage, message_id)

  @doc "Recent messages only — the join backlog. Defaults to the last 5 minutes."
  def recent_messages(room_id, minutes \\ 5, opts \\ []) do
    cutoff =
      DateTime.utc_now() |> DateTime.add(-minutes * 60, :second) |> DateTime.truncate(:second)

    ChatMessage
    |> where([m], m.room_id == ^room_id and m.inserted_at >= ^cutoff)
    |> exclude_pending_scheduled()
    |> order_by([m], asc: m.inserted_at)
    |> limit(^(opts[:limit] || 50))
    |> Repo.all()
  end

  # Replies to a message (threaded), oldest-first (read order within a thread).
  # A nil parent id lists nothing — Ecto rejects `== ^nil` (use is_nil/1), and
  # callers reaching here with nil mean "no thread", not "all roots"
  # (ForwardReplies 500'd on a root message; ticket 998061d9).
  def list_replies(nil), do: []

  def list_replies(message_id) do
    ChatMessage
    |> where([m], m.parent_message_id == ^message_id)
    |> exclude_pending_scheduled()
    |> order_by([m], asc: m.inserted_at)
    |> Repo.all()
  end

  @doc """
  Reply count + last-reply timestamp per root message id, batched (no N+1) for the
  channel list's thread affordances (marcus seq587). Returns
  `%{root_id => %{reply_count, last_reply_at}}`; roots with no replies are absent.
  """
  def thread_summaries(root_ids) when is_list(root_ids) do
    ChatMessage
    |> where([m], m.parent_message_id in ^root_ids)
    |> group_by([m], m.parent_message_id)
    |> select([m], {m.parent_message_id, count(m.id), max(m.inserted_at)})
    |> Repo.all()
    |> Map.new(fn {pid, cnt, last} -> {pid, %{reply_count: cnt, last_reply_at: last}} end)
  end

  @doc "Toggle (or set) the pinned flag on a message."
  def pin_message(message_id, pinned \\ nil) do
    update_message_flag(message_id, :pinned, pinned)
  end

  @doc "Toggle (or set) the highlighted flag on a message."
  def highlight_message(message_id, highlighted \\ nil) do
    update_message_flag(message_id, :highlighted, highlighted)
  end

  defp update_message_flag(message_id, field, value) do
    case Repo.get(ChatMessage, message_id) do
      nil ->
        {:error, :not_found}

      msg ->
        new_value = if is_boolean(value), do: value, else: !Map.get(msg, field)
        msg |> Ecto.Changeset.change(%{field => new_value}) |> Repo.update()
    end
  end

  # ── Scheduled messages ────────────────────────────────────────

  @doc """
  Store a message to be posted at a future instant. The row lands in
  `chat_messages` with `scheduled_for` set; `list_messages`/`recent_messages`
  exclude rows whose `scheduled_for` is still in the future, and no dispatch
  fires until `release_due_scheduled/0` flips it live.
  """
  def schedule_message(attrs) do
    %ChatMessage{} |> ChatMessage.changeset(attrs) |> Repo.insert()
  end

  @doc """
  Release every scheduled message whose time has arrived: clear `scheduled_for`
  and dispatch each live. Returns `{:ok, count}`. Intended to be driven by a
  ticker, or called on demand by the integrator.
  """
  def release_due_scheduled do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    due =
      ChatMessage
      |> where([m], not is_nil(m.scheduled_for) and m.scheduled_for <= ^now)
      |> Repo.all()

    released =
      Enum.map(due, fn msg ->
        case msg |> Ecto.Changeset.change(scheduled_for: nil) |> Repo.update() do
          {:ok, live} ->
            dispatch_chat_message(live)
            live

          _ ->
            nil
        end
      end)
      |> Enum.reject(&is_nil/1)

    {:ok, length(released)}
  end

  # ── Events ────────────────────────────────────────────────────

  def create_event(attrs) do
    with {:ok, event} <- %ChatEvent{} |> ChatEvent.changeset(attrs) |> Repo.insert() do
      dispatch_chat_message(event)
      {:ok, event}
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
      fn {mid, emoji, count} ->
        %{emoji: emoji, count: count, me: MapSet.member?(mine, {mid, emoji})}
      end
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

  def get_member(room_id, persona) do
    Repo.get_by(ChatMember, room_id: room_id, persona: persona)
  end

  @doc """
  Update a member's mute preferences. `settings` may set `:muted` and/or
  `:mute_unless_mentioned`. Creates the membership if absent.
  """
  def mute_room(room_id, persona, settings \\ []) do
    settings = Map.new(settings)

    changes =
      %{}
      |> maybe_put(:muted, Map.get(settings, :muted))
      |> maybe_put(:mute_unless_mentioned, Map.get(settings, :mute_unless_mentioned))

    upsert_member(room_id, persona, changes)
  end

  @doc "Mark a member as having left the room (sets `left_at`)."
  def leave_room(room_id, persona) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    case get_member(room_id, persona) do
      nil -> {:error, :not_found}
      member -> member |> Ecto.Changeset.change(left_at: now) |> Repo.update()
    end
  end

  @doc "Join (or rejoin) a room — inserts the membership and clears `left_at`."
  def join_room(room_id, persona) do
    upsert_member(room_id, persona, %{left_at: nil})
  end

  defp upsert_member(room_id, persona, changes) do
    case get_member(room_id, persona) do
      nil ->
        attrs = Map.merge(%{room_id: room_id, persona: persona}, changes)
        %ChatMember{} |> ChatMember.changeset(attrs) |> Repo.insert()

      member ->
        member |> Ecto.Changeset.change(changes) |> Repo.update()
    end
  end

  # ── Attachments ───────────────────────────────────────────────

  @doc "Attachments recorded against a room (wiki/space/url references)."
  def room_attachments(room_id) do
    NoizuPromptLingua.Services.Attach.list("chat_room", room_id)
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

      _ ->
        {:error, :not_found}
    end
  end

  def clear_all_notifications(persona) do
    {count, _} =
      ChatNotification
      |> where([n], n.persona == ^persona and n.read == false)
      |> Repo.update_all(set: [read: true])

    {:ok, count}
  end

  # ── Private ───────────────────────────────────────────────────

  # Best-effort hand-off to the notifications Dispatch. Never raises into the
  # chat write path; if Dispatch is unavailable the message is simply persisted.
  defp dispatch_chat_message(record) do
    room = get_room(record.room_id)

    try do
      apply(@dispatch, :chat_message, [record, room])
    rescue
      _ -> :ok
    catch
      _, _ -> :ok
    end

    :ok
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  defp exclude_pending_scheduled(q) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    where(q, [m], is_nil(m.scheduled_for) or m.scheduled_for <= ^now)
  end

  defp maybe_filter_organization(q, nil), do: q
  defp maybe_filter_organization(q, org_id), do: where(q, [r], r.organization_id == ^org_id)

  defp maybe_filter_project(q, nil), do: q
  defp maybe_filter_project(q, project_id), do: where(q, [r], r.project_id == ^project_id)

  defp maybe_filter_session(q, nil), do: q
  defp maybe_filter_session(q, sid), do: where(q, [r], r.session_id == ^sid)

  defp maybe_filter_kind(q, nil), do: q
  defp maybe_filter_kind(q, kind), do: where(q, [r], r.kind == ^kind)

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
