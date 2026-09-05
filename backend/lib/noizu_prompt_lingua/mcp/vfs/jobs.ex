defmodule NoizuPromptLingua.MCP.VFS.Jobs do
  @moduledoc """
  The job-dir runner (MCP-VFS-GROUP-MOUNTS.md §3.8) — the server side of the
  long-running-ops convention: a control write creates `…/jobs/{job-id}/request.json`,
  the runner walks `status` through `queued → running → done|error`, and a
  final `result` file appears. Every transition is written THROUGH
  `Noizu.MCP.Server.Features.VFS`, so each one bumps the backend generation and
  publishes a `VFSPubSub` event — a mounter subscribed to the jobs dir sees the
  completion arrive, no polling required.

  ## Topology

  One GenServer, one `Task.Supervisor` pool
  (`#{__MODULE__}.RunnerSup`). Job state is held in memory, keyed
  `{org, session, group, job_id}` — the job files are virtual projections of
  it, so a node restart retires in-flight history (job dirs read `:enoent`
  afterwards). This is the documented v1 semantics: job-dirs are a
  command/completion channel, not a durable store.

  ## Registry

  Group → runner shim: compile-time `@default_shims` merged over the
  application env `:vfs_jobs_shims` (extra shims without code changes; also
  the test seam). A shim implements the `Jobs.Runner` behaviour:

      @callback backend() :: module()          # VFS backend owning the tree
      @callback group() :: String.t()          # path + registry key
      @callback tools() :: %{String.t() => String.t()}  # request tool → canonical MCP tool
      @callback run(request :: map(), ctx :: Noizu.MCP.Ctx.t()) ::
                  {:ok, result :: term()} | {:error, term()}

  ## Runner identity (server-internal)

  Runner writes carry `ctx.assigns[:vfs_job_runner] = job_id` — the marker the
  owning backend uses to admit status/result writes and retention removals
  that no mount-side write may forge (assigns are set server-side only).
  Backends still own every gate: the marker widens nothing by itself.
  """

  use GenServer

  alias Noizu.MCP.Ctx
  alias Noizu.MCP.Server.Features.VFS
  alias NoizuPromptLingua.MCP.VFS.Jobs.Browser, as: BrowserShim

  defmodule Runner do
    @moduledoc "Per-group runner shim contract (see `NoizuPromptLingua.MCP.VFS.Jobs`)."

    @callback backend() :: module()
    @callback group() :: String.t()
    @callback tools() :: %{String.t() => String.t()}
    @callback run(request :: map(), ctx :: Noizu.MCP.Ctx.t()) ::
                {:ok, result :: term()} | {:error, term()}
  end

  @default_shims %{"browser" => BrowserShim}

  @typedoc "In-memory job record — the authoritative state; files are projections."
  @type job :: %{
          required(:org) => String.t(),
          required(:session) => String.t(),
          required(:group) => String.t(),
          required(:job_id) => String.t(),
          required(:request) => map(),
          required(:status) => :queued | :running | :done | :error,
          required(:result) => map() | nil,
          required(:submitted_at) => DateTime.t(),
          required(:finished_at) => DateTime.t() | nil
        }

  # ── API ───────────────────────────────────────────────────────────────────

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, Keyword.take(opts, [:retention]), name: __MODULE__)
  end

  @doc "The group → shim registry (defaults merged over `:vfs_jobs_shims`)."
  @spec shims() :: %{String.t() => module()}
  def shims,
    do: Map.merge(@default_shims, Application.get_env(:noizu_prompt_lingua, :vfs_jobs_shims, %{}))

  @doc "Retention cap: terminal jobs kept per `{org, session, group}` dir."
  @spec retention() :: pos_integer()
  def retention, do: Application.get_env(:noizu_prompt_lingua, :vfs_jobs_retention, 100)

  @doc """
  Submit a job whose `request.json` the CALLER (the owning backend's control
  write) has already gated and validated; `job_id` was chosen at the control
  path. Materializes the job dir through `Features.VFS` (runner-marked ctx)
  and hands the request to the group's shim on the runner pool.
  """
  @spec submit(String.t(), String.t(), String.t(), String.t(), map(), Ctx.t()) ::
          {:ok, String.t()} | {:error, :enosys | :eexist}
  def submit(group, org, session, job_id, request, ctx) do
    GenServer.call(__MODULE__, {:submit, group, org, session, job_id, request, ctx})
  end

  @doc "The known jobs for a session dir (newest first) — the readdir projection."
  @spec list_jobs(String.t(), String.t(), String.t()) :: [job()]
  def list_jobs(org, session, group) do
    GenServer.call(__MODULE__, {:list_jobs, org, session, group})
  end

  @doc "One job's record, or nil."
  @spec get_job(String.t(), String.t(), String.t(), String.t()) :: job() | nil
  def get_job(org, session, group, job_id) do
    GenServer.call(__MODULE__, {:get_job, org, session, group, job_id})
  end

  @doc """
  Drop a job (retention prune / runner remove). Called through the owning
  backend's `remove/2` with a runner-marked ctx; publishes the removal.
  """
  @spec forget(String.t(), String.t(), String.t(), String.t()) :: :ok
  def forget(org, session, group, job_id) do
    GenServer.cast(__MODULE__, {:forget, org, session, group, job_id})
  end

  @doc """
  Runner-side status transition (`queued|running|done|error`). Called through
  the owning backend's runner-marked `write` of the `status` file, so the
  Features.VFS wrapper publishes the event as the table updates.
  """
  @spec record_status(String.t(), String.t(), String.t(), String.t(), binary()) ::
          {:ok, job()} | {:error, :enoent | :eio}
  def record_status(group, org, session, job_id, status) when is_binary(status) do
    status =
      case String.trim(status) do
        s when s in ~w(queued running done error) -> String.to_existing_atom(s)
        _ -> nil
      end

    case status do
      nil -> {:error, :eio}
      status -> GenServer.call(__MODULE__, {:record_status, group, org, session, job_id, status})
    end
  end

  @doc """
  Runner-side result materialization (called through the owning backend's
  runner-marked `create` of the `result` file); stamps `finished_at` and runs
  the retention prune.
  """
  @spec record_result(String.t(), String.t(), String.t(), String.t(), map()) ::
          {:ok, job()} | {:error, :enoent | :eio}
  def record_result(group, org, session, job_id, payload) when is_map(payload) do
    GenServer.call(__MODULE__, {:record_result, group, org, session, job_id, payload})
  end

  def record_result(_group, _org, _session, _job_id, _payload), do: {:error, :eio}

  # ── path composition (the §3.8 layout, shared with the backends) ──────────

  @doc "The job dir for a key, full absolute path."
  @spec job_dir(String.t(), String.t(), String.t(), String.t()) :: String.t()
  def job_dir(org, session, group, job_id) do
    "/tobor/#{org}/#{group}/session/#{session}/jobs/#{job_id}"
  end

  # ── GenServer ─────────────────────────────────────────────────────────────

  @impl true
  def init(_opts), do: {:ok, %{jobs: %{}}}

  @impl true
  def handle_call({:submit, group, org, session, job_id, request, ctx}, _from, state) do
    shim = shims()[group]

    cond do
      is_nil(shim) ->
        {:reply, {:error, :enosys}, state}

      Map.has_key?(state.jobs, key(org, session, group, job_id)) ->
        {:reply, {:error, :eexist}, state}

      true ->
        runner_ctx = mark_runner(ctx, job_id)
        backend = shim.backend()

        with :ok <- ensure_dir(backend, job_dir(org, session, group, job_id), runner_ctx),
             {:ok, _} <-
               VFS.create(
                 backend,
                 job_dir(org, session, group, job_id) <> "/request.json",
                 Jason.encode!(request),
                 runner_ctx
               ),
             {:ok, _} <-
               VFS.create(
                 backend,
                 job_dir(org, session, group, job_id) <> "/status",
                 "queued",
                 runner_ctx
               ) do
          job = %{
            org: org,
            session: session,
            group: group,
            job_id: job_id,
            request: request,
            status: :queued,
            result: nil,
            submitted_at: DateTime.utc_now(),
            finished_at: nil
          }

          Task.Supervisor.start_child(
            __MODULE__.RunnerSup,
            fn -> execute(shim, job, ctx, runner_ctx) end
          )

          {:reply, {:ok, job_id}, put_job(state, job)}
        else
          {:error, _} = error -> {:reply, error, state}
        end
    end
  end

  def handle_call({:list_jobs, org, session, group}, _from, state) do
    jobs =
      state.jobs
      |> Map.values()
      |> Enum.filter(&(&1.org == org and &1.session == session and &1.group == group))
      |> Enum.sort_by(& &1.submitted_at, {:desc, DateTime})

    {:reply, jobs, state}
  end

  def handle_call({:get_job, org, session, group, job_id}, _from, state) do
    {:reply, Map.get(state.jobs, key(org, session, group, job_id)), state}
  end

  # Runner-marked status write (through the owning backend): keep the table
  # coherent with the file the wrapper just published.
  def handle_call({:record_status, group, org, session, job_id, status}, _from, state) do
    k = key(org, session, group, job_id)

    case status_word(status) do
      nil ->
        {:reply, {:error, :eio}, state}

      status ->
        case Map.get(state.jobs, k) do
          nil ->
            {:reply, {:error, :enoent}, state}

          job ->
            {:reply, {:ok, %{job | status: status}},
             put_in(state.jobs[k], %{job | status: status})}
        end
    end
  end

  # Runner-marked result create: stamp terminal state, then prune.
  def handle_call({:record_result, group, org, session, job_id, payload}, _from, state) do
    k = key(org, session, group, job_id)

    case Map.get(state.jobs, k) do
      nil ->
        {:reply, {:error, :enoent}, state}

      job ->
        job = %{job | result: payload, finished_at: DateTime.utc_now()}
        {:reply, {:ok, job}, prune(put_in(state.jobs[k], job), job)}
    end
  end

  @impl true
  def handle_cast({:forget, org, session, group, job_id}, state) do
    {:noreply, %{state | jobs: Map.delete(state.jobs, key(org, session, group, job_id))}}
  end

  @impl true
  def handle_info(_msg, state), do: {:noreply, state}

  # ── runner pool execution ─────────────────────────────────────────────────

  # Table first, file second: each transition updates this table directly,
  # then materializes the file THROUGH Features.VFS so the published event
  # never races a stale read (backends stay pure file materializers — the
  # runner marker admits their writes, nothing more).
  defp execute(shim, job, ctx, runner_ctx) do
    backend = shim.backend()
    base = job_dir(job.org, job.session, job.group, job.job_id)

    record_status(job, "running")
    VFS.write(backend, base <> "/status", "running", runner_ctx)

    outcome =
      try do
        case shim.run(job.request, ctx) do
          {:ok, result} -> {:done, %{"ok" => true, "result" => result}}
          {:error, reason} -> {:error, error_result(reason)}
        end
      rescue
        e -> {:error, error_result(Exception.message(e))}
      catch
        kind, value -> {:error, error_result("runner #{kind}: #{inspect(value)}")}
      end

    {status, payload} = outcome

    record_status(job, Atom.to_string(status))
    record_result(job, payload)

    VFS.write(backend, base <> "/status", Atom.to_string(status), runner_ctx)
    VFS.create(backend, base <> "/result", Jason.encode!(payload), runner_ctx)
  end

  defp record_status(job, status) do
    GenServer.call(
      __MODULE__,
      {:record_status, job.group, job.org, job.session, job.job_id, status}
    )
  end

  defp record_result(job, payload) do
    GenServer.call(
      __MODULE__,
      {:record_result, job.group, job.org, job.session, job.job_id, payload}
    )
  end

  defp error_result(reason) when is_binary(reason), do: %{"ok" => false, "error" => reason}

  defp error_result(reason), do: %{"ok" => false, "error" => inspect(reason)}

  # ── retention ─────────────────────────────────────────────────────────────

  # Oldest terminal jobs beyond the cap are removed through the backend
  # (runner-marked), so mounters see the deletion events like any other prune.
  defp prune(state, job) do
    dir_jobs =
      state.jobs
      |> Map.values()
      |> Enum.filter(&(same_dir?(&1, job) and &1.status in [:done, :error]))
      |> Enum.sort_by(&(&1.finished_at || &1.submitted_at), {:desc, DateTime})

    state =
      Enum.drop(dir_jobs, max(1, retention()))
      |> Enum.reduce(state, fn stale, acc ->
        remove_job_files(stale)
        %{acc | jobs: Map.delete(acc.jobs, key(stale))}
      end)

    state
  end

  defp same_dir?(a, b), do: a.org == b.org and a.session == b.session and a.group == b.group

  # Best effort: a shim unregistered since submission (test seams, hot config)
  # still prunes from memory — only the file-plane deletion is skipped.
  defp remove_job_files(job) do
    case shims()[job.group] do
      nil ->
        :ok

      shim ->
        backend = shim.backend()
        base = job_dir(job.org, job.session, job.group, job.job_id)
        runner_ctx = mark_runner(%Ctx{session_id: "vfs-jobs-retention"}, job.job_id)

        for file <- ["result", "status", "request.json"] do
          _ = VFS.remove(backend, base <> "/" <> file, runner_ctx)
        end

        _ = VFS.remove(backend, base, runner_ctx)
        :ok
    end
  end

  # ── helpers ───────────────────────────────────────────────────────────────

  defp ensure_dir(backend, path, runner_ctx) do
    case VFS.create(backend, path, :dir, runner_ctx) do
      {:ok, _} -> :ok
      {:error, :eexist} -> :ok
      {:error, _} = error -> error
    end
  end

  defp key(org, session, group, job_id), do: {org, session, group, job_id}
  defp key(job), do: key(job.org, job.session, job.group, job.job_id)

  # `queued|running|done|error` in, status atom out (binaries and atoms both
  # flow through the record seam).
  defp status_word(s) when s in [:queued, :running, :done, :error], do: s

  defp status_word(s) when is_binary(s) do
    case String.trim(s) do
      w when w in ~w(queued running done error) -> String.to_existing_atom(w)
      _ -> nil
    end
  end

  defp status_word(_), do: nil

  defp put_job(state, job), do: %{state | jobs: Map.put(state.jobs, key(job), job)}

  # The runner identity marker: server-side only (assigns never come from the
  # wire), scoped to the job it may touch.
  defp mark_runner(ctx, job_id) do
    assigns = Map.put(Map.get(ctx, :assigns) || %{}, :vfs_job_runner, job_id)
    Map.put(ctx, :assigns, assigns)
  end
end
