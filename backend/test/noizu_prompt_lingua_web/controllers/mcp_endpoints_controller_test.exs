defmodule NoizuPromptLinguaWeb.McpEndpointsControllerTest do
  @moduledoc """
  HTTP path for custom MCP endpoints: list templates + personal default,
  create/copy from a template, and set the account default.
  Drives the shipped router + controller + MCPCustomScopes (no mocks).
  """
  use NoizuPromptLinguaWeb.ConnCase

  setup %{conn: conn} do
    %{user: user, access_token: token} = setup_user_and_token()
    {:ok, conn: authenticated_conn(conn, token), user: user}
  end

  test "GET list returns the tobor template plus a personal default", %{conn: conn, user: user} do
    body = conn |> get("/api/v1/auth/mcp/endpoints") |> json_response(200)

    tobor = Enum.find(body["templates"], &(&1["slug"] == "tobor"))
    refute is_nil(tobor)
    assert tobor["owner_kind"] == "template"
    assert tobor["editable"] == false

    default = body["default_scope"]
    assert is_binary(default["id"])
    assert default["id"] != tobor["id"]
    assert default["user_id"] == user.id
    assert default["is_default"] == true
    assert default["editable"] == true
    assert default["owner_kind"] == "user"
    assert default["source_template_slug"] == "tobor"

    assert Enum.any?(body["endpoints"], &(&1["id"] == default["id"]))
  end

  test "POST create from the tobor template yields a distinct personal endpoint", %{
    conn: conn,
    user: user
  } do
    listed = conn |> get("/api/v1/auth/mcp/endpoints") |> json_response(200)
    tobor = Enum.find(listed["templates"], &(&1["slug"] == "tobor"))
    refute is_nil(tobor)
    original_default_id = listed["default_scope"]["id"]
    refute is_nil(original_default_id)

    created =
      conn
      |> post("/api/v1/auth/mcp/endpoints", %{
        endpoint: %{source_id: tobor["id"], name: "Lean pack"}
      })
      |> json_response(201)

    endpoint = created["endpoint"]
    assert is_binary(endpoint["id"])
    assert endpoint["id"] != tobor["id"]
    assert endpoint["id"] != original_default_id
    assert endpoint["user_id"] == user.id
    assert endpoint["name"] == "Lean pack"
    assert endpoint["owner_kind"] == "user"
    assert endpoint["source_template_slug"] == "tobor"
    refute endpoint["is_default"]

    listed_after = conn |> get("/api/v1/auth/mcp/endpoints") |> json_response(200)
    assert Enum.any?(listed_after["endpoints"], &(&1["id"] == endpoint["id"]))
    assert listed_after["default_scope"]["id"] == original_default_id
  end

  test "POST copy of a non-tobor template then use-default makes that row the account default",
       %{conn: conn, user: user} do
    listed = conn |> get("/api/v1/auth/mcp/endpoints") |> json_response(200)
    core = Enum.find(listed["templates"], &(&1["slug"] == "core"))
    tobor = Enum.find(listed["templates"], &(&1["slug"] == "tobor"))
    refute is_nil(core)
    refute is_nil(tobor)
    original_default_id = listed["default_scope"]["id"]
    refute original_default_id == core["id"]

    copied =
      conn
      |> post("/api/v1/auth/mcp/endpoints/#{core["id"]}/copy", %{
        endpoint: %{name: "Core locker"}
      })
      |> json_response(201)

    copy = copied["endpoint"]
    assert is_binary(copy["id"])
    assert copy["id"] != core["id"]
    assert copy["id"] != tobor["id"]
    assert copy["id"] != original_default_id
    assert copy["user_id"] == user.id
    assert copy["name"] == "Core locker"
    # Must clone the selected template, not silently fall back to tobor.
    assert copy["source_template_slug"] == "core"
    refute copy["is_default"]

    used =
      conn
      |> post("/api/v1/auth/mcp/endpoints/#{copy["id"]}/use", %{})
      |> json_response(200)

    assert used["endpoint"]["id"] == copy["id"]
    assert used["endpoint"]["is_default"] == true
    assert used["endpoint"]["user_id"] == user.id

    listed_after = conn |> get("/api/v1/auth/mcp/endpoints") |> json_response(200)
    assert listed_after["default_scope"]["id"] == copy["id"]
    assert listed_after["default_scope"]["is_default"] == true

    previous = Enum.find(listed_after["endpoints"], &(&1["id"] == original_default_id))
    refute is_nil(previous)
    assert previous["is_default"] == false
  end

  # ── W2C coverage extension ──────────────────────────────────────────────────

  describe "visibility + ownership" do
    test "show own default is editable; templates are not; unknown id is 404", %{
      conn: conn,
      user: user
    } do
      listed = conn |> get("/api/v1/auth/mcp/endpoints") |> json_response(200)
      default_id = listed["default_scope"]["id"]
      tobor = Enum.find(listed["templates"], &(&1["slug"] == "tobor"))

      own = conn |> get("/api/v1/auth/mcp/endpoints/#{default_id}") |> json_response(200)
      assert own["endpoint"]["id"] == default_id
      assert own["endpoint"]["owner_kind"] == "user"
      assert own["endpoint"]["editable"] == true
      assert own["endpoint"]["user_id"] == user.id

      template = conn |> get("/api/v1/auth/mcp/endpoints/#{tobor["id"]}") |> json_response(200)
      assert template["endpoint"]["owner_kind"] == "template"
      assert template["endpoint"]["editable"] == false

      assert json_response(get(conn, "/api/v1/auth/mcp/endpoints/#{Ecto.UUID.generate()}"), 404)[
               "error"
             ]
    end

    test "index seeds and lists the org default (owner sees it editable)", %{
      conn: conn,
      user: user
    } do
      org_id = create_org(conn)

      body = conn |> get("/api/v1/auth/mcp/endpoints") |> json_response(200)

      org_endpoint =
        Enum.find(body["endpoints"], &(&1["organization_id"] == org_id and &1["user_id"] == nil))

      refute is_nil(org_endpoint)
      assert org_endpoint["owner_kind"] == "organization"
      assert org_endpoint["editable"] == true
      assert org_endpoint["user_id"] != user.id
      assert org_endpoint["is_default"] == true
    end

    test "org endpoint is visible to a member but read-only; invisible to outsiders", %{
      conn: _conn
    } do
      # Owner org.
      %{access_token: owner_token} = setup_user_and_token()
      owner_conn = authenticated_conn(Phoenix.ConnTest.build_conn(), owner_token)
      org_id = create_org(owner_conn)

      # Member of the same org.
      %{user: member_user, access_token: member_token} = setup_user_and_token()

      {:ok, _} =
        NoizuPromptLingua.Authz.ScopedMemberships.add_member(
          "organization",
          org_id,
          member_user.id,
          "member"
        )

      member_conn = authenticated_conn(Phoenix.ConnTest.build_conn(), member_token)

      listed = member_conn |> get("/api/v1/auth/mcp/endpoints") |> json_response(200)

      org_endpoint =
        Enum.find(
          listed["endpoints"],
          &(&1["organization_id"] == org_id and &1["user_id"] == nil)
        )

      refute is_nil(org_endpoint)
      assert org_endpoint["editable"] == false

      shown =
        member_conn
        |> get("/api/v1/auth/mcp/endpoints/#{org_endpoint["id"]}")
        |> json_response(200)

      assert shown["endpoint"]["owner_kind"] == "organization"
      assert shown["endpoint"]["editable"] == false

      # Outsider cannot even see it.
      %{access_token: outsider_token} = setup_user_and_token()
      outsider = authenticated_conn(Phoenix.ConnTest.build_conn(), outsider_token)

      assert json_response(
               get(outsider, "/api/v1/auth/mcp/endpoints/#{org_endpoint["id"]}"),
               404
             )["error"]
    end
  end

  describe "create variants + errors" do
    test "unknown source_id -> 404 source endpoint not found", %{conn: conn} do
      body =
        conn
        |> post("/api/v1/auth/mcp/endpoints", %{source_id: Ecto.UUID.generate()})
        |> json_response(404)

      assert body["error"] == "source endpoint not found"
    end

    test "source_slug resolves the template without an id", %{conn: conn} do
      # Lazy templates are per-sandbox-transaction; seed the core variant first.
      _ = NoizuPromptLingua.MCPCustomScopes.get_core_variant()

      created =
        conn
        |> post("/api/v1/auth/mcp/endpoints", %{source_slug: "core", name: "By Slug"})
        |> json_response(201)

      assert created["endpoint"]["name"] == "By Slug"
      assert created["endpoint"]["source_template_slug"] == "core"
    end

    test "%{\"scope\" => ...} body wrapper is unwrapped", %{conn: conn} do
      _ = NoizuPromptLingua.MCPCustomScopes.get_core_variant()

      created =
        conn
        |> post("/api/v1/auth/mcp/endpoints", %{scope: %{source_slug: "core", name: "Scoped"}})
        |> json_response(201)

      assert created["endpoint"]["name"] == "Scoped"
    end

    test "organization-owned copy requires admin (owner passes, member 403)", %{conn: _conn} do
      %{access_token: owner_token} = setup_user_and_token()
      owner_conn = authenticated_conn(Phoenix.ConnTest.build_conn(), owner_token)
      org_id = create_org(owner_conn)

      created =
        owner_conn
        |> post("/api/v1/auth/mcp/endpoints", %{
          organization_id: org_id,
          source_slug: "core",
          name: "Org Pack"
        })
        |> json_response(201)

      assert created["endpoint"]["owner_kind"] == "organization"
      assert created["endpoint"]["organization_id"] == org_id
      refute created["endpoint"]["is_default"]

      # A plain member of the same org is below the admin bar.
      %{user: member_user, access_token: member_token} = setup_user_and_token()

      {:ok, _} =
        NoizuPromptLingua.Authz.ScopedMemberships.add_member(
          "organization",
          org_id,
          member_user.id,
          "member"
        )

      member_conn = authenticated_conn(Phoenix.ConnTest.build_conn(), member_token)

      assert json_response(
               post(member_conn, "/api/v1/auth/mcp/endpoints", %{
                 organization_id: org_id,
                 source_slug: "core"
               }),
               403
             )["error"] == "forbidden"
    end

    test "use=true flips the account default to the new copy", %{conn: conn} do
      listed = conn |> get("/api/v1/auth/mcp/endpoints") |> json_response(200)
      original_default = listed["default_scope"]["id"]

      created =
        conn
        |> post("/api/v1/auth/mcp/endpoints", %{
          source_slug: "core",
          name: "New Default",
          use: "true"
        })
        |> json_response(201)

      assert created["endpoint"]["is_default"] == true

      after_list = conn |> get("/api/v1/auth/mcp/endpoints") |> json_response(200)
      assert after_list["default_scope"]["id"] == created["endpoint"]["id"]
      assert after_list["default_scope"]["id"] != original_default
    end
  end

  describe "duplicate / update / use_default / delete" do
    setup %{conn: conn} do
      listed = conn |> get("/api/v1/auth/mcp/endpoints") |> json_response(200)

      {:ok,
       default: listed["default_scope"],
       tobor: Enum.find(listed["templates"], &(&1["slug"] == "tobor"))}
    end

    test "duplicate with a flat body (no endpoint/scope wrapper)", %{conn: conn, tobor: tobor} do
      created =
        conn
        |> post("/api/v1/auth/mcp/endpoints/#{tobor["id"]}/copy", %{name: "Flat Copy"})
        |> json_response(201)

      assert created["endpoint"]["name"] == "Flat Copy"
      assert created["endpoint"]["source_template_slug"] == "tobor"
    end

    test "update renames own endpoint (endpoint + scope keys); empty patch is a no-op", %{
      conn: conn,
      default: default
    } do
      body =
        conn
        |> patch("/api/v1/auth/mcp/endpoints/#{default["id"]}", %{name: "Renamed Locker"})
        |> json_response(200)

      assert body["endpoint"]["name"] == "Renamed Locker"
      assert body["scope"]["name"] == "Renamed Locker"

      noop =
        conn
        |> patch("/api/v1/auth/mcp/endpoints/#{default["id"]}", %{})
        |> json_response(200)

      assert noop["endpoint"]["name"] == "Renamed Locker"
    end

    test "update with use=true sets the account default", %{conn: conn, tobor: tobor} do
      created =
        conn
        |> post("/api/v1/auth/mcp/endpoints", %{source_slug: "core", name: "Late Default"})
        |> json_response(201)

      body =
        conn
        |> patch("/api/v1/auth/mcp/endpoints/#{created["endpoint"]["id"]}", %{use: "true"})
        |> json_response(200)

      assert body["endpoint"]["is_default"] == true

      listed = conn |> get("/api/v1/auth/mcp/endpoints") |> json_response(200)
      assert listed["default_scope"]["id"] == created["endpoint"]["id"]
      assert listed["default_scope"]["id"] != tobor["id"]
    end

    test "update rejects invalid config visibility with 422", %{conn: conn, default: default} do
      body =
        conn
        |> patch("/api/v1/auth/mcp/endpoints/#{default["id"]}", %{
          config: %{visibility: "bogus"}
        })
        |> json_response(422)

      assert body["errors"]
    end

    test "template is read-only for update (copy to edit)", %{conn: conn, tobor: tobor} do
      body =
        conn
        |> patch("/api/v1/auth/mcp/endpoints/#{tobor["id"]}", %{name: "Hijack"})
        |> json_response(403)

      assert body["error"] =~ "read-only"
    end

    test "use_default on a template creates + defaults a personal copy", %{
      conn: conn,
      tobor: tobor
    } do
      before_list = conn |> get("/api/v1/auth/mcp/endpoints") |> json_response(200)
      previous_default = before_list["default_scope"]["id"]

      body =
        conn
        |> post("/api/v1/auth/mcp/endpoints/#{tobor["id"]}/use", %{})
        |> json_response(200)

      assert body["endpoint"]["id"] != tobor["id"]
      assert body["endpoint"]["owner_kind"] == "user"
      assert body["endpoint"]["is_default"] == true

      after_list = conn |> get("/api/v1/auth/mcp/endpoints") |> json_response(200)
      assert after_list["default_scope"]["id"] == body["endpoint"]["id"]

      previous = Enum.find(after_list["endpoints"], &(&1["id"] == previous_default))
      refute previous["is_default"]
    end

    test "use_default on org endpoint as admin copies it to the user", %{conn: _conn} do
      %{access_token: owner_token} = setup_user_and_token()
      owner_conn = authenticated_conn(Phoenix.ConnTest.build_conn(), owner_token)
      org_id = create_org(owner_conn)

      listed = owner_conn |> get("/api/v1/auth/mcp/endpoints") |> json_response(200)

      org_endpoint =
        Enum.find(
          listed["endpoints"],
          &(&1["organization_id"] == org_id and &1["user_id"] == nil)
        )

      body =
        owner_conn
        |> post("/api/v1/auth/mcp/endpoints/#{org_endpoint["id"]}/use", %{})
        |> json_response(200)

      assert body["endpoint"]["user_id"] != nil
      assert body["endpoint"]["user_id"] != org_endpoint["organization_id"]
      assert body["endpoint"]["is_default"] == true
    end

    test "use_default unknown id -> 404", %{conn: conn} do
      assert json_response(
               post(conn, "/api/v1/auth/mcp/endpoints/#{Ecto.UUID.generate()}/use", %{}),
               404
             )["error"]
    end

    test "delete lifecycle: copy deletable, default protected, template forbidden", %{
      conn: conn,
      default: default,
      tobor: tobor
    } do
      created =
        conn
        |> post("/api/v1/auth/mcp/endpoints", %{source_slug: "core", name: "Doomed"})
        |> json_response(201)

      assert json_response(
               delete(conn, "/api/v1/auth/mcp/endpoints/#{created["endpoint"]["id"]}"),
               200
             ) == %{"ok" => true, "id" => created["endpoint"]["id"]}

      assert json_response(
               delete(conn, "/api/v1/auth/mcp/endpoints/#{created["endpoint"]["id"]}"),
               404
             )["error"]

      # The account default cannot be deleted.
      assert json_response(delete(conn, "/api/v1/auth/mcp/endpoints/#{default["id"]}"), 403)[
               "error"
             ] =~ "cannot be deleted"

      # The shared template is not editable -> plain forbidden.
      assert json_response(delete(conn, "/api/v1/auth/mcp/endpoints/#{tobor["id"]}"), 403)[
               "error"
             ] == "forbidden"
    end

    test "org default is protected from deletion even for an admin", %{conn: _conn} do
      %{access_token: owner_token} = setup_user_and_token()
      owner_conn = authenticated_conn(Phoenix.ConnTest.build_conn(), owner_token)
      org_id = create_org(owner_conn)

      listed = owner_conn |> get("/api/v1/auth/mcp/endpoints") |> json_response(200)

      org_endpoint =
        Enum.find(
          listed["endpoints"],
          &(&1["organization_id"] == org_id and &1["user_id"] == nil)
        )

      assert json_response(
               delete(owner_conn, "/api/v1/auth/mcp/endpoints/#{org_endpoint["id"]}"),
               403
             )["error"] =~ "cannot be deleted"
    end
  end

  describe "unauthenticated access (controller-level 401s)" do
    test "every action answers 401 without a session", %{conn: _conn} do
      controller = NoizuPromptLinguaWeb.McpEndpointsController
      conn = Phoenix.ConnTest.build_conn()

      id = Ecto.UUID.generate()

      call = fn action, params ->
        conn |> Map.put(:params, params) |> controller.call(controller.init(action))
      end

      assert json_response(call.(:index, %{}), 401)["error"] == "authentication required"
      assert json_response(call.(:show, %{"id" => id}), 401)["error"]
      assert json_response(call.(:create, %{}), 401)["error"]
      assert json_response(call.(:update, %{"id" => id}), 401)["error"]
      assert json_response(call.(:use_default, %{"id" => id}), 401)["error"]
      assert json_response(call.(:delete, %{"id" => id}), 401)["error"]
    end
  end

  defp create_org(conn) do
    slug = "mcp-eps-org-#{System.unique_integer([:positive])}"

    conn
    |> post("/api/v1/organizations", %{organization: %{slug: slug, name: "MCP Endpoints Org"}})
    |> json_response(201)
    |> get_in(["organization", "id"])
  end
end
