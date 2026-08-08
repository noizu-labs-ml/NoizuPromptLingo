defmodule NoizuPromptLingua.Domains.Memory.Jobs do
  @moduledoc """
  Single indirection for enqueuing the async ingest/recall side-effect workers
  (`EmbeddingWorker`, `LinkJob`, `ReinforcementWorker`).

    * `:oban` (default, prod/dev) — `Oban.insert/1`: durable, queue-processed.
    * `:sync` (tests)            — run the worker's `perform/1` immediately in the **calling
      process**, bypassing Oban's executor.

  Why `:sync` for tests: Oban's executor (even `testing: :inline`) runs jobs with its own
  process/connection handling, which corrupts the Ecto `Sandbox` shared connection under heavy
  job volume. Running `perform/1` directly in the test process keeps every DB write on the test's
  own checked-out connection. Args are JSON round-tripped first so the worker sees the same
  string-keyed map it would receive from a real Oban round-trip.
  """
  require Logger

  @doc "Enqueue (or, in :sync mode, synchronously run) `worker` with `args`."
  @spec enqueue(module(), map()) :: {:ok, term()} | {:error, term()}
  def enqueue(worker, args) when is_atom(worker) and is_map(args) do
    case mode() do
      :sync -> perform_sync(worker, args)
      _ -> args |> worker.new() |> Oban.insert()
    end
  end

  @doc "Current dispatch mode (`:oban` | `:sync`)."
  def mode, do: Application.get_env(:noizu_prompt_lingua, :jobs_mode, :oban)

  defp perform_sync(worker, args) do
    job = %Oban.Job{
      id: System.unique_integer([:positive]),
      args: stringify(args),
      worker: to_string(worker),
      queue: "memory",
      state: "executing",
      attempt: 1,
      max_attempts: 1
    }

    {:ok, worker.perform(job)}
  rescue
    e ->
      Logger.warning("[Memory.Jobs] sync #{inspect(worker)} failed: #{inspect(e)}")
      {:error, e}
  catch
    :exit, reason -> {:error, reason}
  end

  # Mimic Oban's JSON args round-trip so worker `perform/1` matches on string keys.
  defp stringify(args), do: args |> Jason.encode!() |> Jason.decode!()
end
