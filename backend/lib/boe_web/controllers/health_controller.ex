defmodule BoeWeb.HealthController do
  use BoeWeb, :controller

  def index(conn, _params) do
    json(conn, %{status: "ok"})
  end
end
