defmodule NoizuPromptLingua.MCP.VFS.Chat do
  @moduledoc """
  Chat group VFS backend (Wave 3) — the richest append-log plane, per
  MCP-VFS-GROUP-MOUNTS.md §2.9. Wired to `NoizuPromptLingua.Domains.Chat`;
  paths are absolute (the same namespace the composed Router serves), so this
  module is conformance-testable standalone through `Noizu.MCP.Server.Features.VFS`.

  ## Namespace

      /tobor/{org}/chat                        rooms.json · overview.md · {room}/ dirs · dm/
      /tobor/{org}/chat/rooms.json             index w/ this principal's rooms + unread counts
      /tobor/{org}/chat/{room}/record.json     canonical room doc (write = name/description merge
                                               + optional "attach_wiki" op; AttachWiki)
      …/{room}/messages/{ts}-{seq}.json        per-message create-new files (append expressed as
                                               create — there is no append primitive; §6 A1)
      …/messages/{msg-id}.replies/{ts}-{seq}.json   threaded replies
      …/{room}/events/{ts}-{short8}.json       CreateEvent / ListEvents
      …/{room}/members/{persona}.json          AddMember (create) · MuteRoom (write own flags) ·
                                               LeaveRoom (remove own) · JoinRoom (create own)
      …/{room}/attachments/{id}.json           Chat.Attach / Attach.list (URL refs, not blobs — B1)
      …/{room}/reactions.json                  Chat.React — read = room reaction set;
                                               write = one {"target","emoji"[,"persona"][,"remove"]} op
      …/{room}/pinned.json                     PinMessage / HighlightMessage —
                                               write {"target"[,"pinned"][,"highlighted"]}
      …/{room}/scheduled/{send-at}-{short8}.json    ScheduleMessage; remove = cancel
      …/{room}/notifications/{id}.json         this principal's unread room notifications; remove = clear
      /tobor/{org}/chat/dm/{member-pair-key}/  DM rooms (kind "dm"), pair key = sorted member
                                               personas joined "+", same room shape beneath

  `{ts}` is filesystem-safe UTC (`2026-09-05T12-00-01Z`, no colons; §1.1). Message
  files carry a microsecond `{seq}` so file order == send order. **Server-assigned
  canonical names**: a create under `messages/ | events/ | scheduled/ |
  attachments/` tolerates any client-chosen filename — the row's canonical name
  (derived from its timestamps/id) is what `readdir` reports; mounts converge on
  the listing. `record.json` create is the exception: the requested `{room}`
  segment IS the room slug, and a collision is `:eexist` (a create must never
  land at a different path than the client asked; the domain's ADR-013 `-N`
  suffix retry still guards the insert race).

  ## Membership gating (chat membership IS the authz source)

  Every op resolves the connection persona (claims `sub` user → `user_name`,
  else `handle`) and the room's active membership (`chat_members`,
  `left_at IS NULL`):

    * `/chat` and room DIRS are visible to any org-visible principal with the
      chat group (room names are org-internal; this is what keeps JoinRoom
      addressable);
    * every room CONTENT subtree (`record.json`, `messages/`, `events/`,
      `members/`, `attachments/`, `reactions.json`, `pinned.json`, `scheduled/`,
      `notifications/`) is `:enoent` for non-members — hidden, not forbidden;
    * `dm/{pair-key}` is `:enoent` for non-participants (DM existence is
      private), and a pair key not containing the principal never resolves;
    * the ONE non-member-writable node is `members/{me}.json` (create =
      JoinRoom — the §2.9 create-own-member-file mapping stays live despite
      subtree hiding; write/remove of it require membership);
    * `rooms.json` and `dm/` list only the principal's own rooms (unread
      counts are per-principal by nature).

  Group/org gates ride the Wave-0 `Principal` cascade: an excluded chat group
  or an invisible org is `:enoent` for the entire subtree (§1.3). The lib's
  VFS cache is identity-blind (§6 P1) and disabled app-side, so the
  per-principal views here do not cross-contaminate.

  ## Semantics notes

    * **Append-log**: messages are immutable — `write` on a message file is
      `:eacces`; a message appears as exactly one create-new file (one daemon
      materialization per message); `ls messages/ | tail` is the tail -f.
    * **DeleteRoom** = `remove` on the room dir with the behaviour's
      `:enotempty` guard — a room with any content refuses; force-delete stays
      a domain / `/etc/dev` concern (§3.5). `record.json` itself is never
      removable (its remove would be a cascade delete in disguise).
    * **ScheduleMessage**: a create under `scheduled/` stores the row with
      `scheduled_for`; send+move to `messages/` is `Chat.release_due_scheduled/0`,
      driven by the Wave-4 runner (design §3.8 job conventions) — until it
      fires the file sits in `scheduled/` and is invisible under `messages/`.
    * **ForwardReplies** is deliberately unmapped — a state transition routed
      through `/etc/dev` control writes, never a content edit (§2.9, §3.1).
    * `ListMessages` readdir is sorted oldest→newest and cursor-paginated
      (offset cursors; foreign cursors are invalid params); the other listings
      are bounded and uncursored.
  """

  use Noizu.MCP.VFS

  import Ecto.Query, except: [update: 2]

  alias Noizu.MCP.Error
  alias Noizu.MCP.VFS
  alias NoizuPromptLingua.Domains.Chat
  alias NoizuPromptLingua.MCP.Resolve
  alias NoizuPromptLingua.MCP.VFS.Principal
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{ChatMessage, Reaction, Users.User}

  @root "tobor"
  @group "chat"
  @overview "overview.md"
  @index_file "rooms.json"
  @record "record.json"
  @reactions "reactions.json"
  @pinned "pinned.json"
  @dm_dir "dm"
  @content_dirs ~w(messages events members attachments scheduled notifications)

  @message_page 50
  @dir_page 200

  # `{msg-id}.replies/` thread dirs — usable in guards too.
  defguardp replies_dir?(name)
            when is_binary(name) and byte_size(name) > 8 and
                   binary_part(name, byte_size(name) - 8, 8) == ".replies"

  # ── path model ────────────────────────────────────────────────────────────

  defp normalize("/" <> rest), do: String.trim_trailing(rest, "/")
  defp normalize(path) when is_binary(path), do: String.trim_trailing(path, "/")

  # Stable-key segments only: reject traversal and dot segments outright.
  defp split_segments(path) do
    segments = String.split(normalize(path), "/", trim: true)

    if Enum.any?(segments, &(&1 in [".", ".."])),
      do: {:error, :enoent},
      else: {:ok, segments}
  end

  # ── position resolution ───────────────────────────────────────────────────
  #
  # One grammar, shared by every callback:
  #   {:chat_dir, org} | {:group_file, org, file} | {:dm_root, org}
  #   {:room, org, rctx, room_rest}
  # `guest_ok` lets the create path resolve a room WITHOUT membership (the
  # join affordance); reads/lists/stats of room content stay member-only.

  defp position(ctx, segments, guest_ok) do
    case segments do
      [@root, org, @group] ->
        with_org_group(ctx, org, fn -> {:ok, {:chat_dir, org}} end)

      [@root, org, @group, file] when file in [@overview, @index_file] ->
        with_org_group(ctx, org, fn -> {:ok, {:group_file, org, file}} end)

      [@root, org, @group, @dm_dir] ->
        with_org_group(ctx, org, fn -> {:ok, {:dm_root, org}} end)

      [@root, org, @group, @dm_dir, pair | room_rest] ->
        with_dm(ctx, org, pair, fn rctx -> {:ok, {:room, org, rctx, room_rest}} end)

      [@root, org, @group, room | room_rest] ->
        with_channel(ctx, org, room, room_rest, guest_ok)

      _ ->
        {:error, :enoent}
    end
  end

  defp with_channel(ctx, org, room, room_rest, guest_ok) do
    with_org_group(ctx, org, fn ->
      oid = org_id(org)

      case resolve_scoped_room(room, oid, "channel") do
        {:ok, room_row} ->
          me = persona(ctx)
          member = active_member(room_row.id, me)

          if room_rest != [] and member == nil and not guest_ok do
            {:error, :enoent}
          else
            {:ok,
             {:room, org, %{org_id: oid, room: room_row, persona: me, member: member}, room_rest}}
          end

        error ->
          error
      end
    end)
  end

  # Org visibility + chat group gate; the whole subtree is :enoent past either.
  defp with_org_group(ctx, org, fun) do
    if Principal.org_visible?(ctx, org) do
      with :ok <- Principal.group_gate(ctx, @group), do: fun.()
    else
      {:error, :enoent}
    end
  end

  # The connection persona: claims user → user_name, else handle. nil = no
  # attributable identity — the principal can never hold membership.
  defp persona(ctx) do
    with user_id when is_binary(user_id) <- Resolve.current_user_id(ctx),
         %User{} = user <- Repo.get(User, user_id) do
      user.user_name || user.handle
    else
      _ -> nil
    end
  end

  # Resolve the local org row for a visible org slug (rooms are FK-scoped to
  # it). Deliberately a direct query — NOT `Organizations.resolve_org_id/1`,
  # whose Redis-backed slug cache (1h TTL, machine-global, transaction-blind)
  # would serve sandbox-rolled-back/deleted org ids to gating-critical VFS ops.
  defp org_id(org) do
    Repo.one(
      from(o in NoizuPromptLingua.Schema.Organizations.Organization,
        where: o.slug == ^org,
        select: o.id,
        limit: 1
      )
    )
  end

  # Resolve a segment to a room scoped to THIS org and kind (uuid or slug per
  # Chat.resolve_room/2; org + kind verified here — the uuid branch of
  # resolve_room/2 is not org-scoped).
  defp resolve_scoped_room(segment, org_id, kind)

  defp resolve_scoped_room(_segment, nil, _kind), do: {:error, :enoent}

  defp resolve_scoped_room(segment, org_id, kind) do
    case Chat.resolve_room(segment, org_id) do
      {:ok, %{organization_id: ^org_id, kind: ^kind} = room} -> {:ok, room}
      _ -> {:error, :enoent}
    end
  end

  # Resolve dm/{pair-key}: exact member-set match over the org's dm rooms; the
  # pair key must include the principal (a DM you're not in does not exist).
  defp with_dm(ctx, org, pair_key, fun) do
    with_org_group(ctx, org, fn ->
      oid = org_id(org)
      me = persona(ctx)
      wanted = dm_members(pair_key)

      cond do
        oid == nil or me == nil or me not in wanted ->
          {:error, :enoent}

        match?({:ok, _}, find_dm(oid, wanted)) ->
          {:ok, room} = find_dm(oid, wanted)
          fun.(%{org_id: oid, room: room, persona: me, member: active_member(room.id, me)})

        true ->
          {:error, :enoent}
      end
    end)
  end

  defp dm_members(pair_key), do: String.split(pair_key, "+", trim: true)

  defp pair_key(room_id) do
    room_id
    |> Chat.list_members()
    |> Enum.filter(&is_nil(&1.left_at))
    |> Enum.map(& &1.persona)
    |> Enum.sort()
    |> Enum.join("+")
  end

  defp find_dm(org_id, wanted) do
    rooms = Chat.list_rooms(organization_id: org_id, kind: "dm", limit: 10_000)

    room =
      Enum.find(rooms, fn room ->
        members =
          room.id
          |> Chat.list_members()
          |> Enum.filter(&is_nil(&1.left_at))
          |> MapSet.new(& &1.persona)

        MapSet.equal?(members, MapSet.new(wanted))
      end)

    if room, do: {:ok, room}, else: {:error, :enoent}
  end

  defp active_member(room_id, persona) when is_binary(persona) do
    case Chat.get_member(room_id, persona) do
      %{left_at: nil} = member -> member
      _ -> nil
    end
  end

  defp active_member(_room_id, nil), do: nil

  # ── stat/2 ────────────────────────────────────────────────────────────────

  @impl true
  def stat(path, ctx) do
    with {:ok, segments} <- split_segments(path),
         {:ok, pos} <- position(ctx, segments, false) do
      case pos do
        {:chat_dir, _org} -> {:ok, dir_node()}
        {:group_file, org, file} -> {:ok, file_node(content_size(file, org, ctx))}
        {:dm_root, _org} -> {:ok, dir_node()}
        {:room, _org, rctx, []} -> {:ok, room_dir_node(rctx)}
        {:room, _org, rctx, rest} -> stat_room_rest(rctx, rest)
      end
    end
  end

  defp stat_room_rest(rctx, [@record]),
    do: {:ok, file_node(json_size(room_record(rctx)), writable: true)}

  defp stat_room_rest(rctx, [file]) when file in [@reactions, @pinned],
    do: {:ok, file_node(content_size(file, rctx, nil), writable: true)}

  defp stat_room_rest(_rctx, [dir]) when dir in @content_dirs, do: {:ok, dir_node()}

  # A message file — or the {msg-id}.replies dir.
  defp stat_room_rest(rctx, ["messages", name]) do
    if replies_dir?(name) do
      parent_name = String.trim_trailing(name, ".replies")

      with {:ok, _parent} <- fetch_message(rctx, parent_name), do: {:ok, dir_node()}
    else
      with {:ok, msg} <- fetch_message(rctx, name) do
        {:ok, file_node(json_size(message_doc(msg)), writable: false)}
      end
    end
  end

  defp stat_room_rest(rctx, ["messages", parent_name, name]) do
    parent_name = String.trim_trailing(parent_name, ".replies")

    with {:ok, parent} <- fetch_message(rctx, parent_name),
         {:ok, msg} <- fetch_reply(parent.id, name) do
      {:ok, file_node(json_size(message_doc(msg)), writable: false)}
    end
  end

  defp stat_room_rest(rctx, ["events", name]) do
    with {:ok, event} <- fetch_event(rctx, name),
         do: {:ok, file_node(json_size(event_doc(event)), writable: false)}
  end

  defp stat_room_rest(rctx, ["members", member_file]) do
    case fetch_member(rctx, String.trim_trailing(member_file, ".json")) do
      nil ->
        {:error, :enoent}

      member ->
        {:ok, file_node(json_size(member_doc(member)), writable: member.persona == rctx.persona)}
    end
  end

  defp stat_room_rest(rctx, ["attachments", att_file]) do
    case Enum.find(
           Chat.room_attachments(rctx.room.id),
           &(&1.id == String.trim_trailing(att_file, ".json"))
         ) do
      nil -> {:error, :enoent}
      att -> {:ok, file_node(json_size(attachment_doc(att)), writable: false)}
    end
  end

  defp stat_room_rest(rctx, ["scheduled", name]) do
    case Enum.find(scheduled_messages(rctx.room.id), &(scheduled_name(&1) == name)) do
      nil -> {:error, :enoent}
      msg -> {:ok, file_node(json_size(scheduled_doc(msg)), writable: false)}
    end
  end

  defp stat_room_rest(rctx, ["notifications", notif_file]) do
    case room_notification(rctx, String.trim_trailing(notif_file, ".json")) do
      nil -> {:error, :enoent}
      notif -> {:ok, file_node(json_size(notification_doc(notif)), writable: false)}
    end
  end

  defp stat_room_rest(_rctx, _rest), do: {:error, :enoent}

  # ── list/3 ────────────────────────────────────────────────────────────────

  @impl true
  def list(path, cursor, ctx) do
    with {:ok, segments} <- split_segments(path),
         {:ok, pos} <- position(ctx, segments, false) do
      case pos do
        {:chat_dir, org} -> list_chat_dir(org, cursor, ctx)
        {:group_file, _org, _file} -> {:error, :enotdir}
        {:dm_root, org} -> list_dm_root(org, cursor, ctx)
        {:room, _org, rctx, []} -> list_room_root(rctx, cursor)
        {:room, _org, rctx, rest} -> list_room_rest(rctx, rest, cursor)
      end
    end
  end

  defp list_chat_dir(org, cursor, _ctx) do
    oid = org_id(org)

    rooms =
      if oid do
        Chat.list_rooms(organization_id: oid, kind: "channel", limit: 10_000)
      else
        []
      end

    entries =
      [
        file_entry(@index_file),
        file_entry(@overview)
        | rooms |> Enum.map(fn room -> room.slug || room.id end) |> Enum.map(&dir_entry/1)
      ]
      |> Enum.sort_by(& &1.name)

    page(entries, cursor, @dir_page)
  end

  defp list_dm_root(org, cursor, ctx) do
    entries =
      org
      |> my_dm_keys(ctx)
      |> Enum.sort()
      |> Enum.map(&dir_entry/1)

    page(entries, cursor, @dir_page)
  end

  # Room-dir listing — a non-member sees an empty dir (content is :enoent for
  # them; the join affordance is documented in overview.md).
  defp list_room_root(rctx, cursor)

  defp list_room_root(%{member: nil}, _cursor), do: {:ok, [], nil}

  defp list_room_root(_rctx, cursor) do
    entries =
      [
        dir_entry("messages"),
        dir_entry("events"),
        dir_entry("members"),
        dir_entry("attachments"),
        dir_entry("scheduled"),
        dir_entry("notifications"),
        file_entry(@record),
        file_entry(@reactions),
        file_entry(@pinned)
      ]
      |> Enum.sort_by(& &1.name)

    page(entries, cursor, @dir_page)
  end

  defp list_room_rest(rctx, ["messages"], cursor) do
    names =
      rctx.room.id
      |> Chat.list_messages(top_level: true, limit: 10_000)
      |> Enum.map(&message_name/1)

    page(Enum.sort(names) |> Enum.map(&file_entry/1), cursor, @message_page)
  end

  defp list_room_rest(rctx, ["messages", parent_name], cursor) do
    if replies_dir?(parent_name) do
      parent_name = String.trim_trailing(parent_name, ".replies")

      with {:ok, parent} <- fetch_message(rctx, parent_name) do
        names =
          parent.id
          |> Chat.list_replies()
          |> Enum.map(&message_name/1)

        page(Enum.sort(names) |> Enum.map(&file_entry/1), cursor, @message_page)
      end
    else
      {:error, :enoent}
    end
  end

  defp list_room_rest(rctx, ["events"], cursor) do
    names =
      rctx.room.id
      |> Chat.list_events(limit: 10_000)
      |> Enum.map(&event_name/1)

    page(Enum.sort(names) |> Enum.map(&file_entry/1), cursor, @dir_page)
  end

  defp list_room_rest(rctx, ["members"], cursor) do
    names =
      rctx.room.id
      |> Chat.list_members()
      |> Enum.filter(&is_nil(&1.left_at))
      |> Enum.map(&(&1.persona <> ".json"))

    page(Enum.sort(names) |> Enum.map(&file_entry/1), cursor, @dir_page)
  end

  defp list_room_rest(rctx, ["attachments"], cursor) do
    names =
      rctx.room.id
      |> Chat.room_attachments()
      |> Enum.map(&(&1.id <> ".json"))

    page(Enum.sort(names) |> Enum.map(&file_entry/1), cursor, @dir_page)
  end

  defp list_room_rest(rctx, ["scheduled"], cursor) do
    names =
      rctx.room.id
      |> scheduled_messages()
      |> Enum.map(&scheduled_name/1)

    page(Enum.sort(names) |> Enum.map(&file_entry/1), cursor, @dir_page)
  end

  defp list_room_rest(rctx, ["notifications"], cursor) do
    names =
      rctx
      |> room_unread()
      |> Enum.map(&(&1.id <> ".json"))

    page(Enum.sort(names) |> Enum.map(&file_entry/1), cursor, @dir_page)
  end

  defp list_room_rest(_rctx, _rest, _cursor), do: {:error, :enoent}

  defp my_dm_keys(org, ctx) do
    with oid when oid != nil <- org_id(org),
         me when is_binary(me) <- persona(ctx) do
      oid
      |> then(&Chat.list_rooms(organization_id: &1, kind: "dm", limit: 10_000))
      |> Enum.filter(&(active_member(&1.id, me) != nil))
      |> Enum.map(&pair_key(&1.id))
      |> Enum.uniq()
    else
      _ -> []
    end
  end

  # ── read/2 ────────────────────────────────────────────────────────────────

  @impl true
  def read(path, ctx) do
    with {:ok, segments} <- split_segments(path),
         {:ok, pos} <- position(ctx, segments, false) do
      case pos do
        {:chat_dir, _org} -> {:error, :eisdir}
        {:group_file, _org, @overview} -> {:ok, overview_md(), version()}
        {:group_file, org, @index_file} -> {:ok, Jason.encode!(rooms_index(org, ctx)), version()}
        {:dm_root, _org} -> {:error, :eisdir}
        {:room, _org, _rctx, []} -> {:error, :eisdir}
        {:room, _org, rctx, rest} -> read_room_rest(rctx, rest)
      end
    end
  end

  defp read_room_rest(rctx, [@record]), do: {:ok, Jason.encode!(room_record(rctx)), version()}

  defp read_room_rest(rctx, [@reactions]),
    do: {:ok, Jason.encode!(reactions_doc(rctx)), version()}

  defp read_room_rest(rctx, [@pinned]), do: {:ok, Jason.encode!(pinned_doc(rctx)), version()}

  defp read_room_rest(rctx, ["messages", name]) do
    if replies_dir?(name) do
      {:error, :eisdir}
    else
      with {:ok, msg} <- fetch_message(rctx, name),
           do: {:ok, Jason.encode!(message_doc(msg)), version()}
    end
  end

  defp read_room_rest(rctx, ["messages", parent_name, name]) do
    parent_name = String.trim_trailing(parent_name, ".replies")

    with {:ok, parent} <- fetch_message(rctx, parent_name),
         {:ok, msg} <- fetch_reply(parent.id, name) do
      {:ok, Jason.encode!(message_doc(msg)), version()}
    end
  end

  defp read_room_rest(rctx, ["events", name]) do
    with {:ok, event} <- fetch_event(rctx, name),
         do: {:ok, Jason.encode!(event_doc(event)), version()}
  end

  defp read_room_rest(rctx, ["members", member_file]) do
    case fetch_member(rctx, String.trim_trailing(member_file, ".json")) do
      nil -> {:error, :enoent}
      member -> {:ok, Jason.encode!(member_doc(member)), version()}
    end
  end

  defp read_room_rest(rctx, ["attachments", att_file]) do
    att_id = String.trim_trailing(att_file, ".json")

    case Enum.find(Chat.room_attachments(rctx.room.id), &(&1.id == att_id)) do
      nil -> {:error, :enoent}
      att -> {:ok, Jason.encode!(attachment_doc(att)), version()}
    end
  end

  defp read_room_rest(rctx, ["scheduled", name]) do
    case Enum.find(scheduled_messages(rctx.room.id), &(scheduled_name(&1) == name)) do
      nil -> {:error, :enoent}
      msg -> {:ok, Jason.encode!(scheduled_doc(msg)), version()}
    end
  end

  defp read_room_rest(rctx, ["notifications", notif_file]) do
    case room_notification(rctx, String.trim_trailing(notif_file, ".json")) do
      nil -> {:error, :enoent}
      notif -> {:ok, Jason.encode!(notification_doc(notif)), version()}
    end
  end

  defp read_room_rest(_rctx, _rest), do: {:error, :enoent}

  # ── write/3 ───────────────────────────────────────────────────────────────

  @impl true
  def write(path, data, ctx) do
    with {:ok, segments} <- split_segments(path),
         {:ok, pos} <- position(ctx, segments, false) do
      case pos do
        {:room, _org, rctx, [@record]} -> write_record(rctx, data)
        {:room, _org, rctx, [@reactions]} -> write_reactions(rctx, data)
        {:room, _org, rctx, [@pinned]} -> write_pinned(rctx, data)
        {:room, _org, rctx, ["members", member_file]} -> write_member(rctx, member_file, data)
        {:room, _org, _rctx, rest} when rest != [] -> {:error, :eacces}
        _ -> {:error, :eacces}
      end
    end
  end

  # Canonical room doc write: name/description merge + optional "attach_wiki"
  # op ({"url": …, "artifact_type"?: …, "description"?: …}). Malformed JSON or
  # a rejected changeset is :eio (§2 error mapping for malformed writes).
  defp write_record(rctx, data) do
    with {:ok, body} <- decode_object(data, :eio) do
      attrs =
        %{}
        |> maybe_put(:name, body["name"])
        |> maybe_put(:description, body["description"])

      with {:ok, room} <- Chat.update_room(rctx.room, attrs),
           :ok <- maybe_attach_wiki(room, body, rctx.persona) do
        {:ok, file_node(json_size(room_record(%{rctx | room: room})), writable: true)}
      else
        {:error, _} -> {:error, :eio}
        :eio -> {:error, :eio}
      end
    end
  end

  defp maybe_attach_wiki(_room, body, _persona) when not is_map_key(body, "attach_wiki"), do: :ok

  defp maybe_attach_wiki(room, %{"attach_wiki" => op}, persona) when is_map(op) do
    url = op["url"]

    if is_binary(url) and url != "" do
      attrs = %{
        artifact_type: op["artifact_type"] || "wiki",
        url: url,
        description: op["description"],
        created_by: persona
      }

      case NoizuPromptLingua.Services.Attach.add("chat_room", room.id, attrs) do
        {:ok, _} -> :ok
        _ -> :eio
      end
    else
      :eio
    end
  end

  defp maybe_attach_wiki(_room, _body, _persona), do: :eio

  # Reactions: {"target": <msg file-name|uuid>, "emoji": "…"[, "persona": "…",
  # "remove": true]}. Persona defaults to the connection persona.
  defp write_reactions(rctx, data) do
    with {:ok, body} <- decode_object(data, :eio),
         {:ok, {etype, eid}} <- resolve_reaction_target(rctx, body["target"]),
         emoji when is_binary(emoji) and emoji != "" <- body["emoji"] || :no_emoji,
         persona when is_binary(persona) and persona != "" <-
           non_blank(body["persona"]) || rctx.persona || :no_persona do
      if body["remove"] == true do
        case Chat.remove_reaction(etype, eid, persona, emoji) do
          :ok -> {:ok, file_node(0, writable: true)}
          {:error, :not_found} -> {:error, :enoent}
        end
      else
        case Chat.add_reaction(%{
               entity_type: etype,
               entity_id: eid,
               persona: persona,
               emoji: emoji
             }) do
          {:ok, _} -> {:ok, file_node(0, writable: true)}
          {:error, _cs} -> {:error, :eio}
        end
      end
    else
      {:error, _} = err -> err
      :no_emoji -> {:error, :eio}
      :no_persona -> {:error, :eacces}
    end
  end

  defp resolve_reaction_target(_rctx, target) when not is_binary(target) or target == "",
    do: {:error, :eio}

  defp resolve_reaction_target(rctx, target) do
    case fetch_message(rctx, target) do
      {:ok, msg} -> {:ok, {"chat_message", msg.id}}
      error -> error
    end
  end

  # Pins/highlights: {"target": …[, "pinned": bool][, "highlighted": bool]} —
  # a present-but-null key toggles (mirrors the tools' omit-to-toggle).
  defp write_pinned(rctx, data) do
    with {:ok, body} <- decode_object(data, :eio),
         {:ok, {_etype, msg_id}} <- resolve_reaction_target(rctx, body["target"]),
         true <- pinned_op?(body) || :error do
      with :ok <- apply_flag(&Chat.pin_message/2, msg_id, body, "pinned"),
           :ok <- apply_flag(&Chat.highlight_message/2, msg_id, body, "highlighted") do
        {:ok, file_node(0, writable: true)}
      else
        other -> {:error, normalize_eio(other)}
      end
    else
      {:error, _} = err -> err
      :error -> {:error, :eio}
    end
  end

  defp pinned_op?(body),
    do: Map.has_key?(body, "pinned") or Map.has_key?(body, "highlighted")

  defp apply_flag(fun, id, body, key) do
    if Map.has_key?(body, key) do
      case fun.(id, body[key]) do
        {:ok, _} -> :ok
        _ -> :eio
      end
    else
      :ok
    end
  end

  # MuteRoom — write own flags; another persona's file is not writable.
  defp write_member(rctx, member_file, data) do
    persona_name = String.trim_trailing(member_file, ".json")

    cond do
      persona_name != rctx.persona ->
        {:error, :eacces}

      rctx.member == nil ->
        {:error, :enoent}

      true ->
        with {:ok, body} <- decode_object(data, :eio),
             settings = own_flag_settings(body),
             true <- settings != %{} || :error do
          case Chat.mute_room(rctx.room.id, rctx.persona, Map.to_list(settings)) do
            {:ok, _} -> {:ok, file_node(0, writable: true)}
            {:error, _cs} -> {:error, :eio}
          end
        else
          {:error, _} = err -> err
          :error -> {:error, :eio}
        end
    end
  end

  defp own_flag_settings(body) do
    %{}
    |> put_flag(:muted, body, "muted")
    |> put_flag(:mute_unless_mentioned, body, "mute_unless_mentioned")
  end

  defp put_flag(map, key, body, json_key) do
    if Map.has_key?(body, json_key) and is_boolean(body[json_key]),
      do: Map.put(map, key, body[json_key]),
      else: map
  end

  # ── create/3 ──────────────────────────────────────────────────────────────

  @impl true
  def create(path, data, ctx) do
    with {:ok, segments} <- split_segments(path) do
      create_segments(segments, data, ctx)
    end
  end

  # CreateRoom — create {room}/record.json (or a bare :dir at {room}). The
  # segment IS the slug: collision is :eexist (a create never lands at a
  # different path); the domain's ADR-013 retry guards the insert race.
  defp create_segments([@root, org, @group, room, @record], data, ctx),
    do: create_room_at(ctx, org, room, data)

  # BEFORE the bare-room clause — a :dir create at chat/dm must hit this, not
  # create a channel literally named "dm".
  defp create_segments([@root, _org, @group, @dm_dir], _data, _ctx), do: {:error, :eexist}

  defp create_segments([@root, org, @group, room], :dir, ctx),
    do: create_room_at(ctx, org, room, nil)

  # DM — create dm/{member-pair-key} as a dir. File semantics over the domain's
  # reuse-by-member-set: an existing pair key is :eexist.
  defp create_segments([@root, org, @group, @dm_dir, pair], :dir, ctx),
    do: create_dm_at(ctx, org, pair)

  defp create_segments([@root, _org, @group, @dm_dir, _pair], _data, _ctx), do: {:error, :eisdir}

  defp create_segments([@root, org, @group | rest], data, ctx) do
    with {:ok, pos} <- position(ctx, [@root, org, @group | rest], true) do
      case pos do
        {:room, _org, rctx, ["messages", name]} when not replies_dir?(name) ->
          create_message(rctx, data, nil)

        {:room, _org, rctx, ["messages", parent_name, _name]} ->
          parent_name = String.trim_trailing(parent_name, ".replies")

          with {:ok, parent} <- fetch_message(rctx, parent_name) do
            create_message(rctx, data, parent.id)
          end

        {:room, _org, rctx, ["events", _name]} ->
          create_event(rctx, data)

        {:room, _org, rctx, ["members", member_file]} ->
          create_member(rctx, String.trim_trailing(member_file, ".json"), data)

        {:room, _org, rctx, ["attachments", _name]} ->
          create_attachment(rctx, data)

        {:room, _org, rctx, ["scheduled", name]} ->
          create_scheduled(rctx, name, data)

        {:room, _org, _rctx, rest} when rest != [] ->
          {:error, :eexist}

        _ ->
          {:error, :eexist}
      end
    end
  end

  defp create_segments(_, _data, _ctx), do: {:error, :enoent}

  defp create_room_at(ctx, org, segment, data) do
    with_org_group(ctx, org, fn ->
      oid = org_id(org)
      base = if oid, do: slug_base(segment), else: nil

      cond do
        oid == nil ->
          {:error, :enoent}

        base == nil ->
          {:error, Error.invalid_params("room slug must match [a-z0-9](-[a-z0-9])*")}

        Chat.get_room_by_slug(oid, nil, base) != nil ->
          {:error, :eexist}

        true ->
          with {:ok, body} <- create_body(data) do
            attrs = %{
              organization_id: oid,
              slug: base,
              name: body["name"] || base,
              description: body["description"]
            }

            case Chat.create_room(attrs) do
              {:ok, room} ->
                # The creator auto-joins: the file plane has no separate join
                # step, and a create whose own record.json reads back :enoent
                # would be a broken flow. (The MCP tool surface leaves joining
                # explicit; mounts need the subtree open.)
                me = persona(ctx)

                member =
                  if is_binary(me) do
                    case Chat.join_room(room.id, me) do
                      {:ok, m} -> m
                      _ -> nil
                    end
                  end

                rctx = %{org_id: oid, room: room, persona: me, member: member}
                {:ok, file_node(json_size(room_record(rctx)), writable: true)}

              {:error, _cs} ->
                # Race: another principal took the slug between probe and
                # insert — the domain may have landed a suffixed slug, which
                # would NOT match the requested path; refuse instead.
                {:error, :eexist}
            end
          end
      end
    end)
  end

  defp slug_base(segment) do
    if Regex.match?(~r/^[a-z0-9](-?[a-z0-9])*$/, segment), do: segment, else: nil
  end

  defp create_dm_at(ctx, org, pair_key) do
    with_org_group(ctx, org, fn ->
      oid = org_id(org)
      me = persona(ctx)
      members = Enum.uniq(dm_members(pair_key))

      cond do
        oid == nil ->
          {:error, :enoent}

        me == nil ->
          {:error, :eacces}

        me not in members ->
          {:error, :eacces}

        length(members) < 2 ->
          {:error, Error.invalid_params("a DM requires at least 2 members")}

        match?({:ok, _}, find_dm(oid, members)) ->
          {:error, :eexist}

        true ->
          case Chat.create_dm(oid, nil, members) do
            {:ok, _room} -> {:ok, dir_node(writable: true)}
            {:error, _} -> {:error, :eio}
          end
      end
    end)
  end

  # SendMessage — append expressed as create-new; the client filename is a
  # wish, the canonical {ts}-{seq}.json name is server-assigned.
  defp create_message(rctx, data, parent_id) do
    with {:ok, body} <- message_body(data),
         content when is_binary(content) and content != "" <- body_content(body) || :error,
         sender when is_binary(sender) and sender != "" <-
           non_blank(body["sender"]) || rctx.persona || :error do
      attrs =
        %{room_id: rctx.room.id, content: content, sender: sender}
        |> maybe_put(:parent_message_id, parent_id)

      case Chat.send_message(attrs) do
        {:ok, msg} -> {:ok, file_node(json_size(message_doc(msg)), writable: false)}
        {:error, _cs} -> {:error, :eio}
      end
    else
      {:error, _} = err -> err
      :error -> {:error, :eio}
    end
  end

  defp create_event(rctx, data) do
    with {:ok, body} <- decode_object(data, :eio),
         etype when etype in ~w(action todo milestone decision) <- body["event_type"],
         content when is_binary(content) and content != "" <- non_blank(body["content"]),
         sender when is_binary(sender) and sender != "" <-
           non_blank(body["sender"]) || rctx.persona || :error do
      attrs =
        %{room_id: rctx.room.id, event_type: etype, content: content, sender: sender}
        |> maybe_put(:metadata, body["metadata"])

      case Chat.create_event(attrs) do
        {:ok, event} -> {:ok, file_node(json_size(event_doc(event)), writable: false)}
        {:error, _cs} -> {:error, :eio}
      end
    else
      {:error, _} = err -> err
      :error -> {:error, :eio}
      _ -> {:error, :eio}
    end
  end

  # AddMember / JoinRoom — create members/{persona}.json. Own file = join
  # (allowed WITHOUT membership — the one non-member create; optional flags
  # body applies initial mute settings). Another persona = AddMember, members
  # only.
  defp create_member(rctx, persona_name, data)

  defp create_member(_rctx, "", _data), do: {:error, :enoent}

  defp create_member(rctx, persona_name, data) when persona_name == rctx.persona do
    cond do
      rctx.persona == nil ->
        {:error, :eacces}

      rctx.member != nil ->
        {:error, :eexist}

      true ->
        with {:ok, _} <- Chat.join_room(rctx.room.id, rctx.persona),
             {:ok, body} <- create_body(data) do
          settings = own_flag_settings(body)

          case apply_join_flags(rctx.room.id, rctx.persona, settings) do
            :ok -> {:ok, file_node(0, writable: true)}
            :eio -> {:error, :eio}
          end
        else
          {:error, _cs} -> {:error, :eio}
          other -> normalize_eio(other)
        end
    end
  end

  defp create_member(rctx, persona_name, data) do
    if rctx.member == nil do
      {:error, :eacces}
    else
      if active_member(rctx.room.id, persona_name) != nil do
        {:error, :eexist}
      else
        with {:ok, body} <- create_body(data) do
          case Chat.add_member(%{
                 room_id: rctx.room.id,
                 persona: persona_name,
                 role: body["role"] || "member"
               }) do
            {:ok, _} -> {:ok, file_node(0, writable: false)}
            {:error, _cs} -> {:error, :eio}
          end
        end
      end
    end
  end

  defp apply_join_flags(_room_id, _persona, settings) when settings == %{}, do: :ok

  defp apply_join_flags(room_id, persona, settings) do
    case Chat.mute_room(room_id, persona, Map.to_list(settings)) do
      {:ok, _} -> :ok
      _ -> :eio
    end
  end

  # Chat.Attach — URL-reference attachments (blobs are B1, not this wave).
  defp create_attachment(rctx, data) do
    with {:ok, body} <- attachment_body(data),
         url when is_binary(url) and url != "" <- non_blank(body["url"]),
         me when is_binary(me) <- rctx.persona || :error do
      attrs =
        %{
          artifact_type: body["artifact_type"] || "url",
          url: url,
          description: body["description"],
          created_by: me
        }
        |> maybe_put(:git_branch, body["git_branch"])

      case NoizuPromptLingua.Services.Attach.add("chat_room", rctx.room.id, attrs) do
        {:ok, att} -> {:ok, file_node(json_size(attachment_doc(att)), writable: false)}
        {:error, _cs} -> {:error, :eio}
      end
    else
      {:error, _} = err -> err
      :error -> {:error, :eacces}
      _ -> {:error, :eio}
    end
  end

  # ScheduleMessage — scheduled/{send-at}[-{anything}].json; remove = cancel.
  defp create_scheduled(rctx, name, data) do
    with {:ok, send_at} <- parse_send_at(String.trim_trailing(name, ".json")),
         {:ok, body} <- message_body(data),
         content when is_binary(content) and content != "" <- body_content(body) || :error,
         sender when is_binary(sender) and sender != "" <-
           non_blank(body["sender"]) || rctx.persona || :error do
      attrs = %{
        room_id: rctx.room.id,
        content: content,
        sender: sender,
        scheduled_for: DateTime.truncate(send_at, :second)
      }

      case Chat.schedule_message(attrs) do
        {:ok, msg} -> {:ok, file_node(json_size(scheduled_doc(msg)), writable: false)}
        {:error, _cs} -> {:error, :eio}
      end
    else
      {:error, _} = err -> err
      :error -> {:error, :eio}
    end
  end

  # ── remove/2 ──────────────────────────────────────────────────────────────

  @impl true
  def remove(path, ctx) do
    with {:ok, segments} <- split_segments(path) do
      remove_segments(segments, ctx)
    end
  end

  defp remove_segments([@root, org, @group | rest], ctx) do
    with {:ok, pos} <- position(ctx, [@root, org, @group | rest], false) do
      case pos do
        {:room, _org, rctx, []} ->
          remove_room(rctx)

        {:room, _org, rctx, ["members", member_file]} ->
          remove_member(rctx, member_file)

        {:room, _org, rctx, ["scheduled", name]} ->
          remove_scheduled(rctx, name)

        {:room, _org, rctx, ["notifications", notif_file]} ->
          remove_notification(rctx, notif_file)

        {:room, _org, rctx, ["attachments", att_file]} ->
          remove_attachment(rctx, att_file)

        {:room, _org, _rctx, rest} when rest != [] ->
          {:error, :eacces}

        _ ->
          {:error, :eacces}
      end
    end
  end

  defp remove_segments(_, _ctx), do: {:error, :enoent}

  # DeleteRoom — behaviour :enotempty guard; an EMPTY room (record.json is
  # virtual) deletes. Force-delete with content is not file-exposed (§3.5).
  defp remove_room(rctx) do
    if rctx.member == nil do
      {:error, :enoent}
    else
      room_id = rctx.room.id

      # "Empty" = no content artifacts; memberships are presence, not content —
      # deleting a room you can see always only cascades trivial rows.
      empty? =
        Chat.list_messages(room_id, limit: 1) == [] and
          Chat.list_events(room_id, limit: 1) == [] and
          Chat.room_attachments(room_id) == [] and
          scheduled_messages(room_id) == []

      if empty? do
        case Chat.delete_room(room_id) do
          {:ok, _} -> :ok
          {:error, _} -> {:error, :eio}
        end
      else
        {:error, :enotempty}
      end
    end
  end

  # LeaveRoom — remove own member file (clears the subtree for this principal).
  defp remove_member(rctx, member_file) do
    persona_name = String.trim_trailing(member_file, ".json")

    cond do
      persona_name != rctx.persona ->
        {:error, :eacces}

      rctx.member == nil ->
        {:error, :enoent}

      true ->
        case Chat.leave_room(rctx.room.id, rctx.persona) do
          {:ok, _} -> :ok
          {:error, _cs} -> {:error, :eio}
        end
    end
  end

  # Scheduled remove = cancel (the Wave-4 runner never sends it).
  defp remove_scheduled(rctx, name) do
    case Enum.find(scheduled_messages(rctx.room.id), &(scheduled_name(&1) == name)) do
      nil ->
        {:error, :enoent}

      msg ->
        case Repo.delete(msg) do
          {:ok, _} -> :ok
          {:error, _} -> {:error, :eio}
        end
    end
  end

  # Notification remove = clear (mark read; the unread listing drops it).
  defp remove_notification(rctx, notif_file) do
    notif_id = String.trim_trailing(notif_file, ".json")

    if room_notification(rctx, notif_id) == nil do
      {:error, :enoent}
    else
      case Chat.clear_notification(rctx.persona, notif_id) do
        {:ok, _} -> :ok
        {:error, :not_found} -> {:error, :enoent}
      end
    end
  end

  defp remove_attachment(rctx, att_file) do
    att_id = String.trim_trailing(att_file, ".json")

    if Enum.any?(Chat.room_attachments(rctx.room.id), &(&1.id == att_id)) do
      case NoizuPromptLingua.Services.Attach.remove(att_id) do
        {:ok, _} -> :ok
        {:error, _} -> {:error, :eio}
      end
    else
      {:error, :enoent}
    end
  end

  # ── fetchers ──────────────────────────────────────────────────────────────

  # Resolve a message by canonical file name ({ts}-{seq}.json) or bare UUID.
  defp fetch_message(rctx, name)

  defp fetch_message(_rctx, name) when not is_binary(name) or name == "", do: {:error, :enoent}

  defp fetch_message(rctx, name) do
    cond do
      is_uuid(name) ->
        case Chat.get_message(name) do
          %{room_id: room_id} = msg when room_id == rctx.room.id -> {:ok, msg}
          _ -> {:error, :enoent}
        end

      String.ends_with?(name, ".json") ->
        msgs = Chat.list_messages(rctx.room.id, top_level: true, limit: 10_000)

        case Enum.find(msgs, &(message_name(&1) == name)) do
          nil -> {:error, :enoent}
          msg -> {:ok, msg}
        end

      true ->
        {:error, :enoent}
    end
  end

  defp fetch_reply(parent_id, name) do
    if String.ends_with?(name, ".json") do
      case Enum.find(Chat.list_replies(parent_id), &(message_name(&1) == name)) do
        nil -> {:error, :enoent}
        msg -> {:ok, msg}
      end
    else
      {:error, :enoent}
    end
  end

  defp fetch_event(rctx, name) do
    events = Chat.list_events(rctx.room.id, limit: 10_000)

    cond do
      is_uuid(name) ->
        case Enum.find(events, &(&1.id == name)) do
          nil -> {:error, :enoent}
          event -> {:ok, event}
        end

      String.ends_with?(name, ".json") ->
        case Enum.find(events, &(event_name(&1) == name)) do
          nil -> {:error, :enoent}
          event -> {:ok, event}
        end

      true ->
        {:error, :enoent}
    end
  end

  defp fetch_member(rctx, persona_name) do
    rctx.room.id
    |> Chat.list_members()
    |> Enum.filter(&is_nil(&1.left_at))
    |> Enum.find(&(&1.persona == persona_name))
  end

  defp is_uuid(s), do: match?({:ok, _}, Ecto.UUID.cast(s))

  defp scheduled_messages(room_id) do
    ChatMessage
    |> where([m], m.room_id == ^room_id and not is_nil(m.scheduled_for))
    |> order_by([m], asc: m.scheduled_for)
    |> Repo.all()
  end

  # This principal's unread notifications for the room (empty for a
  # persona-less connection).
  defp room_unread(rctx) do
    case rctx.persona do
      persona when is_binary(persona) ->
        persona
        |> Chat.list_notifications()
        |> Enum.filter(&(&1.room_id == rctx.room.id))

      _ ->
        []
    end
  end

  defp room_notification(rctx, notif_id), do: Enum.find(room_unread(rctx), &(&1.id == notif_id))

  # ── documents ─────────────────────────────────────────────────────────────

  defp message_name(msg) do
    {us, _} = msg.inserted_at.microsecond
    seq = us |> Integer.to_string() |> String.pad_leading(6, "0")
    "#{safe_ts(msg.inserted_at)}-#{seq}.json"
  end

  defp event_name(event), do: "#{safe_ts(event.inserted_at)}-#{short8(event.id)}.json"

  defp scheduled_name(msg), do: "#{safe_ts(msg.scheduled_for)}-#{short8(msg.id)}.json"

  defp safe_ts(dt), do: Calendar.strftime(dt, "%Y-%m-%dT%H-%M-%SZ")

  defp short8(id), do: id |> String.replace("-", "") |> binary_part(0, 8)

  defp message_doc(msg) do
    %{
      "id" => msg.id,
      "file" => message_name(msg),
      "content" => msg.content,
      "sender" => msg.sender,
      "created_at" => DateTime.to_iso8601(msg.inserted_at),
      "pinned" => msg.pinned,
      "highlighted" => msg.highlighted,
      "parent_id" => msg.parent_message_id,
      "scheduled_for" => msg.scheduled_for && DateTime.to_iso8601(msg.scheduled_for)
    }
    |> put_if_true("important", msg.highlighted)
  end

  defp event_doc(event) do
    %{
      "id" => event.id,
      "file" => event_name(event),
      "event_type" => event.event_type,
      "content" => event.content,
      "sender" => event.sender,
      "metadata" => event.metadata,
      "created_at" => DateTime.to_iso8601(event.inserted_at)
    }
  end

  defp scheduled_doc(msg), do: message_doc(msg)

  defp member_doc(member) do
    %{
      "persona" => member.persona,
      "role" => member.role,
      "muted" => member.muted,
      "mute_unless_mentioned" => member.mute_unless_mentioned,
      "joined_at" => member.inserted_at && DateTime.to_iso8601(member.inserted_at),
      "left_at" => member.left_at && DateTime.to_iso8601(member.left_at)
    }
  end

  defp attachment_doc(att) do
    %{
      "id" => att.id,
      "artifact_type" => att.artifact_type,
      "url" => att.url,
      "description" => att.description,
      "created_by" => att.created_by,
      "created_at" => att.inserted_at && DateTime.to_iso8601(att.inserted_at)
    }
  end

  defp notification_doc(notif) do
    %{
      "id" => notif.id,
      "message" => notif.message,
      "read" => notif.read,
      "created_at" => notif.inserted_at && DateTime.to_iso8601(notif.inserted_at)
    }
  end

  defp room_record(rctx) do
    room = rctx.room

    unread = length(room_unread(rctx))

    members = Enum.filter(Chat.list_members(room.id), &is_nil(&1.left_at))

    %{
      "id" => room.id,
      "slug" => room.slug,
      "name" => room.name,
      "kind" => room.kind,
      "description" => room.description,
      "organization_id" => room.organization_id,
      "project_id" => room.project_id,
      "session_id" => room.session_id,
      "chatroom_url" => NoizuPromptLingua.MCP.Urls.chat_room_url(room),
      "member_count" => length(members),
      "unread" => unread,
      "attachments" => Enum.map(Chat.room_attachments(room.id), &attachment_doc/1),
      "created_at" => room.inserted_at && DateTime.to_iso8601(room.inserted_at),
      "updated_at" => room.updated_at && DateTime.to_iso8601(room.updated_at)
    }
  end

  defp rooms_index(org, ctx) do
    me = persona(ctx)
    oid = org_id(org)

    unread_by_room =
      if is_binary(me) do
        me
        |> Chat.list_notifications()
        |> Enum.filter(&(&1.room.organization_id == oid))
        |> Enum.frequencies_by(& &1.room_id)
      else
        %{}
      end

    rooms =
      if oid && is_binary(me) do
        Chat.list_rooms(organization_id: oid, limit: 10_000)
        |> Enum.filter(&(active_member(&1.id, me) != nil))
        |> Enum.map(fn room ->
          %{
            "slug" => room.slug || room.id,
            "name" => room.name,
            "kind" => room.kind,
            "dm_key" => if(room.kind == "dm", do: pair_key(room.id)),
            "unread" => Map.get(unread_by_room, room.id, 0)
          }
        end)
        |> Enum.sort_by(& &1["slug"])
      else
        []
      end

    %{
      "principal" => me,
      "rooms" => rooms,
      "generated_at" => DateTime.utc_now() |> DateTime.to_iso8601()
    }
  end

  defp reactions_doc(rctx) do
    room_id = rctx.room.id

    message_ids = room_id |> Chat.list_messages(limit: 10_000) |> Enum.map(& &1.id)
    event_ids = room_id |> Chat.list_events(limit: 10_000) |> Enum.map(& &1.id)

    reactions =
      Enum.flat_map([{"chat_message", message_ids}, {"chat_event", event_ids}], fn {etype, ids} ->
        reactions_for(etype, ids)
      end)

    %{
      "reactions" =>
        Enum.map(reactions, fn r ->
          %{
            "entity_type" => r.entity_type,
            "entity_id" => r.entity_id,
            "persona" => r.persona,
            "emoji" => r.emoji,
            "created_at" => r.inserted_at && DateTime.to_iso8601(r.inserted_at)
          }
        end)
    }
  end

  defp reactions_for(_etype, []), do: []

  defp reactions_for(etype, ids) do
    Repo.all(
      Ecto.Query.from(r in Reaction,
        where: r.entity_type == ^etype and r.entity_id in ^ids,
        order_by: [asc: r.inserted_at]
      )
    )
  end

  defp pinned_doc(rctx) do
    msgs = Chat.list_messages(rctx.room.id, limit: 10_000)

    %{
      "pinned" => Enum.filter(msgs, & &1.pinned) |> Enum.map(&message_doc/1),
      "highlighted" => Enum.filter(msgs, & &1.highlighted) |> Enum.map(&message_doc/1)
    }
  end

  defp overview_md do
    """
    # Chat

    Rooms, messages, events, members, and scheduling — the append-log plane
    (MCP-VFS-GROUP-MOUNTS.md §2.9). Messages are per-message create-new files
    under `{room}/messages/` (sorted oldest→newest); replies nest under
    `messages/{msg-id}.replies/`. Membership gates every room content subtree:
    non-members see `:enoent`. Join by creating `members/{me}.json`.

    Scheduled sends live under `scheduled/` until the Wave-4 runner releases
    them (`Chat.release_due_scheduled/0`); ForwardReplies routes through
    `/etc/dev`, not the file plane.
    """
  end

  # ── payload helpers ───────────────────────────────────────────────────────

  # JSON object bodies; malformed JSON → :eio (§2 error mapping for malformed
  # writes). Non-JSON plain text is rejected here.
  defp decode_object(data, errno) when is_binary(data) do
    case Jason.decode(String.trim(data)) do
      {:ok, %{} = body} -> {:ok, body}
      _ -> {:error, errno}
    end
  end

  defp decode_object(_, errno), do: {:error, errno}

  # Create bodies: a JSON object carries structured fields; plain text is the
  # name payload. JSON-LOOKING text that fails to decode is :eio.
  defp create_body(data)

  defp create_body(data) when is_binary(data) do
    trimmed = String.trim(data)

    cond do
      trimmed == "" ->
        {:ok, %{}}

      String.starts_with?(trimmed, "{") ->
        case Jason.decode(trimmed) do
          {:ok, %{} = body} -> {:ok, body}
          _ -> {:error, :eio}
        end

      true ->
        {:ok, %{"name" => trimmed}}
    end
  end

  defp create_body(nil), do: {:ok, %{}}

  # Message/schedule bodies: JSON object with content fields, or plain text =
  # the message content.
  defp message_body(data) when is_binary(data) do
    trimmed = String.trim(data)

    cond do
      trimmed == "" ->
        {:error, :eio}

      String.starts_with?(trimmed, "{") ->
        case Jason.decode(trimmed) do
          {:ok, %{} = body} -> {:ok, body}
          _ -> {:error, :eio}
        end

      true ->
        {:ok, %{"content" => trimmed}}
    end
  end

  defp message_body(_), do: {:error, :eio}

  defp body_content(%{"content" => c}) when is_binary(c), do: String.trim(c)
  defp body_content(_), do: nil

  # Attachment bodies: plain text = url; JSON object = fields.
  defp attachment_body(data) when is_binary(data) do
    trimmed = String.trim(data)

    cond do
      trimmed == "" ->
        {:error, :eio}

      String.starts_with?(trimmed, "{") ->
        case Jason.decode(trimmed) do
          {:ok, %{} = body} -> {:ok, body}
          _ -> {:error, :eio}
        end

      true ->
        {:ok, %{"url" => trimmed}}
    end
  end

  defp attachment_body(_), do: {:error, :eio}

  # scheduled/{send-at}[-{anything}]: the filesystem-safe form
  # (2026-09-05T12-00-01Z) or a raw ISO8601 instant.
  defp parse_send_at(base) do
    case safe_ts_dt(base) || iso_dt(base) do
      {:ok, dt} -> {:ok, dt}
      _ -> {:error, Error.invalid_params("send-at must be a UTC instant (YYYY-MM-DDTHH-MM-SSZ)")}
    end
  end

  defp safe_ts_dt(base) do
    case Regex.run(~r/^(\d{4}-\d{2}-\d{2})T(\d{2})-(\d{2})-(\d{2})Z?(?:-.*)?$/, base) do
      [_, date, h, m, s] ->
        case NaiveDateTime.from_iso8601("#{date}T#{h}:#{m}:#{s}Z") do
          {:ok, naive} -> DateTime.from_naive(naive, "Etc/UTC")
          _ -> nil
        end

      _ ->
        nil
    end
  end

  defp iso_dt(base) do
    case DateTime.from_iso8601(base) do
      {:ok, dt, _} -> {:ok, dt}
      _ -> nil
    end
  end

  # ── node/entry builders ───────────────────────────────────────────────────

  defp dir_node(opts \\ [])

  defp dir_node(opts),
    do: %VFS{type: :dir, mtime: now_ms(), version: version(), writable: opts[:writable] || false}

  defp room_dir_node(rctx), do: dir_node(writable: rctx.member != nil)

  defp file_node(size, opts \\ [])

  defp file_node(size, opts),
    do: %VFS{
      type: :file,
      size: size,
      mtime: now_ms(),
      version: version(),
      writable: opts[:writable] || false
    }

  defp dir_entry(name),
    do: %{name: name, type: :dir, size: 0, mtime: now_ms(), version: version()}

  defp file_entry(name),
    do: %{name: name, type: :file, size: 0, mtime: now_ms(), version: version()}

  defp json_size(doc), do: byte_size(Jason.encode!(doc))

  # Content sizes for the always-present files; listing entries carry size 0
  # (the daemon stats per file — same tradeoff Root makes).
  defp content_size(@overview, _org, _ctx), do: byte_size(overview_md())
  defp content_size(@index_file, org, ctx), do: json_size(rooms_index(org, ctx))
  defp content_size(@record, rctx, _ctx), do: json_size(room_record(rctx))
  defp content_size(@reactions, rctx, _ctx), do: json_size(reactions_doc(rctx))
  defp content_size(@pinned, rctx, _ctx), do: json_size(pinned_doc(rctx))

  # Meta content varies by principal, not by mutation — a flat version keeps
  # the wire contract satisfied; the dispatcher stamps its generation on top.
  defp version, do: 1
  defp now_ms, do: System.os_time(:millisecond)

  defp maybe_put(map, _k, nil), do: map
  defp maybe_put(map, k, v), do: Map.put(map, k, v)

  defp put_if_true(map, _k, false), do: map
  defp put_if_true(map, k, true), do: Map.put(map, k, true)

  defp non_blank(v) when is_binary(v) and v != "", do: v
  defp non_blank(_), do: nil

  # A helper that returned a bare errno atom (from an :ok-aware branch) folds
  # into the {:error, atom} shape; errors pass through.
  defp normalize_eio(atom) when is_atom(atom), do: {:error, atom}
  defp normalize_eio(other), do: other

  # Cursor pagination: offset cursors; foreign/garbage cursors are invalid
  # params (the Root convention, generalized — chat listings do grow).
  defp page(entries, cursor, page_size) do
    case cursor_offset(cursor) do
      {:error, _} = error ->
        error

      {:ok, offset} ->
        slice = Enum.slice(entries, offset, page_size)

        next =
          if offset + length(slice) < length(entries),
            do: Integer.to_string(offset + length(slice)),
            else: nil

        {:ok, slice, next}
    end
  end

  defp cursor_offset(nil), do: {:ok, 0}
  defp cursor_offset(""), do: {:ok, 0}

  defp cursor_offset(cursor) when is_binary(cursor) do
    case Integer.parse(cursor) do
      {n, ""} when n >= 0 -> {:ok, n}
      _ -> {:error, Error.invalid_params("invalid cursor")}
    end
  end

  defp cursor_offset(_), do: {:error, Error.invalid_params("invalid cursor")}
end
