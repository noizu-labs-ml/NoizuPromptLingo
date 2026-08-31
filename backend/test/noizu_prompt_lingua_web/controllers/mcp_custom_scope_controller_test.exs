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

  test "admin can clone a custom scope (config copied, original untouched)", %{conn: conn} do
    post(conn, "/api/v1/admin/mcp-custom-scopes", %{
      scope: %{
        slug: "clone-src",
        name: "Clone Source",
        description: "before clone",
        config: %{groups: %{sessions: %{tools: %{"Session.Create" => %{disabled: true}}}}}
      }
    })
    |> json_response(201)

    clone =
      post(conn, "/api/v1/admin/mcp-custom-scopes/clone-src/clone", %{
        scope: %{slug: "clone-dst", name: "Clone Dst"}
      })
      |> json_response(201)

    assert clone["scope"]["slug"] == "clone-dst"
    assert clone["scope"]["name"] == "Clone Dst"
    # description/kind/config fall back to the source
    assert clone["scope"]["description"] == "before clone"
    assert clone["scope"]["source_template_slug"] == "clone-src"
    assert clone["scope"]["config"]["groups"]["sessions"]["tools"]["Session.Create"]["disabled"] ==
             true

    # the source scope is untouched
    orig = conn |> get("/api/v1/admin/mcp-custom-scopes/clone-src") |> json_response(200)
    assert orig["scope"]["name"] == "Clone Source"
    assert orig["scope"]["slug"] == "clone-src"

    # legacy /copy alias route resolves to the same action
    alias_copy =
      post(conn, "/api/v1/admin/mcp-custom-scopes/clone-src/copy", %{
        scope: %{slug: "clone-alias"}
      })
      |> json_response(201)

    assert alias_copy["scope"]["slug"] == "clone-alias"

    missing = post(conn, "/api/v1/admin/mcp-custom-scopes/nope/clone") |> json_response(404)
    assert missing["error"] =~ "not found"
  end
end
