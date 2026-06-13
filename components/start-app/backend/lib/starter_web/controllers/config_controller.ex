defmodule StarterWeb.ConfigController do
  use StarterWeb, :controller

  def features(conn, _params) do
    flags = Starter.FeatureFlags.all()
    conn |> put_status(:ok) |> json(%{features: flags})
  end
end
