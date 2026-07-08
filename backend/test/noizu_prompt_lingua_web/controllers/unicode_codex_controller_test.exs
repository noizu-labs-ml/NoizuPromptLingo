defmodule NoizuPromptLinguaWeb.UnicodeCodexControllerTest do
  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.Domains.UnicodeCodex

  setup %{conn: conn} do
    %{access_token: token} = setup_user_and_token()
    auth_conn = authenticated_conn(conn, token)

    slug = "unicode-rest-org-#{System.unique_integer([:positive])}"

    org =
      auth_conn
      |> post("/api/v1/organizations", %{organization: %{slug: slug, name: "Unicode REST Org"}})
      |> json_response(201)
      |> Map.fetch!("organization")

    {:ok, conn: auth_conn, org_id: org["id"]}
  end

  test "lists and shows scoped Unicode elements", %{conn: conn, org_id: org_id} do
    element_slug = "rest-escape-#{System.unique_integer([:positive])}"

    {:ok, element} =
      UnicodeCodex.upsert_element(%{
        scope: "organization",
        organization_id: org_id,
        slug: element_slug,
        codepoint: "U+001B",
        name: "ESCAPE",
        title: "REST Escape",
        printable: false,
        visibility: "control",
        flags: ["control"]
      })

    assert element.slug == element_slug

    list =
      conn
      |> get("/api/v1/organizations/#{org_id}/unicode/elements?q=#{element_slug}")
      |> json_response(200)

    assert [row] = list["elements"]
    assert row["slug"] == element_slug
    assert row["scope"] == "organization"

    detail =
      conn
      |> get("/api/v1/organizations/#{org_id}/unicode/elements/#{element_slug}")
      |> json_response(200)

    assert detail["element"]["display"] == "<REST Escape>"
    assert "non_printable" in detail["element"]["warnings"]
  end

  test "returns 404 for missing Unicode elements", %{conn: conn, org_id: org_id} do
    conn = get(conn, "/api/v1/organizations/#{org_id}/unicode/elements/does-not-exist")
    assert json_response(conn, 404)["error"] == "Unicode element not found"
  end
end
