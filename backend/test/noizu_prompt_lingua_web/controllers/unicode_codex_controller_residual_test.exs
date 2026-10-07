defmodule NoizuPromptLinguaWeb.UnicodeCodexControllerResidualTest do
  @moduledoc """
  Residual arms of the unicode codex REST surface (complements
  unicode_codex_controller_test.exs): relations, special-usage index/show,
  and every with_scope fold (org 404, project 404/422, non-member 403).
  """
  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.Domains.UnicodeCodex
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Organizations.Organization
  alias NoizuPromptLingua.Schema.Projects.Project

  setup %{conn: conn} do
    %{access_token: token, user: user} = setup_user_and_token()
    auth = authenticated_conn(conn, token)
    %{access_token: outsider_token} = setup_user_and_token()

    suffix = System.unique_integer([:positive])

    # Created through the API so the caller gets an owner membership
    # (the unicode routes are viewer-gated).
    %{"organization" => %{"id" => org_id, "slug" => org_slug}} =
      auth
      |> post("/api/v1/organizations", %{
        organization: %{slug: "ucx-org-#{suffix}", name: "UCX Org #{suffix}"}
      })
      |> json_response(201)

    {:ok,
     auth: auth,
     user: user,
     outsider_token: outsider_token,
     org: %{id: org_id, slug: org_slug},
     suffix: suffix}
  end

  defp base(org, path), do: "/api/v1/organizations/#{org.id}/unicode/#{path}"

  # ── relations ─────────────────────────────────────────────────────────────

  test "relations returns the relation map for an element", %{auth: auth, org: org} do
    slug = "ucx-rel-#{System.unique_integer([:positive])}"

    {:ok, element} =
      UnicodeCodex.upsert_element(%{
        scope: "organization",
        organization_id: org.id,
        slug: slug,
        codepoint: "U+231C",
        char: "⌜",
        name: "TOP LEFT CORNER",
        title: "Rel Corner"
      })

    UnicodeCodex.replace_element_relations(element, [], org.id, nil)

    assert conn = auth |> get(base(org, "elements/#{slug}/relations")) |> json_response(200)
    assert is_map(conn)
  end

  test "relations for an unknown slug → 404", %{auth: auth, org: org} do
    assert %{"error" => "Unicode element not found"} =
             auth |> get(base(org, "elements/no-such-ucx/relations")) |> json_response(404)
  end

  # ── special usages ────────────────────────────────────────────────────────

  test "special-usage index and show", %{auth: auth, org: org} do
    uslug = "ucx-usage-#{System.unique_integer([:positive])}"

    {:ok, _} =
      UnicodeCodex.upsert_special_usage(%{
        scope: "organization",
        organization_id: org.id,
        slug: uslug,
        name: uslug,
        title: "Usage"
      })

    assert %{"special_usages" => _} =
             auth |> get(base(org, "special-usages")) |> json_response(200)

    assert conn = auth |> get(base(org, "special-usages/#{uslug}")) |> json_response(200)
    assert is_map(conn)

    assert %{"error" => "Unicode special usage not found"} =
             auth
             |> get(base(org, "special-usages/no-such-usage"))
             |> json_response(404)
  end

  # ── with_scope folds ──────────────────────────────────────────────────────

  test "unknown organization → 404", %{auth: auth} do
    assert %{"error" => "Organization not found"} =
             auth
             |> get("/api/v1/organizations/no-such-org-xyz/unicode/elements")
             |> json_response(404)
  end

  test "org resolves by slug for members", %{auth: auth, org: org} do
    assert conn =
             auth
             |> get("/api/v1/organizations/#{org.slug}/unicode/elements")
             |> json_response(200)

    assert is_map(conn)
  end

  test "unknown project → 404", %{auth: auth, org: org} do
    assert %{"error" => "Project not found"} =
             auth
             |> get(base(org, "elements") <> "?project=ghost-project")
             |> json_response(404)
  end

  test "non-member → 403", %{auth: auth, org: org, outsider_token: t} do
    assert %{"error" => "Not a member of this organization"} =
             auth
             |> authenticated_conn(t)
             |> get(base(org, "elements"))
             |> json_response(403)
  end
end
