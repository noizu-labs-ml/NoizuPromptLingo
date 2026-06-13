defmodule StarterWeb.HealthControllerTest do
  use StarterWeb.ConnCase

  test "GET /health returns ok", %{conn: conn} do
    conn = get(conn, "/health")
    assert json_response(conn, 200)["status"] == "ok"
  end
end
