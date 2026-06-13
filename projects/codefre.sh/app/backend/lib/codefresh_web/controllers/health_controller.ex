defmodule CodefreshWeb.HealthController do
  use CodefreshWeb, :controller

  def index(conn, _params) do
    json(conn, %{status: "ok"})
  end
end
