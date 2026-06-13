defmodule StarterWeb.HealthController do
  use StarterWeb, :controller

  def index(conn, _params) do
    json(conn, %{status: "ok"})
  end
end
