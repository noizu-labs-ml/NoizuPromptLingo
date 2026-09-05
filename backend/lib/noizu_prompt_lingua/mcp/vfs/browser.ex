defmodule NoizuPromptLingua.MCP.VFS.Browser do
  @moduledoc """
  VFS backend for the `browser` group (MCP-VFS-GROUP-MOUNTS.md §2.21) —
  control/query + async job-dirs over the org's local Playwright controller
  (`NoizuPromptLingua.Domains.Browser` → Relay → user-machine transport).
  Full absolute paths, self-enforced §1.3 gates (via
  `NoizuPromptLingua.MCP.VFS.Scope`), independently conformance-testable.

      /tobor/{org}/browser                                → group root (readdir)
      …/browser/overview.md                               → Overview tool render
      …/browser/session                                   → sessions with recorded urls
      …/browser/session/{id}                              → one named session (virtual)
      …/browser/session/{id}/url                          → CONTROL: read url · write = navigate job
      …/browser/session/{id}/state.json                   → read = live GetState render
      …/browser/session/{id}/screenshots                  → capture metadata (B1: no bytes)
      …/browser/session/{id}/screenshots/_capture         → CONTROL: write = screenshot job
      …/browser/session/{id}/screenshots/{ts}-{s8}.png    → read `:enosys` (B1); xattr = media url
      …/browser/session/{id}/recordings                   → recording metadata (B1)
      …/browser/session/{id}/recordings/_start|_stop      → CONTROL: record job writes
      …/browser/session/{id}/jobs                         → this session's job dirs
      …/browser/session/{id}/jobs/{job-id}/request.json   → CONTROL: create = submit job
      …/browser/session/{id}/jobs/{job-id}/status         → read · queued|running|done|error
      …/browser/session/{id}/jobs/{job-id}/result         → read when done/error

  ## Read-only subtree, control files (§2.21)

  Browser actions are commands, not document edits: the ONLY external write
  surfaces are the control nodes above (`url`, `_capture`, `_start`, `_stop`,
  and `request.json` create). Everything else refuses `:erofs` — including
  `status`/`result`, which only the server-side runner may touch.

  ## Gating

  The subtree exists only for principals whose key carries the browser grant:
  the §1.3 group gate (`Scope.gate/3`) hides it entirely otherwise (`:enoent`,
  no existence leak). Commands are additionally ToolGuard-checked per the tool
  each control file maps to (`Browser.Navigate`, `Browser.Click`, …) — an
  ACL-denied tool refuses its control write with `:eacces`. Read ops stop at
  the group gate: polling a job's `status` must not require a per-tool grant,
  while every command path re-verifies the exact tool it maps to (the §2.21
  "every op ToolGuard-checked" intent, applied where a tool mapping exists).

  ## Job-dirs (§3.8, via `NoizuPromptLingua.MCP.VFS.Jobs`)

  `create` of `request.json` (`{"tool": "click", "args": {...}}`) submits the
  job; the runner walks `status` queued→running→done|error and materializes
  `result` — every transition THROUGH `Features.VFS`, so pubsub announces it.
  Runner writes carry the server-side `assigns[:vfs_job_runner]` marker scoped
  to the job id; without it those paths are `:erofs` (assigns never come from
  the wire). Job ids are consumer-chosen stable keys matching
  `[a-z0-9][a-z0-9_-]{0,63}` (uuid-shaped slugs qualify).

  ## B1 (binary caveat)

  The wire is UTF-8 JSON text — screenshots/recordings mount as metadata
  entries (fs-safe timestamp names, xattr carrying the media serve URL);
  reading the `.png`/`.webm` bytes is `:enosys` until the lib grows a binary
  contract (design §6 B1).
  """

  use Noizu.MCP.VFS

  alias NoizuPromptLingua.Domains.Browser
  alias NoizuPromptLingua.MCP.Resolve
  alias NoizuPromptLingua.MCP.VFS.{Jobs, Overview, Principal, Scope}
  alias NoizuPromptLingua.MCP.VFS.Jobs.Browser, as: BrowserShim

  @behaviour NoizuPromptLingua.MCP.VFS.Jobs.Runner

  @group "browser"
  @session_dir "session"
  @jobs_dir "jobs"
  @media_dirs ["screenshots", "recordings"]

  @id_re ~r/^[a-z0-9][a-z0-9_-]{0,63}$/
  @url_max 2048
  @request_max 65_536
  @capture_window 100
  @state_timeout 10_000

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

  defp stat_rest(_org, [], gate, _ctx), do: {:ok, dir_node(gate)}

  defp stat_rest(_org, ["overview.md"], gate, _ctx),
    do: {:ok, file_node(byte_size(Overview.md(overview_tool(), @group)), gate.writable)}

  defp stat_rest(_org, [@session_dir], _gate, _ctx), do: {:ok, Scope.dir_node()}

  defp stat_rest(_org, [@session_dir, id], gate, _ctx) do
    with :ok <- valid_id(id), do: {:ok, dir_node(gate)}
  end

  # `url` is a control node: writing it IS the navigate command.
  defp stat_rest(org, [@session_dir, id, "url"], gate, _ctx) do
    with :ok <- valid_id(id) do
      {:ok, control_node(gate, url_size(org, id))}
    end
  end

  defp stat_rest(org, [@session_dir, id, "state.json"], _gate, _ctx) do
    with :ok <- valid_id(id) do
      {:ok, Scope.file_node(byte_size(state_doc(org, id)))}
    end
  end

  defp stat_rest(_org, [@session_dir, id, dir], _gate, _ctx)
       when dir in @media_dirs or dir == @jobs_dir,
       do: with(:ok <- valid_id(id), do: {:ok, Scope.dir_node()})

  defp stat_rest(_org, [@session_dir, id, "screenshots", "_capture"], gate, _ctx),
    do: with(:ok <- valid_id(id), do: {:ok, control_node(gate, 0)})

  defp stat_rest(_org, [@session_dir, id, "recordings", flag], gate, _ctx)
       when flag in ["_start", "_stop"],
       do: with(:ok <- valid_id(id), do: {:ok, control_node(gate, 0)})

  defp stat_rest(org, [@session_dir, id, dir, name], _gate, _ctx)
       when dir in @media_dirs do
    with :ok <- valid_id(id),
         {:ok, entry} <- find_media(org, dir, name) do
      {:ok, %{Scope.file_node(0) | xattrs: media_xattrs(entry)}}
    end
  end

  defp stat_rest(org, [@session_dir, id, @jobs_dir, job_id], _gate, _ctx) do
    with :ok <- valid_id(id),
         :ok <- valid_id(job_id),
         {:ok, _job} <- fetch_job(org, id, job_id) do
      {:ok, Scope.dir_node()}
    end
  end

  defp stat_rest(org, [@session_dir, id, @jobs_dir, job_id, file], gate, ctx)
       when file in ["request.json", "status", "result"] do
    with :ok <- valid_id(id),
         :ok <- valid_id(job_id),
         {:ok, job} <- fetch_job(org, id, job_id) do
      job_file_node(file, job, gate, ctx)
    end
  end

  defp stat_rest(_org, _rest, _gate, _ctx), do: {:error, :enoent}

  defp job_file_node("request.json", job, gate, _ctx),
    do: {:ok, file_node(byte_size(Jason.encode!(job.request)), gate.writable)}

  defp job_file_node("status", job, _gate, _ctx),
    do: {:ok, Scope.file_node(String.length(Atom.to_string(job.status)))}

  defp job_file_node("result", job, _gate, _ctx),
    do:
      if(is_map(job.result),
        do: {:ok, Scope.file_node(byte_size(Jason.encode!(job.result)))},
        else: {:error, :enoent}
      )

  # ── list/3 ────────────────────────────────────────────────────────────────

  @impl true
  def list(path, cursor, ctx) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, _gate} <- Scope.gate(ctx, org, @group) do
      # Bounded by construction: capture window + retention cap; a cursor can
      # only be stale/foreign — reject rather than mis-paginate (wave-0 rule).
      if cursor in [nil, ""] do
        list_rest(org, rest, ctx)
      else
        {:error, Noizu.MCP.Error.invalid_params("invalid cursor")}
      end
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enoent}
    end
  end

  defp list_rest(_org, [], _ctx),
    do: {:ok, [Scope.file_entry("overview.md"), Scope.dir_entry(@session_dir)], nil}

  defp list_rest(_org, ["overview.md"], _ctx), do: {:error, :enotdir}

  defp list_rest(org, [@session_dir], _ctx),
    do: {:ok, Enum.map(BrowserShim.sessions(org), &Scope.dir_entry/1), nil}

  defp list_rest(_org, [@session_dir, id], _ctx) do
    with :ok <- valid_id(id) do
      {:ok,
       [
         %{Scope.file_entry("url") | type: :control},
         Scope.file_entry("state.json"),
         Scope.dir_entry("screenshots"),
         Scope.dir_entry("recordings"),
         Scope.dir_entry(@jobs_dir)
       ], nil}
    end
  end

  defp list_rest(_org, [_id, node], _ctx) when node in ["url", "state.json"],
    do: {:error, :enotdir}

  defp list_rest(org, [@session_dir, id, dir], _ctx) when dir in @media_dirs do
    with :ok <- valid_id(id) do
      controls =
        if dir == "screenshots",
          do: [%{Scope.file_entry("_capture") | type: :control}],
          else: [
            %{Scope.file_entry("_start") | type: :control},
            %{Scope.file_entry("_stop") | type: :control}
          ]

      ext = if(dir == "screenshots", do: "png", else: "webm")

      entries =
        org
        |> media_entries(dir)
        |> Enum.map(&Scope.file_entry(media_name(&1, ext)))

      {:ok, controls ++ entries, nil}
    end
  end

  defp list_rest(org, [@session_dir, id, @jobs_dir], _ctx) do
    with :ok <- valid_id(id) do
      {:ok, Enum.map(Jobs.list_jobs(org, id, @group), &Scope.dir_entry(&1.job_id)), nil}
    end
  end

  defp list_rest(org, [@session_dir, id, @jobs_dir, job_id], _ctx) do
    with :ok <- valid_id(id),
         {:ok, job} <- fetch_job(org, id, job_id) do
      files =
        ["request.json", "status"] ++
          if(job.status in [:done, :error], do: ["result"], else: [])

      {:ok, Enum.map(files, &Scope.file_entry/1), nil}
    end
  end

  defp list_rest(_org, _rest, _ctx), do: {:error, :enoent}

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

  defp read_rest(_org, ["overview.md"], _ctx),
    do: {:ok, Overview.md(overview_tool(), @group), Scope.version()}

  defp read_rest(_org, [@session_dir], _ctx), do: {:error, :eisdir}

  defp read_rest(_org, [@session_dir, id], _ctx),
    do: with(:ok <- valid_id(id), do: {:error, :eisdir})

  # read = the session's current url (last landed navigation; empty before one).
  defp read_rest(org, [@session_dir, id, "url"], _ctx) do
    with :ok <- valid_id(id) do
      {:ok, BrowserShim.session_url(org, id) || "", Scope.version()}
    end
  end

  defp read_rest(org, [@session_dir, id, "state.json"], _ctx) do
    with :ok <- valid_id(id) do
      case state_render(org, id) do
        {:ok, doc} -> {:ok, doc, Scope.version()}
        {:error, _} = error -> error
      end
    end
  end

  # B1: capture/record BYTES never cross the wire — metadata rides stat/xattr.
  defp read_rest(_org, [@session_dir, _id, dir, _name], _ctx) when dir in @media_dirs,
    do: {:error, :enosys}

  defp read_rest(org, [@session_dir, id, @jobs_dir, job_id, "request.json"], _ctx) do
    with {:ok, job} <- fetch_job(org, id, job_id) do
      {:ok, Jason.encode!(job.request), Scope.version()}
    end
  end

  defp read_rest(org, [@session_dir, id, @jobs_dir, job_id, "status"], _ctx) do
    with {:ok, job} <- fetch_job(org, id, job_id) do
      {:ok, Atom.to_string(job.status), Scope.version()}
    end
  end

  defp read_rest(org, [@session_dir, id, @jobs_dir, job_id, "result"], _ctx) do
    with {:ok, job} <- fetch_job(org, id, job_id),
         result when is_map(result) <- job.result do
      {:ok, Jason.encode!(result), Scope.version()}
    else
      _ -> {:error, :enoent}
    end
  end

  defp read_rest(_org, _rest, _ctx), do: {:error, :enoent}

  # ── write/3 — control files + the runner-marked status seam ───────────────

  @impl true
  def write(path, data, ctx) when is_binary(data) do
    case Scope.split_segments(path) do
      {:ok, [_tobor, org, @group, @session_dir, _id, @jobs_dir, job_id, "status"]} ->
        cond do
          # Runner writes are marker-authoritative and DB-FREE: gating here
          # would drag the EffectiveToolset cascade (DB) into every transition,
          # racing the submitting principal's session lifecycle.
          runner_for?(ctx, job_id) ->
            {:ok, Scope.file_node(byte_size(data))}

          match?({:ok, _}, Scope.gate(ctx, org, @group)) ->
            {:error, :erofs}

          true ->
            {:error, :enoent}
        end

      {:ok, [_tobor, org, @group | rest]} ->
        with {:ok, gate} <- Scope.gate(ctx, org, @group) do
          write_rest(org, rest, data, gate, ctx)
        end

      {:ok, _} ->
        {:error, :erofs}

      {:error, _} = error ->
        error
    end
  end

  def write(_path, _data, _ctx), do: {:error, :enosys}

  # `url` — the purest write-to-command in the tree: write a one-line url, a
  # navigate job is submitted, its id rides the node xattrs.
  defp write_rest(org, [@session_dir, id, "url"], data, gate, ctx) do
    with :ok <- Scope.require_writable(gate),
         :ok <- Principal.tool_gate("Browser.Navigate", %{}, ctx),
         :ok <- valid_id(id),
         {:ok, url} <- one_line_url(data) do
      request = %{
        "tool" => "navigate",
        "args" => %{"url" => url},
        "organization" => org,
        "session" => id
      }

      submit_job(org, id, "navigate", request, ctx, gate)
    end
  end

  defp write_rest(org, [@session_dir, id, "screenshots", "_capture"], _data, gate, ctx) do
    with :ok <- Scope.require_writable(gate),
         :ok <- Principal.tool_gate("Browser.Screenshot", %{}, ctx),
         :ok <- valid_id(id) do
      request = %{"tool" => "screenshot", "args" => %{}, "organization" => org, "session" => id}
      submit_job(org, id, "screenshot", request, ctx, gate)
    end
  end

  defp write_rest(org, [@session_dir, id, "recordings", flag], _data, gate, ctx)
       when flag in ["_start", "_stop"] do
    tool = if(flag == "_start", do: "Browser.RecordStart", else: "Browser.RecordStop")
    tool_name = if(flag == "_start", do: "record_start", else: "record_stop")

    with :ok <- Scope.require_writable(gate),
         :ok <- Principal.tool_gate(tool, %{}, ctx),
         :ok <- valid_id(id) do
      request = %{"tool" => tool_name, "args" => %{}, "organization" => org, "session" => id}
      submit_job(org, id, String.trim_leading(flag, "_"), request, ctx, gate)
    end
  end

  # (Runner status writes never reach here — intercepted marker-first in
  # write/3 above. Everyone else: read-only subtree.)
  defp write_rest(_org, _rest, _data, _gate, _ctx), do: {:error, :erofs}

  defp submit_job(org, session, prefix, request, ctx, gate) do
    job_id = "#{prefix}-#{Ecto.UUID.generate()}"

    with {:ok, ^job_id} <- Jobs.submit(@group, org, session, job_id, request, ctx) do
      {:ok, %{control_node(gate, 0) | xattrs: %{"job" => job_id}}}
    end
  end

  # ── create/3 — request.json submit + runner materialization ───────────────

  @impl true
  def create(path, data, ctx) do
    case Scope.split_segments(path) do
      {:ok, [_tobor, org, @group, @session_dir, id, @jobs_dir, job_id, "request.json"]} ->
        cond do
          # Runner-materialized echo (marker short-circuit — this create runs
          # INSIDE Jobs.submit; re-entering it would self-call the GenServer).
          runner_for?(ctx, job_id) ->
            {:ok, Scope.file_node(byte_size(data || ""))}

          is_binary(data) ->
            with {:ok, gate} <- Scope.gate(ctx, org, @group) do
              create_request(org, id, job_id, data, gate, ctx)
            end

          true ->
            {:error, :eio}
        end

      {:ok, [_tobor, org, @group, @session_dir, id, @jobs_dir, job_id, file]} ->
        cond do
          # Runner materialization is marker-authoritative and DB-free (same
          # rationale as the runner status write above).
          runner_for?(ctx, job_id) ->
            runner_create(org, id, job_id, file, data)

          match?({:ok, _}, Scope.gate(ctx, org, @group)) ->
            {:error, :erofs}

          true ->
            {:error, :enoent}
        end

      # The job dir itself — runner-created during submit.
      {:ok, [_tobor, org, @group, @session_dir, _id, @jobs_dir, job_id]} ->
        cond do
          runner_for?(ctx, job_id) and valid_id(job_id) == :ok ->
            {:ok, Scope.dir_node()}

          match?({:ok, _}, Scope.gate(ctx, org, @group)) ->
            {:error, :erofs}

          true ->
            {:error, :enoent}
        end

      {:ok, _} ->
        {:error, :erofs}

      {:error, _} = error ->
        error
    end
  end

  # The external control create: gate → validate → ToolGuard → submit.
  defp create_request(org, session, job_id, data, gate, ctx) when is_binary(data) do
    with :ok <- Scope.require_writable(gate),
         :ok <- valid_id(job_id),
         :ok <- byte_cap(data, @request_max),
         {:ok, %{"tool" => tool} = request} <- parse_request(data),
         {:ok, guard_tool} <- mapped_tool(tool) do
      with :ok <- Principal.tool_gate(guard_tool, %{}, ctx) do
        enriched =
          request
          |> Map.put("organization", org)
          |> Map.put("session", session)

        case Jobs.submit(@group, org, session, job_id, enriched, ctx) do
          {:ok, _} -> {:ok, file_node(byte_size(data), gate.writable)}
          {:error, _} = error -> error
        end
      end
    else
      {:error, _} = error -> error
      _ -> {:error, :eio}
    end
  end

  # Runner-marked materialization: request.json echo, dir, and the result
  # payload (recorded into the job table, then announced by the wrapper).
  defp runner_create(_org, _session, _job_id, "request.json", data) when is_binary(data),
    do: {:ok, Scope.file_node(byte_size(data))}

  defp runner_create(_org, _session, _job_id, "status", data) when is_binary(data),
    do: {:ok, Scope.file_node(byte_size(data))}

  defp runner_create(_org, _session, _job_id, _file, :dir), do: {:ok, Scope.dir_node()}

  defp runner_create(_org, _session, _job_id, "result", data) when is_binary(data),
    do: {:ok, Scope.file_node(byte_size(data))}

  defp runner_create(_org, _session, _job_id, _file, _data), do: {:error, :eio}

  # ── remove/2 — runner-marked retention prunes only ────────────────────────

  @impl true
  def remove(path, ctx) do
    case Scope.split_segments(path) do
      {:ok, [_tobor, org, @group, @session_dir, id, @jobs_dir, job_id]} ->
        cond do
          # Runner-marked removes (retention prunes) carry no principal — the
          # server-side marker IS their authority; gating would deny them.
          runner_for?(ctx, job_id) and valid_id(job_id) == :ok ->
            Jobs.forget(org, id, @group, job_id)
            :ok

          match?({:ok, _}, Scope.gate(ctx, org, @group)) ->
            {:error, :erofs}

          true ->
            {:error, :enoent}
        end

      {:ok, [_tobor, org, @group, @session_dir, _id, @jobs_dir, job_id, file]}
      when file in ["result", "status", "request.json"] ->
        cond do
          runner_for?(ctx, job_id) and valid_id(job_id) == :ok ->
            :ok

          match?({:ok, _}, Scope.gate(ctx, org, @group)) ->
            {:error, :erofs}

          true ->
            {:error, :enoent}
        end

      {:ok, _} ->
        {:error, :erofs}

      {:error, _} = error ->
        error
    end
  end

  # ── xattr/2 ───────────────────────────────────────────────────────────────

  @impl true
  def xattr(path, ctx) do
    case Scope.split_segments(path) do
      {:ok, [_tobor, org, @group | rest]} ->
        if match?({:ok, _}, Scope.gate(ctx, org, @group)) do
          {:ok, xattrs_for(org, rest)}
        else
          {:ok, %{}}
        end

      _ ->
        {:ok, %{}}
    end
  end

  defp xattrs_for(_org, [@session_dir, id]), do: %{"session" => id}

  defp xattrs_for(org, [@session_dir, id, "url"]),
    do: %{"session" => id, "url" => BrowserShim.session_url(org, id)}

  defp xattrs_for(_org, [@session_dir, _id, "state.json"]),
    do: %{"source" => "Browser.GetState", "live" => true}

  defp xattrs_for(_org, [@session_dir, _id, "screenshots"]),
    do: %{"binary" => false, "note" => "B1: bytes stay off the VFS; media url rides xattrs"}

  defp xattrs_for(org, [@session_dir, _id, dir, name]) when dir in @media_dirs do
    case find_media(org, dir, name) do
      {:ok, entry} -> media_xattrs(entry)
      _ -> %{}
    end
  end

  defp xattrs_for(_org, [@session_dir, _id, @jobs_dir, _job_id, file])
       when file in ["request.json", "status", "result"],
       do: %{}

  defp xattrs_for(_org, _rest), do: %{}

  # ── Runner behaviour (delegates to the shim; the Jobs registry points
  #    here, keeping the group's runner + file plane co-located) ─────────────

  @impl NoizuPromptLingua.MCP.VFS.Jobs.Runner
  def backend, do: __MODULE__

  @impl NoizuPromptLingua.MCP.VFS.Jobs.Runner
  def group, do: @group

  @impl NoizuPromptLingua.MCP.VFS.Jobs.Runner
  defdelegate tools(), to: BrowserShim

  @impl NoizuPromptLingua.MCP.VFS.Jobs.Runner
  defdelegate run(request, ctx), to: BrowserShim

  # ── helpers ───────────────────────────────────────────────────────────────

  defp overview_tool, do: NoizuPromptLingua.Domains.Browser.Tools.Overview

  defp valid_id(id) when is_binary(id),
    do: if(Regex.match?(@id_re, id), do: :ok, else: {:error, :enoent})

  defp valid_id(_), do: {:error, :enoent}

  defp one_line_url(data) do
    url = String.trim(data)

    cond do
      url == "" or String.contains?(url, ["\n", "\r"]) -> {:error, :eio}
      byte_size(url) > @url_max -> {:error, :eio}
      true -> {:ok, url}
    end
  end

  defp byte_cap(data, cap), do: if(byte_size(data) <= cap, do: :ok, else: {:error, :eio})

  defp parse_request(data) do
    case Jason.decode(data) do
      {:ok, %{"tool" => tool} = request} when is_binary(tool) -> {:ok, request}
      _ -> {:error, :eio}
    end
  end

  defp mapped_tool(tool) do
    case BrowserShim.tools()[tool] do
      nil -> {:error, :eio}
      canonical -> {:ok, canonical}
    end
  end

  defp dir_node(gate), do: %{Scope.dir_node() | writable: gate.writable}

  defp file_node(size, writable), do: %{Scope.file_node(size) | writable: writable}

  defp control_node(gate, size) do
    %Noizu.MCP.VFS{type: :control, size: size, mtime: Scope.now_ms(), version: Scope.version()}
    |> Map.put(:writable, gate.writable)
  end

  defp url_size(org, id), do: byte_size(BrowserShim.session_url(org, id) || "")

  # Live GetState render (§2.21). No controller is a documented state
  # (`connected: false`), not an error; other relay failures are `:eio`.
  defp state_render(org, id) do
    now = DateTime.utc_now() |> DateTime.to_iso8601()

    case Browser.run(org, "state", %{include_text: false}, @state_timeout) do
      {:ok, data} ->
        {:ok,
         Jason.encode!(%{
           "session" => id,
           "connected" => true,
           "url" => data["url"] || BrowserShim.session_url(org, id),
           "state" => data,
           "generated_at" => now
         })}

      {:error, "no local browser controller" <> _} ->
        {:ok,
         Jason.encode!(%{
           "session" => id,
           "connected" => false,
           "url" => BrowserShim.session_url(org, id),
           "state" => nil,
           "generated_at" => now
         })}

      _ ->
        {:error, :eio}
    end
  end

  defp state_doc(org, id) do
    case state_render(org, id) do
      {:ok, doc} -> doc
      _ -> Jason.encode!(%{"session" => id, "connected" => false, "state" => nil})
    end
  end

  # ── capture/record metadata (B1: names + xattrs, never bytes) ─────────────

  defp media_entries(org, media_dir) do
    media_type = if(media_dir == "screenshots", do: :image, else: :video)

    case Resolve.organization_id(org) do
      nil ->
        []

      org_id ->
        org_id
        |> Browser.list_captures(@capture_window)
        |> Enum.filter(&(&1.media_type == media_type))
    end
  end

  defp media_name(entry, ext), do: "#{fs_ts(entry.inserted_at)}-#{short8(entry.short_id)}.#{ext}"

  defp find_media(org, media_dir, name) do
    ext = if(media_dir == "screenshots", do: "png", else: "webm")

    if String.ends_with?(name, "." <> ext) do
      entries = media_entries(org, media_dir)

      case Enum.find(entries, &(media_name(&1, ext) == name)) do
        nil -> {:error, :enoent}
        entry -> {:ok, entry}
      end
    else
      {:error, :enoent}
    end
  end

  defp media_xattrs(entry),
    do: %{"media_id" => entry.id, "url" => entry.url, "binary" => false}

  # §1.1: filesystem-safe timestamps (`2026-09-05T12-00-01Z-…` — no colons).
  defp fs_ts(%DateTime{} = dt), do: Calendar.strftime(dt, "%Y-%m-%dT%H-%M-%SZ")
  defp fs_ts(_), do: "unknown"

  defp short8(nil), do: "00000000"
  defp short8(id) when is_binary(id), do: String.slice(id, 0, 8)

  defp fetch_job(org, session, job_id) do
    case Jobs.get_job(org, session, @group, job_id) do
      nil -> {:error, :enoent}
      job -> {:ok, job}
    end
  end

  defp runner_for?(ctx, job_id) do
    case ctx do
      %{assigns: %{vfs_job_runner: ^job_id}} -> true
      _ -> false
    end
  end
end
