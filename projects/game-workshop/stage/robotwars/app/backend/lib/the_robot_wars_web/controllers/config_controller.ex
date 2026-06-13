defmodule TheRobotWarsWeb.ConfigController do
  use TheRobotWarsWeb, :controller

  def features(conn, _params) do
    flags = TheRobotWars.FeatureFlags.all()
    conn |> put_status(:ok) |> json(%{features: flags})
  end
end
