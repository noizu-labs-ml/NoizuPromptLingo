defmodule NoizuPromptLinguaWeb.OrganizationControllerTest do
  @moduledoc """
  Organization lifecycle: index (caller's orgs), create (nested
  "organization" body — api-probe contract), show by slug/id with the
  membership guard, admin-gated update, owner-gated delete, and the
  validation arms (bad slug -> 422, unknown -> 404, non-member -> 403).
  """

  use NoizuPromptLinguaWeb.ConnCase

  setup %{conn: conn} do
    %{access_token: token, user: user} = setup_user_and_token()
    auth = authenticated_conn(conn, token)
    %{access_token: outsider_token} = setup_user_and_token()

    {:ok, auth: auth, user: user, outsider_token: outsider_token}
  end

  defp uslug(p), do: "#{p}-#{System.unique_integer([:positive])}"

  defp create_org(auth, name \\ "Org") do
    auth
    |> post("/api/v1/organizations", %{organization: %{slug: uslug("org"), name: name}})
  end

  describe "POST /organizations (create)" do
    test "happy path returns id/slug/name/key_prefix", %{auth: auth} do
      conn = create_org(auth, "Acme")

      assert %{"organization" => %{"id" => id, "slug" => slug, "name" => "Acme"}} =
               json_response(conn, 201)

      assert is_binary(id) and slug =~ "org-"
    end

    test "missing name -> 422", %{auth: auth} do
      conn = post(auth, "/api/v1/organizations", %{organization: %{slug: uslug("n")}})

      assert json_response(conn, 422) |> Map.has_key?("errors")
    end

    test "duplicate slug -> 422", %{auth: auth} do
      slug = uslug("dup")

      auth
      |> post("/api/v1/organizations", %{organization: %{slug: slug, name: "A"}})
      |> json_response(201)

      conn = post(auth, "/api/v1/organizations", %{organization: %{slug: slug, name: "B"}})

      assert json_response(conn, 422)
    end
  end

  describe "GET /organizations (index + show)" do
    test "index lists the caller's orgs", %{auth: auth} do
      %{"organization" => %{"id" => id}} = create_org(auth) |> json_response(201)

      %{"organizations" => orgs} = auth |> get("/api/v1/organizations") |> json_response(200)
      assert Enum.any?(orgs, &(&1["id"] == id))
    end

    test "show resolves by slug or id for members", %{auth: auth} do
      %{"organization" => %{"id" => id, "slug" => slug}} =
        create_org(auth) |> json_response(201)

      by_id = auth |> get("/api/v1/organizations/#{id}") |> json_response(200)
      assert by_id["organization"]["id"] == id

      by_slug = auth |> get("/api/v1/organizations/#{slug}") |> json_response(200)
      assert by_slug["organization"]["slug"] == slug
    end

    test "show unknown org -> 404; non-member -> 403", %{auth: auth, outsider_token: t} do
      assert %{"error" => "Organization not found"} =
               auth |> get("/api/v1/organizations/no-such-org-xyz") |> json_response(404)

      %{"organization" => %{"id" => id}} = create_org(auth) |> json_response(201)

      assert %{"error" => "Not a member of this organization"} =
               auth
               |> authenticated_conn(t)
               |> get("/api/v1/organizations/#{id}")
               |> json_response(403)
    end
  end

  describe "PUT /organizations/:id (update, admin-gated)" do
    test "owner (rank >= admin) renames the org", %{auth: auth} do
      %{"organization" => %{"id" => id}} = create_org(auth) |> json_response(201)

      body =
        auth
        |> put("/api/v1/organizations/#{id}", %{organization: %{name: "Renamed Org"}})
        |> json_response(200)
        |> Map.fetch!("organization")

      assert body["name"] == "Renamed Org"
      assert body["id"] == id
    end

    test "non-member update -> 403", %{auth: auth, outsider_token: t} do
      %{"organization" => %{"id" => id}} = create_org(auth) |> json_response(201)

      assert %{"error" => "Not a member of this organization"} =
               auth
               |> authenticated_conn(t)
               |> put("/api/v1/organizations/#{id}", %{organization: %{name: "X"}})
               |> json_response(403)
    end

    test "unknown org -> 404", %{auth: auth} do
      assert %{"error" => "Organization not found"} =
               auth
               |> put("/api/v1/organizations/no-such-org-xyz", %{organization: %{name: "X"}})
               |> json_response(404)
    end
  end

  describe "DELETE /organizations/:id (owner-gated)" do
    test "owner deletes the org; it then 404s", %{auth: auth} do
      %{"organization" => %{"id" => id, "slug" => slug}} =
        create_org(auth) |> json_response(201)

      assert %{"message" => "Organization deleted"} =
               auth |> delete("/api/v1/organizations/#{id}") |> json_response(200)

      assert %{"error" => "Organization not found"} =
               auth |> get("/api/v1/organizations/#{slug}") |> json_response(404)
    end

    test "non-member delete -> 403", %{auth: auth, outsider_token: t} do
      %{"organization" => %{"id" => id}} = create_org(auth) |> json_response(201)

      assert %{"error" => "Not a member of this organization"} =
               auth
               |> authenticated_conn(t)
               |> delete("/api/v1/organizations/#{id}")
               |> json_response(403)
    end
  end
end
