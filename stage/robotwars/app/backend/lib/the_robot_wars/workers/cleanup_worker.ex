defmodule TheRobotWars.Workers.CleanupWorker do
  use Oban.Worker, queue: :cleanup, max_attempts: 1

  import Ecto.Query

  @impl Oban.Worker
  def perform(_job) do
    cutoff = DateTime.utc_now() |> DateTime.add(-30, :day)

    from(s in TheRobotWars.Schema.Users.Sessions.UserSession,
      where: s.inserted_at < ^cutoff
    )
    |> TheRobotWars.Repo.delete_all()

    :ok
  end
end
