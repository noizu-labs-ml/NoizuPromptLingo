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
    # W4 cutover: project ∈ org validation resolves via the TRP stub.
    NoizuPromptLingua.TRP.Cache.clear()
    NoizuPromptLingua.TRP.TestStub.reset()

    %{access_token: token} = setup_user_and_token()
    auth_conn = authenticated_conn(conn, token)

    slug = "board-org-#{System.unique_integer([:positive])}"

    created =
      post(auth_conn, "/api/v1/organizations", %{organization: %{slug: slug, name: "Board Org"}})

    org_id = json_response(created, 201)["organization"]["id"]
    NoizuPromptLingua.TRP.TestStub.seed_org(org_id, slug)

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
  # W4 cutover: Projects.get_project (the controller's project ∈ org validation)
  # resolves via the TRP stub, while ticket_queues' FK stays app-local.
  defp insert_project(org_id) do
    id = Ecto.UUID.generate()

    NoizuPromptLingua.TRP.TestStub.seed_project(org_id, %{
      id: id,
      slug: "boardproj-#{System.unique_integer([:positive])}",
      name: "Board Test Project"
    })

    id
  end

  # ── W5A coverage extension: CRUD + stages/iterations + authz arms ─────────

  describe "GET /boards (index)" do
    test "lists boards with methodologies and scope summaries", %{
      conn: conn,
      base: base,
      project_id: pid
    } do
      conn
      |> post(base, %{board: %{name: "Kanban", slug: uslug("kb")}})
      |> json_response(201)

      conn
      |> post(base, %{board: %{name: "Scoped", slug: uslug("sc"), project_id: pid}})
      |> json_response(201)

      %{"boards" => boards, "methodologies" => methodologies} =
        conn |> get(base) |> json_response(200)

      # Unfiltered index = global + org-scope boards; project boards need the
      # project_id filter (Queues.visible_scope/2).
      assert Enum.map(boards, & &1["name"]) == ["Kanban"]
      assert boards |> hd() |> Map.fetch!("scope") == "org"
      assert "kanban" in methodologies
    end

    test "project_id filter adds that project's boards to global+org", %{
      conn: conn,
      base: base,
      project_id: pid
    } do
      conn
      |> post(base, %{board: %{name: "In", slug: uslug("in"), project_id: pid}})
      |> json_response(201)

      conn |> post(base, %{board: %{name: "Out", slug: uslug("out")}}) |> json_response(201)

      %{"boards" => boards} =
        conn |> get(base, %{project_id: pid}) |> json_response(200)

      assert Enum.map(boards, & &1["name"]) == ["In", "Out"]
    end

    test "unknown org -> 404", %{conn: conn} do
      assert conn
             |> get("/api/v1/organizations/no-such-board-org/boards")
             |> json_response(404)
             |> Map.has_key?("error")
    end

    test "non-member -> 403 not_a_member", %{conn: conn, base: base} do
      %{access_token: outsider} = setup_user_and_token()

      assert conn
             |> authenticated_conn(outsider)
             |> get(base)
             |> json_response(403)
             |> Map.fetch!("error") =~ "Not a member"
    end
  end

  describe "board show / update / delete" do
    test "show returns detail with stages + iterations maps", %{conn: conn, base: base} do
      %{"board" => %{"id" => id}} =
        conn
        |> post(base, %{board: %{name: "Detail", slug: uslug("dt")}})
        |> json_response(201)

      body =
        conn
        |> get("#{base}/#{id}")
        |> json_response(200)
        |> Map.fetch!("board")

      assert body["name"] == "Detail"
      # Kanban boards ship with default stages (todo/in_progress/done).
      assert is_list(body["stages"])
      assert "todo" in Enum.map(body["stages"], & &1["slug"])
      assert body["iterations"] == []
      assert Map.has_key?(body, "config")
    end

    test "show 404 for unknown id and for cross-org board (visible? guard)", %{
      conn: conn,
      base: base
    } do
      assert %{"error" => "Board not found"} =
               conn |> get("#{base}/#{Ecto.UUID.generate()}") |> json_response(404)

      other =
        post(conn, "/api/v1/organizations", %{
          organization: %{slug: "board-org3-#{System.unique_integer([:positive])}", name: "O3"}
        })

      other_org = json_response(other, 201)["organization"]["id"]

      other_base = "/api/v1/organizations/#{other_org}/boards"

      %{"board" => %{"id" => foreign_id}} =
        conn
        |> post(other_base, %{board: %{name: "Foreign", slug: uslug("fg")}})
        |> json_response(201)

      assert %{"error" => "Board not found"} =
               conn |> get("#{base}/#{foreign_id}") |> json_response(404)
    end

    test "update renames and accepts config; cross-org board is 403 (managed-by guard)", %{
      conn: conn,
      base: base
    } do
      %{"board" => %{"id" => id}} =
        conn
        |> post(base, %{board: %{name: "Before", slug: uslug("bf")}})
        |> json_response(201)

      body =
        conn
        |> put("#{base}/#{id}", %{board: %{name: "After", config: %{"wip" => 3}}})
        |> json_response(200)
        |> Map.fetch!("board")

      assert body["name"] == "After"
      assert body["config"] == %{"wip" => 3}

      other =
        post(conn, "/api/v1/organizations", %{
          organization: %{slug: "board-org4-#{System.unique_integer([:positive])}", name: "O4"}
        })

      other_org = json_response(other, 201)["organization"]["id"]
      other_base = "/api/v1/organizations/#{other_org}/boards"

      %{"board" => %{"id" => foreign_id}} =
        conn
        |> post(other_base, %{board: %{name: "Foreign2", slug: uslug("fg2")}})
        |> json_response(201)

      assert %{"error" => "This board is not managed by your organization"} =
               conn
               |> put("#{base}/#{foreign_id}", %{board: %{name: "Hijack"}})
               |> json_response(403)
    end

    test "update with invalid attrs -> 422", %{conn: conn, base: base} do
      %{"board" => %{"id" => id}} =
        conn
        |> post(base, %{board: %{name: "Up422", slug: uslug("u4")}})
        |> json_response(201)

      assert json_response(
               put(conn, "#{base}/#{id}", %{board: %{name: ""}}),
               422
             )
             |> Map.has_key?("errors")
    end

    test "delete removes the board", %{conn: conn, base: base} do
      %{"board" => %{"id" => id}} =
        conn
        |> post(base, %{board: %{name: "Doomed", slug: uslug("dm")}})
        |> json_response(201)

      assert %{"message" => "Board deleted"} =
               conn |> delete("#{base}/#{id}") |> json_response(200)

      assert %{"error" => "Board not found"} =
               conn |> get("#{base}/#{id}") |> json_response(404)
    end
  end

  describe "board stages" do
    setup %{conn: conn, base: base} do
      %{"board" => board} =
        conn
        |> post(base, %{board: %{name: "StageBoard", slug: uslug("sb")}})
        |> json_response(201)

      {:ok, board: board}
    end

    test "add / update / delete stage lifecycle", %{conn: conn, base: base, board: board} do
      stage =
        conn
        |> post("#{base}/#{board["id"]}/stages", %{
          stage: %{
            slug: "review-#{System.unique_integer([:positive])}",
            name: "Review",
            kind: "todo",
            position: 4
          }
        })
        |> json_response(201)
        |> Map.fetch!("stage")

      assert stage["name"] == "Review"
      assert stage["position"] == 4

      updated =
        conn
        |> put("#{base}/#{board["id"]}/stages/#{stage["id"]}", %{stage: %{name: "Inbox"}})
        |> json_response(200)
        |> Map.fetch!("stage")

      assert updated["name"] == "Inbox"

      assert %{"message" => "Stage deleted"} =
               conn
               |> delete("#{base}/#{board["id"]}/stages/#{stage["id"]}")
               |> json_response(200)
    end

    test "add stage validation error -> 422; unknown stage -> 404", %{
      conn: conn,
      base: base,
      board: board
    } do
      assert json_response(
               post(conn, "#{base}/#{board["id"]}/stages", %{stage: %{name: "No Slug"}}),
               422
             )
             |> Map.has_key?("errors")

      missing = Ecto.UUID.generate()

      assert %{"error" => "Stage not found"} =
               conn
               |> put("#{base}/#{board["id"]}/stages/#{missing}", %{stage: %{name: "X"}})
               |> json_response(404)

      assert %{"error" => "Stage not found"} =
               conn
               |> delete("#{base}/#{board["id"]}/stages/#{missing}")
               |> json_response(404)
    end
  end

  describe "board iterations" do
    setup %{conn: conn, base: base} do
      %{"board" => board} =
        conn
        |> post(base, %{board: %{name: "IterBoard", slug: uslug("ib")}})
        |> json_response(201)

      {:ok, board: board}
    end

    test "add / update / delete iteration lifecycle", %{conn: conn, base: base, board: board} do
      it =
        conn
        |> post("#{base}/#{board["id"]}/iterations", %{
          iteration: %{name: "Sprint 1", sequence: 1, status: "active"}
        })
        |> json_response(201)
        |> Map.fetch!("iteration")

      assert it["name"] == "Sprint 1"
      assert it["sequence"] == 1

      updated =
        conn
        |> put("#{base}/#{board["id"]}/iterations/#{it["id"]}", %{iteration: %{goal: "ship"}})
        |> json_response(200)
        |> Map.fetch!("iteration")

      assert updated["goal"] == "ship"

      assert %{"message" => "Iteration deleted"} =
               conn
               |> delete("#{base}/#{board["id"]}/iterations/#{it["id"]}")
               |> json_response(200)
    end

    test "add iteration validation error -> 422; unknown iteration -> 404", %{
      conn: conn,
      base: base,
      board: board
    } do
      assert json_response(
               post(conn, "#{base}/#{board["id"]}/iterations", %{iteration: %{sequence: 9}}),
               422
             )
             |> Map.has_key?("errors")

      missing = Ecto.UUID.generate()

      assert %{"error" => "Iteration not found"} =
               conn
               |> put("#{base}/#{board["id"]}/iterations/#{missing}", %{iteration: %{goal: "x"}})
               |> json_response(404)

      assert %{"error" => "Iteration not found"} =
               conn
               |> delete("#{base}/#{board["id"]}/iterations/#{missing}")
               |> json_response(404)
    end
  end
end
