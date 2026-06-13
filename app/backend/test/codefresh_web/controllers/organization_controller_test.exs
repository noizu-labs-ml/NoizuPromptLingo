defmodule CodefreshWeb.OrganizationControllerTest do
  use CodefreshWeb.ConnCase, async: true
  import Codefresh.Fixtures

  describe "POST /api/v1/organizations (US-039)" do
    test "creates org and grants owner membership to creator", %{conn: conn} do
      user = user_fixture()
      conn = auth_conn(conn, user)

      conn =
        post(conn, ~p"/api/v1/organizations", %{
          "organization" => %{"name" => "Acme Corp", "slug" => "acme-corp"}
        })

      assert %{"organization" => %{"id" => id, "slug" => "acme-corp", "role" => "owner"}} =
               json_response(conn, 201)

      assert is_binary(id)

      # user now lists the org
      index_conn = auth_conn(build_conn(), user) |> get(~p"/api/v1/organizations")

      assert %{"organizations" => [%{"slug" => "acme-corp", "role" => "owner"}]} =
               json_response(index_conn, 200)
    end

    test "auto-derives slug from name when omitted", %{conn: conn} do
      user = user_fixture()
      conn = auth_conn(conn, user)

      conn = post(conn, ~p"/api/v1/organizations", %{"organization" => %{"name" => "My Team!"}})
      assert %{"organization" => %{"slug" => "my-team"}} = json_response(conn, 201)
    end

    test "rejects duplicate slug", %{conn: conn} do
      user = user_fixture()
      _ = org_with_owner(%{slug: "taken", name: "Taken"})
      conn = auth_conn(conn, user)

      conn =
        post(conn, ~p"/api/v1/organizations", %{
          "organization" => %{"name" => "Other", "slug" => "taken"}
        })

      assert %{"errors" => errors} = json_response(conn, 422)
      assert Map.has_key?(errors, "slug")
    end

    test "rejects invalid slug format", %{conn: conn} do
      user = user_fixture()
      conn = auth_conn(conn, user)

      conn =
        post(conn, ~p"/api/v1/organizations", %{
          "organization" => %{"name" => "Bad", "slug" => "NOT VALID"}
        })

      assert %{"errors" => %{"slug" => _}} = json_response(conn, 422)
    end

    test "401 when unauthenticated", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/organizations", %{"organization" => %{"name" => "X"}})
      assert response(conn, 401)
    end
  end

  describe "GET /api/v1/organizations/:id" do
    test "members can view; non-members get 404", %{conn: conn} do
      %{user: owner, organization: org} = org_with_owner(%{slug: "viewtest", name: "View"})
      stranger = user_fixture()

      owner_resp =
        conn |> auth_conn(owner) |> get(~p"/api/v1/organizations/#{org.id}") |> json_response(200)

      assert owner_resp["organization"]["role"] == "owner"

      stranger_conn =
        build_conn() |> auth_conn(stranger) |> get(~p"/api/v1/organizations/#{org.id}")

      assert response(stranger_conn, 404)
    end
  end
end
