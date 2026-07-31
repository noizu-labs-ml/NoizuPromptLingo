defmodule NoizuPromptLinguaWeb.BoardControllerTest do
  @moduledoc """
  Board (queue) create scoping — ticket d4a8fd52 ("boards not project-scoped").

  The BE root-fix: a supplied `project_id` makes a PROJECT board (validated ∈ org)
  whether or not `scope:"project"` was sent, so a client (MCP/curl, or an FE
  regression) that sends `project_id` without `scope` no longer silently produces an
  org-level board. No `project_id` => org board; a `project_id` not in the org => 422
  (deny-safe, never a silent org fallback). Mirrors the chat controller test pattern.
  """
  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.Repo

  setup %{conn: conn} do
    %{access_token: token} = setup_user_and_token()
    auth_conn = authenticated_conn(conn, token)

    slug = "board-org-#{System.unique_integer([:positive])}"

    created =
      post(auth_conn, "/api/v1/organizations", %{organization: %{slug: slug, name: "Board Org"}})

    org_id = json_response(created, 201)["organization"]["id"]

    project_id = insert_project(org_id)
    base = "/api/v1/organizations/#{org_id}/boards"
    {:ok, conn: auth_conn, org_id: org_id, project_id: project_id, base: base}
  end

  describe "POST board scoping (d4a8fd52)" do
    test "explicit scope:project + project_id -> project board", %{
      conn: conn,
      base: base,
      project_id: pid
    } do
      board =
        conn
        |> post(base, %{
          board: %{name: "Proj Board", slug: uslug("pb"), scope: "project", project_id: pid}
        })
        |> json_response(201)
        |> Map.fetch!("board")

      assert board["project_id"] == pid
      assert board["scope"] == "project"
    end

    test "project_id WITHOUT scope (MCP/curl) -> project board, NOT a silent org board", %{
      conn: conn,
      base: base,
      project_id: pid
    } do
      # The footgun the ticket is about: a client sends project_id but omits scope.
      # Pre-fix this dropped to an org board (project_id lost); now it's inferred.
      board =
        conn
        |> post(base, %{
          board: %{name: "Inferred Proj Board", slug: uslug("ipb"), project_id: pid}
        })
        |> json_response(201)
        |> Map.fetch!("board")

      assert board["project_id"] == pid,
             "project_id must be persisted, not silently dropped to an org board"

      assert board["scope"] == "project"
    end

    test "no scope and no project_id -> org board", %{conn: conn, base: base} do
      board =
        conn
        |> post(base, %{board: %{name: "Org Board", slug: uslug("ob")}})
        |> json_response(201)
        |> Map.fetch!("board")

      assert is_nil(board["project_id"])
      assert board["scope"] == "org"
    end

    test "project_id from ANOTHER org -> 422, not a silent org board (deny-safe)", %{
      conn: conn,
      base: base
    } do
      other_slug = "board-org2-#{System.unique_integer([:positive])}"

      other =
        post(conn, "/api/v1/organizations", %{
          organization: %{slug: other_slug, name: "Other Org"}
        })

      other_org_id = json_response(other, 201)["organization"]["id"]
      foreign_pid = insert_project(other_org_id)

      assert json_response(
               post(conn, base, %{board: %{name: "X", slug: uslug("x"), project_id: foreign_pid}}),
               422
             )["error"]
    end

    test "explicit scope:global -> 403 (system-managed)", %{conn: conn, base: base} do
      assert json_response(
               post(conn, base, %{board: %{name: "G", slug: uslug("g"), scope: "global"}}),
               403
             )["error"]
    end
  end

  defp uslug(p), do: "#{p}-#{System.unique_integer([:positive])}"

  # ticket_queues.project_id -> projects(id); the project-scope cases need a backing row.
  defp insert_project(org_id) do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO projects (id, organization_id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, $3, now(), now()) RETURNING id",
        [
          Ecto.UUID.dump!(org_id),
          "boardproj-#{System.unique_integer([:positive])}",
          "Board Test Project"
        ]
      )

    Ecto.UUID.load!(raw)
  end
end
