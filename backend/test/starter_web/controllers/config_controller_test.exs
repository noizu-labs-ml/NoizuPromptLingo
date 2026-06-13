defmodule StarterWeb.ConfigControllerTest do
  use StarterWeb.ConnCase

  test "GET /api/v1/config/features returns feature list", %{conn: conn} do
    conn = get(conn, "/api/v1/config/features")
    response = json_response(conn, 200)

    assert is_list(response["features"])
  end
end
