defmodule DerobotWeb.HealthController do
  use DerobotWeb, :controller

  def index(conn, _params) do
    json(conn, %{status: "ok"})
  end
end
