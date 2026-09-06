defmodule NoizuPromptLinguaWeb.DashboardStatsTest do
  @moduledoc """
  Regression (fix/error-family B3, stage log c6301): `Dashboard.stats/2` read
  `opts[:range] || opts["range"]` — Access on a keyword list rejects string
  keys, so any request WITHOUT `?range=` raised ArgumentError → 500. The
  option is now read per-shape; a request with no range, a valid range, or a
  garbage range all answer 200 (garbage falls back to the 14-day default).
  """

  use NoizuPromptLinguaWeb.ConnCase

  setup %{conn: conn} do
    %{access_token: token} = setup_user_and_token()
    auth = authenticated_conn(conn, token)

    slug = "dash-org-#{System.unique_integer([:positive])}"

    created =
      post(auth, "/api/v1/organizations", %{organization: %{slug: slug, name: "Dash Org"}})

    org_id = json_response(created, 201)["organization"]["id"]
    base = "/api/v1/organizations/#{org_id}/dashboard/stats"

    {:ok, conn: auth, org_id: org_id, base: base}
  end

  test "stats answers 200 without ?range= (the crash case)", %{conn: conn, base: base} do
    stats = json_response(get(conn, base), 200)["stats"]
    assert stats["range"] == 14
    assert is_map(stats["counts"])
  end

  test "stats honors ?range=7", %{conn: conn, base: base} do
    stats = json_response(get(conn, base <> "?range=7"), 200)["stats"]
    assert stats["range"] == 7
    assert stats["counts"]["tickets"] == 0
  end

  test "stats falls back to the default range on garbage input", %{conn: conn, base: base} do
    stats = json_response(get(conn, base <> "?range=banana"), 200)["stats"]
    assert stats["range"] == 14
  end
end
