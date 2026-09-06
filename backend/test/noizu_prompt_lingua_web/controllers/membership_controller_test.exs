defmodule NoizuPromptLinguaWeb.MembershipControllerTest do
  @moduledoc """
  Org member management (PBAC scoped_memberships rows): index with the
  caller's effective_role echo, create by EMAIL (top-level email/role body —
  the api-probe contract), role update, removal with the sole-owner guard,
  and the not-found/conflict/invalid-role arms. Route gated by :org_admin —
  the creating owner passes the pipeline.
  """

  use NoizuPromptLinguaWeb.ConnCase

  setup %{conn: conn} do
    %{access_token: token, user: owner} = setup_user_and_token()
    auth = authenticated_conn(conn, token)

    slug = "mem-org-#{System.unique_integer([:positive])}"

    org_id =
      auth
      |> post("/api/v1/organizations", %{organization: %{slug: slug, name: "Mem Org"}})
      |> json_response(201)
      |> get_in(["organization", "id"])

    # A second user to invite (lookup is by email).
    %{user: invitee} = setup_user_and_token()

    base = "/api/v1/organizations/#{org_id}/members"

    {:ok, auth: auth, owner: owner, invitee: invitee, org_id: org_id, base: base}
  end

  describe "GET /members (index)" do
    test "lists members with the caller's effective_role echoed", %{auth: auth, base: base} do
      %{"members" => members} = auth |> get(base) |> json_response(200)

      assert length(members) >= 1
      assert Enum.any?(members, &(&1["effective_role"] in ["owner", "admin"]))

      owner_row = Enum.find(members, &(&1["member_type"] == "user"))
      assert owner_row["resource_type"] == "organization"
    end

    test "role facet filters rows", %{auth: auth, base: base, invitee: invitee, org_id: org_id} do
      _ =
        auth
        |> post(base, %{email: invitee.email, role: "viewer"})
        |> json_response(201)

      %{"members" => viewers} =
        auth |> get(base, %{role: "viewer"}) |> json_response(200)

      assert Enum.all?(viewers, &(&1["role"] == "viewer"))
      assert length(viewers) >= 1
      _ = org_id
    end
  end

  describe "POST /members (create by email)" do
    test "invites an existing user by email (top-level body)", %{
      auth: auth,
      base: base,
      invitee: invitee
    } do
      conn = post(auth, base, %{email: invitee.email, role: "member"})

      assert %{"members" => members} = json_response(conn, 201)
      assert Enum.any?(members, &(&1["member_id"] == invitee.id and &1["role"] == "member"))
    end

    test "unknown email -> 404", %{auth: auth, base: base} do
      assert %{"error" => "User not found"} =
               auth
               |> post(base, %{email: "ghost-#{System.unique_integer([:positive])}@example.com"})
               |> json_response(404)
    end

    test "duplicate membership -> 409", %{auth: auth, base: base, invitee: invitee} do
      auth |> post(base, %{email: invitee.email, role: "viewer"}) |> json_response(201)

      assert %{"error" => "User is already a member"} =
               auth
               |> post(base, %{email: invitee.email, role: "member"})
               |> json_response(409)
    end

    test "invalid role -> 400", %{auth: auth, base: base, invitee: invitee} do
      assert %{"error" => "Invalid role"} =
               auth
               |> post(base, %{email: invitee.email, role: "emperor"})
               |> json_response(400)
    end
  end

  describe "member show / update / delete" do
    setup %{auth: auth, base: base, invitee: invitee} do
      %{"members" => members} =
        auth
        |> post(base, %{email: invitee.email, role: "viewer"})
        |> json_response(201)

      row = Enum.find(members, &(&1["member_id"] == invitee.id))

      {:ok, row: row}
    end

    test "show returns one membership with effective_role", %{
      auth: auth,
      org_id: org_id,
      row: row
    } do
      body =
        auth
        |> get("/api/v1/organizations/#{org_id}/members/#{row["id"]}")
        |> json_response(200)
        |> Map.fetch!("member")

      assert body["id"] == row["id"]
      assert body["member_id"] == row["member_id"]
      assert body["effective_role"] in ["owner", "admin"]
    end

    test "show for a foreign membership id -> 404", %{auth: auth, org_id: org_id} do
      assert %{"error" => "Member not found"} =
               auth
               |> get("/api/v1/organizations/#{org_id}/members/#{Ecto.UUID.generate()}")
               |> json_response(404)
    end

    test "update promotes the member's role (top-level role body)", %{
      auth: auth,
      base: base,
      org_id: org_id,
      invitee: invitee,
      row: row
    } do
      %{"members" => members} =
        auth
        |> put("#{base}/#{row["member_id"]}", %{role: "member"})
        |> json_response(200)

      updated = Enum.find(members, &(&1["member_id"] == invitee.id))
      assert updated["role"] == "member"

      # unknown member id -> 404
      assert %{"error" => "Member not found"} =
               auth
               |> put("#{base}/#{Ecto.UUID.generate()}", %{role: "member"})
               |> json_response(404)

      _ = org_id
    end

    test "delete removes the member; the owner cannot be removed", %{
      auth: auth,
      base: base,
      org_id: org_id,
      owner: owner,
      row: row
    } do
      assert %{"message" => "Member removed"} =
               auth |> delete("#{base}/#{row["member_id"]}") |> json_response(200)

      assert %{"error" => "Member not found"} =
               auth |> delete("#{base}/#{row["member_id"]}") |> json_response(404)

      # The creating owner is the sole owner — removing them is forbidden.
      assert %{"error" => "Cannot remove the owner"} =
               auth |> delete("#{base}/#{owner.id}") |> json_response(403)

      _ = org_id
    end
  end
end
