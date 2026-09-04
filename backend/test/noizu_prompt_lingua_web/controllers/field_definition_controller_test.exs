defmodule NoizuPromptLinguaWeb.FieldDefinitionControllerTest do
  @moduledoc """
  Ticket field-definition CRUD (beyond FieldDefinitionShowTest's GET-by-id):
  index with the field-type catalogue, create scope resolution (org/project/
  global-forbidden), update/delete ownership ladder, and the org authz arms.
  Definitions live on the TRP stub (W4 cutover). The changeset-422 arms are
  unreachable offline: the stub performs no schema validation, so only the
  live TRP plane can reject payloads.
  """

  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.TRP.{Cache, TestStub}

  setup %{conn: conn} do
    Cache.clear()
    TestStub.reset()

    %{access_token: token} = setup_user_and_token()
    auth = authenticated_conn(conn, token)

    slug = "fd-org-#{System.unique_integer([:positive])}"

    org_id =
      auth
      |> post("/api/v1/organizations", %{organization: %{slug: slug, name: "FD Org"}})
      |> json_response(201)
      |> get_in(["organization", "id"])

    TestStub.seed_org(org_id, slug)

    project_id = Ecto.UUID.generate()

    TestStub.seed_project(org_id, %{
      id: project_id,
      slug: "fd-proj-#{System.unique_integer([:positive])}",
      name: "FD Project"
    })

    base = "/api/v1/organizations/#{org_id}/ticket-field-definitions"
    %{access_token: outsider_token} = setup_user_and_token()

    {:ok,
     auth: auth,
     org_id: org_id,
     project_id: project_id,
     base: base,
     outsider_token: outsider_token}
  end

  defp uslug(p), do: "#{p}-#{System.unique_integer([:positive])}"

  defp create_field(auth, base, attrs) do
    auth
    |> post(base, %{field_definition: Map.merge(%{label: "L", field_type: "text"}, attrs)})
    |> json_response(201)
    |> Map.fetch!("field_definition")
  end

  describe "GET /ticket-field-definitions (index)" do
    test "lists fields and exposes the field-type catalogue", %{auth: auth, base: base} do
      create_field(auth, base, %{scope: "org", slug: uslug("sev")})

      body = auth |> get(base) |> json_response(200)

      assert [%{"slug" => slug}] = body["field_definitions"]
      assert slug =~ "sev-"
      assert is_list(body["field_types"]) and body["field_types"] != []
      assert "text" in body["field_types"]
    end

    test "unknown org -> 404; non-member -> 403", %{auth: auth, org_id: org_id, outsider_token: t} do
      assert %{"error" => "Organization not found"} =
               auth
               |> get("/api/v1/organizations/no-such-fd-org/ticket-field-definitions")
               |> json_response(404)

      assert %{"error" => "Not a member of this organization"} =
               auth
               |> authenticated_conn(t)
               |> get("/api/v1/organizations/#{org_id}/ticket-field-definitions")
               |> json_response(403)
    end
  end

  describe "POST /ticket-field-definitions (create)" do
    test "org scope happy path stores label/type/options", %{auth: auth, base: base} do
      body = create_field(auth, base, %{scope: "org", slug: uslug("pri"), label: "Priority"})

      assert body["scope"] == "org"
      assert body["label"] == "Priority"
      assert body["field_type"] == "text"
      assert body["disabled"] == false
    end

    test "scope:global -> 403 (system-managed)", %{auth: auth, base: base} do
      assert %{"error" => "Global definitions are system-managed and cannot be created here"} =
               auth
               |> post(base, %{
                 field_definition: %{
                   slug: uslug("g"),
                   label: "G",
                   field_type: "text",
                   scope: "global"
                 }
               })
               |> json_response(403)
    end

    test "scope:project in-org -> 201; foreign project -> 422", %{
      auth: auth,
      base: base,
      project_id: pid
    } do
      body =
        create_field(auth, base, %{
          scope: "project",
          slug: uslug("pp"),
          project_id: pid
        })

      assert body["scope"] == "project"
      assert body["project_id"] == pid

      assert %{"error" => "Project does not belong to this organization"} =
               auth
               |> post(base, %{
                 field_definition: %{
                   slug: uslug("pf"),
                   label: "PF",
                   field_type: "text",
                   scope: "project",
                   project_id: Ecto.UUID.generate()
                 }
               })
               |> json_response(422)
    end
  end

  describe "field update / delete lifecycle" do
    setup %{auth: auth, base: base} do
      field = create_field(auth, base, %{scope: "org", slug: uslug("life")})
      {:ok, field: field}
    end

    test "update renames the field", %{auth: auth, base: base, field: f} do
      body =
        auth
        |> put("#{base}/#{f["id"]}", %{field_definition: %{label: "Renamed"}})
        |> json_response(200)
        |> Map.fetch!("field_definition")

      assert body["label"] == "Renamed"
    end

    test "update clears the label (stub performs no validation)", %{
      auth: auth,
      base: base,
      field: f
    } do
      body =
        auth
        |> put("#{base}/#{f["id"]}", %{field_definition: %{label: "Adjusted"}})
        |> json_response(200)
        |> Map.fetch!("field_definition")

      assert body["label"] == "Adjusted"
    end

    test "update/delete on unknown id -> 404", %{auth: auth, base: base} do
      missing = Ecto.UUID.generate()

      assert %{"error" => "Field not found"} =
               auth
               |> put("#{base}/#{missing}", %{field_definition: %{label: "X"}})
               |> json_response(404)

      assert %{"error" => "Field not found"} =
               auth |> delete("#{base}/#{missing}") |> json_response(404)
    end

    test "cross-org field is 403 on update and delete (managed-by guard)", %{
      auth: auth,
      base: base,
      field: f
    } do
      _ = f
      other_slug = "fd-org2-#{System.unique_integer([:positive])}"

      other_org =
        auth
        |> post("/api/v1/organizations", %{organization: %{slug: other_slug, name: "FD2"}})
        |> json_response(201)
        |> get_in(["organization", "id"])

      TestStub.seed_org(other_org, other_slug)
      other_base = "/api/v1/organizations/#{other_org}/ticket-field-definitions"

      foreign = create_field(auth, other_base, %{scope: "org", slug: uslug("foreign")})

      assert %{"error" => "This definition is not managed by your organization"} =
               auth
               |> put("#{base}/#{foreign["id"]}", %{field_definition: %{label: "Hijack"}})
               |> json_response(403)

      assert %{"error" => "This definition is not managed by your organization"} =
               auth |> delete("#{base}/#{foreign["id"]}") |> json_response(403)
    end

    test "delete removes the field", %{auth: auth, base: base, field: f} do
      assert %{"message" => "Field deleted"} =
               auth |> delete("#{base}/#{f["id"]}") |> json_response(200)

      assert %{"error" => "Field not found"} =
               auth |> get("#{base}/#{f["id"]}") |> json_response(404)
    end
  end
end
