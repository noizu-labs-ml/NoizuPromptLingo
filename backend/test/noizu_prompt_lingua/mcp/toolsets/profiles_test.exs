defmodule NoizuPromptLingua.MCP.Toolsets.ProfilesTest do
  @moduledoc """
  N2a profiles-as-data matrix (PRD-N2 AC-2A-7): the built-in profile slugs,
  expanded group lists vs. the MCPServers registry, annotation-registry inverse
  consistency, the core restricted per-tool policy, and the compile-time
  registry validation (negative compile-check via `Code.compile_string`).

  No DB — the registry is pure code (Decision 4).
  """
  use ExUnit.Case, async: true

  alias NoizuPromptLingua.MCPServers
  alias NoizuPromptLingua.MCP.Toolsets.Profiles

  @customizable_ids Enum.map(MCPServers.customizable(), & &1.id)

  # R1 profile memberships (PRD-N2 FR-2A-8), sorted for order-insensitive
  # comparison; `full` is asserted exact (== customizable, registry order).
  @r1 %{
    "agent-ops" => ~w(organizations sessions projects notifications memory),
    "pm-dev" => ~w(projects tickets review github instructions sessions),
    "content" => ~w(artifacts assets wiki markdown market campaigns customers unicode),
    "comms" => ~w(chat notifications pubsub personas memory wiki)
  }

  describe "slugs" do
    test "the canonical slugs in order" do
      assert Profiles.slugs() == ["full", "agent-ops", "pm-dev", "content", "comms", "core"]
    end

    test "get/1 returns DATA for each slug and nil for unknown" do
      for slug <- Profiles.slugs() do
        profile = Profiles.get(slug)
        assert profile.slug == slug
        assert is_binary(profile.label) and profile.label != ""
        assert is_binary(profile.description) and profile.description != ""
        assert profile.groups != []
      end

      assert Profiles.get("nope") == nil
      assert Profiles.get("root") == nil
    end

    test "all/0 covers every slug" do
      assert Enum.map(Profiles.all(), & &1.slug) == Profiles.slugs()
    end
  end

  describe "group expansion" do
    test "full == MCPServers.customizable() (21 ids, registry order)" do
      assert Profiles.groups_for("full") == @customizable_ids
      assert length(@customizable_ids) == 21
      refute "root" in Profiles.groups_for("full")
    end

    test "each R1 capability profile matches its membership list" do
      for {slug, expected} <- @r1 do
        assert Enum.sort(Profiles.groups_for(slug)) == Enum.sort(expected),
               "profile #{slug} expansion drifted from the R1 list"

        # Full is a strict superset of every capability profile.
        assert Profiles.groups_for(slug) -- Profiles.groups_for("full") == []
      end
    end

    test "every expanded group id resolves in the @servers registry" do
      for slug <- Profiles.slugs(), group_id <- Profiles.groups_for(slug) do
        assert group_id in @customizable_ids,
               "#{slug} expands to unknown group #{inspect(group_id)}"
      end
    end

    test "browser participates only in full (no capability annotation)" do
      assert "browser" in Profiles.groups_for("full")

      for slug <- @r1 |> Map.keys() do
        refute "browser" in Profiles.groups_for(slug)
      end
    end
  end

  describe "core policy profile (restricted starter surface)" do
    @core_policy %{
      "organizations" => ~w(Organization_Overview Organization_Get),
      "projects" => ~w(Project_Overview Project_Get),
      "sessions" => ~w(Session_Create Session_Overview Session_Manifest)
    }

    test "core is a reserved slug expanding to exactly the three restricted groups" do
      assert "core" in Profiles.slugs()
      assert Enum.sort(Profiles.groups_for("core")) == ~w(organizations projects sessions)

      # Member of `full`'s universe, and every group resolves in the registry
      # (the shared slugs-loop assertion covers this too — kept local for the
      # failure message).
      for group_id <- Profiles.groups_for("core") do
        assert group_id in @customizable_ids
        assert "core" in Profiles.groups_for_tool(group_id)
      end
    end

    test "core carries the 7-tool allowlist; every other profile is group-grain" do
      assert Profiles.get("core").tools == @core_policy
      assert @core_policy |> Map.values() |> Enum.map(&length/1) |> Enum.sum() == 7

      for slug <- Profiles.slugs() -- ["core"] do
        assert Profiles.get(slug).tools == nil, "unexpected per-tool policy on #{slug}"
      end
    end

    test "core clone_config stamps disabled on non-essential catalog tools" do
      config = Profiles.clone_config("core")

      assert MapSet.new(Map.keys(config["groups"])) ==
               MapSet.new(~w(organizations projects sessions))

      for {group_id, essential} <- @core_policy do
        group = config["groups"][group_id]
        assert group["enabled"] == true
        assert is_map(group["tools"]) and map_size(group["tools"]) > 0

        for {name, cfg} <- group["tools"] do
          if name in essential do
            assert cfg == %{}, "expected #{name} enabled (default entry)"
          else
            assert cfg == %{"enabled" => false}, "expected #{name} stamped disabled"
          end
        end

        for name <- essential do
          assert Map.has_key?(group["tools"], name),
                 "#{name} missing from #{group_id}'s live catalog walk"
        end
      end
    end

    test "group-grain clone_config stays group-grain (no per-tool stamps)" do
      config = Profiles.clone_config("pm-dev")
      assert MapSet.new(Map.keys(config["groups"])) == MapSet.new(Profiles.groups_for("pm-dev"))
      assert Enum.all?(Map.values(config["groups"]), &(&1 == %{"enabled" => true}))
    end

    test "core custom/1 is immutable and carries the allowlist as static ops" do
      custom = Profiles.custom("core")
      assert custom.immutable
      assert custom.slug == "profile:core"

      essentials = List.flatten(Map.values(@core_policy))

      refute custom.tools == %{}

      for {name, ops} <- custom.tools do
        canonical = NoizuPromptLingua.MCP.ToolNames.canonical(name)
        refute canonical in essentials, "essential #{name} must not carry override ops"

        assert Enum.sort(Enum.map(ops, & &1.op)) == [:set_callable, :set_visible]
        assert Enum.all?(ops, &(&1.value == false))
      end
    end
  end

  describe "annotation inverse (groups_for_tool/1)" do
    test "inverse is consistent with the forward expansion" do
      for slug <- Profiles.slugs(), group_id <- Profiles.groups_for(slug) do
        assert slug in Profiles.groups_for_tool(group_id)
      end
    end

    test "every customizable group resolves (full covers the unannotated)" do
      for group_id <- @customizable_ids do
        assert "full" in Profiles.groups_for_tool(group_id)
      end
    end

    test "unknown groups resolve to nothing" do
      assert Profiles.groups_for_tool("root") == []
      assert Profiles.groups_for_tool("not-a-group") == []
      assert Profiles.groups_for_tool(nil) == []
    end

    test "capability slugs follow the annotations" do
      assert Profiles.groups_for_tool("tickets") == ["full", "pm-dev"]
      assert Profiles.groups_for_tool("wiki") == ["full", "content", "comms"]
      assert Profiles.groups_for_tool("browser") == ["full"]
    end
  end

  describe "compile-time registry validation (Decision 4 / AC-2A-7)" do
    test "the shipped registry validates" do
      assert Profiles.validate_registry!(
               Enum.map(@customizable_ids, &{&1, ["full"]}) |> Map.new(),
               @customizable_ids,
               Profiles.slugs()
             ) == :ok
    end

    test "an unknown group id raises" do
      assert_raise ArgumentError, ~r/unknown MCP group id "bogus-group"/, fn ->
        Profiles.validate_registry!(
          %{"bogus-group" => ["full"]},
          @customizable_ids,
          Profiles.slugs()
        )
      end
    end

    test "an unknown profile slug raises" do
      assert_raise ArgumentError, ~r/unknown profile slug "freelance"/, fn ->
        Profiles.validate_registry!(
          %{"tickets" => ["freelance"]},
          @customizable_ids,
          Profiles.slugs()
        )
      end
    end

    # Negative compile-check: a fixture module carrying a bad @profile_groups
    # annotation fails COMPILATION, mirroring the shipped after_compile check.
    # Module-body raises surface as the ORIGINAL ArgumentError (not wrapped in
    # CompileError) under Code.compile_string on this Elixir. Note:
    # compile_string does NOT interpolate, so the unique suffix is interpolated
    # into the source BEFORE compile_string sees it.
    test "a fixture module with an unknown group fails to compile" do
      assert_raise ArgumentError, ~r/unknown MCP group id "phantom"/, fn ->
        fixture("""
        defmodule N2aBadGroupRegistry_#{:erlang.unique_integer([:positive])} do
          _ = NoizuPromptLingua.MCP.Toolsets.Profiles.validate_registry!(
                %{"phantom" => ["full"]},
                NoizuPromptLingua.MCPServers.customizable() |> Enum.map(& &1.id),
                NoizuPromptLingua.MCP.Toolsets.Profiles.slugs()
              )
        end
        """)
      end
    end

    test "a fixture module with an unknown slug fails to compile" do
      assert_raise ArgumentError, ~r/unknown profile slug "phantom-slug"/, fn ->
        fixture("""
        defmodule N2aBadSlugRegistry_#{:erlang.unique_integer([:positive])} do
          _ = NoizuPromptLingua.MCP.Toolsets.Profiles.validate_registry!(
                %{"tickets" => ["phantom-slug"]},
                NoizuPromptLingua.MCPServers.customizable() |> Enum.map(& &1.id),
                NoizuPromptLingua.MCP.Toolsets.Profiles.slugs()
              )
        end
        """)
      end
    end
  end

  defp fixture(source), do: Code.compile_string(source)
end
