defmodule NoizuPromptLinguaWeb.CustomRoleControllerTest do
  @moduledoc """
  PBAC v2 custom roles (/api/v1/organizations/:org_id/roles): viewer-gated
  reads, manage_settings-gated writes, permission add/remove, and the
  404/403 folds (org resolved by slug or UUID before any Authz query).
  """
  use NoizuPromptLinguaWeb.ConnCase

  import Ecto.Query

  alias NoizuPromptLingua.Schema.Organizations.CustomRolePermission

  setup %{conn: conn} do
    %{access_token: token, user: user} = setup_user_and_token()
    auth = authenticated_conn(conn, token)

    {:ok, auth: auth, user: user}
  end

  defp uslug(p), do: "#{p}-#{System.unique_integer([:positive])}"

  defp org!(auth) do
    %{"organization" => %{"id" => id, "slug" => slug}} =
      auth
      |> post("/api/v1/organizations", %{
        organization: %{slug: uslug("roleorg"), name: "Role Org"}
      })
      |> json_response(201)

    %{id: id, slug: slug}
  end

  defp role_attrs do
    n = uslug("role")
    %{name: n, display_name: "Role #{n}", description: "test role"}
  end

  defp create_role!(auth, org) do
    %{"role" => role} =
      auth
      |> post("/api/v1/organizations/#{org.id}/roles", %{role: role_attrs()})
      |> json_response(201)

    role
  end

  # ── index (viewer-gated) ──────────────────────────────────────────────────

  test "index lists the org's active roles", %{auth: auth} do
    org = org!(auth)
    role = create_role!(auth, org)

    %{"roles" => roles} =
      auth |> get("/api/v1/organizations/#{org.id}/roles") |> json_response(200)

    assert Enum.any?(roles, &(&1["id"] == role["id"]))
  end

  test "index resolves the org by slug", %{auth: auth} do
    org = org!(auth)
    create_role!(auth, org)

    %{"roles" => roles} =
      auth |> get("/api/v1/organizations/#{org.slug}/roles") |> json_response(200)

    assert length(roles) >= 1
  end

  test "index unknown org -> 404", %{auth: auth} do
    assert %{"error" => "Organization not found"} =
             auth |> get("/api/v1/organizations/no-such-org-xyz/roles") |> json_response(404)
  end

  test "index non-member -> 403", %{auth: auth} do
    %{access_token: outsider} = setup_user_and_token()
    org = org!(auth)

    assert %{"error" => "Insufficient permissions"} =
             auth
             |> authenticated_conn(outsider)
             |> get("/api/v1/organizations/#{org.id}/roles")
             |> json_response(403)
  end

  # ── create (manage_settings-gated) ────────────────────────────────────────

  test "create makes an active role", %{auth: auth} do
    org = org!(auth)
    attrs = role_attrs()

    %{"role" => role} =
      auth
      |> post("/api/v1/organizations/#{org.id}/roles", %{role: attrs})
      |> json_response(201)

    assert role["name"] == attrs.name
    assert role["display_name"] == attrs.display_name
    assert role["is_active"] == true
  end

  test "create missing display_name -> 422", %{auth: auth} do
    org = org!(auth)

    conn =
      post(auth, "/api/v1/organizations/#{org.id}/roles", %{role: %{name: uslug("bare")}})

    assert json_response(conn, 422) |> Map.has_key?("errors")
  end

  test "create unknown org -> 404; non-member -> 403", %{auth: auth} do
    %{access_token: outsider} = setup_user_and_token()
    org = org!(auth)

    assert %{"error" => "Organization not found"} =
             auth
             |> post("/api/v1/organizations/no-such-org-xyz/roles", %{role: role_attrs()})
             |> json_response(404)

    assert %{"error" => "Insufficient permissions"} =
             auth
             |> authenticated_conn(outsider)
             |> post("/api/v1/organizations/#{org.id}/roles", %{role: role_attrs()})
             |> json_response(403)
  end

  # ── show (viewer-gated) ───────────────────────────────────────────────────

  test "show returns the role with its permission list", %{auth: auth} do
    org = org!(auth)
    role = create_role!(auth, org)

    %{"role" => shown} =
      auth
      |> get("/api/v1/organizations/#{org.id}/roles/#{role["id"]}")
      |> json_response(200)

    assert shown["id"] == role["id"]
    assert shown["permissions"] == []
  end

  test "show unknown role -> 404", %{auth: auth} do
    org = org!(auth)
    missing = Ecto.UUID.generate()

    assert %{"error" => "Role not found"} =
             auth
             |> get("/api/v1/organizations/#{org.id}/roles/#{missing}")
             |> json_response(404)
  end

  test "show unknown org -> 404; non-member -> 403", %{auth: auth} do
    %{access_token: outsider} = setup_user_and_token()
    org = org!(auth)
    role = create_role!(auth, org)

    assert %{"error" => "Organization not found"} =
             auth
             |> get("/api/v1/organizations/no-such-org-xyz/roles/#{role["id"]}")
             |> json_response(404)

    assert %{"error" => "Insufficient permissions"} =
             auth
             |> authenticated_conn(outsider)
             |> get("/api/v1/organizations/#{org.id}/roles/#{role["id"]}")
             |> json_response(403)
  end

  # ── update (manage_settings-gated) ────────────────────────────────────────

  test "update renames the role", %{auth: auth} do
    org = org!(auth)
    role = create_role!(auth, org)

    %{"role" => updated} =
      auth
      |> put("/api/v1/organizations/#{org.id}/roles/#{role["id"]}", %{
        role: %{name: uslug("renamed"), display_name: "Renamed"}
      })
      |> json_response(200)

    assert updated["display_name"] == "Renamed"
  end

  test "update clearing a required field -> 422", %{auth: auth} do
    org = org!(auth)
    role = create_role!(auth, org)

    conn =
      put(auth, "/api/v1/organizations/#{org.id}/roles/#{role["id"]}", %{
        role: %{display_name: nil}
      })

    assert json_response(conn, 422) |> Map.has_key?("errors")
  end

  test "update unknown role -> 404", %{auth: auth} do
    org = org!(auth)
    missing = Ecto.UUID.generate()

    assert %{"error" => "Role not found"} =
             auth
             |> put("/api/v1/organizations/#{org.id}/roles/#{missing}", %{
               role: %{display_name: "X"}
             })
             |> json_response(404)
  end

  test "update unknown org -> 404; non-member -> 403", %{auth: auth} do
    %{access_token: outsider} = setup_user_and_token()
    org = org!(auth)
    role = create_role!(auth, org)

    assert %{"error" => "Organization not found"} =
             auth
             |> put("/api/v1/organizations/no-such-org-xyz/roles/#{role["id"]}", %{
               role: %{display_name: "X"}
             })
             |> json_response(404)

    assert %{"error" => "Insufficient permissions"} =
             auth
             |> authenticated_conn(outsider)
             |> put("/api/v1/organizations/#{org.id}/roles/#{role["id"]}", %{
               role: %{display_name: "X"}
             })
             |> json_response(403)
  end

  # ── delete (deactivate) ───────────────────────────────────────────────────

  test "delete deactivates the role and index stops listing it", %{auth: auth} do
    org = org!(auth)
    role = create_role!(auth, org)

    assert %{"message" => "Role deactivated"} =
             auth
             |> delete("/api/v1/organizations/#{org.id}/roles/#{role["id"]}")
             |> json_response(200)

    %{"roles" => roles} =
      auth |> get("/api/v1/organizations/#{org.id}/roles") |> json_response(200)

    refute Enum.any?(roles, &(&1["id"] == role["id"]))
  end

  test "delete unknown role -> 404", %{auth: auth} do
    org = org!(auth)
    missing = Ecto.UUID.generate()

    assert %{"error" => "Role not found"} =
             auth
             |> delete("/api/v1/organizations/#{org.id}/roles/#{missing}")
             |> json_response(404)
  end

  test "delete unknown org -> 404; non-member -> 403", %{auth: auth} do
    %{access_token: outsider} = setup_user_and_token()
    org = org!(auth)
    role = create_role!(auth, org)

    assert %{"error" => "Organization not found"} =
             auth
             |> delete("/api/v1/organizations/no-such-org-xyz/roles/#{role["id"]}")
             |> json_response(404)

    assert %{"error" => "Insufficient permissions"} =
             auth
             |> authenticated_conn(outsider)
             |> delete("/api/v1/organizations/#{org.id}/roles/#{role["id"]}")
             |> json_response(403)
  end

  # ── permissions ───────────────────────────────────────────────────────────

  test "add_permission grants then remove_permission revokes", %{auth: auth} do
    org = org!(auth)
    role = create_role!(auth, org)
    base = "/api/v1/organizations/#{org.id}/roles/#{role["id"]}/permissions"

    %{"permissions" => perms} =
      auth |> post(base, %{permission: "ticket:read"}) |> json_response(201)

    assert perms == ["ticket:read"]

    perm_id =
      NoizuPromptLingua.Repo.one!(
        from p in CustomRolePermission, where: p.role_id == ^role["id"], select: p.id
      )

    assert %{"message" => "Permission removed"} =
             auth |> delete("#{base}/#{perm_id}") |> json_response(200)

    %{"role" => shown} =
      auth |> get("/api/v1/organizations/#{org.id}/roles/#{role["id"]}") |> json_response(200)

    assert shown["permissions"] == []
  end

  test "add_permission validation failure -> 422", %{auth: auth} do
    org = org!(auth)
    role = create_role!(auth, org)

    conn =
      post(auth, "/api/v1/organizations/#{org.id}/roles/#{role["id"]}/permissions", %{
        permission: nil
      })

    assert json_response(conn, 422) |> Map.has_key?("errors")
  end

  test "remove_permission unknown id -> 404", %{auth: auth} do
    org = org!(auth)
    role = create_role!(auth, org)

    assert %{"error" => "Permission not found"} =
             auth
             |> delete(
               "/api/v1/organizations/#{org.id}/roles/#{role["id"]}/permissions/#{Ecto.UUID.generate()}"
             )
             |> json_response(404)
  end

  test "permission writes unknown org -> 404; non-member -> 403", %{auth: auth} do
    %{access_token: outsider} = setup_user_and_token()
    org = org!(auth)
    role = create_role!(auth, org)

    assert %{"error" => "Organization not found"} =
             auth
             |> post("/api/v1/organizations/no-such-org-xyz/roles/#{role["id"]}/permissions", %{
               permission: "ticket:read"
             })
             |> json_response(404)

    assert %{"error" => "Insufficient permissions"} =
             auth
             |> authenticated_conn(outsider)
             |> post(
               "/api/v1/organizations/#{org.id}/roles/#{role["id"]}/permissions",
               %{permission: "ticket:read"}
             )
             |> json_response(403)
  end
end
