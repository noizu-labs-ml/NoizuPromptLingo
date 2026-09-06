defmodule NoizuPromptLingua.MCP.VFS.Notifications do
  @moduledoc """
  VFS backend for the `notifications` group (MCP-VFS-GROUP-MOUNTS.md §2.10) —
  append-log + subscribe, wired to the `NoizuPromptLingua.Domains.Notifications`
  context. Full absolute paths, self-enforced §1.3 gates (via
  `NoizuPromptLingua.MCP.VFS.Scope`), independently conformance-testable.

      /tobor/{org}/notifications                       → own inbox root (readdir)
      /tobor/{org}/notifications/overview.md           → Overview tool render
      /tobor/{org}/notifications/{recipient}           → one recipient's inbox (readdir)
      /tobor/{org}/notifications/{recipient}/{id}.json → notification doc (flags in-doc)
      /tobor/{org}/notifications/{recipient}/{id}.meta.json → flags sub-doc

  ## Per-principal path enforcement (§2.10)

  The recipient path segment IS the security boundary: every read-side op
  (stat/list/read/write/xattr) resolves the connection principal's handle
  (`handle` claim, else the API-key user's `handle`) and refuses any other
  recipient subtree with `:enoent` — no existence leak, and no
  arbitrary-recipient reads even for Notify-capable principals. Only `create`
  crosses recipients, because sending *to* someone is its purpose.

  ## Tool mapping

    * **Notify** → `create` of `{recipient}/{name}.json` (cross-recipient,
      ToolGuard-gated: the `Notify` tool must be in the principal's effective
      set, on top of the group writable gate). Content is the body (the tool's
      128-char DM cap applies — overflow is `:eio`); the row id is
      server-generated and returned in the node `xattrs`, mirroring the
      per-entry create-new convention (§6 A1).
    * **MarkRead / MarkSeen / Ack** → `write` of the notification's flag
      fields, accepted on both `{id}.json` (in-doc) and `{id}.meta.json`.
      Content is a JSON object `{"read": true}` / `{"seen": true}` /
      `{"acked": true}` (any subset), or the bare word (`read`/`seen`/`acked`).
      Acked rows leave the inbox listing (they are removed from future
      deliveries by design).
    * **Clear** → deliberately unmapped (§3.5: bulk-destructive ops stay
      control-file / `/etc/dev` writes); `remove` of entries is `:enosys` —
      ack is the file-plane dismissal path.
    * **Watch** → native `vfs/subscribe` over `{recipient}` — the mounter's
      `fswatch` headline. Mutation events flow from the `Features.VFS`
      wrappers; MCP-surface deliveries surface within the TTL (§6 L1).
    * **FollowUp / Share** → `/etc/dev` control writes (§2.10), not mapped.

  Listing = the recipient's non-acked rows, `seq` ascending, bounded window
  (500) with lib cursor pagination. Scheduled (`deliver_after`) rows are listed
  — the file plane is the durable record; delivery pacing stays a cursor-pull
  concern (`get/3`). The inbox query reads `Repo` directly: the context exposes
  only the rate-limited cursor pull (`get/3`), whose delivery window must not
  gate a file listing.
  """

  use Noizu.MCP.VFS

  import Ecto.Query

  alias Noizu.MCP.Server.Features.Pagination
  alias NoizuPromptLingua.Domains.Notifications
  alias NoizuPromptLingua.MCP.Resolve
  alias NoizuPromptLingua.MCP.VFS.{Overview, Principal, Scope}
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Notification
  alias NoizuPromptLingua.Schema.Users.User

  @group "notifications"
  @fetch_ceiling 500
  @page_size 100
  @dm_cap 128
  @flags ~w(read seen acked)

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

  # Only the principal's own recipient subtree exists — anyone else's is
  # indistinguishable from absent.
  defp stat_rest(_org, [recipient], gate, ctx) do
    with :ok <- own_subtree(ctx, recipient) do
      {:ok, %{Scope.dir_node() | writable: gate.writable}}
    end
  end

  defp stat_rest(org, [recipient, filename], _gate, ctx) do
    with :ok <- own_subtree(ctx, recipient),
         {:ok, row} <- fetch(org, recipient, filename) do
      {:ok, Scope.file_node(byte_size(doc(row, filename)))}
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

  # The group root lists exactly the principal's own subtree (or nothing).
  defp list_rest(_org, [], _cursor, ctx) do
    entries =
      case my_handle(ctx) do
        nil -> [Scope.file_entry("overview.md")]
        handle -> [Scope.file_entry("overview.md"), Scope.dir_entry(handle)]
      end

    {:ok, entries, nil}
  end

  defp list_rest(_org, ["overview.md"], _cursor, _ctx), do: {:error, :enotdir}

  defp list_rest(org, [recipient], cursor, ctx) do
    with :ok <- own_subtree(ctx, recipient) do
      entries =
        [Scope.file_entry("overview.md") | Enum.map(inbox_rows(org, recipient), &file_entry/1)]

      paginate(entries, cursor)
    end
  end

  defp list_rest(_org, [_recipient, _filename], _cursor, _ctx), do: {:error, :enotdir}
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

  defp read_rest(_org, [recipient], ctx) do
    with :ok <- own_subtree(ctx, recipient) do
      {:error, :eisdir}
    end
  end

  defp read_rest(org, [recipient, filename], ctx) do
    with :ok <- own_subtree(ctx, recipient),
         {:ok, row} <- fetch(org, recipient, filename) do
      {:ok, doc(row, filename), Scope.version()}
    end
  end

  defp read_rest(_org, _rest, _ctx), do: {:error, :enoent}

  # ── create/3 — Notify (cross-recipient, ToolGuard-gated) ──────────────────

  @impl true
  def create(path, data, ctx) when is_binary(data) do
    with {:ok, [_tobor, org, @group, recipient, filename]} <- Scope.split_segments(path),
         {:ok, gate} <- Scope.gate(ctx, org, @group),
         :ok <- Scope.require_writable(gate),
         :ok <- Principal.tool_gate("Notify", %{}, ctx),
         :ok <- notify_name(filename) do
      notify(org, recipient, data, ctx)
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enosys}
    end
  end

  def create(_path, _data, _ctx), do: {:error, :enosys}

  # ── write/3 — MarkRead / MarkSeen / Ack field writes ──────────────────────

  @impl true
  def write(path, data, ctx) when is_binary(data) do
    with {:ok, [_tobor, org, @group, recipient, filename]} <- Scope.split_segments(path),
         {:ok, gate} <- Scope.gate(ctx, org, @group),
         :ok <- Scope.require_writable(gate),
         :ok <- own_subtree(ctx, recipient),
         {:ok, row} <- fetch(org, recipient, filename),
         {:ok, flags} <- parse_flags(data) do
      apply_flags(org, recipient, row, flags)
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enosys}
    end
  end

  def write(_path, _data, _ctx), do: {:error, :enosys}

  # Clear is control-only (§3.5) and entries are not file-removable.
  @impl true
  def remove(_path, _ctx), do: {:error, :enosys}

  @impl true
  def xattr(path, ctx) do
    with {:ok, [_tobor, org, @group, recipient, filename]} <- Scope.split_segments(path),
         :ok <- own_subtree(ctx, recipient),
         {:ok, row} <- fetch(org, recipient, filename) do
      {:ok, %{"kind" => row.kind, "seq" => row.seq, "sender" => row.sender}}
    else
      _ -> {:ok, %{}}
    end
  end

  # ── per-principal recipient enforcement (§2.10) ───────────────────────────

  defp own_subtree(ctx, recipient) do
    if my_handle(ctx) == recipient, do: :ok, else: {:error, :enoent}
  end

  # The principal's notification handle: a `handle` claim when present, else
  # the API-key/OAuth user's `handle` resolved from the subject claim.
  defp my_handle(ctx) do
    claims =
      case ctx do
        %{assigns: %{auth_claims: claims}} when is_map(claims) -> claims
        _ -> %{}
      end

    cond do
      handle = claims["handle"] -> handle
      id = claims["sub"] || claims["user_id"] -> user_handle(id)
      true -> nil
    end
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

  # ── Notify create ─────────────────────────────────────────────────────────

  # Any `{name}.json` is accepted as the create request (per-entry create-new);
  # the server id is authoritative and returned via xattrs.
  defp notify_name(filename) do
    if String.ends_with?(filename, ".json"), do: :ok, else: {:error, :enoent}
  end

  defp notify(org, recipient, body, ctx) do
    if byte_size(body) > @dm_cap do
      {:error, :eio}
    else
      attrs = %{
        organization_id: org_id!(org),
        recipient: recipient,
        sender: my_handle(ctx) || "vfs-mount",
        kind: "dm",
        body: body
      }

      case Notifications.notify(attrs) do
        {:ok, [row | _]} ->
          {:ok, %{Scope.file_node(byte_size(body)) | xattrs: %{"id" => row.id, "seq" => row.seq}}}

        _ ->
          {:error, :eio}
      end
    end
  end

  # ── MarkRead / MarkSeen / Ack writes ──────────────────────────────────────

  # JSON object with any subset of the flag keys, or the bare word.
  defp parse_flags(data) do
    trimmed = String.trim(data)

    cond do
      trimmed in @flags ->
        {:ok, %{trimmed => true}}

      String.starts_with?(trimmed, "{") ->
        case Jason.decode(trimmed) do
          {:ok, map} when is_map(map) ->
            if Map.keys(map) -- @flags == [],
              do: {:ok, Map.take(map, @flags)},
              else: {:error, :enosys}

          _ ->
            {:error, :eio}
        end

      true ->
        {:error, :eio}
    end
  end

  defp apply_flags(org, recipient, row, flags) do
    org_id = org_id!(org)

    results =
      Enum.map(flags, fn
        {"read", true} -> Notifications.mark_read(org_id, recipient, [row.id])
        {"seen", true} -> Notifications.mark_seen(org_id, recipient, [row.id])
        {"acked", true} -> Notifications.ack(org_id, recipient, [row.id])
        _ -> {:ok, 0}
      end)

    if Enum.all?(results, &match?({:ok, _}, &1)),
      do: {:ok, Scope.file_node(0)},
      else: {:error, :eio}
  end

  # ── resolution / inbox ────────────────────────────────────────────────────

  defp overview_tool, do: NoizuPromptLingua.Domains.Notifications.Tools.Overview

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

  # One notification by filename — `{id}.json` (in-doc) or `{id}.meta.json`
  # (flags sub-doc); both resolve the same row.
  defp fetch(org, recipient, filename) do
    with {:ok, org_id} <- org_id(org),
         {:ok, id} <- notification_id(filename),
         {:ok, row} <- inbox_row(org_id, recipient, id) do
      {:ok, row}
    end
  end

  defp notification_id(filename) do
    base =
      cond do
        String.ends_with?(filename, ".meta.json") -> String.trim_trailing(filename, ".meta.json")
        String.ends_with?(filename, ".json") -> String.trim_trailing(filename, ".json")
        true -> ""
      end

    case NoizuPromptLingua.UUID.cast(base) do
      {:ok, uuid} -> {:ok, uuid}
      :error -> {:error, :enoent}
    end
  end

  defp inbox_row(org_id, recipient, id) do
    Repo.one(
      from n in Notification,
        where: n.organization_id == ^org_id and n.recipient == ^recipient and n.id == ^id
    )
    |> case do
      nil -> {:error, :enoent}
      row -> {:ok, row}
    end
  end

  # The inbox: every non-acked row for the recipient (scheduled rows included —
  # the file plane is the durable record, delivery pacing stays in get/3).
  defp inbox_rows(org, recipient) do
    with {:ok, org_id} <- org_id(org) do
      from(n in Notification,
        where: n.organization_id == ^org_id and n.recipient == ^recipient and n.acked == false,
        order_by: [asc: n.seq],
        limit: @fetch_ceiling
      )
      |> Repo.all()
    else
      _ -> []
    end
  end

  # ── payloads ──────────────────────────────────────────────────────────────

  # `{id}.meta.json` renders the flags sub-doc; `{id}.json` the full record.
  defp doc(row, filename) do
    payload =
      if String.ends_with?(filename, ".meta.json") do
        %{
          "read" => row.read,
          "read_at" => iso(row.read_at),
          "seen" => row.seen,
          "seen_at" => iso(row.seen_at),
          "acked" => row.acked,
          "acked_at" => iso(row.acked_at)
        }
      else
        %{
          "id" => row.id,
          "seq" => row.seq,
          "kind" => row.kind,
          "sender" => row.sender,
          "recipient" => row.recipient,
          "subject_type" => row.subject_type,
          "subject_id" => row.subject_id,
          "body" => row.body,
          "payload" => row.payload,
          "dedup_key" => row.dedup_key,
          "deliver_after" => iso(row.deliver_after),
          "read" => row.read,
          "seen" => row.seen,
          "acked" => row.acked,
          "created_at" => iso(row.inserted_at)
        }
      end

    Jason.encode!(payload)
  end

  defp file_entry(row), do: Scope.file_entry("#{row.id}.json")

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
