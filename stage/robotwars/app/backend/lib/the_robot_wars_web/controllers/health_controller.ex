defmodule TheRobotWarsWeb.HealthController do
  use TheRobotWarsWeb, :controller

  def index(conn, _params) do
    json(conn, %{status: "ok"})
  end
end
