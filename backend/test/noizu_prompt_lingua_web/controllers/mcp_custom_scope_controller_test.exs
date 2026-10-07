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
    assert Enum.any?(sessions["tools"], &(&1["name"] == "Session_Create"))
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

  # ── alacarte WP1/WP4: display passthrough + clone inheritance ────────────────

  describe "display styling config (alacarte)" do
    @display %{"image" => "abc123shortid", "emoji" => "🚀", "color" => "#ff8800"}

    test "admin create + update round-trip display; group-only updates keep it", %{conn: conn} do
      created =
        post(conn, "/api/v1/admin/mcp-custom-scopes", %{
          scope: %{
            slug: "display-admin",
            name: "Display Admin",
            config: %{groups: %{sessions: %{}}, display: @display}
          }
        })
        |> json_response(201)

      assert created["scope"]["config"]["display"] == @display

      # a groups-only update must not drop the stored display (prior carry)
      updated =
        patch(conn, "/api/v1/admin/mcp-custom-scopes/display-admin", %{
          scope: %{config: %{groups: %{tickets: %{}}}}
        })
        |> json_response(200)

      assert updated["scope"]["config"]["display"] == @display
      assert Map.has_key?(updated["scope"]["config"]["groups"], "tickets")

      # a new display replaces it
      replaced =
        patch(conn, "/api/v1/admin/mcp-custom-scopes/display-admin", %{
          scope: %{config: %{display: %{"emoji" => "🎯", "color" => "#f80"}}}
        })
        |> json_response(200)

      assert replaced["scope"]["config"]["display"] == %{"emoji" => "🎯", "color" => "#f80"}
    end

    test "display sanitization: non-conforming fields dropped, conforming kept", %{conn: conn} do
      created =
        post(conn, "/api/v1/admin/mcp-custom-scopes", %{
          scope: %{
            slug: "display-sanitize",
            name: "Display Sanitize",
            config: %{
              groups: %{sessions: %{}},
              display: %{
                image: String.duplicate("a", 513),
                emoji: "🚀",
                color: "not-a-color",
                bogus: "x"
              }
            }
          }
        })
        |> json_response(201)

      assert created["scope"]["config"]["display"] == %{"emoji" => "🚀"}
    end

    test "clone inherits the source display", %{conn: conn} do
      post(conn, "/api/v1/admin/mcp-custom-scopes", %{
        scope: %{
          slug: "display-src",
          name: "Display Source",
          config: %{groups: %{sessions: %{}}, display: @display}
        }
      })
      |> json_response(201)

      clone =
        post(conn, "/api/v1/admin/mcp-custom-scopes/display-src/clone", %{
          scope: %{slug: "display-clone", name: "Display Clone"}
        })
        |> json_response(201)

      assert clone["scope"]["config"]["display"] == @display
    end

    test "user default endpoint round-trips display through its config", %{conn: conn} do
      # seed the user's default endpoint (cloned from the tobor template)
      shown = conn |> get("/api/v1/auth/mcp/default-endpoint") |> json_response(200)
      assert shown["scope"]["slug"]

      updated =
        patch(conn, "/api/v1/auth/mcp/default-endpoint", %{
          config: %{groups: %{sessions: %{}}, display: %{"emoji" => "🎯", "color" => "#f80"}}
        })
        |> json_response(200)

      assert updated["scope"]["config"]["display"] == %{"emoji" => "🎯", "color" => "#f80"}

      # persisted — a re-fetch shows the stored display
      fetched = conn |> get("/api/v1/auth/mcp/default-endpoint") |> json_response(200)
      assert fetched["scope"]["config"]["display"] == %{"emoji" => "🎯", "color" => "#f80"}
    end
  end
end
