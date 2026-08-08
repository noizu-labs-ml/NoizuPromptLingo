defmodule NoizuPromptLinguaWeb.FieldDefinitionShowTest do
  @moduledoc """
  Ticket field-definition GET-by-id (ticket f73f4cd2). Mirrors the type-def show
  contract: fetch a single field by id under viewer role, with an org/global
  visibility guard — a field owned by another org returns 404 (no cross-org
  existence leak).
  """
  use NoizuPromptLinguaWeb.ConnCase

  setup %{conn: conn} do
    %{access_token: token} = setup_user_and_token()
    auth = authenticated_conn(conn, token)

    created =
      post(auth, "/api/v1/organizations", %{
        organization: %{slug: "fd-org-#{System.unique_integer([:positive])}", name: "FD Org"}
      })

    org_id = json_response(created, 201)["organization"]["id"]

    field =
      post(auth, "/api/v1/organizations/#{org_id}/ticket-field-definitions", %{
        field_definition: %{
          scope: "org",
          slug: "severity-#{System.unique_integer([:positive])}",
          label: "Severity",
          field_type: "text"
        }
      })
      |> json_response(201)
      |> Map.fetch!("field_definition")

    {:ok, conn: auth, org_id: org_id, field: field}
  end

  defp path(org_id, id), do: "/api/v1/organizations/#{org_id}/ticket-field-definitions/#{id}"

  describe "GET /ticket-field-definitions/:id" do
    test "returns the org-owned field by id", %{conn: conn, org_id: org_id, field: f} do
      body =
        conn |> get(path(org_id, f["id"])) |> json_response(200) |> Map.fetch!("field_definition")

      assert body["id"] == f["id"]
      assert body["slug"] == f["slug"]
      assert body["label"] == "Severity"
      assert body["scope"] == "org"
    end

    test "404 for a field owned by another org (no cross-org leak)", %{conn: conn, org_id: org_id} do
      other =
        post(conn, "/api/v1/organizations", %{
          organization: %{slug: "fd-org2-#{System.unique_integer([:positive])}", name: "Other"}
        })

      other_org_id = json_response(other, 201)["organization"]["id"]

      other_field =
        post(conn, "/api/v1/organizations/#{other_org_id}/ticket-field-definitions", %{
          field_definition: %{
            scope: "org",
            slug: "other-#{System.unique_integer([:positive])}",
            label: "Other",
            field_type: "text"
          }
        })
        |> json_response(201)
        |> Map.fetch!("field_definition")

      # requested under org_id's path but owned by other_org_id -> 404
      assert conn |> get(path(org_id, other_field["id"])) |> json_response(404)
    end

    test "404 when the field does not exist", %{conn: conn, org_id: org_id} do
      assert conn |> get(path(org_id, Ecto.UUID.generate())) |> json_response(404)
    end
  end
end
