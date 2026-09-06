defmodule NoizuPromptLingua.MCP.VFS.PubSub do
  @moduledoc """
  VFS backend for the `pubsub` group (MCP-VFS-GROUP-MOUNTS.md §2.11) —
  stream/subscribe, wired to the `NoizuPromptLingua.Domains.PubSub` context.
  Full absolute paths, self-enforced §1.3 gates (via
  `NoizuPromptLingua.MCP.VFS.Scope`), independently conformance-testable.

      /tobor/{org}/pubsub                          → channel listing (FetchAll)
      /tobor/{org}/pubsub/overview.md              → Overview tool render
      /tobor/{org}/pubsub/{channel}                → one channel
      /tobor/{org}/pubsub/{channel}/pointer.json   → the principal's follow pointer
      /tobor/{org}/pubsub/{channel}/messages/      → the message log (readdir)
      /tobor/{org}/pubsub/{channel}/messages/{ts}-{seq}.json → one message

  ## Tool mapping

    * **PubSub.Tools.Publish** → `create` of `messages/{name}.json` (sender =
      the principal's handle, body = content; ToolGuard-gated on
      `PubSub.Publish` on top of the group writable gate). The server-assigned
      `seq` comes back in the node `xattrs` — the local draft's name is
      advisory, per the per-entry create-new convention (§6 A1 / §1.1
      filesystem-safe stamps).
    * **FetchChannel** → readdir `messages/`; **FetchAll** → readdir the group
      root (the channel listing). Both are bounded windows (500, cursor
      paginated); full history stays server-side.
    * **PubSub.Tools.Ack** → `write` of `pointer.json` (any content): advances
      the follower's `last_acked_seq` to the channel head and, when caught up,
      clears the `pubsub_available` notification (domain `ack/3`).
    * **Follow / Unfollow** → per design these are *native*
      `vfs/subscribe`/`unsubscribe` over `{channel}`. The domain follow row is
      additionally mapped file-naturally so ack works from a mount:
      `create pointer.json` = follow (pointer starts at 0 — everything is
      unread), `remove pointer.json` = unfollow. Documented convention; the
      domain rows are per-persona, so `pointer.json` content is
      **per-principal** (safe only because the app runs with the VFS read
      cache disabled — design §6 P1).
    * Channel/message `remove` is `:enosys` — the ring, not the consumer,
      retires messages; channels have no delete tool.

  ## Ring-buffer retention (§2.11)

  After each file-plane publish the server prunes the channel to the newest
  `N` messages (`Application.get_env(:noizu_prompt_lingua,
  :vfs_pubsub_ring_size, 100)`) and emits one `:remove` event per pruned file
  through `Noizu.MCP.Server.VFSPubSub` — mirrors delete cleanly. Out-of-band
  publishes (MCP surface) do not prune; they surface within the TTL (§6 L1).
  """

  use Noizu.MCP.VFS

  import Ecto.Query

  alias Noizu.MCP.Server.Features.Pagination
  alias Noizu.MCP.Server.VFSPubSub
  alias NoizuPromptLingua.Domains.PubSub
  alias NoizuPromptLingua.MCP.Resolve
  alias NoizuPromptLingua.MCP.VFS.{Overview, Principal, Scope}
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.PubSubFollow
  alias NoizuPromptLingua.Schema.PubSubMessage
  alias NoizuPromptLingua.Schema.Users.User

  @group "pubsub"
  @fetch_ceiling 500
  @page_size 100
  @ring_default 100

  # ── stat/2 ────────────────────────────────────────────────────────────────

  @impl true
  def stat(path, ctx) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, gate} <- Scope.gate(ctx, org, @group) do
      stat_rest(org, rest, gate, ctx)
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enoent}
    end
  end

  defp stat_rest(_org, [], gate, _ctx), do: {:ok, %{Scope.dir_node() | writable: gate.writable}}

  defp stat_rest(_org, ["overview.md"], _gate, _ctx),
    do: {:ok, Scope.file_node(byte_size(Overview.md(overview_tool(), @group)))}

  defp stat_rest(org, [channel], gate, _ctx) do
    with {:ok, _channel} <- resolve_channel(org, channel) do
      {:ok, %{Scope.dir_node() | writable: gate.writable}}
    end
  end

  defp stat_rest(org, [channel, "pointer.json"], _gate, ctx) do
    with {:ok, channel} <- resolve_channel(org, channel),
         {:ok, _follow} <- fetch_follow(channel, ctx) do
      {:ok, Scope.file_node(byte_size(pointer_doc(channel, ctx)))}
    end
  end

  defp stat_rest(org, [channel, "messages"], gate, _ctx) do
    with {:ok, _channel} <- resolve_channel(org, channel) do
      {:ok, %{Scope.dir_node() | writable: gate.writable}}
    end
  end

  defp stat_rest(org, [channel, "messages", filename], _gate, _ctx) do
    with {:ok, channel} <- resolve_channel(org, channel),
         {:ok, message} <- fetch_message(channel, filename) do
      {:ok, Scope.file_node(byte_size(message_doc(message)))}
    end
  end

  defp stat_rest(_org, _rest, _gate, _ctx), do: {:error, :enoent}

  # ── list/3 ────────────────────────────────────────────────────────────────

  @impl true
  def list(path, cursor, ctx) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, _gate} <- Scope.gate(ctx, org, @group) do
      list_rest(org, rest, cursor, ctx)
    end
  end

  defp list_rest(org, [], cursor, _ctx) do
    channels =
      org
      |> org_id!()
      |> PubSub.list_channels()
      |> Enum.map(&Scope.dir_entry(&1.slug))

    paginate([Scope.file_entry("overview.md") | channels], cursor)
  end

  defp list_rest(_org, ["overview.md"], _cursor, _ctx), do: {:error, :enotdir}

  defp list_rest(org, [channel], cursor, _ctx) do
    with {:ok, _channel} <- resolve_channel(org, channel) do
      paginate([Scope.file_entry("pointer.json"), Scope.dir_entry("messages")], cursor)
    end
  end

  defp list_rest(org, [channel, "messages"], cursor, _ctx) do
    with {:ok, channel} <- resolve_channel(org, channel) do
      entries =
        channel.id
        |> PubSub.fetch_channel(limit: @fetch_ceiling)
        |> Enum.map(&Scope.file_entry(message_name(&1)))

      paginate(entries, cursor)
    end
  end

  defp list_rest(_org, [_channel, _deeper], _cursor, _ctx), do: {:error, :enotdir}
  defp list_rest(_org, _rest, _cursor, _ctx), do: {:error, :enoent}

  # ── read/2 ────────────────────────────────────────────────────────────────

  @impl true
  def read(path, ctx) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, _gate} <- Scope.gate(ctx, org, @group) do
      read_rest(org, rest, ctx)
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enoent}
    end
  end

  defp read_rest(_org, [], _ctx), do: {:error, :eisdir}

  defp read_rest(_org, ["overview.md"], _ctx) do
    {:ok, Overview.md(overview_tool(), @group), Scope.version()}
  end

  defp read_rest(org, [channel], _ctx) do
    with {:ok, _channel} <- resolve_channel(org, channel) do
      {:error, :eisdir}
    end
  end

  # Per-principal: the caller's own follow state (§2.11 pointer convention).
  defp read_rest(org, [channel, "pointer.json"], ctx) do
    with {:ok, channel} <- resolve_channel(org, channel),
         {:ok, _follow} <- fetch_follow(channel, ctx) do
      {:ok, pointer_doc(channel, ctx), Scope.version()}
    end
  end

  defp read_rest(org, [channel, "messages"], _ctx) do
    with {:ok, _channel} <- resolve_channel(org, channel) do
      {:error, :eisdir}
    end
  end

  defp read_rest(org, [channel, "messages", filename], _ctx) do
    with {:ok, channel} <- resolve_channel(org, channel),
         {:ok, message} <- fetch_message(channel, filename) do
      {:ok, message_doc(message), Scope.version()}
    end
  end

  defp read_rest(_org, _rest, _ctx), do: {:error, :enoent}

  # ── create/3 — Publish (messages/) + Follow (pointer.json) ────────────────

  @impl true
  def create(path, data, ctx) when is_binary(data) do
    with {:ok, [_tobor, org, @group, channel | rest]} <- Scope.split_segments(path),
         {:ok, gate} <- Scope.gate(ctx, org, @group),
         :ok <- Scope.require_writable(gate) do
      create_rest(org, channel, rest, data, ctx)
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enosys}
    end
  end

  def create(_path, _data, _ctx), do: {:error, :enosys}

  # PubSub.Tools.Publish: any `{name}.json` under messages/ is the request;
  # the server `seq` is authoritative (xattrs) and the ring is pruned after.
  defp create_rest(org, channel, ["messages", _filename], data, ctx) do
    with {:ok, channel} <- resolve_channel(org, channel),
         :ok <- Principal.tool_gate("PubSub.Publish", %{}, ctx) do
      publish(org, channel, data, ctx)
    end
  end

  # Follow: pointer.json is the canonical pointer-file creation (§6 R1); the
  # follow row starts at 0, so everything currently in the channel is unread.
  defp create_rest(org, channel, ["pointer.json"], _data, ctx) do
    with {:ok, channel} <- resolve_channel(org, channel),
         {:ok, persona} <- require_handle(ctx),
         nil <- fetch_follow_row(channel, persona),
         {:ok, follow} <- PubSub.follow(channel.id, persona) do
      {:ok,
       %{
         Scope.file_node(byte_size(pointer_state(channel, follow)))
         | xattrs: %{"persona" => persona}
       }}
    else
      %PubSubFollow{} -> {:error, :eexist}
      {:error, _} = error -> error
      _ -> {:error, :eio}
    end
  end

  defp create_rest(_org, _channel, _rest, _data, _ctx), do: {:error, :enosys}

  # ── write/3 — Ack (pointer advance) ───────────────────────────────────────

  @impl true
  def write(path, _data, ctx) do
    with {:ok, [_tobor, org, @group, channel, "pointer.json"]} <- Scope.split_segments(path),
         {:ok, gate} <- Scope.gate(ctx, org, @group),
         :ok <- Scope.require_writable(gate),
         {:ok, channel} <- resolve_channel(org, channel),
         {:ok, persona} <- require_handle(ctx) do
      # PubSub.Tools.Ack: advance the caller's pointer to the channel head.
      case PubSub.ack(org_id!(org), channel.id, persona) do
        {:ok, %{last_acked_seq: seq}} ->
          {:ok, Scope.file_node(byte_size(to_string(seq)))}

        {:error, :not_following} ->
          {:error, :enoent}
      end
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enosys}
    end
  end

  # ── remove/2 — Unfollow (pointer file); everything else stays ─────────────

  @impl true
  def remove(path, ctx) do
    with {:ok, [_tobor, org, @group, channel, "pointer.json"]} <- Scope.split_segments(path),
         {:ok, gate} <- Scope.gate(ctx, org, @group),
         :ok <- Scope.require_writable(gate),
         {:ok, channel} <- resolve_channel(org, channel),
         {:ok, persona} <- require_handle(ctx),
         %PubSubFollow{} <- fetch_follow_row(channel, persona),
         {:ok, _} <- PubSub.unfollow(channel.id, persona) do
      :ok
    else
      nil -> {:error, :enoent}
      {:error, _} = error -> error
      _fallback -> {:error, :enosys}
    end
  end

  # ── publish + ring prune (§2.11) ──────────────────────────────────────────

  defp publish(org, channel, body, ctx) do
    with {:ok, persona} <- require_handle(ctx) do
      attrs = %{channel_id: channel.id, sender: persona, body: body}

      case PubSub.publish(attrs) do
        {:ok, message} ->
          ring = prune!(org, channel, ctx)

          {:ok,
           %{Scope.file_node(byte_size(body)) | xattrs: %{"seq" => message.seq, "pruned" => ring}}}

        {:error, _changeset} ->
          {:error, :eio}
      end
    end
  end

  # Keep the newest N messages; delete the rest and announce each removal so
  # mirrors delete cleanly (design §2.11). Best-effort: a prune failure never
  # fails the publish that triggered it.
  defp prune!(org, channel, ctx) do
    keep = ring_size()

    threshold =
      from(m in PubSubMessage,
        where: m.channel_id == ^channel.id,
        order_by: [desc: m.seq],
        offset: ^(keep - 1),
        limit: 1,
        select: m.seq
      )
      |> Repo.one()

    if threshold do
      stale =
        from(m in PubSubMessage,
          where: m.channel_id == ^channel.id and m.seq < ^threshold,
          select: {m.id, m.seq, m.inserted_at}
        )
        |> Repo.all()

      if stale != [] do
        stale
        |> Enum.map(&elem(&1, 0))
        |> then(&from(m in PubSubMessage, where: m.id in ^&1))
        |> Repo.delete_all()

        Enum.each(stale, fn {_id, seq, inserted_at} ->
          name = message_name(%{seq: seq, inserted_at: inserted_at})
          path = "/tobor/#{org}/pubsub/#{channel.slug}/messages/#{name}"
          VFSPubSub.publish(__MODULE__, :remove, path, Scope.version(), ctx)
        end)
      end

      length(stale)
    else
      0
    end
  rescue
    _ -> 0
  end

  defp ring_size,
    do: Application.get_env(:noizu_prompt_lingua, :vfs_pubsub_ring_size, @ring_default)

  # ── resolution ────────────────────────────────────────────────────────────

  defp overview_tool, do: NoizuPromptLingua.Domains.PubSub.Tools.Overview

  defp org_id(org) do
    case Resolve.organization_id(org) do
      nil -> {:error, :enoent}
      id -> {:ok, id}
    end
  end

  defp org_id!(org) do
    {:ok, id} = org_id(org)
    id
  end

  defp resolve_channel(org, slug) do
    case PubSub.get_channel(org_id!(org), slug) do
      nil -> {:error, :enoent}
      channel -> {:ok, channel}
    end
  end

  # The caller's notification handle ("persona" in the follow rows): `handle`
  # claim, else the API-key/OAuth user's `handle`.
  defp require_handle(ctx) do
    claims =
      case ctx do
        %{assigns: %{auth_claims: claims}} when is_map(claims) -> claims
        _ -> %{}
      end

    handle =
      cond do
        h = claims["handle"] -> h
        id = claims["sub"] || claims["user_id"] -> user_handle(id)
        true -> nil
      end

    if handle, do: {:ok, handle}, else: {:error, :enoent}
  end

  defp user_handle(id) do
    user =
      case NoizuPromptLingua.UUID.cast(id) do
        {:ok, uuid} -> Repo.get(User, uuid)
        :error -> Repo.get_by(User, handle: to_string(id))
      end

    user && user.handle
  rescue
    _ -> nil
  end

  defp fetch_follow_row(channel, persona) when is_binary(persona) do
    Repo.get_by(PubSubFollow, channel_id: channel.id, persona: persona)
  end

  defp fetch_follow_row(_channel, _), do: nil

  defp fetch_follow(channel, ctx) do
    with {:ok, persona} <- require_handle(ctx),
         %PubSubFollow{} = follow <- fetch_follow_row(channel, persona) do
      {:ok, follow}
    else
      _ -> {:error, :enoent}
    end
  end

  defp fetch_message(channel, filename) do
    with {:ok, seq} <- parse_seq(filename),
         %PubSubMessage{} = message <- window_message(channel, seq) do
      {:ok, message}
    else
      _ -> {:error, :enoent}
    end
  end

  # `{ts}-{seq}.json` → the trailing seq. One bounded-window lookup; files
  # aged out of the window are :enoent (full history stays server-side).
  defp parse_seq(filename) do
    case Regex.run(~r/-(\d+)\.json$/, filename) do
      [_, digits] ->
        case Integer.parse(digits) do
          {seq, ""} -> {:ok, seq}
          _ -> {:error, :enoent}
        end

      _ ->
        {:error, :enoent}
    end
  end

  defp window_message(channel, seq) do
    channel.id
    |> PubSub.fetch_channel(limit: @fetch_ceiling)
    |> Enum.find(&(&1.seq == seq))
  end

  # ── payloads ──────────────────────────────────────────────────────────────

  # Filesystem-safe stamp (§1.1 — no colons): 2026-09-05T12-00-01Z-{seq}.json
  defp message_name(%{seq: seq, inserted_at: %DateTime{} = at}) do
    stamp = at |> DateTime.to_iso8601() |> String.replace(":", "-")
    "#{stamp}-#{seq}.json"
  end

  defp message_name(%{seq: seq}), do: "unknown-#{seq}.json"

  defp message_doc(m) do
    %{
      "seq" => m.seq,
      "channel_id" => m.channel_id,
      "sender" => m.sender,
      "body" => m.body,
      "created_at" => iso(m.inserted_at)
    }
    |> Jason.encode!()
  end

  # The caller's pointer state: ack/view cursors against the channel head.
  # `unread` is a row count — the seq is a shared DB sequence, so a numeric
  # head-minus-acked difference would count other channels' traffic.
  defp pointer_doc(channel, ctx) do
    with {:ok, persona} <- require_handle(ctx),
         follow when follow != nil <- fetch_follow_row(channel, persona) do
      %{
        "channel" => channel.slug,
        "persona" => persona,
        "last_acked_seq" => follow.last_acked_seq,
        "last_viewed_seq" => follow.last_viewed_seq,
        "head_seq" => channel_head(channel),
        "unread" => unread_count(channel, follow.last_acked_seq)
      }
      |> Jason.encode!()
    else
      _ -> Jason.encode!(%{})
    end
  end

  defp pointer_state(channel, follow) do
    Jason.encode!(%{
      "channel" => channel.slug,
      "last_acked_seq" => follow.last_acked_seq,
      "head_seq" => channel_head(channel),
      "unread" => unread_count(channel, follow.last_acked_seq)
    })
  end

  defp unread_count(channel, last_acked_seq) do
    from(m in PubSubMessage,
      where: m.channel_id == ^channel.id and m.seq > ^last_acked_seq,
      select: count(m.id)
    )
    |> Repo.one()
    |> Kernel.||(0)
  end

  defp channel_head(channel) do
    from(m in PubSubMessage, where: m.channel_id == ^channel.id, select: max(m.seq))
    |> Repo.one()
    |> Kernel.||(0)
  end

  defp paginate(items, cursor) do
    cursor = if cursor == "", do: nil, else: cursor

    case Pagination.paginate(items, cursor, @page_size) do
      {:ok, page, next} -> {:ok, page, next}
      {:error, _} -> {:error, Noizu.MCP.Error.invalid_params("invalid cursor")}
    end
  end

  defp iso(nil), do: nil
  defp iso(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  defp iso(dt), do: to_string(dt)
end
