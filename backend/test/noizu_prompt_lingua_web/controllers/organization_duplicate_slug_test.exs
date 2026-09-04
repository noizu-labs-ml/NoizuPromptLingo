defmodule NoizuPromptLinguaWeb.OrganizationDuplicateSlugTest do
  @moduledoc """
  Regression (fix/error-family B5, stage log c6326): creating an org with an
  already-taken slug raised Ecto.ConstraintError → 500, because the changeset
  declared the inferred constraint name `organizations_slug_index` while the
  real DB objects are the 009 table constraint `organizations_slug_key` and the
  082 index `idx_organizations_slug`. Both names are now declared; a collision
  answers 422 with a slug field error.
  """

  use NoizuPromptLinguaWeb.ConnCase

  setup %{conn: conn} do
    %{access_token: token} = setup_user_and_token()
    auth = authenticated_conn(conn, token)
    {:ok, conn: auth}
  end

  test "duplicate slug answers 422 with a slug error, not 500", %{conn: conn} do
    slug = "dupe-org-#{System.unique_integer([:positive])}"

    assert %{"organization" => _} =
             json_response(
               post(conn, "/api/v1/organizations", %{organization: %{slug: slug, name: "First"}}),
               201
             )

    conn =
      post(conn, "/api/v1/organizations", %{organization: %{slug: slug, name: "Second"}})

    body = json_response(conn, 422)
    assert body["errors"]["slug"] != nil
  end
end
