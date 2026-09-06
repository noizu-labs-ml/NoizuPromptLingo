defmodule NoizuPromptLingua.MCP.CustomScopeTest do
  use NoizuPromptLingua.DataCase

  alias Noizu.MCP.Ctx
  alias NoizuPromptLingua.MCP.Custom
  alias NoizuPromptLingua.MCPCustomScopes
  alias NoizuPromptLingua.Tools.{ToolDefinition, ToolHelp, ToolSearch, ToolSummary}

  defp ctx(slug) do
    %Ctx{server: Custom, assigns: %{custom_scope_slug: slug}}
  end

  defp tool_specs(slug) do
    Custom.catalog_specs(ctx(slug))
  end

  test "custom scope combines selected groups and applies disabled/hidden overrides" do
    {:ok, _scope} =
      MCPCustomScopes.create(%{
        "slug" => "ops",
        "name" => "Ops",
        "config" => %{
          "groups" => %{
            "sessions" => %{
              "tools" => %{
                "Session.Create" => %{"disabled" => true},
                "Session.Get" => %{"hidden" => false}
              }
            },
            "tickets" => %{"hidden" => true}
          }
        }
      })

    specs = tool_specs("ops")
    names = Enum.map(specs, & &1.definition.name)

    refute "Session.Create" in names
    assert "Session.Get" in names
    assert "Ticket.Create" in names
    assert Enum.count(names, &(&1 == "ToolSummary")) == 1

    assert Enum.find(specs, &(&1.definition.name == "Session.Get")).hidden == false
    assert Enum.find(specs, &(&1.definition.name == "Ticket.Create")).hidden == true
  end

  test "discovery summary/search/definition are filtered to the custom scope" do
    {:ok, _scope} =
      MCPCustomScopes.create(%{
        "slug" => "sessions-only",
        "name" => "Sessions Only",
        "config" => %{"groups" => %{"sessions" => %{}}}
      })

    c = ctx("sessions-only")

    {:ok, summary} = ToolSummary.call(%{}, c)
    categories = Enum.map(summary.categories, & &1.category)
    assert "Sessions" in categories
    refute "Projects" in categories

    {:ok, search} = ToolSearch.call(%{query: "Project", mode: :text, limit: 10}, c)
    # Text search matches descriptions too — session tools legitimately mention
    # "project" in their docs. The scope contract is that no Project.* tool is
    # reachable, not that the substring never appears. Names emit canonical
    # underscore form (F5): Session_*, never dotted.
    assert search.matches
           |> Enum.map(& &1.name)
           |> Enum.all?(&String.starts_with?(&1, "Session_"))

    refute Enum.any?(search.matches, &String.starts_with?(&1.name, "Project_"))

    {:ok, definitions} = ToolDefinition.call(%{tool: "Session.Get,Project.Get"}, c)
    # dotted input accepted as alias; emitted name is canonical underscore
    assert [%{name: "Session_Get"}] = definitions.definitions
    assert definitions.not_found == ["Project.Get"]
  end

  test "tool-specific help uses the active custom scope" do
    {:ok, _scope} =
      MCPCustomScopes.create(%{
        "slug" => "tickets-only",
        "name" => "Tickets Only",
        "config" => %{"groups" => %{"tickets" => %{}}}
      })

    {:ok, found} =
      ToolHelp.call(%{tool: "Ticket.Create", task: "create a task"}, ctx("tickets-only"))

    # dotted input accepted as alias; echoed name is canonical underscore (F5)
    assert found.tool == "Ticket_Create"

    {:ok, missing} =
      ToolHelp.call(%{tool: "Project.Get", task: "inspect project"}, ctx("tickets-only"))

    assert missing.status == "error"
  end

  test "core session tools are public by default and re-hideable per scope" do
    {:ok, _plain} =
      MCPCustomScopes.create(%{
        "slug" => "plain",
        "name" => "Plain",
        "config" => %{"groups" => %{"sessions" => %{}}}
      })

    {:ok, _lean} =
      MCPCustomScopes.create(%{
        "slug" => "lean",
        "name" => "Lean",
        "config" => %{
          "groups" => %{
            "sessions" => %{"tools" => %{"Session.Create" => %{"hidden" => true}}}
          }
        }
      })

    # Compile-time default: surfaced in tools/list without any override.
    plain = tool_specs("plain")
    assert Enum.find(plain, &(&1.definition.name == "Session.Create")).hidden == false

    # Per-scope override re-hides it — but it stays in the catalog (callable
    # via ToolCall), which is what list_tools rejects on, not this.
    lean_names = tool_specs("lean") |> Enum.map(& &1.definition.name)
    assert "Session.Create" in lean_names
    assert Enum.find(tool_specs("lean"), &(&1.definition.name == "Session.Create")).hidden == true
  end

  # ── alacarte WP1: `display` reserved config key ──────────────────────────────

  describe "display reserved key" do
    @valid_display %{"image" => "abc123shortid", "emoji" => "🚀", "color" => "#ff8800"}

    test "a valid display persists through create" do
      {:ok, scope} =
        MCPCustomScopes.create(%{
          "slug" => "display-1",
          "name" => "Display",
          "config" => %{"groups" => %{"sessions" => %{}}, "display" => @valid_display}
        })

      assert scope.config["display"] == @valid_display
    end

    test "hex3/hex8 and CSS named colors pass" do
      for color <- ["#f80", "#ff8800", "#ff8800cc", "cornflowerblue", "rebeccapurple"] do
        {:ok, scope} =
          MCPCustomScopes.create(%{
            "slug" => "display-#{System.unique_integer([:positive])}",
            "name" => "Display",
            "config" => %{"groups" => %{"sessions" => %{}}, "display" => %{"color" => color}}
          })

        assert scope.config["display"] == %{"color" => color}
      end
    end

    test "non-conforming fields are dropped, conforming ones kept" do
      {:ok, scope} =
        MCPCustomScopes.create(%{
          "slug" => "display-mixed",
          "name" => "Display",
          "config" => %{
            "groups" => %{"sessions" => %{}},
            "display" => %{
              "image" => String.duplicate("a", 513),
              "emoji" => "🚀",
              "color" => "not-a-color",
              "bogus" => "x"
            }
          }
        })

      assert scope.config["display"] == %{"emoji" => "🚀"}
    end

    test "a display that sanitizes to nothing is dropped entirely" do
      for bad <- [
            %{"emoji" => String.duplicate("🚀", 17)},
            %{"color" => 12},
            "red",
            %{"bogus" => "x"}
          ] do
        {:ok, scope} =
          MCPCustomScopes.create(%{
            "slug" => "display-bad-#{System.unique_integer([:positive])}",
            "name" => "Display",
            "config" => %{"groups" => %{"sessions" => %{}}, "display" => bad}
          })

        refute Map.has_key?(scope.config, "display")
      end
    end

    test "absent display carries prior across a group-only edit; empty display too" do
      {:ok, scope} =
        MCPCustomScopes.create(%{
          "slug" => "display-carry",
          "name" => "Display",
          "config" => %{"groups" => %{"sessions" => %{}}, "display" => @valid_display}
        })

      {:ok, updated} =
        MCPCustomScopes.update("display-carry", %{
          "config" => %{"groups" => %{"sessions" => %{}, "tickets" => %{}}}
        })

      assert updated.config["display"] == @valid_display
      assert Map.has_key?(updated.config["groups"], "tickets")

      # an explicit empty display sanitizes to nothing → prior carries (matches
      # the reservation semantics: absent ≠ clear)
      {:ok, kept} =
        MCPCustomScopes.update("display-carry", %{"config" => %{"display" => %{}}})

      assert kept.config["display"] == @valid_display
      _ = scope
    end

    test "a new display replaces the prior one" do
      {:ok, _} =
        MCPCustomScopes.create(%{
          "slug" => "display-replace",
          "name" => "Display",
          "config" => %{"groups" => %{"sessions" => %{}}, "display" => @valid_display}
        })

      {:ok, updated} =
        MCPCustomScopes.update("display-replace", %{
          "config" => %{"display" => %{"emoji" => "🎯", "color" => "#f80"}}
        })

      assert updated.config["display"] == %{"emoji" => "🎯", "color" => "#f80"}
    end
  end

  # ── alacarte WP2: restricted core variant + heal ─────────────────────────────

  describe "restricted core variant" do
    defp unrestricted_core_config do
      %{
        "groups" => %{
          "sessions" => %{"tools" => %{"Session_Manifest" => %{}}},
          "organizations" => %{"tools" => %{}},
          "projects" => %{"tools" => %{}}
        }
      }
    end

    test "fresh core seed is restricted (catalog walk stamps non-essentials)" do
      core = MCPCustomScopes.get_core_variant()
      groups = core.config["groups"]

      sessions = groups["sessions"]["tools"]
      assert sessions["Session_Create"] == %{}
      assert sessions["Session_Overview"] == %{}
      assert sessions["Session_Manifest"] == %{}

      for stripped <- ~w(Session_Get Session_Update Session_List Session_Archive) do
        assert sessions[stripped] == %{"disabled" => true}, stripped
      end

      organizations = groups["organizations"]["tools"]
      assert organizations["Organization_Overview"] == %{}
      assert organizations["Organization_Get"] == %{}

      for stripped <- ~w(Organization_Create Organization_Update Organization_List) do
        assert organizations[stripped] == %{"disabled" => true}, stripped
      end

      projects = groups["projects"]["tools"]
      assert projects["Project_Overview"] == %{}
      assert projects["Project_Get"] == %{}
      assert projects["Project_Create"] == %{"disabled" => true}
    end

    test "heal stamps the policy on a prod-shaped unrestricted core row" do
      {:ok, _} =
        MCPCustomScopes.create(%{
          "slug" => "core",
          "name" => "Core",
          "kind" => "core_variant",
          "config" => unrestricted_core_config()
        })

      core = MCPCustomScopes.get_core_variant()
      sessions = core.config["groups"]["sessions"]["tools"]

      # non-essentials stamped
      assert sessions["Session_Archive"] == %{"disabled" => true}
      # essentials left enabled (heal never adds entries; absent = enabled)
      assert Map.get(sessions, "Session_Create") in [nil, %{}]
      assert Map.get(sessions, "Session_Overview") in [nil, %{}]
      # manifest exempt: present + enabled
      assert sessions["Session_Manifest"] == %{}

      organizations = core.config["groups"]["organizations"]["tools"]
      assert organizations["Organization_Create"] == %{"disabled" => true}
      assert Map.get(organizations, "Organization_Get") in [nil, %{}]

      # other groups untouched; groups not in the core set never appear
      refute Map.has_key?(core.config["groups"], "tickets")
    end

    test "heal clears stray disables on essentials and is idempotent" do
      {:ok, _} =
        MCPCustomScopes.create(%{
          "slug" => "core",
          "name" => "Core",
          "kind" => "core_variant",
          "config" =>
            unrestricted_core_config()
            |> put_in(
              ["groups", "sessions", "tools", "Session_Create"],
              %{"disabled" => true}
            )
            |> put_in(
              ["groups", "sessions", "tools", "Session_Manifest"],
              %{"disabled" => true}
            )
        })

      core = MCPCustomScopes.get_core_variant()
      sessions = core.config["groups"]["sessions"]["tools"]

      # stray disables on essentials cleared
      assert sessions["Session_Create"] == %{}
      assert sessions["Session_Manifest"] == %{}
      assert sessions["Session_Archive"] == %{"disabled" => true}

      # idempotent: a second heal changes nothing
      core2 = MCPCustomScopes.get_core_variant()
      assert core2.config == core.config
    end

    test "user clones of core keep their frozen configs (heal touches the template only)" do
      {:ok, _} =
        MCPCustomScopes.create(%{
          "slug" => "core",
          "name" => "Core",
          "kind" => "core_variant",
          "config" => unrestricted_core_config()
        })

      {:ok, _clone} =
        MCPCustomScopes.copy("core", %{"slug" => "core-clone-frozen", "name" => "Frozen"})

      _healed = MCPCustomScopes.get_core_variant()

      clone = MCPCustomScopes.get_by_slug("core-clone-frozen")
      sessions = clone.config["groups"]["sessions"]["tools"]
      # unrestricted carry-over survives — no policy stamps on the clone
      refute Map.has_key?(sessions, "Session_Archive")
      assert sessions["Session_Manifest"] == %{}
    end
  end

  # ── core endpoints carry the minimal NPL loader pair (root-plane, not a
  #    selectable group) — restricted group surface stays restricted ──────────

  describe "core variant NPL loaders" do
    test "the core endpoint lists NPLLoad/NPLSpec" do
      core = MCPCustomScopes.get_core_variant()
      names = tool_specs(core.slug) |> Enum.map(& &1.definition.name)

      assert "NPLLoad" in names
      assert "NPLSpec" in names
      # loaders ride along; the restricted group surface is unchanged
      # (catalog-level names are dotted; Session_Manifest is underscore-native)
      assert "Session.Create" in names
      refute "Session.Archive" in names
    end

    test "clones of core keep the loaders (lineage, not kind)" do
      _core = MCPCustomScopes.get_core_variant()

      {:ok, clone} =
        MCPCustomScopes.copy("core", %{"slug" => "core-npl-clone", "name" => "Clone"})

      # copy/2 defaults kind to "custom" — the core lineage is what carries them
      assert clone.kind == "custom"

      names = tool_specs("core-npl-clone") |> Enum.map(& &1.definition.name)
      assert "NPLLoad" in names
      assert "NPLSpec" in names
    end

    test "tobor-lineage clones are unchanged: still list the loaders" do
      {:ok, _} =
        MCPCustomScopes.create(%{
          "slug" => "tobor-npl-clone",
          "name" => "Tobor Clone",
          "source_template_slug" => MCPCustomScopes.default_package_slug(),
          "config" => %{"groups" => %{"sessions" => %{}}}
        })

      names = tool_specs("tobor-npl-clone") |> Enum.map(& &1.definition.name)
      assert "NPLLoad" in names
      assert "NPLSpec" in names
    end

    test "plain custom scopes without core/tobor lineage do not list the loaders" do
      {:ok, _} =
        MCPCustomScopes.create(%{
          "slug" => "npl-less",
          "name" => "No Loaders",
          "config" => %{"groups" => %{"sessions" => %{}}}
        })

      names = tool_specs("npl-less") |> Enum.map(& &1.definition.name)
      refute "NPLLoad" in names
      refute "NPLSpec" in names
    end

    test "NPLLoad dispatches on the core endpoint" do
      _core = MCPCustomScopes.get_core_variant()

      # success path returns a bare ToolResult (Dispatch convention)
      result =
        NoizuPromptLingua.MCP.Dispatch.call(
          Custom,
          "NPLLoad",
          %{"expression" => "syntax"},
          ctx(MCPCustomScopes.core_variant_slug())
        )

      assert %Noizu.MCP.Types.ToolResult{} = result
      refute result.is_error

      # and the same dispatch is refused on a scope without the loaders
      {:ok, _} =
        MCPCustomScopes.create(%{
          "slug" => "npl-less-dispatch",
          "name" => "No Loaders Dispatch",
          "config" => %{"groups" => %{"sessions" => %{}}}
        })

      assert {:error, _} =
               NoizuPromptLingua.MCP.Dispatch.call(
                 Custom,
                 "NPLLoad",
                 %{"expression" => "syntax"},
                 ctx("npl-less-dispatch")
               )
    end
  end

  # ── alacarte WP2: core/full presets ──────────────────────────────────────────

  describe "core/full presets" do
    test "presets/0: core over the core-variant groups, full over every customizable group" do
      presets = MCPCustomScopes.presets()
      assert presets["core"].groups == ~w(sessions projects organizations)

      full_groups = presets["full"].groups
      assert length(full_groups) == length(NoizuPromptLingua.MCPServers.customizable())

      assert MapSet.subset?(
               MapSet.new(~w(sessions projects organizations)),
               MapSet.new(full_groups)
             )
    end

    test "preset_tool_sets/1: core expands to the policy + manifest; unknown rejected" do
      assert {:ok, core_set} = MCPCustomScopes.preset_tool_sets("core")

      for name <- ~w(Organization_Overview Organization_Get Project_Overview Project_Get
                     Session_Create Session_Overview Session_Manifest) do
        assert MapSet.member?(core_set, name), name
      end

      for stripped <- ~w(Session_Get Session_Archive Organization_Create Project_Create) do
        refute MapSet.member?(core_set, stripped), stripped
      end

      assert :unknown_preset = MCPCustomScopes.preset_tool_sets("nope")
      assert :unknown_preset = MCPCustomScopes.preset_tool_sets(nil)
    end

    test "preset_tool_sets/1: full covers every catalog tool (core ⊆ full); basic_crud restricted" do
      assert {:ok, core_set} = MCPCustomScopes.preset_tool_sets("core")
      assert {:ok, full_set} = MCPCustomScopes.preset_tool_sets("full")

      assert MapSet.subset?(core_set, full_set)

      for name <- ~w(Session_Archive Session_Get Session_Update Session_List
                     Organization_Create Organization_Update Project_Create Project_List) do
        assert MapSet.member?(full_set, name), name
      end

      assert {:ok, crud_set} = MCPCustomScopes.preset_tool_sets("basic_crud")
      for name <- ~w(Session_Create Session_Get Session_List Ticket_List Ticket_Create) do
        assert MapSet.member?(crud_set, name), name
      end

      for stripped <- ~w(Session_Archive Ticket_Comment Ticket_Watch) do
        refute MapSet.member?(crud_set, stripped), stripped
      end
    end

    test "preset_config/1 seeds the restricted core stamps" do
      assert %{"groups" => groups} = MCPCustomScopes.preset_config("core")

      tools = groups["sessions"]["tools"]
      # enabled tools are absent from the tools map; only non-essentials stamped
      refute Map.has_key?(tools, "Session_Create")
      refute Map.has_key?(tools, "Session_Overview")
      assert tools["Session_Manifest"] == %{}
      assert tools["Session_Get"] == %{"disabled" => true}
      assert tools["Session_Archive"] == %{"disabled" => true}

      assert %{"groups" => full_groups} = MCPCustomScopes.preset_config("full")
      # :all = no stamps; the manifest keeps its explicit sessions entry
      assert full_groups["sessions"]["tools"] == %{"Session_Manifest" => %{}}
      assert full_groups["organizations"]["tools"] == %{}
      assert full_groups["projects"]["tools"] == %{}
    end

    test "create with the core preset seeds a restricted scope" do
      {:ok, scope} =
        MCPCustomScopes.create(%{
          "slug" => "preset-core",
          "name" => "Preset Core",
          "preset" => "core"
        })

      sessions = scope.config["groups"]["sessions"]["tools"]
      assert sessions["Session_List"] == %{"disabled" => true}
      assert sessions["Session_Manifest"] == %{}
      refute Map.has_key?(sessions, "Session_Create")

      {:ok, full} =
        MCPCustomScopes.create(%{
          "slug" => "preset-full",
          "name" => "Preset Full",
          "preset" => "full"
        })

      assert full.config["groups"]["projects"]["tools"] == %{}
      # full covers every customizable group, all tools enabled (no stamps)
      assert map_size(full.config["groups"]) ==
               length(NoizuPromptLingua.MCPServers.customizable())
    end
  end
end
