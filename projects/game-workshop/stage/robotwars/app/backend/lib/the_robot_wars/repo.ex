defmodule TheRobotWars.Repo do
  use Ecto.Repo,
    otp_app: :the_robot_wars,
    adapter: Ecto.Adapters.Postgres
end
