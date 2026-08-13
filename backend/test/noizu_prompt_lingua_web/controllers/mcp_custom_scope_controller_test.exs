defmodule NoizuPromptLinguaWeb.MCPCustomScopeControllerTest do
  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Users.User

  setup %{conn: conn} do
    %{user: user, access_token: token} = setup_user_and_token()
    Repo.get!(User, user.id) |> Ecto.Changeset.change(role: :admin) |> Repo.update!()
    {:ok, conn: authenticated_conn(conn, token)}
  end

  test "admin can inspect available custom-scope groups", %{conn: conn} do
    body = conn |> get("/api/v1/admin/mcp-custom-scopes/catalog") |> json_response(200)

    assert %{"groups" => groups} = body
    sessions = Enum.find(groups, &(&1["id"] == "sessions"))
    assert sessions["label"] == "Sessions"
    assert Enum.any?(sessions["tools"], &(&1["name"] == "Session.Create"))
    refute Enum.any?(sessions["tools"], &(&1["name"] == "ToolSummary"))
  end

  test "admin can create and update a custom scope", %{conn: conn} do
    create =
      post(conn, "/api/v1/admin/mcp-custom-scopes", %{
        scope: %{
          slug: "ops-admin",
          name: "Ops Admin",
          description: "Operations tools",
          config: %{groups: %{sessions: %{tools: %{"Session.Create" => %{disabled: true}}}}}
        }
      })
      |> json_response(201)

    assert create["scope"]["slug"] == "ops-admin"

    assert create["scope"]["config"]["groups"]["sessions"]["tools"]["Session.Create"]["disabled"] ==
             true

    update =
      patch(conn, "/api/v1/admin/mcp-custom-scopes/ops-admin", %{
        scope: %{name: "Ops Admin Updated", config: %{groups: %{tickets: %{hidden: true}}}}
      })
      |> json_response(200)

    assert update["scope"]["name"] == "Ops Admin Updated"
    assert update["scope"]["config"]["groups"]["tickets"]["hidden"] == true

    list = conn |> get("/api/v1/admin/mcp-custom-scopes") |> json_response(200)
    assert Enum.any?(list["scopes"], &(&1["slug"] == "ops-admin"))
    assert Enum.any?(list["scopes"], &(&1["slug"] == "tobor"))
  end

  test "default tobor package cannot be deleted", %{conn: conn} do
    conn |> get("/api/v1/admin/mcp-custom-scopes") |> json_response(200)

    denied =
      conn
      |> delete("/api/v1/admin/mcp-custom-scopes/tobor")
      |> json_response(403)

    assert denied["error"] =~ "cannot be deleted"
  end
end
