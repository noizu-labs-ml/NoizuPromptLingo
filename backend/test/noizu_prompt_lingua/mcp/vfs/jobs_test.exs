defmodule NoizuPromptLingua.MCP.VFS.JobsTest do
  @moduledoc """
  The generic §3.8 job-dir runner (MCP-VFS-GROUP-MOUNTS.md §3.8), exercised
  against a `testjobs` shim registered through the `:vfs_jobs_shims` seam and
  an in-memory test backend:

    * submit → request.json + status=queued materialized through
      `Noizu.MCP.Server.Features.VFS` → runner pool walks running → done
    * `result` carries `{"ok": true, "result": …}` on success and
      `{"ok": false, "error": …}` on shim errors AND shim raises
    * consumer-chosen job ids collide → `:eexist`; unknown group → `:enosys`
    * retention: terminal jobs beyond the `:vfs_jobs_retention` cap are
      pruned through the backend (marker-scoped removes)
    * pubsub: every transition publishes a VFSPubSub event (the §3.8 point)
    * marker discipline: without the server-side runner assign, backend
      writes are refused

  The `browser` group's concrete shim is covered by `BrowserTest`.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias Noizu.MCP.Ctx
  alias Noizu.MCP.Server.Features.VFS
  alias Noizu.MCP.Server.VFSPubSub
  alias NoizuPromptLingua.MCP.VFS.Jobs

  # ── fixtures: in-memory backend + echo/fail shim for a `testjobs` group ──

  defmodule TestBackend do
    @moduledoc false

    use Noizu.MCP.VFS

    @store :npl_vfs_jobs_test_backend

    defp get(path), do: :persistent_term.get({@store, path}, nil)
    defp put(path, node), do: :persistent_term.put({@store, path}, node)
    defp del(path), do: :persistent_term.erase({@store, path})

    def reset do
      :persistent_term.get()
      |> Enum.each(fn
        {{@store, _path}, _} = entry -> :persistent_term.erase(elem(entry, 0))
        _ -> :ok
      end)

      :ok
    end

    defp runner?(ctx, job_id) do
      case ctx do
        %{assigns: %{vfs_job_runner: ^job_id}} -> true
        _ -> false
      end
    end

    defp segments("/" <> rest), do: String.split(rest, "/", trim: true)

    @impl true
    def stat(path, _ctx) do
      case get(path) do
        {:dir, _} ->
          {:ok, %Noizu.MCP.VFS{type: :dir, version: 1}}

        {:file, content} ->
          {:ok, %Noizu.MCP.VFS{type: :file, size: byte_size(content), version: 1}}

        nil ->
          {:error, :enoent}
      end
    end

    @impl true
    def list(path, _cursor, _ctx) do
      prefix = if path == "/", do: "", else: path

      entries =
        :persistent_term.get()
        |> Enum.flat_map(fn
          {{@store, p}, {kind, _}} ->
            case p do
              ^prefix <> "/" <> child ->
                name = child |> String.split("/") |> hd()

                if name == "" do
                  []
                else
                  [%{name: name, type: kind, size: 0, mtime: 0, version: 1}]
                end

              _ ->
                []
            end

          _ ->
            []
        end)
        |> Enum.uniq_by(& &1.name)

      {:ok, entries, nil}
    end

    @impl true
    def read(path, _ctx) do
      case get(path) do
        {:file, content} -> {:ok, content, 1}
        _ -> {:error, :enoent}
      end
    end

    @impl true
    def write(path, data, ctx) when is_binary(data) do
      case segments(path) do
        [_tobor, _org, _group, "session", _session, "jobs", job_id, "status"] ->
          if runner?(ctx, job_id) and match?({:file, _}, get(path)) do
            put(path, {:file, data})
            {:ok, %Noizu.MCP.VFS{type: :file, size: byte_size(data), version: 1}}
          else
            {:error, :erofs}
          end

        _ ->
          {:error, :erofs}
      end
    end

    def write(_path, _data, _ctx), do: {:error, :enosys}

    @impl true
    def create(path, :dir, ctx) do
      case segments(path) do
        [_tobor, _org, _group, "session", _session, "jobs", job_id] ->
          if runner?(ctx, job_id) do
            case get(path) do
              nil ->
                put(path, {:dir, nil})
                {:ok, %Noizu.MCP.VFS{type: :dir, version: 1}}

              _ ->
                {:error, :eexist}
            end
          else
            {:error, :erofs}
          end

        _ ->
          {:error, :enosys}
      end
    end

    def create(path, data, ctx) when is_binary(data) do
      case segments(path) do
        [_tobor, _org, _group, "session", _session, "jobs", job_id, file]
        when file in ["request.json", "result", "status"] ->
          if runner?(ctx, job_id) do
            if get(path) do
              {:error, :eexist}
            else
              put(path, {:file, data})
              {:ok, %Noizu.MCP.VFS{type: :file, size: byte_size(data), version: 1}}
            end
          else
            {:error, :erofs}
          end

        _ ->
          {:error, :enosys}
      end
    end

    def create(_path, _data, _ctx), do: {:error, :enosys}

    @impl true
    def remove(path, ctx) do
      case segments(path) do
        [_tobor, _org, _group, "session", _session, "jobs", job_id | _rest] ->
          if runner?(ctx, job_id) do
            del(path)
            :ok
          else
            {:error, :erofs}
          end

        _ ->
          {:error, :erofs}
      end
    end
  end

  defmodule TestRunner do
    @moduledoc false

    @behaviour NoizuPromptLingua.MCP.VFS.Jobs.Runner

    @impl true
    def backend, do: NoizuPromptLingua.MCP.VFS.JobsTest.TestBackend

    @impl true
    def group, do: "testjobs"

    @impl true
    def tools, do: %{"echo" => "Echo.Tool"}

    @impl true
    def run(%{"tool" => "echo", "args" => %{"v" => v}}, _ctx), do: {:ok, %{"echo" => v}}
    def run(%{"tool" => "fail"}, _ctx), do: {:error, "nope"}
    def run(%{"tool" => "boom"}, _ctx), do: raise("boom")
    def run(_request, _ctx), do: {:error, "malformed"}
  end

  # ── setup ──────────────────────────────────────────────────────────────────

  setup do
    TestBackend.reset()
    Application.put_env(:noizu_prompt_lingua, :vfs_jobs_shims, %{"testjobs" => TestRunner})

    on_exit(fn ->
      Application.delete_env(:noizu_prompt_lingua, :vfs_jobs_shims)
      Application.delete_env(:noizu_prompt_lingua, :vfs_jobs_retention)
    end)

    org = "jobs-org-#{System.unique_integer([:positive])}"
    session = "main"

    ctx = %Ctx{session_id: "jobs-" <> Integer.to_string(System.unique_integer([:positive]))}

    %{org: org, session: session, ctx: ctx}
  end

  defp request(tool, args \\ %{}), do: %{"tool" => tool, "args" => args}

  defp base(org, session, job_id),
    do: Jobs.job_dir(org, session, "testjobs", job_id)

  defp eventually(fun, tries \\ 100)

  defp eventually(_fun, 0), do: flunk("condition never became true")

  defp eventually(fun, tries) do
    if fun.() do
      :ok
    else
      Process.sleep(20)
      eventually(fun, tries - 1)
    end
  end

  # ── lifecycle: queued → running → done → result ───────────────────────────

  test "submit walks queued → done and materializes the job dir", %{
    org: org,
    session: session,
    ctx: ctx
  } do
    assert {:ok, job_id} =
             Jobs.submit(
               "testjobs",
               org,
               session,
               "job-echo",
               request("echo", %{"v" => "hi"}),
               ctx
             )

    dir = base(org, session, job_id)

    # request.json echoes the request as submitted (enrichment with
    # organization/session is the owning backend's concern — browser_test
    # covers it); the runner stamps status and the result.
    {:ok, req_json, _} = VFS.read(TestBackend, dir <> "/request.json", ctx)
    assert %{"tool" => "echo", "args" => %{"v" => "hi"}} = Jason.decode!(req_json)

    eventually(fn ->
      match?({:ok, "done", _}, VFS.read(TestBackend, dir <> "/status", ctx))
    end)

    {:ok, result_json, _} = VFS.read(TestBackend, dir <> "/result", ctx)
    assert %{"ok" => true, "result" => %{"echo" => "hi"}} = Jason.decode!(result_json)

    # The job dir lists the terminal file set, and the session's jobs dir
    # lists the job.
    assert {:ok, files, nil} = VFS.list(TestBackend, dir, nil, ctx)

    assert Enum.map(files, & &1.name) |> Enum.sort() ==
             Enum.sort(["request.json", "status", "result"])

    assert {:ok, job_entries, nil} =
             VFS.list(TestBackend, Path.dirname(dir), nil, ctx)

    assert Enum.any?(job_entries, &(&1.name == job_id))

    assert %{status: :done, job_id: ^job_id} = Jobs.get_job(org, session, "testjobs", job_id)
  end

  test "shim error → status=error, result carries the error", %{
    org: org,
    session: session,
    ctx: ctx
  } do
    {:ok, job_id} = Jobs.submit("testjobs", org, session, "job-fail", request("fail"), ctx)
    dir = base(org, session, job_id)

    eventually(fn ->
      match?({:ok, "error", _}, VFS.read(TestBackend, dir <> "/status", ctx))
    end)

    {:ok, result_json, _} = VFS.read(TestBackend, dir <> "/result", ctx)
    assert %{"ok" => false, "error" => "nope"} = Jason.decode!(result_json)
  end

  test "shim raise → status=error, result carries the exception message", %{
    org: org,
    session: session,
    ctx: ctx
  } do
    {:ok, job_id} = Jobs.submit("testjobs", org, session, "job-boom", request("boom"), ctx)
    dir = base(org, session, job_id)

    eventually(fn ->
      match?({:ok, "error", _}, VFS.read(TestBackend, dir <> "/status", ctx))
    end)

    {:ok, result_json, _} = VFS.read(TestBackend, dir <> "/result", ctx)
    assert %{"ok" => false, "error" => "boom"} = Jason.decode!(result_json)
  end

  # ── submit guards ──────────────────────────────────────────────────────────

  test "duplicate job id → :eexist", %{org: org, session: session, ctx: ctx} do
    assert {:ok, _} =
             Jobs.submit("testjobs", org, session, "dupe", request("echo", %{"v" => "1"}), ctx)

    assert {:error, :eexist} = Jobs.submit("testjobs", org, session, "dupe", request("echo"), ctx)
  end

  test "unknown group → :enosys", %{org: org, session: session, ctx: ctx} do
    assert {:error, :enosys} = Jobs.submit("nosuch", org, session, "x", request("echo"), ctx)
  end

  # ── retention ──────────────────────────────────────────────────────────────

  test "terminal jobs beyond the retention cap are pruned through the backend", %{
    org: org,
    session: session,
    ctx: ctx
  } do
    Application.put_env(:noizu_prompt_lingua, :vfs_jobs_retention, 1)

    {:ok, first} =
      Jobs.submit("testjobs", org, session, "keep-1", request("echo", %{"v" => "1"}), ctx)

    eventually(fn ->
      case Jobs.get_job(org, session, "testjobs", first) do
        %{status: :done} -> true
        _ -> false
      end
    end)

    {:ok, second} =
      Jobs.submit("testjobs", org, session, "keep-2", request("echo", %{"v" => "2"}), ctx)

    eventually(fn ->
      case Jobs.get_job(org, session, "testjobs", second) do
        %{status: :done} -> true
        _ -> false
      end
    end)

    # The oldest terminal job is gone from the table AND the file plane.
    assert Jobs.get_job(org, session, "testjobs", first) == nil
    assert {:error, :enoent} = VFS.stat(TestBackend, base(org, session, first), ctx)
    assert %{status: :done} = Jobs.get_job(org, session, "testjobs", second)
  end

  # ── pubsub: transitions announce through Features.VFS (§3.8) ───────────────

  test "status transitions and result publish vfs events", %{org: org, session: session, ctx: ctx} do
    :ok = VFSPubSub.watch(TestBackend, ["/"], depth: :infinity)

    {:ok, job_id} =
      Jobs.submit("testjobs", org, session, "job-pub", request("echo", %{"v" => "p"}), ctx)

    dir = base(org, session, job_id)

    eventually(fn ->
      match?({:ok, "done", _}, VFS.read(TestBackend, dir <> "/status", ctx))
    end)

    events = drain_events(50)
    paths = Enum.map(events, & &1.path)

    assert Enum.any?(paths, &String.ends_with?(&1, "/request.json"))
    assert Enum.any?(paths, &String.ends_with?(&1, "/status"))
    assert Enum.any?(paths, &String.ends_with?(&1, "/result"))

    ops = MapSet.new(Enum.map(events, & &1.op))
    assert MapSet.member?(ops, :create)
    assert MapSet.member?(ops, :write)
  end

  defp drain_events(timeout) do
    receive do
      {:vfs_event, event} -> [event | drain_events(timeout)]
    after
      timeout -> []
    end
  end

  # ── marker discipline ──────────────────────────────────────────────────────

  test "writes without the runner marker are refused", %{org: org, session: session, ctx: ctx} do
    {:ok, job_id} =
      Jobs.submit("testjobs", org, session, "job-mk", request("echo", %{"v" => "m"}), ctx)

    dir = base(org, session, job_id)

    eventually(fn ->
      match?({:ok, "done", _}, VFS.read(TestBackend, dir <> "/status", ctx))
    end)

    # No runner assign: status overwrite + result create + removes are :erofs.
    assert {:error, :erofs} = VFS.write(TestBackend, dir <> "/status", "done", ctx)
    assert {:error, :erofs} = VFS.create(TestBackend, dir <> "/result", "{}", ctx)
    assert {:error, :erofs} = VFS.remove(TestBackend, dir <> "/status", ctx)
    assert {:error, :erofs} = VFS.remove(TestBackend, dir, ctx)
  end
end
