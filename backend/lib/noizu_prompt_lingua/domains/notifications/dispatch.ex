defmodule NoizuPromptLingua.Domains.Notifications.Dispatch do
  @moduledoc """
  Fan-out engine that turns domain events (chat messages, reactions, comments,
  ticket changes, generic watch updates, agent presence) into notifications via
  `NoizuPromptLingua.Domains.Notifications.notify/1`.

  Every public hook is **best-effort**: it is wrapped in `try/rescue` and will
  never raise into the caller. A failure to fan out a notification must not break
  the domain action that triggered it.

  Recipient resolution combines the entity owner/assignee/author, the entity's
  watchers (`NoizuPromptLingua.Services.Watch.watchers/2`), and — for chat —
  thread participants.
  """

  import Ecto.Query
  require Logger

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema
  alias NoizuPromptLingua.Services.Watch
  alias NoizuPromptLingua.Domains.Notifications

  @owner_fields %{
    "chat_message" => [:sender],
    "chat_event" => [:persona, :sender],
    "ticket" => [:assignee, :reporter],
    "review" => [:reviewer_persona, :author, :created_by],
    "wiki_page" => [:author, :created_by, :owner],
    "artifact" => [:created_by, :author, :owner],
    "asset" => [:created_by, :author, :owner],
    "asset_entry" => [:created_by, :author, :owner]
  }

  @entity_schemas %{
    "chat_message" => Schema.ChatMessage,
    "chat_event" => Schema.ChatEvent,
    "ticket" => Schema.Ticket,
    "review" => Schema.Review,
    "wiki_page" => Schema.Wiki.Page,
    "artifact" => Schema.Artifact,
    "asset" => Schema.AssetEntry,
    "asset_entry" => Schema.AssetEntry
  }

  @digest_delay_seconds 5 * 60

  # ------------------------------------------------------------------
  # Chat
  # ------------------------------------------------------------------

  @doc """
  Fan out a chat message.

    * `@everyone` / `@handle` mentions of room members → immediate `mention`.
      Muted members are skipped entirely; `mute_unless_mentioned` members still
      receive mention notifications.
    * Remaining members → a coalesced `chat_digest` (dedup
      `chat_digest:<room_id>`, delivered in 5 minutes). Muted and
      `mute_unless_mentioned` members are skipped.
    * Room watchers whose filter matches the message body → `watch_update`.
    * Thread replies (`parent_message_id` set) → `comment` to the parent author
      and prior thread repliers.
  """
  def chat_message(msg, room) do
    safe(fn ->
      org_id = entity_org_id(room) || val(msg, :organization_id)
      project_id = entity_project_id(room) || val(msg, :project_id)
      room_id = val(room, :id) || val(msg, :room_id)
      content = val(msg, :content) || ""
      sender = val(msg, :sender)
      message_id = val(msg, :id)

      members = room_members(room_id)
      mentioned = mentioned_personas(content, members)

      # 1. Mentions — immediate, skip muted entirely.
      Enum.each(members, fn member ->
        persona = member.persona

        cond do
          persona == sender -> :skip
          muted?(member) -> :skip
          not MapSet.member?(mentioned, persona) -> :skip
          true ->
            notify(%{
              organization_id: org_id,
              project_id: project_id,
              recipient: persona,
              sender: sender,
              kind: "mention",
              subject_type: "chat_message",
              subject_id: message_id,
              body: content,
              payload: %{room_id: room_id, message_id: message_id}
            })
        end
      end)

      # 2. Digest — non-mention traffic, coalesced per room.
      Enum.each(members, fn member ->
        persona = member.persona

        cond do
          persona == sender -> :skip
          muted?(member) -> :skip
          mute_unless_mentioned?(member) -> :skip
          MapSet.member?(mentioned, persona) -> :skip
          true ->
            notify(%{
              organization_id: org_id,
              project_id: project_id,
              recipient: persona,
              sender: sender,
              kind: "chat_digest",
              subject_type: "chat_room",
              subject_id: room_id,
              dedup_key: "chat_digest:#{room_id}",
              deliver_after: DateTime.add(DateTime.utc_now(), @digest_delay_seconds, :second),
              payload: %{room_id: room_id}
            })
        end
      end)

      # 3. Room watchers — honour per-watch filters against the message body.
      safe(fn ->
        Watch.watchers_with_filter("chat_room", room_id)
        |> Enum.each(fn {persona, filter} ->
          if persona != sender and Watch.matches_filter?(filter, content) do
            notify(%{
              organization_id: org_id,
              project_id: project_id,
              recipient: persona,
              sender: sender,
              kind: "watch_update",
              subject_type: "chat_room",
              subject_id: room_id,
              body: content,
              payload: %{room_id: room_id, message_id: message_id}
            })
          end
        end)
      end)

      # 4. Thread replies → notify the parent author + prior thread repliers.
      case val(msg, :parent_message_id) do
        nil -> :ok
        parent_id -> safe(fn -> notify_thread(msg, parent_id, org_id, project_id, sender) end)
      end

      :ok
    end)
  end

  defp notify_thread(msg, parent_id, org_id, project_id, sender) do
    parent = safe_get(Schema.ChatMessage, parent_id)
    parent_author = parent && parent.sender

    repliers =
      Schema.ChatMessage
      |> where([m], field(m, ^:parent_message_id) == ^parent_id)
      |> select([m], m.sender)
      |> Repo.all()

    recipients =
      [parent_author | repliers]
      |> Enum.reject(&(is_nil(&1) or &1 == sender))
      |> Enum.uniq()

    Enum.each(recipients, fn persona ->
      notify(%{
        organization_id: org_id,
        project_id: project_id,
        recipient: persona,
        sender: sender,
        kind: "comment",
        subject_type: "chat_message",
        subject_id: val(msg, :id),
        body: val(msg, :content),
        payload: %{
          room_id: val(msg, :room_id),
          parent_message_id: parent_id,
          message_id: val(msg, :id)
        }
      })
    end)
  end

  # ------------------------------------------------------------------
  # Reactions / comments
  # ------------------------------------------------------------------

  @doc "Notify an entity's owner and watchers that it received a reaction."
  def reaction(reaction), do: safe(fn -> notify_entity_followers(reaction, "reaction") end)

  @doc "Notify an entity's owner and watchers that it received a comment."
  def comment(comment), do: safe(fn -> notify_entity_followers(comment, "comment") end)

  defp notify_entity_followers(map, kind) do
    entity_type = val(map, :entity_type)
    entity_id = val(map, :entity_id)
    actor = val(map, :persona) || val(map, :author) || val(map, :sender)
    record = load_entity(entity_type, entity_id)

    org_id = (record && entity_org_id(record)) || val(map, :organization_id)
    project_id = (record && entity_project_id(record)) || val(map, :project_id)
    owner = owner_of(entity_type, entity_id, record)

    recipients =
      [owner | Watch.watchers(entity_type, entity_id)]
      |> Enum.reject(&(is_nil(&1) or &1 == actor))
      |> Enum.uniq()

    if org_id && recipients != [] do
      notify(%{
        organization_id: org_id,
        project_id: project_id,
        recipients: recipients,
        sender: actor,
        kind: kind,
        subject_type: entity_type,
        subject_id: entity_id,
        body: val(map, :content) || val(map, :emoji),
        payload: %{entity_type: entity_type, entity_id: entity_id}
      })
    end
  end

  # ------------------------------------------------------------------
  # Tickets
  # ------------------------------------------------------------------

  @doc "Notify a newly-assigned ticket's assignee."
  def ticket_assigned(ticket) do
    safe(fn ->
      org_id = val(ticket, :organization_id)
      assignee = val(ticket, :assignee)
      reporter = val(ticket, :reporter)

      if org_id && assignee && assignee != reporter do
        notify(%{
          organization_id: org_id,
          project_id: val(ticket, :project_id),
          recipient: assignee,
          sender: reporter,
          kind: "ticket_assigned",
          subject_type: "ticket",
          subject_id: val(ticket, :id),
          body: val(ticket, :title),
          payload: %{ticket_id: val(ticket, :id), status: val(ticket, :status)}
        })
      end
    end)
  end

  @doc "Notify a ticket's assignee, reporter, and watchers of an update."
  def ticket_update(ticket) do
    safe(fn ->
      org_id = val(ticket, :organization_id)
      ticket_id = val(ticket, :id)

      recipients =
        [val(ticket, :assignee), val(ticket, :reporter) | Watch.watchers("ticket", ticket_id)]
        |> Enum.reject(&is_nil/1)
        |> Enum.uniq()

      if org_id && recipients != [] do
        notify(%{
          organization_id: org_id,
          project_id: val(ticket, :project_id),
          recipients: recipients,
          kind: "ticket_update",
          subject_type: "ticket",
          subject_id: ticket_id,
          body: val(ticket, :title),
          payload: %{ticket_id: ticket_id, status: val(ticket, :status)}
        })
      end
    end)
  end

  # ------------------------------------------------------------------
  # Generic watch updates
  # ------------------------------------------------------------------

  @doc """
  Notify the watchers of any entity that it changed. `change` may be a string or
  a map (`:text`/`:summary`/`:content` are used as the body, `:actor`/`:persona`
  as the originator and excluded from recipients). Per-watch filters are applied
  against the change text.
  """
  def watch_update(entity_type, entity_id, change) do
    safe(fn ->
      cmap = if is_map(change), do: change, else: %{}
      record = load_entity(entity_type, entity_id)

      org_id = (record && entity_org_id(record)) || Map.get(cmap, :organization_id)
      project_id = (record && entity_project_id(record)) || Map.get(cmap, :project_id)
      actor = Map.get(cmap, :actor) || Map.get(cmap, :persona)
      text = change_text(change)

      recipients =
        Watch.watchers_with_filter(entity_type, entity_id)
        |> Enum.filter(fn {persona, filter} ->
          persona != actor and Watch.matches_filter?(filter, text)
        end)
        |> Enum.map(fn {persona, _filter} -> persona end)
        |> Enum.uniq()

      if org_id && recipients != [] do
        notify(%{
          organization_id: org_id,
          project_id: project_id,
          recipients: recipients,
          sender: actor,
          kind: "watch_update",
          subject_type: entity_type,
          subject_id: entity_id,
          body: text,
          payload: %{entity_type: entity_type, entity_id: entity_id, change: normalize_change(change)}
        })
      end
    end)
  end

  # ------------------------------------------------------------------
  # Presence
  # ------------------------------------------------------------------

  @doc """
  Announce an agent presence transition. Best-effort PubSub broadcast on the
  `"presence"` topic; consumers (e.g. live notification streams) subscribe to it.
  """
  def presence(handle, status) do
    safe(fn ->
      Phoenix.PubSub.broadcast(
        NoizuPromptLingua.PubSub,
        "presence",
        {:presence, handle, status}
      )
    end)

    :ok
  end

  # ------------------------------------------------------------------
  # Owner resolution
  # ------------------------------------------------------------------

  @doc """
  Resolve the owning persona for an entity. Covers chat_message (sender),
  ticket (assignee/creator), and artifact/asset/wiki_page/review
  (author/created_by). Returns nil when no owner can be resolved — callers then
  fall back to notifying watchers only.
  """
  def owner_of(entity_type, entity_id) do
    owner_of(entity_type, entity_id, load_entity(entity_type, entity_id))
  end

  defp owner_of(_entity_type, _entity_id, nil), do: nil

  defp owner_of(entity_type, _entity_id, record) do
    fields = Map.get(@owner_fields, entity_type, [:created_by, :author, :owner, :persona])
    Enum.find_value(fields, fn f -> blank_to_nil(Map.get(record, f)) end)
  end

  # ------------------------------------------------------------------
  # Internals
  # ------------------------------------------------------------------

  defp notify(attrs), do: Notifications.notify(attrs)

  defp load_entity(entity_type, entity_id) when is_binary(entity_id) do
    case Map.get(@entity_schemas, entity_type) do
      nil -> nil
      mod -> safe_get(mod, entity_id)
    end
  end

  defp load_entity(_entity_type, _entity_id), do: nil

  defp safe_get(mod, id) do
    Repo.get(mod, id)
  rescue
    _ -> nil
  end

  defp room_members(nil), do: []

  defp room_members(room_id) do
    Schema.ChatMember
    |> where([m], m.room_id == ^room_id)
    |> Repo.all()
  end

  defp mentioned_personas(content, members) do
    handles = parse_mentions(content)

    if MapSet.member?(handles, "everyone") do
      MapSet.new(Enum.map(members, & &1.persona))
    else
      members
      |> Enum.map(& &1.persona)
      |> MapSet.new()
      |> MapSet.intersection(handles)
    end
  end

  defp parse_mentions(content) when is_binary(content) do
    ~r/@([A-Za-z0-9_.\-]+)/
    |> Regex.scan(content)
    |> Enum.map(fn [_full, handle] -> handle end)
    |> MapSet.new()
  end

  defp parse_mentions(_), do: MapSet.new()

  # chat messages carry org/project via their room.
  defp entity_org_id(%Schema.ChatMessage{room_id: room_id}) do
    case safe_get(Schema.ChatRoom, room_id) do
      nil -> nil
      room -> room.organization_id
    end
  end

  defp entity_org_id(record) when is_map(record), do: Map.get(record, :organization_id)
  defp entity_org_id(_), do: nil

  defp entity_project_id(%Schema.ChatMessage{room_id: room_id}) do
    case safe_get(Schema.ChatRoom, room_id) do
      nil -> nil
      room -> room.project_id
    end
  end

  defp entity_project_id(record) when is_map(record), do: Map.get(record, :project_id)
  defp entity_project_id(_), do: nil

  defp change_text(change) when is_binary(change), do: change

  defp change_text(change) when is_map(change) do
    Map.get(change, :text) || Map.get(change, :summary) || Map.get(change, :content) || ""
  end

  defp change_text(_), do: ""

  defp normalize_change(change) when is_map(change), do: change
  defp normalize_change(change), do: %{text: change_text(change)}

  defp flag?(member, key), do: Map.get(member, key) in [true, "true", 1]
  defp muted?(member), do: flag?(member, :muted)
  defp mute_unless_mentioned?(member), do: flag?(member, :mute_unless_mentioned)

  defp val(map, key) when is_map(map), do: Map.get(map, key)
  defp val(_, _), do: nil

  defp blank_to_nil(""), do: nil
  defp blank_to_nil(value), do: value

  defp safe(fun) do
    fun.()
    :ok
  rescue
    e ->
      Logger.warning("[Notifications.Dispatch] hook error: #{inspect(e)}")
      :error
  catch
    kind, reason ->
      Logger.warning("[Notifications.Dispatch] hook #{kind}: #{inspect(reason)}")
      :error
  end
end
