defmodule NoizuPromptLinguaWeb.NPLControllerTest do
  use NoizuPromptLinguaWeb.ConnCase, async: false

  describe "GET /api/v1/npl/gallery (public)" do
    test "returns convention sections with generated sample markdown", %{conn: conn} do
      conn = get(conn, "/api/v1/npl/gallery")
      assert %{"sections" => sections} = json_response(conn, 200)
      assert is_list(sections)
      assert sections != []

      syntax = Enum.find(sections, &(&1["section"] == "syntax"))
      assert syntax
      assert is_binary(syntax["title"])
      assert syntax["component_count"] > 0
      assert is_binary(syntax["sample"])
      assert syntax["sample"] != ""
    end
  end

  describe "GET /api/v1/npl/sections (public)" do
    test "does not require a bearer token", %{conn: conn} do
      conn = get(conn, "/api/v1/npl/sections")
      assert %{"sections" => sections} = json_response(conn, 200)
      assert Enum.any?(sections, &(&1["section"] == "syntax"))
    end
  end
end
