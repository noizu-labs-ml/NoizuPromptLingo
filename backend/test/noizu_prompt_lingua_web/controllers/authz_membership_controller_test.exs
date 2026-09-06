defmodule NoizuPromptLinguaWeb.AuthzMembershipControllerTest do
  @moduledoc """
  Read-plane membership endpoints (PBAC): /memberships/me, the canonical
  org-members list with the effective_role echo, single membership lookup,
  and project members gated by project:view.
  """

  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.Authz.ScopedMemberships

  setup %{conn: conn} do
    %{access_token: token, user: user} = setup_user_and_token()
    auth = authenticated_conn(conn, token)

    slug = "az-org-#{System.unique_integer([:positive])}"

    org_id =
      auth
      |> post("/api/v1/organizations", %{organization: %{slug: slug, name: "AZ Org"}})
      |> json_response(201)
      |> get_in(["organization", "id"])

    # A second org the user is NOT a member of, with its own member row.
    %{user: outsider} = setup_user_and_token()

    other_slug = "az-org2-#{System.unique_integer([:positive])}"

    other_org_id =
      auth
      |> post("/api/v1/organizations", %{organization: %{slug: other_slug, name: "AZ2"}})
      |> json_response(201)
      |> get_in(["organization", "id"])

    {:ok, _} = ScopedMemberships.add_member("organization", other_org_id, outsider.id, "member")

    project_id = Ecto.UUID.generate()

    {:ok,
     auth: auth,
     user: user,
     org_id: org_id,
     other_org_id: other_org_id,
     outsider: outsider,
     project_id: project_id}
  end

  describe "GET /memberships/me" do
    test "lists the caller's memberships", %{auth: auth, org_id: org_id} do
      %{"memberships" => memberships} =
        auth |> get("/api/v1/memberships/me") |> json_response(200)

      assert Enum.any?(memberships, &(&1["resource_id"] == org_id))
    end
  end

  describe "GET /memberships/organizations/:org_id (org_members)" do
    test "member sees org rows with their own effective_role", %{auth: auth, org_id: org_id} do
      %{"members" => members} =
        auth |> get("/api/v1/memberships/organizations/#{org_id}") |> json_response(200)

      assert length(members) >= 1
      assert Enum.all?(members, &(&1["effective_role"] in ["owner", "admin"]))
    end

    test "role facet filters", %{auth: auth, org_id: org_id} do
      %{"members" => members} =
        auth
        |> get("/api/v1/memberships/organizations/#{org_id}", %{role: "owner"})
        |> json_response(200)

      assert Enum.all?(members, &(&1["role"] == "owner"))
    end

    test "non-member -> 403", %{auth: auth, outsider: outsider, org_id: org_id} do
      %{access_token: t} = setup_user_and_token()
      _ = outsider

      assert %{"error" => "Not a member of this organization"} =
               auth
               |> authenticated_conn(t)
               |> get("/api/v1/memberships/organizations/#{org_id}")
               |> json_response(403)
    end
  end

  describe "GET /memberships/organizations/:org_id/members/:id (org_member)" do
    test "member fetches a membership row by id", %{auth: auth, org_id: org_id, user: user} do
      # The creating user already owns an owner row on this org.
      members =
        auth
        |> get("/api/v1/memberships/organizations/#{org_id}")
        |> json_response(200)
        |> Map.fetch!("members")

      row = Enum.find(members, &(&1["member_id"] == user.id))

      body =
        auth
        |> get("/api/v1/memberships/organizations/#{org_id}/members/#{row["id"]}")
        |> json_response(200)
        |> Map.fetch!("member")

      assert body["id"] == row["id"]
      assert body["effective_role"] in ["owner", "admin"]
    end

    test "unknown membership id -> 404; non-member -> 403", %{
      auth: auth,
      org_id: org_id
    } do
      assert %{"error" => "Member not found"} =
               auth
               |> get(
                 "/api/v1/memberships/organizations/#{org_id}/members/#{Ecto.UUID.generate()}"
               )
               |> json_response(404)

      %{access_token: t} = setup_user_and_token()

      assert %{"error" => "Insufficient permissions"} =
               auth
               |> authenticated_conn(t)
               |> get(
                 "/api/v1/memberships/organizations/#{org_id}/members/#{Ecto.UUID.generate()}"
               )
               |> json_response(403)
    end
  end

  describe "GET /memberships/projects/:project_id (project_members)" do
    test "non-member of the project -> 403", %{auth: auth, project_id: pid} do
      assert %{"error" => "Insufficient permissions"} =
               auth
               |> get("/api/v1/memberships/projects/#{pid}")
               |> json_response(403)
    end

    test "project member sees project rows", %{auth: auth, user: user, project_id: pid} do
      {:ok, _} = ScopedMemberships.add_member("project", pid, user.id, "member")

      %{"members" => members} =
        auth |> get("/api/v1/memberships/projects/#{pid}") |> json_response(200)

      assert Enum.any?(
               members,
               &(&1["member_id"] == user.id and &1["resource_type"] == "project")
             )
    end
  end
end
