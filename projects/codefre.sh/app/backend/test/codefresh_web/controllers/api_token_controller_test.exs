defmodule CodefreshWeb.ApiTokenControllerTest do
  use CodefreshWeb.ConnCase, async: true
  import Codefresh.Fixtures

  alias Codefresh.ApiTokens

  describe "POST /api/v1/organizations/:id/api-tokens (US-096)" do
    test "admin creates token; raw_token shown once", %{conn: conn} do
      %{user: owner, organization: org} = org_with_owner()
      conn = auth_conn(conn, owner)

      conn =
        post(conn, ~p"/api/v1/organizations/#{org.id}/api-tokens", %{
          "token" => %{"name" => "ci-main", "role" => "ci"}
        })

      resp = json_response(conn, 201)
      assert resp["token"]["name"] == "ci-main"
      assert resp["token"]["role"] == "ci"
      assert is_binary(resp["token"]["key_prefix"])
      assert String.length(resp["raw_token"]) > 20
      refute Map.has_key?(resp["token"], "token_hash")
    end

    test "token authenticates via ApiTokens.authenticate/1", %{conn: conn} do
      %{user: owner, organization: org} = org_with_owner()
      conn = auth_conn(conn, owner)

      conn =
        post(conn, ~p"/api/v1/organizations/#{org.id}/api-tokens", %{
          "token" => %{"name" => "sdk-1", "role" => "editor"}
        })

      raw = json_response(conn, 201)["raw_token"]
      assert {:ok, token} = ApiTokens.authenticate(raw)
      assert token.name == "sdk-1"
      refute is_nil(token.last_used_at)
    end

    test "rejects invalid role", %{conn: conn} do
      %{user: owner, organization: org} = org_with_owner()
      conn = auth_conn(conn, owner)

      conn =
        post(conn, ~p"/api/v1/organizations/#{org.id}/api-tokens", %{
          "token" => %{"name" => "bad", "role" => "owner"}
        })

      assert %{"errors" => %{"role" => _}} = json_response(conn, 422)
    end

    test "editor cannot create token (403)", %{conn: conn} do
      %{user: _owner, organization: org} = org_with_owner()
      editor = user_fixture()
      membership_fixture(editor, org, "editor")
      conn = auth_conn(conn, editor)

      conn =
        post(conn, ~p"/api/v1/organizations/#{org.id}/api-tokens", %{
          "token" => %{"name" => "x", "role" => "editor"}
        })

      assert response(conn, 403)
    end

    test "duplicate name in same org rejected", %{conn: conn} do
      %{user: owner, organization: org} = org_with_owner()
      {_t, _raw} = api_token_fixture(org, owner, %{name: "shared"})
      conn = auth_conn(conn, owner)

      conn =
        post(conn, ~p"/api/v1/organizations/#{org.id}/api-tokens", %{
          "token" => %{"name" => "shared", "role" => "editor"}
        })

      assert %{"errors" => _} = json_response(conn, 422)
    end
  end

  describe "POST /api/v1/organizations/:id/api-tokens/:id/revoke (US-097)" do
    test "revokes token and subsequent auth fails", %{conn: conn} do
      %{user: owner, organization: org} = org_with_owner()
      {token, raw} = api_token_fixture(org, owner)

      assert {:ok, _} = ApiTokens.authenticate(raw)

      conn =
        conn
        |> auth_conn(owner)
        |> post(~p"/api/v1/organizations/#{org.id}/api-tokens/#{token.id}/revoke")

      assert %{"token" => %{"revoked_at" => ra}} = json_response(conn, 200)
      refute is_nil(ra)

      assert {:error, :invalid_token} = ApiTokens.authenticate(raw)
    end
  end

  describe "POST /api/v1/organizations/:id/api-tokens/:id/rotate (US-097)" do
    test "rotation revokes old and issues new with same logical name", %{conn: conn} do
      %{user: owner, organization: org} = org_with_owner()
      {token, raw_old} = api_token_fixture(org, owner, %{name: "rotating", role: "editor"})

      conn =
        conn
        |> auth_conn(owner)
        |> post(~p"/api/v1/organizations/#{org.id}/api-tokens/#{token.id}/rotate")

      resp = json_response(conn, 201)
      assert resp["token"]["name"] == "rotating"
      assert resp["token"]["role"] == "editor"
      raw_new = resp["raw_token"]

      assert raw_new != raw_old
      assert {:error, :invalid_token} = ApiTokens.authenticate(raw_old)
      assert {:ok, _} = ApiTokens.authenticate(raw_new)
    end
  end

  describe "GET /api/v1/organizations/:id/api-tokens" do
    test "lists tokens; never exposes hash", %{conn: conn} do
      %{user: owner, organization: org} = org_with_owner()
      {_t1, _} = api_token_fixture(org, owner, %{name: "a"})
      {_t2, _} = api_token_fixture(org, owner, %{name: "b"})

      conn =
        conn
        |> auth_conn(owner)
        |> get(~p"/api/v1/organizations/#{org.id}/api-tokens")

      %{"tokens" => tokens} = json_response(conn, 200)
      assert length(tokens) == 2
      assert Enum.all?(tokens, fn t -> not Map.has_key?(t, "token_hash") end)
    end

    test "cross-org isolation: member of org A cannot see org B tokens", %{conn: conn} do
      %{user: _owner_a, organization: org_a} = org_with_owner()
      %{user: owner_b, organization: _org_b} = org_with_owner()
      conn = auth_conn(conn, owner_b)

      resp = get(conn, ~p"/api/v1/organizations/#{org_a.id}/api-tokens")
      assert response(resp, 404)
    end
  end
end
