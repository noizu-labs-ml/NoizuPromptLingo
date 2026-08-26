defmodule NoizuPromptLingua.Workers.SessionInactivityWorker do
  @moduledoc """
  Hourly sweep flipping work sessions `active` → `inactive` when no activity
  has been recorded for the configured window.

  Cutoff: `coalesce(last_activity_at, updated_at)` — rows that predate the
  `last_activity_at` column (Liquibase 079 backfills them, but belt+suspenders)
  fall back to `updated_at`. See `NoizuPromptLingua.Sessions` @moduledoc for
  what counts as an event.

  Config: `:noizu_prompt_lingua, :session_inactivity_hours` (env
  `NPL_SESSION_INACTIVITY_HOURS`, default 24), read at perform time so a
  config change redeploys nothing. `nil` or `0` disables the sweep (no-op).
  """

  use Oban.Worker, queue: :cleanup, max_attempts: 1

  import Ecto.Query
  require Logger

  @impl Oban.Worker
  def perform(_job) do
    case inactivity_hours() do
      hours when is_number(hours) and hours > 0 ->
        sweep(hours)

      _ ->
        Logger.info("[SessionInactivityWorker] session_inactivity_hours unset or 0 — skipping")
        :ok
    end
  end

  defp sweep(hours) do
    cutoff = DateTime.utc_now() |> DateTime.add(-round(hours * 3600), :second)

    {count, _} =
      from(s in NoizuPromptLingua.Schema.Sessions.Session,
        where: s.status == "active",
        where: fragment("coalesce(?, ?) < ?", s.last_activity_at, s.updated_at, ^cutoff)
      )
      |> NoizuPromptLingua.Repo.update_all(set: [status: "inactive"])

    if count > 0, do: Logger.info("[SessionInactivityWorker] marked #{count} session(s) inactive")

    :ok
  end

  defp inactivity_hours do
    Application.get_env(:noizu_prompt_lingua, :session_inactivity_hours, 24)
  end
end
