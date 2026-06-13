defmodule CodefreshWeb.InviteControllerTest do
  use CodefreshWeb.ConnCase, async: true
  import Codefresh.Fixtures

  describe "POST /api/v1/organizations/:id/invites (US-040)" do
    test "admin can invite a pending user (returns raw_token once)", %{conn: conn} do
      %{user: owner, organization: org} = org_with_owner()
      conn = auth_conn(conn, owner)

      conn =
        post(conn, ~p"/api/v1/organizations/#{org.id}/invites", %{
          "invite" => %{"email" => "newbie@test.local", "role" => "editor"}
        })

      resp = json_response(conn, 201)
      assert resp["invite"]["email"] == "newbie@test.local"
      assert resp["invite"]["role"] == "editor"
      assert is_binary(resp["raw_token"])
      assert String.length(resp["raw_token"]) > 20
    end

    test "creates membership directly when invitee email already registered", %{conn: conn} do
      %{user: owner, organization: org} = org_with_owner()
      existing = user_fixture(%{"email" => "existing@test.local"})
      conn = auth_conn(conn, owner)

      conn =
        post(conn, ~p"/api/v1/organizations/#{org.id}/invites", %{
          "invite" => %{"email" => "existing@test.local", "role" => "viewer"}
        })

      resp = json_response(conn, 201)
      assert resp["membership"]["user_id"] == existing.id
      assert resp["membership"]["role"] == "viewer"
    end

    test "editor cannot invite (403)", %{conn: conn} do
      %{user: owner, organization: org} = org_with_owner()
      editor = user_fixture()
      membership_fixture(editor, org, "editor")
      conn = auth_conn(conn, editor)
      _ = owner

      conn =
        post(conn, ~p"/api/v1/organizations/#{org.id}/invites", %{
          "invite" => %{"email" => "x@y.com", "role" => "viewer"}
        })

      assert response(conn, 403)
    end

    test "admin cannot grant owner role (only owner can)", %{conn: conn} do
      %{user: owner, organization: org} = org_with_owner()
      admin = user_fixture()
      membership_fixture(admin, org, "admin")
      _ = owner
      conn = auth_conn(conn, admin)

      conn =
        post(conn, ~p"/api/v1/organizations/#{org.id}/invites", %{
          "invite" => %{"email" => "promoted@test.local", "role" => "owner"}
        })

      assert %{"error" => msg} = json_response(conn, 403)
      assert msg =~ "owner"
    end

    test "non-member gets 404 (tenant isolation)", %{conn: conn} do
      %{user: _owner, organization: org} = org_with_owner()
      stranger = user_fixture()
      conn = auth_conn(conn, stranger)

      conn =
        post(conn, ~p"/api/v1/organizations/#{org.id}/invites", %{
          "invite" => %{"email" => "x@y.com", "role" => "viewer"}
        })

      assert response(conn, 404)
    end

    test "rejects duplicate member add", %{conn: conn} do
      %{user: owner, organization: org} = org_with_owner()
      existing = user_fixture(%{"email" => "dup@test.local"})
      membership_fixture(existing, org, "editor")
      conn = auth_conn(conn, owner)

      conn =
        post(conn, ~p"/api/v1/organizations/#{org.id}/invites", %{
          "invite" => %{"email" => "dup@test.local", "role" => "viewer"}
        })

      assert %{"errors" => _} = json_response(conn, 422)
    end
  end

  describe "GET /api/v1/organizations/:id/invites" do
    test "lists active invites for admins", %{conn: conn} do
      %{user: owner, organization: org} = org_with_owner()
      auth = auth_conn(conn, owner)

      post(auth, ~p"/api/v1/organizations/#{org.id}/invites", %{
        "invite" => %{"email" => "a@t.local", "role" => "editor"}
      })

      list_conn =
        auth_conn(build_conn(), owner) |> get(~p"/api/v1/organizations/#{org.id}/invites")

      assert %{"invites" => [%{"email" => "a@t.local"}]} = json_response(list_conn, 200)
    end
  end
end
