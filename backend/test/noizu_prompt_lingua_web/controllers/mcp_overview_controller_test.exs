defmodule NoizuPromptLinguaWeb.McpOverviewControllerTest do
  @moduledoc """
  Admin review-flow controller: list / approve / reject / edit. Actions are invoked
  directly (the admin auth pipeline is covered elsewhere); this asserts the review
  transitions + JSON shape.
  """
  use NoizuPromptLinguaWeb.ConnCase, async: false

  alias NoizuPromptLinguaWeb.McpOverviewController
  alias NoizuPromptLingua.Domains.MCPOverview.Store

  defp seed(status) do
    {:ok, row} =
      Store.insert_overview(%{
        scope_slug: "ctrl-#{System.unique_integer([:positive])}",
        task_text: "review me",
        overview_md: "# original",
        status: status
      })

    row
  end

  test "index lists overviews, filterable by status", %{conn: conn} do
    generated = seed("generated")
    approved = seed("approved")

    resp = McpOverviewController.index(conn, %{"status" => "generated"}) |> json_response(200)
    ids = Enum.map(resp["overviews"], & &1["id"])
    assert generated.id in ids
    refute approved.id in ids
  end

  test "approve moves generated → approved", %{conn: conn} do
    row = seed("generated")

    resp = McpOverviewController.approve(conn, %{"id" => row.id}) |> json_response(200)
    assert resp["overview"]["status"] == "approved"
    assert Store.get_overview(row.id).status == "approved"
  end

  test "reject moves generated → rejected", %{conn: conn} do
    row = seed("generated")

    resp = McpOverviewController.reject(conn, %{"id" => row.id}) |> json_response(200)
    assert resp["overview"]["status"] == "rejected"
    assert Store.get_overview(row.id).status == "rejected"
  end

  test "editing the markdown implies approval", %{conn: conn} do
    row = seed("generated")

    resp =
      McpOverviewController.update(conn, %{
        "id" => row.id,
        "overview" => %{"overview_md" => "# edited body"}
      })
      |> json_response(200)

    assert resp["overview"]["overview_md"] == "# edited body"
    assert resp["overview"]["status"] == "approved"

    stored = Store.get_overview(row.id)
    assert stored.overview_md == "# edited body"
    assert stored.status == "approved"
  end

  test "approve on a missing id returns 404", %{conn: conn} do
    resp =
      McpOverviewController.approve(conn, %{"id" => Ecto.UUID.generate()}) |> json_response(404)

    assert resp["error"] =~ "not found"
  end
end
