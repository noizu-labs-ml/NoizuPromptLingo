defmodule NoizuPromptLingua.MCP.CustomEntitiesGatewayTest do
  use NoizuPromptLingua.DataCase, async: true

  alias Noizu.MCP.Ctx
  alias NoizuPromptLingua.MCP.Custom
  alias NoizuPromptLingua.MCPResources
  alias NoizuPromptLingua.MCPCustomScopes
  alias NoizuPromptLingua.MCPrompts

  defp ctx_for_scope(slug) do
    %Ctx{server: Custom, assigns: %{custom_scope_slug: slug}}
  end

  defp create_scope(slug, config) do
    {:ok, scope} =
      MCPCustomScopes.create(%{"slug" => slug, "name" => slug, "config" => config})

    scope
  end

  defp prompt(slug, extra \\ %{}) do
    {:ok, prompt} =
      MCPrompts.create(
        Map.merge(
          %{
            "slug" => slug,
            "name" => slug,
            "arguments" => [%{"name" => "topic", "required" => false}]
          },
          extra
        )
      )

    {:ok, _} = MCPrompts.publish_version(prompt, "About {{topic}}", nil)
    prompt
  end

  # ── prompts/list ──────────────────────────────────────────────────────────

  test "prompts/list serves entries when group present, filters hidden entries" do
    create_scope("prompts-on", %{
      "groups" => %{
        "prompts" => %{
          "entries" => %{"secret-prompt" => %{"hidden" => true}}
        }
      }
    })

    prompt("open-prompt")
    prompt("secret-prompt")
    c = ctx_for_scope("prompts-on")

    assert {:ok, prompts, nil} = Custom.handle_list_prompts(nil, c)
    names = Enum.map(prompts, & &1.name)
    assert "open-prompt" in names
    refute "secret-prompt" in names
  end

  test "prompts/list hides all entries for a hidden group, empty for absent group" do
    create_scope("prompts-hidden", %{"groups" => %{"prompts" => %{"hidden" => true}}})
    create_scope("prompts-off", %{"groups" => %{"sessions" => %{}}})

    prompt("sneaky")

    assert {:ok, prompts, nil} = Custom.handle_list_prompts(nil, ctx_for_scope("prompts-hidden"))
    assert prompts == []

    assert {:ok, prompts, nil} = Custom.handle_list_prompts(nil, ctx_for_scope("prompts-off"))
    assert prompts == []
  end

  test "group entry disabled keeps prompt listed (hidden is the list filter); get still respects disabled" do
    create_scope("prompts-mixed", %{
      "groups" => %{"prompts" => %{"entries" => %{"dead-prompt" => %{"disabled" => true}}}}
    })

    prompt("dead-prompt")
    prompt("live-prompt")

    {:ok, prompts, nil} = Custom.handle_list_prompts(nil, ctx_for_scope("prompts-mixed"))
    names = Enum.map(prompts, & &1.name)
    assert "live-prompt" in names
    # disabled entries stay discoverable (same semantics as tools); get refuses
    assert "dead-prompt" in names

    assert {:error, %Noizu.MCP.Error{}} =
             Custom.handle_get_prompt("dead-prompt", %{}, ctx_for_scope("prompts-mixed"))

    assert {:ok, [%{content: %{text: "About {{topic}}"}}]} =
             Custom.handle_get_prompt("live-prompt", %{}, ctx_for_scope("prompts-mixed"))
  end

  # ── prompts/get ───────────────────────────────────────────────────────────

  test "prompts/get renders the active version with argument substitution" do
    create_scope("prompts-get", %{"groups" => %{"prompts" => %{}}})
    prompt("explain")

    assert {:ok, [%{role: :user, content: content}]} =
             Custom.handle_get_prompt(
               "explain",
               %{"topic" => "ACLs"},
               ctx_for_scope("prompts-get")
             )

    assert content.text == "About ACLs"
  end

  test "prompts/get enforces required arguments and unknown prompts" do
    create_scope("prompts-get2", %{"groups" => %{"prompts" => %{}}})

    {:ok, prompt} =
      MCPrompts.create(%{
        "slug" => "strict",
        "name" => "strict",
        "arguments" => [%{"name" => "topic", "required" => true}]
      })

    {:ok, _} = MCPrompts.publish_version(prompt, "S: {{topic}}", nil)

    assert {:error, %Noizu.MCP.Error{reason: :invalid_params}} =
             Custom.handle_get_prompt("strict", %{}, ctx_for_scope("prompts-get2"))

    assert {:error, %Noizu.MCP.Error{}} =
             Custom.handle_get_prompt("nope", %{}, ctx_for_scope("prompts-get2"))
  end

  test "prompts/get refuses disabled group and disabled entries; hidden group still serves" do
    create_scope("prompts-disabled", %{"groups" => %{"prompts" => %{"disabled" => true}}})

    create_scope("prompts-entry-off", %{
      "groups" => %{"prompts" => %{"entries" => %{"closed" => %{"disabled" => true}}}}
    })

    create_scope("prompts-hidden-get", %{"groups" => %{"prompts" => %{"hidden" => true}}})

    prompt("closed")
    prompt("sneaky2")

    assert {:error, %Noizu.MCP.Error{}} =
             Custom.handle_get_prompt("sneaky2", %{}, ctx_for_scope("prompts-disabled"))

    assert {:error, %Noizu.MCP.Error{}} =
             Custom.handle_get_prompt("closed", %{}, ctx_for_scope("prompts-entry-off"))

    assert {:ok, [%{content: %{text: "About {{topic}}"}}]} =
             Custom.handle_get_prompt("sneaky2", %{}, ctx_for_scope("prompts-hidden-get"))
  end

  # ── resources/list + templates + read ─────────────────────────────────────

  defp seed_resources do
    {:ok, _} =
      MCPResources.create_resource(%{
        "uri" => "notes://tobor/open",
        "name" => "Open",
        "content" => "open body"
      })

    {:ok, _} =
      MCPResources.create_resource(%{
        "uri" => "notes://tobor/hidden",
        "name" => "Hidden",
        "content" => "hidden body"
      })

    {:ok, _} =
      MCPResources.create_template(%{
        "uri_template" => "notes://tobor/pages/{page}",
        "name" => "Pages"
      })
  end

  test "resources/list + templates/list respect group gating and hidden entries" do
    create_scope("resources-on", %{
      "groups" => %{
        "resources" => %{"entries" => %{"notes://tobor/hidden" => %{"hidden" => true}}}
      }
    })

    seed_resources()
    c = ctx_for_scope("resources-on")

    assert {:ok, resources, nil} = Custom.handle_list_resources(nil, c)
    uris = Enum.map(resources, & &1.uri)
    assert "notes://tobor/open" in uris
    refute "notes://tobor/hidden" in uris

    assert {:ok, [template], nil} = Custom.handle_list_resource_templates(nil, c)
    assert template.uri_template == "notes://tobor/pages/{page}"
  end

  test "resources/read serves content; hidden entries still readable; disabled refused" do
    create_scope("resources-read", %{
      "groups" => %{
        "resources" => %{"entries" => %{"notes://tobor/closed" => %{"disabled" => true}}}
      }
    })

    seed_resources()

    {:ok, _} =
      MCPResources.create_resource(%{
        "uri" => "notes://tobor/closed",
        "name" => "Closed",
        "content" => "closed body"
      })

    c = ctx_for_scope("resources-read")

    assert {:ok, "open body"} = Custom.handle_read_resource("notes://tobor/open", c)

    # hidden-but-present entries remain readable (hidden = undiscoverable only)
    assert {:ok, "hidden body"} = Custom.handle_read_resource("notes://tobor/hidden", c)

    assert {:error, %Noizu.MCP.Error{reason: :resource_not_found}} =
             Custom.handle_read_resource("notes://tobor/closed", c)

    assert {:error, %Noizu.MCP.Error{reason: :resource_not_found}} =
             Custom.handle_read_resource("notes://tobor/missing", c)
  end

  test "resources/read refuses when group absent or disabled" do
    create_scope("resources-off", %{"groups" => %{"sessions" => %{}}})
    create_scope("resources-disabled", %{"groups" => %{"resources" => %{"disabled" => true}}})

    seed_resources()

    assert {:error, %Noizu.MCP.Error{reason: :resource_not_found}} =
             Custom.handle_read_resource("notes://tobor/open", ctx_for_scope("resources-off"))

    assert {:ok, [], nil} =
             Custom.handle_list_resources(nil, ctx_for_scope("resources-disabled"))
  end

  # ── scoping through the gateway ───────────────────────────────────────────

  test "gateway scope org restricts visibility: org prompt served to own org, hidden from others" do
    org_id = Ecto.UUID.generate()
    other_org = Ecto.UUID.generate()

    scope =
      create_scope("scoped-prompts", %{"groups" => %{"prompts" => %{}}})

    {:ok, _} =
      NoizuPromptLingua.Repo.update(Ecto.Changeset.change(scope, organization_id: org_id))

    create_scope("other-org-scope", %{"groups" => %{"prompts" => %{}}})

    prompt("global-only")

    {:ok, org_prompt} =
      MCPrompts.create(%{
        "slug" => "org-secret",
        "name" => "org-secret",
        "organization_id" => org_id
      })

    {:ok, _} = MCPrompts.publish_version(org_prompt, "About {{topic}}", nil)

    # own-org scope lists the global + the org rows; get renders the org row
    {:ok, prompts, nil} = Custom.handle_list_prompts(nil, ctx_for_scope("scoped-prompts"))
    names = Enum.map(prompts, & &1.name)
    assert "global-only" in names
    assert "org-secret" in names

    assert {:ok, [%{content: %{text: "About {{topic}}"}}]} =
             Custom.handle_get_prompt("org-secret", %{}, ctx_for_scope("scoped-prompts"))

    # a scope from another org sees the global row but not the org row
    {:ok, other_prompts, nil} =
      Custom.handle_list_prompts(nil, ctx_for_scope("other-org-scope"))

    other_names = Enum.map(other_prompts, & &1.name)
    assert "global-only" in other_names
    refute "org-secret" in other_names

    assert {:error, %Noizu.MCP.Error{}} =
             Custom.handle_get_prompt("org-secret", %{}, ctx_for_scope("other-org-scope"))
  end

  test "normalizer preserves prompts/resources group configs (entries included)" do
    scope =
      create_scope("normalize-check", %{
        "groups" => %{
          "prompts" => %{"hidden" => true, "entries" => %{"x" => %{"disabled" => true}}},
          "resources" => %{}
        }
      })

    groups = get_in(scope.config, ["groups"])
    assert get_in(groups, ["prompts", "hidden"]) == true
    assert get_in(groups, ["prompts", "entries", "x", "disabled"]) == true
    assert Map.has_key?(groups, "resources")
  end
end
