defmodule TheRobotWarsWeb.OrganizationControllerTest do
  use TheRobotWarsWeb.ConnCase

  describe "organizations" do
    test "create and list organizations", %{conn: conn} do
      %{access_token: token} = setup_user_and_token()
      auth_conn = authenticated_conn(conn, token)

      # Create org
      slug = "test-org-#{System.unique_integer([:positive])}"

      conn1 =
        post(auth_conn, "/api/v1/organizations", %{
          organization: %{slug: slug, name: "Test Org"}
        })

      assert json_response(conn1, 201)["organization"]["name"] == "Test Org"

      # List orgs
      conn2 = get(auth_conn, "/api/v1/organizations")
      orgs = json_response(conn2, 200)["organizations"]
      assert length(orgs) >= 1
    end
  end
end
