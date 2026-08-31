defmodule NoizuPromptLingua.MCP.CustomKeyToolsetTest do
  use NoizuPromptLingua.DataCase

  # Key toolset overrides ON the custom endpoint (/custom/:slug/mcp):
  # the scope's include set still governs; the key config only flips
  # disabled/hidden flags. Disabled tools remain in the catalog (so the
  # guard denies explicitly) but drop out of listing.

  alias Noizu.MCP.Ctx
  alias NoizuPromptLingua.MCP.Custom
  alias NoizuPromptLingua.MCP.Server, as: NPLServer
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCPCustomScopes

  setup do
    uniq = System.unique_integer([:positive])

    user =
      %NoizuPromptLingua.Schema.Users.User{
        id: Ecto.UUID.generate(),
        email: "ck-#{uniq}@example.com",
        user_name: "ck#{uniq}",
        handle: "ck#{uniq}",
        status: :active
      }
      |> NoizuPromptLingua.Repo.insert!()

    {:ok, scope} =
      MCPCustomScopes.create(%{
        "slug" => "ck-ops",
        "name" => "CK Ops",
        "config" => %{
          "groups" => %{
            "sessions" => %{"tools" => %{}},
            "projects" => %{"tools" => %{"Project.Create" => %{"hidden" => true}}}
          }
        }
      })

    %{user: user, scope: scope}
  end

  defp scope_ctx(slug), do: %Ctx{assigns: %{custom_scope_slug: slug}}

  defp key_ctx(slug, key_id),
    do: %Ctx{
      assigns: %{custom_scope_slug: slug, auth_claims: %{"api_key_id" => key_id}}
    }

  test "key-disabled tool stays in catalog (guard denies) but drops from listing", %{
    user: user,
    scope: scope
  } do
    {:ok, key, _raw} =
      MCPApiKeys.generate_api_key(user.id, "k",
        toolset_config: %{
          "groups" => %{"sessions" => %{"tools" => %{"Session.Update" => %{"disabled" => true}}}}
        }
      )

    ctx = key_ctx(scope.slug, key.id)

    # catalog: still present (ToolGuard denies at call time)
    cat_names = Custom.catalog_specs(ctx) |> Enum.map(& &1.definition.name)
    assert "Session.Update" in cat_names

    # listing: dropped. Listing emits canonical underscore names (F5 naming);
    # catalog_specs returns raw registry names (dotted = alias source).
    {:ok, tools, _cursor} = NPLServer.list_tools(Custom, nil, ctx)
    listed = Enum.map(tools, & &1.name)
    refute "Session_Update" in listed
    assert "Session_Get" in listed
  end

  test "key-hidden hides from listing; scope-hidden still hides; both callable if enabled", %{
    user: user,
    scope: scope
  } do
    {:ok, key, _raw} =
      MCPApiKeys.generate_api_key(user.id, "k",
        toolset_config: %{
          "groups" => %{"sessions" => %{"tools" => %{"Session.Get" => %{"hidden" => true}}}}
        }
      )

    ctx = key_ctx(scope.slug, key.id)
    {:ok, tools, _cursor} = NPLServer.list_tools(Custom, nil, ctx)
    listed = Enum.map(tools, & &1.name)

    # scope-level hidden (Project.Create) and key-level hidden (Session.Get)
    refute "Project_Create" in listed
    refute "Session_Get" in listed
    assert "Session_Update" in listed
  end

  test "key group-level disabled hides that group's tools from listing", %{
    user: user,
    scope: scope
  } do
    {:ok, key, _raw} =
      MCPApiKeys.generate_api_key(user.id, "k",
        toolset_config: %{"groups" => %{"projects" => %{"disabled" => true}}}
      )

    ctx = key_ctx(scope.slug, key.id)
    {:ok, tools, _cursor} = NPLServer.list_tools(Custom, nil, ctx)
    listed = Enum.map(tools, & &1.name)

    # group disabled -> dropped from listing AND catalog calls denied by guard;
    # the OTHER group's tools remain
    refute "Project_Get" in listed
    assert "Session_Update" in listed
  end

  test "no key on the request -> scope config alone governs", %{scope: scope} do
    ctx = scope_ctx(scope.slug)
    {:ok, tools, _cursor} = NPLServer.list_tools(Custom, nil, ctx)
    listed = Enum.map(tools, & &1.name)

    refute "Project_Create" in listed
    assert "Session_Update" in listed
    assert "Session_Get" in listed
  end
end
