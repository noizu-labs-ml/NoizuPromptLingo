defmodule NoizuPromptLingua.MCP.VFS.Sessions do
  @moduledoc """
  `MCP.Sessions` entity-dir + activity log (MCP-VFS-GROUP-MOUNTS.md §2.7).

  Owns the `/tobor/{org}/sessions` subtree (Root dispatches mapped groups
  wholly):

      /tobor/{org}/sessions                      readdir = Session.List
      /tobor/{org}/sessions/overview.md          group overview
      /tobor/{org}/sessions/{session-id}         session dir (server-assigned UUID)
      …/{session-id}/record.json                 read = Session.Get · write = Session.Update
                                                 create = Session.Create
      …/{session-id}/manifest.json               read = Sessions.Tools.Manifest (this principal)
      …/{session-id}/log/                        append-only activity log
      …/{session-id}/log/{ts}-{event}.json       derived, immutable entries
      …/{session-id}/actions/archive             control write = Session.Archive (§3.5)

  Sessions live in the LOCAL app DB; a TRP-only org has no session subtree
  (`:enoent`) because there is no local row to hang one on.

  ## Log

  No append primitive exists (§0.1) and sessions carry no event table, so the
  log is the append-only projection of the row's own lifecycle: one immutable
  `{ts}-{event}.json` entry per state change the row records (created /
  updated / archived). Entries are created-as-new-files by convention (§0.3),
  never rewritten — a write to an existing entry is `:eacces`. Caller-authored
  log entries need a backing store and are wave-3 material (create →
  `:enosys`).

  ## Control writes

  Archive is a state transition, never a content edit (§3.5): `status:
  "archived"` via `record.json` is refused `:eacces`; the transition rides the
  `actions/archive` control node (the in-tree `actions/` convention §2.18
  uses) or the `/etc/dev` plane.
  """

  use Noizu.MCP.VFS

  alias Noizu.MCP.VFS
  alias NoizuPromptLingua.MCP.SessionManifest
  alias NoizuPromptLingua.MCP.Resolve
  alias NoizuPromptLingua.MCP.VFS.Principal
  alias NoizuPromptLingua.Organizations
  alias NoizuPromptLingua.Sessions, as: SessionsCtx

  @orgs_root "tobor"
  @group_id "sessions"
  @group_dir "sessions"
  @record "record.json"
  @manifest "manifest.json"
  @log "log"
  @actions "actions"
  @archive "archive"

  @record_write_fields ["title", "description", "model", "runner"]
  @statuses ["active", "inactive", "completed"]

  # Readdir windows: listings page in-memory over the org's id list; the
  # window size is tunable (tests, oversized orgs).
  @default_window 200
  @listing_cap 10_000

  # ── stat/2 ────────────────────────────────────────────────────────────────

  @impl true
  def stat(path, ctx) do
    with {:ok, segments} <- split_segments(path) do
      case segments do
        [@orgs_root, org, @group_dir] ->
          require_org(ctx, org, fn -> tap_writable({:ok, dir_node()}, ctx) end)

        [@orgs_root, org, @group_dir, "overview.md"] ->
          require_org(ctx, org, fn ->
            {:ok, %{file_node(byte_size(overview_md())) | writable: gate_writable?(ctx)}}
          end)

        [@orgs_root, org, @group_dir, id] ->
          with_session(ctx, org, id, fn _session -> tap_writable({:ok, dir_node()}, ctx) end)

        [@orgs_root, org, @group_dir, id, @record] ->
          with_session(ctx, org, id, fn session ->
            tap_writable({:ok, file_node(doc_size(session))}, ctx)
          end)

        [@orgs_root, org, @group_dir, id, @manifest] ->
          with_session(ctx, org, id, fn _session ->
            {:ok, file_node(byte_size(Jason.encode!(SessionManifest.generate(ctx))))}
          end)

        [@orgs_root, org, @group_dir, id, @log] ->
          with_session(ctx, org, id, fn session -> {:ok, dir_node(log_mtime(session))} end)

        [@orgs_root, org, @group_dir, id, @log, entry] ->
          with_session(ctx, org, id, fn session ->
            with {:ok, _event} <- find_log_entry(session, entry), do: {:ok, file_node(0)}
          end)

        [@orgs_root, org, @group_dir, id, @actions, @archive] ->
          with_session(ctx, org, id, fn _session -> tap_writable({:ok, control_node()}, ctx) end)

        _ ->
          {:error, :enoent}
      end
    end
  end

  # ── list/3 ────────────────────────────────────────────────────────────────

  @impl true
  def list(path, cursor, ctx) do
    with {:ok, segments} <- split_segments(path),
         {:ok, entries} <- list_segments(segments, ctx) do
      paginate(entries, cursor)
    end
  end

  defp list_segments([@orgs_root, org, @group_dir], ctx) do
    require_org(ctx, org, fn ->
      with {:ok, org_id} <- resolve_org_id(org) do
        SessionsCtx.list_for_org(org_id, limit: @listing_cap)
        |> Enum.map(& &1.id)
        |> Enum.sort()
        |> Enum.map(&dir_entry/1)
        |> then(&{:ok, &1})
      end
    end)
  end

  defp list_segments([@orgs_root, org, @group_dir, "overview.md"], ctx) do
    require_org(ctx, org, fn -> {:ok, [file_entry("overview.md")]} end)
  end

  defp list_segments([@orgs_root, org, @group_dir, id], ctx) do
    with_session(ctx, org, id, fn _session ->
      {:ok,
       [
         file_entry(@record),
         file_entry(@manifest),
         dir_entry(@log),
         dir_entry(@actions)
       ]}
    end)
  end

  defp list_segments([@orgs_root, org, @group_dir, id, @log], ctx) do
    with_session(ctx, org, id, fn session ->
      entries =
        session
        |> log_entries()
        |> Enum.map(fn {dt, event} -> file_entry(log_name(dt, event)) end)
        |> Enum.sort_by(& &1.name)

      {:ok, entries}
    end)
  end

  defp list_segments([@orgs_root, org, @group_dir, id, @actions], ctx) do
    with_session(ctx, org, id, fn _session -> {:ok, [file_entry(@archive)]} end)
  end

  defp list_segments(_, _), do: {:error, :enoent}

  # ── read/2 ────────────────────────────────────────────────────────────────

  @impl true
  def read(path, ctx) do
    with {:ok, segments} <- split_segments(path) do
      case segments do
        [@orgs_root, org, @group_dir, "overview.md"] ->
          require_org(ctx, org, fn -> {:ok, overview_md(), version()} end)

        [@orgs_root, org, @group_dir, id, @record] ->
          with_session(ctx, org, id, fn session ->
            {:ok, Jason.encode!(session_doc(session)), version()}
          end)

        [@orgs_root, org, @group_dir, id, @manifest] ->
          with_session(ctx, org, id, fn _session ->
            {:ok, Jason.encode!(SessionManifest.generate(ctx)), version()}
          end)

        [@orgs_root, org, @group_dir, id, @log, entry] ->
          with_session(ctx, org, id, fn session ->
            with {:ok, event} <- find_log_entry(session, entry) do
              {:ok, Jason.encode!(log_doc(session, event)), version()}
            end
          end)

        [@orgs_root, org, @group_dir, id, @actions, @archive] ->
          with_session(ctx, org, id, fn _session ->
            {:ok, Jason.encode!(%{"action" => "archive", "session" => id}), version()}
          end)

        [@orgs_root, _org, @group_dir] ->
          {:error, :eisdir}

        _ ->
          {:error, :enoent}
      end
    end
  end

  # ── write/3 ───────────────────────────────────────────────────────────────

  @impl true
  def write(path, content, ctx) do
    with {:ok, segments} <- split_segments(path) do
      case segments do
        [@orgs_root, org, @group_dir, id, @record] -> write_record(org, id, content, ctx)
        [@orgs_root, org, @group_dir, id, @actions, @archive] -> write_archive(org, id, ctx)
        # Log entries are immutable once created (append-only §2.7).
        [@orgs_root, _org, @group_dir, _id, @log, _entry] -> {:error, :eacces}
        _ -> {:error, :enoent}
      end
    end
  end

  # Session.Update — canonical doc merge (§3.4). Archive through the content
  # plane is refused loudly: the state transition rides actions/archive (§3.5).
  defp write_record(org, id, content, ctx) do
    with :ok <- require_writable(ctx, org),
         {:ok, session} <- fetch_session(ctx, org, id),
         {:ok, doc} <- decode(content),
         :ok <- refuse_archive(doc) do
      attrs =
        doc
        |> Map.take(@record_write_fields ++ ["status"])
        |> Map.reject(fn {_k, v} -> not writable_value?(v) end)
        |> atomize_known()

      case SessionsCtx.update_session(session.id, attrs) do
        {:ok, updated} -> {:ok, file_node(doc_size(updated))}
        {:error, :not_found} -> {:error, :enoent}
        {:error, _changeset} -> {:error, :eio}
      end
    else
      {:error, _} = err -> err
    end
  end

  defp refuse_archive(%{"status" => "archived"}), do: {:error, :eacces}
  defp refuse_archive(%{"status" => status}) when status in @statuses, do: :ok
  defp refuse_archive(%{"status" => _}), do: {:error, :eio}
  defp refuse_archive(_), do: :ok

  # Session.Archive — the control write (§2.7/§3.5).
  defp write_archive(org, id, ctx) do
    with :ok <- require_writable(ctx, org),
         {:ok, session} <- fetch_session(ctx, org, id) do
      case SessionsCtx.archive(session.id) do
        {:ok, _} -> {:ok, control_node()}
        {:error, :not_found} -> {:error, :enoent}
        {:error, _} -> {:error, :eio}
      end
    else
      {:error, _} = err -> err
    end
  end

  # ── create/3 — Session.Create ─────────────────────────────────────────────

  @impl true
  def create(_path, :dir, _ctx), do: {:error, :enosys}

  def create(path, content, ctx) do
    with {:ok, segments} <- split_segments(path) do
      case segments do
        [@orgs_root, org, @group_dir, _token, @record] -> create_session(org, content, ctx)
        # Caller-authored log entries have no backing store yet (moduledoc).
        [@orgs_root, _org, @group_dir, _id, @log, _entry] -> {:error, :enosys}
        _ -> {:error, :enoent}
      end
    end
  end

  defp create_session(org, content, ctx) do
    with :ok <- require_writable(ctx, org),
         {:ok, org_id} <- resolve_org_id(org),
         {:ok, doc} <- decode(content),
         {:ok, title} <- require_field(doc, "title") do
      attrs = %{
        organization_id: org_id,
        title: title,
        description: valid_string(doc["description"]),
        status: status_from(doc),
        model: valid_string(doc["model"]),
        runner: valid_string(doc["runner"]),
        project_id: uuid_or_nil(doc["project_id"])
      }

      case SessionsCtx.create(attrs, Resolve.current_user_id(ctx)) do
        {:ok, session} ->
          xattrs = %{
            "id" => session.id,
            "canonical_path" => "/#{@orgs_root}/#{org}/#{@group_dir}/#{session.id}/#{@record}"
          }

          {:ok, %VFS{file_node(doc_size(session)) | xattrs: xattrs}}

        {:error, %Ecto.Changeset{}} ->
          {:error, :eio}

        {:error, _} ->
          {:error, :eio}
      end
    else
      {:error, _} = err -> err
    end
  end

  # ── payload ───────────────────────────────────────────────────────────────

  defp session_doc(session) do
    %{
      "id" => session.id,
      "organization_id" => session.organization_id,
      "project_id" => session.project_id,
      "title" => session.title,
      "description" => session.description,
      "status" => session.status,
      "model" => session.model,
      "runner" => session.runner,
      "created_by" => session.created_by,
      "created_at" => iso(session.inserted_at),
      "updated_at" => iso(session.updated_at),
      "archived_at" => iso(session.archived_at)
    }
  end

  defp doc_size(session), do: byte_size(Jason.encode!(session_doc(session)))

  # Derived lifecycle entries — the append-only activity log (§2.7).
  defp log_entries(session) do
    [{session.inserted_at, "created"}]
    |> maybe_add(session.updated_at, session.inserted_at, "updated")
    |> maybe_add(session.archived_at, nil, "archived")
  end

  defp maybe_add(entries, ts, _guard, _event) when is_nil(ts), do: entries

  defp maybe_add(entries, ts, guard, event) do
    cond do
      is_nil(guard) -> entries ++ [{ts, event}]
      DateTime.compare(ts, guard) == :gt -> entries ++ [{ts, event}]
      true -> entries
    end
  end

  defp find_log_entry(session, name) do
    case Enum.find(log_entries(session), fn {dt, event} -> log_name(dt, event) == name end) do
      nil -> {:error, :enoent}
      {_dt, event} -> {:ok, event}
    end
  end

  defp log_name(dt, event), do: "#{format_ts(dt)}-#{event}.json"

  defp log_doc(session, event) do
    %{
      "event" => event,
      "session" => session.id,
      "status" => session.status,
      "archived_at" => iso(session.archived_at)
    }
  end

  defp log_mtime(session) do
    session
    |> log_entries()
    |> Enum.map(fn {dt, _} -> DateTime.to_unix(dt, :millisecond) end)
    |> Enum.max(fn -> 0 end)
  end

  defp format_ts(dt) do
    dt
    |> DateTime.truncate(:second)
    |> Calendar.strftime("%Y%m%dT%H%M%S")
  end

  # ── pagination (§3.2 — readdir cursors) ───────────────────────────────────

  defp paginate(entries, cursor) do
    case decode_cursor(cursor) do
      {:error, _} = err ->
        err

      offset ->
        window = list_window()
        page = Enum.slice(entries, offset, window)
        next = if offset + window < length(entries), do: encode_cursor(offset + window)
        {:ok, page, next}
    end
  end

  defp decode_cursor(c) when c in [nil, ""], do: 0

  defp decode_cursor(c) when is_binary(c) do
    with {:ok, json} <- Base.url_decode64(c, padding: false),
         {:ok, %{"o" => o}} <- Jason.decode(json),
         true <- is_integer(o) and o >= 0 do
      o
    else
      _ -> {:error, Noizu.MCP.Error.invalid_params("invalid cursor")}
    end
  end

  defp decode_cursor(_), do: {:error, Noizu.MCP.Error.invalid_params("invalid cursor")}

  defp encode_cursor(offset),
    do: Jason.encode!(%{"o" => offset}) |> Base.url_encode64(padding: false)

  defp list_window do
    Application.get_env(:noizu_prompt_lingua, :vfs, [])
    |> Keyword.get(:list_window, @default_window)
  end

  # ── gates + lookups ───────────────────────────────────────────────────────

  defp require_org(ctx, org, fun) do
    if Principal.org_visible?(ctx, org) and match?(:ok, Principal.group_gate(ctx, @group_id)) do
      fun.()
    else
      {:error, :enoent}
    end
  end

  defp require_writable(ctx, org) do
    cond do
      not (Principal.org_visible?(ctx, org) and match?(:ok, Principal.group_gate(ctx, @group_id))) ->
        {:error, :enoent}

      not gate_writable?(ctx) ->
        {:error, :eacces}

      true ->
        :ok
    end
  end

  defp gate_writable?(ctx) do
    case Principal.groups(ctx)[@group_id] do
      %{writable: true} -> true
      _ -> false
    end
  end

  defp tap_writable({:ok, node}, ctx), do: {:ok, %{node | writable: gate_writable?(ctx)}}

  # Local org row or nothing — sessions hang off the app-DB org id.
  defp resolve_org_id(org) do
    case Organizations.get_id_by_slug(org) do
      nil -> {:error, :enoent}
      id -> {:ok, id}
    end
  end

  defp with_session(ctx, org, id, fun) do
    require_org(ctx, org, fn ->
      with {:ok, session} <- fetch_session(ctx, org, id), do: fun.(session)
    end)
  end

  defp fetch_session(_ctx, org, id) do
    with {:ok, org_id} <- resolve_org_id(org),
         %{} = session when session.organization_id == org_id <- SessionsCtx.get_session(id) do
      {:ok, session}
    else
      _ -> {:error, :enoent}
    end
  end

  # ── shared shape helpers ──────────────────────────────────────────────────

  defp decode(content) when is_binary(content) do
    case Jason.decode(content) do
      {:ok, doc} when is_map(doc) -> {:ok, doc}
      _ -> {:error, :eio}
    end
  end

  defp decode(_), do: {:error, :eio}

  defp require_field(doc, key) do
    case doc[key] do
      v when is_binary(v) and v != "" -> {:ok, v}
      _ -> {:error, :eio}
    end
  end

  defp valid_string(v) when is_binary(v) and v != "", do: v
  defp valid_string(_), do: nil

  defp writable_value?(v) when is_binary(v), do: v != ""
  defp writable_value?(_), do: false

  defp status_from(%{"status" => status}) when status in @statuses, do: status
  defp status_from(_), do: "active"

  defp uuid_or_nil(v) do
    case NoizuPromptLingua.UUID.cast(v) do
      {:ok, uuid} -> uuid
      :error -> nil
    end
  end

  # `Sessions.update_session/2` merges an atom-keyed `:last_activity_at` into
  # the caller's attrs before cast — mixed atom/string keys raise
  # Ecto.CastError, so the accepted whitelist goes through as ATOM keys (the
  # same convention the Session.Update tool uses via Args.take/2).
  defp atomize_known(map) when is_map(map) do
    Map.new(map, fn
      {k, v} when is_binary(k) -> {String.to_existing_atom(k), v}
      {k, v} -> {k, v}
    end)
  end

  defp iso(nil), do: nil
  defp iso(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  defp iso(other), do: to_string(other)

  defp overview_md do
    """
    # Sessions (sessions)

    Work-session entity-dir (`MCP-VFS-GROUP-MOUNTS.md` §2.7). One dir per
    session (server-assigned UUID); `record.json` is the canonical document,
    `manifest.json` renders this connection's tool manifest, `log/` is the
    append-only activity log, and lifecycle transitions (archive) ride
    `actions/archive` control writes — never record edits.
    """
  end

  # ── node builders (Root.ex conventions) ───────────────────────────────────

  defp dir_node(mtime \\ now_ms()), do: %VFS{type: :dir, mtime: mtime, version: version()}
  defp file_node(size), do: %VFS{type: :file, size: size, mtime: now_ms(), version: version()}

  defp control_node, do: %VFS{type: :control, size: 0, mtime: now_ms(), version: version()}

  defp dir_entry(name),
    do: %{name: name, type: :dir, size: 0, mtime: now_ms(), version: version()}

  defp file_entry(name),
    do: %{name: name, type: :file, size: 0, mtime: now_ms(), version: version()}

  defp version, do: 1
  defp now_ms, do: System.os_time(:millisecond)

  defp split_segments(path) do
    segments =
      path
      |> String.trim_trailing("/")
      |> String.split("/", trim: true)

    if Enum.any?(segments, &(&1 in [".", ".."])),
      do: {:error, :enoent},
      else: {:ok, segments}
  end
end
