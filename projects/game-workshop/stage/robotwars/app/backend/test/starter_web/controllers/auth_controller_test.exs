defmodule TheRobotWarsWeb.AuthControllerTest do
  use TheRobotWarsWeb.ConnCase

  describe "POST /api/v1/auth/login" do
    test "returns tokens on valid credentials", %{conn: conn} do
      %{user: user, password: password} = setup_user_and_token()

      conn = post(conn, "/api/v1/auth/login", %{email: user.email, password: password})
      response = json_response(conn, 200)

      assert response["access_token"]
      assert response["refresh_token"]
      assert response["user"]["email"] == user.email
    end

    test "returns 401 on invalid credentials", %{conn: conn} do
      conn = post(conn, "/api/v1/auth/login", %{email: "nobody@example.com", password: "wrongpassword"})
      assert json_response(conn, 401)["error"]
    end
  end

  describe "POST /api/v1/auth/refresh" do
    test "rotates tokens on valid refresh", %{conn: conn} do
      %{refresh_token: refresh_token} = setup_user_and_token()

      conn = post(conn, "/api/v1/auth/refresh", %{refresh_token: refresh_token})
      response = json_response(conn, 200)

      assert response["access_token"]
      assert response["refresh_token"]
    end

    test "rejects reused refresh token", %{conn: conn} do
      %{refresh_token: refresh_token} = setup_user_and_token()

      # First refresh succeeds
      conn1 = post(conn, "/api/v1/auth/refresh", %{refresh_token: refresh_token})
      assert json_response(conn1, 200)["access_token"]

      # Second refresh with same token fails (JTI was revoked)
      conn2 = post(conn, "/api/v1/auth/refresh", %{refresh_token: refresh_token})
      assert json_response(conn2, 401)["error"]
    end
  end

  describe "GET /api/v1/auth/me" do
    test "returns current user when authenticated", %{conn: conn} do
      %{access_token: token, user: user} = setup_user_and_token()

      conn = conn |> authenticated_conn(token) |> get("/api/v1/auth/me")
      response = json_response(conn, 200)

      assert response["user"]["email"] == user.email
    end

    test "returns 401 without token", %{conn: conn} do
      conn = get(conn, "/api/v1/auth/me")
      assert conn.status == 401
    end
  end

  describe "POST /api/v1/auth/verify-email" do
    test "sends verification email when authenticated", %{conn: conn} do
      %{access_token: token} = setup_user_and_token()

      conn = conn |> authenticated_conn(token) |> post("/api/v1/auth/verify-email")
      response = json_response(conn, 200)

      assert response["message"] =~ "Verification"
    end
  end
end
