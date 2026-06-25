defmodule NoizuPromptLinguaWeb.EffectiveRoleEchoTest do
  @moduledoc """
  ADR-015 affordance echo (16dc3df2): list serializers carry the CALLER's effective_role
  per row so the FE can gate per-row actions (advisory only — the RBAC guard is the
  deny-closed boundary). Covers the organizations list + the org members list.
  """
  use NoizuPromptLinguaWeb.ConnCase

  setup %{conn: conn} do
    %{access_token: token} = setup_user_and_token()
    auth_conn = authenticated_conn(conn, token)

    slug = "erole-org-#{System.unique_integer([:positive])}"
    created = post(auth_conn, "/api/v1/organizations", %{organization: %{slug: slug, name: "ERole Org"}})
    org_id = json_response(created, 201)["organization"]["id"]

    {:ok, conn: auth_conn, org_id: org_id, slug: slug}
  end

  test "organizations list echoes the caller's effective_role per org", %{conn: conn, org_id: org_id} do
    orgs = json_response(get(conn, "/api/v1/organizations"), 200)["organizations"]
    mine = Enum.find(orgs, &(&1["id"] == org_id))

    # creator is the owner of the org they just created
    assert mine["effective_role"] == "owner"
    assert mine["role"] == "owner"
  end

  test "members list echoes the CALLER's effective_role on each member row", %{conn: conn, org_id: org_id} do
    members = json_response(get(conn, "/api/v1/organizations/#{org_id}/members"), 200)["members"]

    assert members != []
    # the caller (owner) sees effective_role 'owner' on every row, alongside each
    # member's own (target) role — so the FE can do caller-rank vs target-rank gating.
    assert Enum.all?(members, &(&1["effective_role"] == "owner"))
    assert Enum.all?(members, &Map.has_key?(&1, "role"))
  end
end
