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
end
