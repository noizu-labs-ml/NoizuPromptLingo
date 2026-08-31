defmodule NoizuPromptLinguaWeb.CustomMCPGatewayControllerTest do
  use NoizuPromptLinguaWeb.ConnCase, async: true

  alias NoizuPromptLingua.MCPCustomScopes
  alias NoizuPromptLingua.Schema.MCPCustomScope

  # --- W2 /user/:slug/mcp route resolution ------------------------------------

  test "unknown scope at /user/:slug/mcp resolves to a JSON 404" do
    conn = get(build_conn(), "/user/does-not-exist/mcp")

    assert json_response(conn, 404) == %{"error" => "Custom MCP scope not found"}
  end

  test "unknown scope at /custom/:slug/mcp still resolves to a JSON 404" do
    conn = get(build_conn(), "/custom/does-not-exist/mcp")

    assert json_response(conn, 404) == %{"error" => "Custom MCP scope not found"}
  end

  test "resolve_scope/3: :user serves account/shared scopes with the /user path" do
    for visibility <- ~w(account shared) do
      slug = "user-route-#{visibility}"

      {:ok, _} =
        MCPCustomScopes.create(%{
          "slug" => slug,
          "name" => "User Route",
          "visibility" => visibility
        })

      expected_path = "/user/#{slug}/mcp"

      assert {:ok, scope, ^slug, ^expected_path} =
               NoizuPromptLinguaWeb.CustomMCPGatewayController.resolve_scope(
                 build_conn(),
                 :user,
                 %{"slug" => slug}
               )

      assert %MCPCustomScope{} = scope
    end
  end

  test "resolve_scope/3: :user 404s org-visibility scopes (no existence leak)" do
    {:ok, _} =
      MCPCustomScopes.create(%{
        "slug" => "user-route-org",
        "name" => "Org Only",
        "visibility" => "org"
      })

    assert {:error, :not_found} =
             NoizuPromptLinguaWeb.CustomMCPGatewayController.resolve_scope(
               build_conn(),
               :user,
               %{"slug" => "user-route-org"}
             )

    # ...but the org-only scope still resolves on the legacy alias.
    assert {:ok, _scope, "user-route-org", "/custom/user-route-org/mcp"} =
             NoizuPromptLinguaWeb.CustomMCPGatewayController.resolve_scope(
               build_conn(),
               :legacy,
               %{"slug" => "user-route-org"}
             )
  end

  test "resolve_scope/3: unknown slug is not_found on both routes" do
    controller = NoizuPromptLinguaWeb.CustomMCPGatewayController

    assert {:error, :not_found} = controller.resolve_scope(build_conn(), :user, %{"slug" => "ghost"})
    assert {:error, :not_found} = controller.resolve_scope(build_conn(), :legacy, %{"slug" => "ghost"})
    assert {:error, :not_found} = controller.resolve_scope(build_conn(), :legacy, %{})
  end
end
