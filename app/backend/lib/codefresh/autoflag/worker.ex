defmodule Codefresh.AutoFlag.Worker do
  @moduledoc """
  Oban worker that evaluates every active auto-flagging rule against a
  completed run (US-147). Enqueued from `Codefresh.Runs.Worker` after the run
  transitions into a terminal state (`passed | warned | failed | errored`).

  Runs on the `:default` queue. In `:test` Oban is configured as
  `testing: :manual` so jobs must be drained explicitly. Tests generally
  invoke `Codefresh.AutoFlag.eval_rules_against_run/1` directly.
  """

  use Oban.Worker, queue: :default, max_attempts: 3

  alias Codefresh.AutoFlag

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"run_id" => run_id}}) when is_binary(run_id) do
    case AutoFlag.eval_rules_against_run(run_id) do
      {:ok, _summary} -> :ok
      {:error, :run_not_found} -> {:discard, :run_not_found}
      {:error, reason} -> {:error, reason}
    end
  end
end
