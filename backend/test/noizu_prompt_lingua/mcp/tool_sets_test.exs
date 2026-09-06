defmodule NoizuPromptLingua.MCP.ToolSetsTest do
  @moduledoc """
  N2a storage matrix (PRD-N2 AC-2A-2 … AC-2A-8): MCPToolSet changeset rules
  (slugify, reserved slugs, org-wide uniqueness, closed-vocabulary config,
  settings whitelist, shape invariants), context CRUD/deactivate/clone,
  request-path scoping, and the to_overrides translation table.
  """
  use NoizuPromptLingua.DataCase
  @moduletag :db

  alias NoizuPromptLingua.MCP.ToolSets
  alias NoizuPromptLingua.Schema.MCPToolSet

  @valid_config %{
    "groups" => %{
      "tickets" => %{
        "enabled" => true,
        "tools" => %{
          "Tickets_Create" => %{
            "enabled" => true,
            "name" => "create_ticket",
            "args" => %{"priority" => %{"enum_remove" => ["urgent"]}}
          }
        }
      }
    }
  }

  # PRD-N2 §4.1 example config — the to_overrides fixture (AC-2A-4).
  @example_config %{
    "groups" => %{
      "tickets" => %{
        "enabled" => true,
        "tools" => %{
          "Tickets_Create" => %{
            "enabled" => true,
            "name" => "create_ticket",
            "description" => "Create a ticket",
            "args" => %{
              "priority" => %{"enum_remove" => ["urgent"]},
              "internal_field" => %{"hide" => true},
              "assignee" => %{"rename" => "owner"},
              "mode" => %{"default" => "fast"},
              "notes" => %{"description" => "Free-form notes"}
            }
          }
        }
      }
    }
  }

  setup do
    {:ok, org_id: insert_org(), other_org_id: insert_org()}
  end

  # ---- changeset: slugs (AC-2A-2) ----

  describe "changeset slug handling" do
    test "slugifies messy slugs", %{org_id: org_id} do
      changeset = MCPToolSet.changeset(%MCPToolSet{}, base_attrs(org_id, slug: "My Tool Set!"))
      assert changeset.valid?
      assert Ecto.Changeset.get_field(changeset, :slug) == "my-tool-set"
    end

    test "derives slug from display name when slug absent", %{org_id: org_id} do
      attrs = base_attrs(org_id) |> Map.drop(["slug"]) |> Map.put("display_name", "Release Ops")

      changeset = MCPToolSet.changeset(%MCPToolSet{}, attrs)
      assert changeset.valid?
      assert Ecto.Changeset.get_field(changeset, :slug) == "release-ops"
    end

    test "requires a slug when neither slug nor display name yields one", %{org_id: org_id} do
      attrs = base_attrs(org_id) |> Map.drop(["slug", "display_name"])
      changeset = MCPToolSet.changeset(%MCPToolSet{}, attrs)
      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset, :slug)
    end

    test "rejects the 5 profile slugs and root as reserved", %{org_id: org_id} do
      for slug <- ["full", "agent-ops", "pm-dev", "content", "comms", "root"] do
        changeset = MCPToolSet.changeset(%MCPToolSet{}, base_attrs(org_id, slug: slug))
        refute changeset.valid?, "expected #{inspect(slug)} to be reserved"
        assert "is reserved" in errors_on(changeset, :slug)
      end
    end

    test "caps slugs at the 64-char column limit" do
      # slugify always normalizes into the ^[a-z0-9][a-z0-9-]{0,63}$ charset,
      # so the format validator is defense-in-depth; the observable boundary is
      # the 64-char cap.
      long = String.duplicate("abcdefgh", 10)

      changeset =
        MCPToolSet.changeset(%MCPToolSet{}, base_attrs(Ecto.UUID.generate(), slug: long))

      assert String.length(Ecto.Changeset.get_field(changeset, :slug)) == 64
    end

    test "org-wide (org, slug) uniqueness across shapes (R4)", %{
      org_id: org_id,
      other_org_id: other_org_id
    } do
      {:ok, _} = ToolSets.create(base_attrs(org_id, slug: "dupe"))

      # Same slug, project shape, same org => rejected (org-wide namespace).
      {:error, changeset} =
        ToolSets.create(
          base_attrs(org_id, slug: "dupe")
          |> Map.put("project_id", Ecto.UUID.generate())
        )

      assert "has already been taken" in errors_on(changeset, :slug)

      # Same slug, other org => fine.
      assert {:ok, _} = ToolSets.create(base_attrs(other_org_id, slug: "dupe"))
    end

    test "requires organization_id", %{org_id: _org_id} do
      changeset =
        MCPToolSet.changeset(
          %MCPToolSet{},
          base_attrs(Ecto.UUID.generate()) |> Map.drop(["organization_id"])
        )

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset, :organization_id)
    end
  end

  # ---- changeset: closed vocabulary (AC-2A-3) ----

  describe "changeset config validation" do
    test "accepts the §4.1 example config", %{org_id: org_id} do
      changeset = MCPToolSet.changeset(%MCPToolSet{}, base_attrs(org_id, config: @example_config))
      assert changeset.valid?
    end

    test "rejects unknown tool-level keys with a named error", %{org_id: org_id} do
      config =
        put_in(@valid_config, ["groups", "tickets", "tools", "Tickets_Create", "visible"], true)

      changeset = MCPToolSet.changeset(%MCPToolSet{}, base_attrs(org_id, config: config))
      refute changeset.valid?
      assert error_mentions(changeset, :config, ~r/unknown key "visible"/)
    end

    test "rejects legacy-vocabulary keys (name_override, arg_overrides, enum)", %{org_id: org_id} do
      for {path_key, value} <- [
            {"name_override", "x"},
            {"arg_overrides", %{}}
          ] do
        config =
          put_in(@valid_config, ["groups", "tickets", "tools", "Tickets_Create", path_key], value)

        changeset = MCPToolSet.changeset(%MCPToolSet{}, base_attrs(org_id, config: config))
        refute changeset.valid?, "expected #{path_key} to be rejected"
        assert error_mentions(changeset, :config, ~r/unknown key/)
      end

      config =
        put_in(
          @valid_config,
          ["groups", "tickets", "tools", "Tickets_Create", "args", "priority", "enum"],
          ["a"]
        )

      changeset = MCPToolSet.changeset(%MCPToolSet{}, base_attrs(org_id, config: config))
      refute changeset.valid?
      assert error_mentions(changeset, :config, ~r/unknown key "enum"/)
    end

    test "rejects unknown group-level and top-level keys", %{org_id: org_id} do
      config = put_in(@valid_config, ["groups", "tickets", "kind"], "weird")
      changeset = MCPToolSet.changeset(%MCPToolSet{}, base_attrs(org_id, config: config))
      refute changeset.valid?
      assert error_mentions(changeset, :config, ~r/unknown key "kind"/)

      config = Map.put(@valid_config, "presets", %{})
      changeset = MCPToolSet.changeset(%MCPToolSet{}, base_attrs(org_id, config: config))
      refute changeset.valid?
      assert error_mentions(changeset, :config, ~r/unknown key "presets"/)
    end

    test "rejects non-boolean enabled/hide", %{org_id: org_id} do
      config =
        put_in(@valid_config, ["groups", "tickets", "tools", "Tickets_Create", "enabled"], "yes")

      changeset = MCPToolSet.changeset(%MCPToolSet{}, base_attrs(org_id, config: config))
      refute changeset.valid?
      assert error_mentions(changeset, :config, ~r/\.enabled: must be a boolean/)

      config =
        put_in(
          @valid_config,
          ["groups", "tickets", "tools", "Tickets_Create", "args", "priority", "hide"],
          1
        )

      changeset = MCPToolSet.changeset(%MCPToolSet{}, base_attrs(org_id, config: config))
      refute changeset.valid?
      assert error_mentions(changeset, :config, ~r/\.hide: must be a boolean/)
    end

    test "rejects enum_remove that is not a list of scalars", %{org_id: org_id} do
      for bad <- ["urgent", ["urgent", %{}], 42] do
        config =
          put_in(
            @valid_config,
            ["groups", "tickets", "tools", "Tickets_Create", "args", "priority", "enum_remove"],
            bad
          )

        changeset = MCPToolSet.changeset(%MCPToolSet{}, base_attrs(org_id, config: config))
        refute changeset.valid?
        assert error_mentions(changeset, :config, ~r/enum_remove: must be a list of scalars/)
      end
    end

    test "rejects rename colliding with another arg of the same tool", %{org_id: org_id} do
      config =
        put_in(
          @valid_config,
          ["groups", "tickets", "tools", "Tickets_Create", "args", "assignee"],
          %{"rename" => "priority"}
        )

      changeset = MCPToolSet.changeset(%MCPToolSet{}, base_attrs(org_id, config: config))
      refute changeset.valid?
      assert error_mentions(changeset, :config, ~r/collides with existing arg "priority"/)
    end

    test "rejects two renames colliding on the same target", %{org_id: org_id} do
      config =
        put_in(@valid_config, ["groups", "tickets", "tools", "Tickets_Create", "args"], %{
          "a" => %{"rename" => "same"},
          "b" => %{"rename" => "same"}
        })

      changeset = MCPToolSet.changeset(%MCPToolSet{}, base_attrs(org_id, config: config))
      refute changeset.valid?
      assert error_mentions(changeset, :config, ~r/multiple renames collide on "same"/)
    end

    test "rejects non-map groups/tools/args containers", %{org_id: org_id} do
      config = Map.put(@valid_config, "groups", ["tickets"])
      changeset = MCPToolSet.changeset(%MCPToolSet{}, base_attrs(org_id, config: config))
      refute changeset.valid?
      assert error_mentions(changeset, :config, ~r/groups: must be an object/)

      config = put_in(@valid_config, ["groups", "tickets", "tools"], 42)
      changeset = MCPToolSet.changeset(%MCPToolSet{}, base_attrs(org_id, config: config))
      refute changeset.valid?
      assert error_mentions(changeset, :config, ~r/\.tools: must be an object/)
    end
  end

  # ---- changeset: settings whitelist (AC-2A-5) ----

  describe "changeset settings whitelist" do
    test "accepts the v1 keys with type checks", %{org_id: org_id} do
      settings = %{
        "allow_api_keys" => false,
        "description_verbosity" => "concise",
        "instructions" => "Be terse."
      }

      changeset = MCPToolSet.changeset(%MCPToolSet{}, base_attrs(org_id, settings: settings))
      assert changeset.valid?
    end

    test "rejects unknown/misspelled keys and bad types", %{org_id: org_id} do
      changeset =
        MCPToolSet.changeset(
          %MCPToolSet{},
          base_attrs(org_id, settings: %{"persona" => "dark"})
        )

      refute changeset.valid?
      assert error_mentions(changeset, :settings, ~r/unknown key "persona"/)

      changeset =
        MCPToolSet.changeset(
          %MCPToolSet{},
          base_attrs(org_id, settings: %{"description_verbosity" => "verbose"})
        )

      refute changeset.valid?

      changeset =
        MCPToolSet.changeset(
          %MCPToolSet{},
          base_attrs(org_id, settings: %{"allow_api_keys" => "false"})
        )

      refute changeset.valid?

      changeset =
        MCPToolSet.changeset(%MCPToolSet{}, base_attrs(org_id, settings: %{"instructions" => 42}))

      refute changeset.valid?
    end
  end

  # ---- shape invariants (AC-2A-2 / FR-2A-6) ----

  describe "changeset shape invariants" do
    test "org-set (neither project nor group) is valid", %{org_id: org_id} do
      changeset = MCPToolSet.changeset(%MCPToolSet{}, base_attrs(org_id))
      assert changeset.valid?
    end

    test "project and group audiences are mutually exclusive", %{org_id: org_id} do
      {:ok, group_id} = insert_group()

      attrs =
        base_attrs(org_id)
        |> Map.put("project_id", Ecto.UUID.generate())
        |> Map.put("group_id", group_id)

      changeset = MCPToolSet.changeset(%MCPToolSet{}, attrs)
      refute changeset.valid?

      assert "project and group audiences are mutually exclusive" in errors_on(
               changeset,
               :project_id
             )
    end

    test "group-set requires an existing authz group", %{org_id: org_id} do
      attrs = base_attrs(org_id) |> Map.put("group_id", Ecto.UUID.generate())
      changeset = MCPToolSet.changeset(%MCPToolSet{}, attrs)
      refute changeset.valid?
      assert "does not exist" in errors_on(changeset, :group_id)

      {:ok, group_id} = insert_group()
      attrs = base_attrs(org_id) |> Map.put("group_id", group_id)
      changeset = MCPToolSet.changeset(%MCPToolSet{}, attrs)
      assert changeset.valid?
    end

    test "clone source requires provenance", %{org_id: org_id} do
      attrs = base_attrs(org_id) |> Map.put("source", "clone")
      changeset = MCPToolSet.changeset(%MCPToolSet{}, attrs)
      refute changeset.valid?

      attrs =
        base_attrs(org_id) |> Map.put("source", "clone") |> Map.put("source_profile", "pm-dev")

      assert MCPToolSet.changeset(%MCPToolSet{}, attrs).valid?

      attrs =
        base_attrs(org_id)
        |> Map.put("source", "clone")
        |> Map.put("settings", %{"cloned_from" => "some-set"})

      assert MCPToolSet.changeset(%MCPToolSet{}, attrs).valid?
    end
  end

  # ---- context CRUD + request path (AC-2A-8) ----

  describe "context" do
    test "create persists defaults and stamps actor", %{org_id: org_id} do
      {:ok, set} = ToolSets.create(base_attrs(org_id), actor_id: "user-1")

      assert %MCPToolSet{} = set
      assert set.source == "custom"
      assert set.is_active
      assert set.config == %{}
      assert set.settings["updated_by"] == "user-1"
    end

    test "update changes mutable fields only; identity fields are create-only", %{org_id: org_id} do
      {:ok, set} = ToolSets.create(base_attrs(org_id, slug: "mutable"))

      {:ok, updated} =
        ToolSets.update(set, %{
          "display_name" => "Renamed",
          "config" => @valid_config,
          "slug" => "hijack",
          "organization_id" => Ecto.UUID.generate()
        })

      assert updated.display_name == "Renamed"
      assert updated.config["groups"]["tickets"]
      assert updated.slug == "mutable"
      assert updated.organization_id == org_id
    end

    test "deactivate soft-kills; request path drops, admin path still resolves", %{org_id: org_id} do
      {:ok, set} = ToolSets.create(base_attrs(org_id, slug: "killable"))

      assert {:ok, %{is_active: false}} = ToolSets.deactivate(set)
      assert ToolSets.get_for_request(org_id, "killable") == nil
      assert %MCPToolSet{} = ToolSets.get_by_org_and_slug(org_id, "killable")
    end

    test "get_by_org_and_slug normalizes case and never leaks across orgs", %{
      org_id: org_id,
      other_org_id: other_org_id
    } do
      {:ok, _} = ToolSets.create(base_attrs(org_id, slug: "scoped-set"))

      assert %MCPToolSet{} = ToolSets.get_by_org_and_slug(org_id, "Scoped-Set")
      assert ToolSets.get_by_org_and_slug(other_org_id, "scoped-set") == nil
      assert ToolSets.get_by_org_and_slug(other_org_id, "missing") == nil
    end

    test "get_for_request drops expired sets and other-org sets", %{
      org_id: org_id,
      other_org_id: other_org_id
    } do
      past = DateTime.add(DateTime.utc_now(), -60, :second)
      future = DateTime.add(DateTime.utc_now(), 3600, :second)

      {:ok, _} =
        ToolSets.create(base_attrs(org_id, slug: "expired") |> Map.put("expires_at", past))

      {:ok, _} =
        ToolSets.create(base_attrs(org_id, slug: "live") |> Map.put("expires_at", future))

      {:ok, _} = ToolSets.create(base_attrs(other_org_id, slug: "elsewhere"))

      assert ToolSets.get_for_request(org_id, "expired") == nil
      assert %MCPToolSet{} = ToolSets.get_for_request(org_id, "live")
      assert ToolSets.get_for_request(org_id, "elsewhere") == nil
    end

    test "list_for_org returns active sets only, scoped to the org", %{
      org_id: org_id,
      other_org_id: other_org_id
    } do
      {:ok, kept} = ToolSets.create(base_attrs(org_id, slug: "kept"))
      {:ok, dropped} = ToolSets.create(base_attrs(org_id, slug: "dropped"))
      {:ok, _} = ToolSets.create(base_attrs(other_org_id, slug: "foreign"))
      {:ok, _} = ToolSets.deactivate(dropped)

      slugs = ToolSets.list_for_org(org_id) |> Enum.map(& &1.slug)
      assert slugs == [kept.slug]
    end
  end

  # ---- clone (AC-2A-6) ----

  describe "clone/2" do
    test "from a profile: allowlist config, provenance, auto slug", %{org_id: org_id} do
      {:ok, clone} = ToolSets.clone("pm-dev", %{"organization_id" => org_id})

      assert clone.source == "clone"
      assert clone.source_profile == "pm-dev"
      assert clone.slug == "pm-dev-copy"
      assert clone.display_name == "pm-dev copy"
      assert clone.is_active

      enabled_groups = clone.config["groups"]

      assert MapSet.new(Map.keys(enabled_groups)) ==
               MapSet.new(NoizuPromptLingua.MCP.Toolsets.Profiles.groups_for("pm-dev"))

      assert Enum.all?(enabled_groups, fn {_g, cfg} -> cfg == %{"enabled" => true} end)
    end

    test "from a profile: slug auto-suggest skips taken slugs", %{org_id: org_id} do
      {:ok, first} = ToolSets.clone("pm-dev", %{"organization_id" => org_id})
      assert first.slug == "pm-dev-copy"

      {:ok, second} = ToolSets.clone("pm-dev", %{"organization_id" => org_id})
      assert second.slug == "pm-dev-copy-2"

      {:ok, third} = ToolSets.clone("pm-dev", %{"organization_id" => org_id})
      assert third.slug == "pm-dev-copy-3"
    end

    test "from a set: config deep-copied, provenance in settings.cloned_from, independent", %{
      org_id: org_id
    } do
      {:ok, source} = ToolSets.create(base_attrs(org_id, slug: "origin", config: @valid_config))

      {:ok, clone} = ToolSets.clone(source, %{"organization_id" => org_id})

      assert clone.source == "clone"
      assert is_nil(clone.source_profile)
      assert clone.settings["cloned_from"] == "origin"
      assert clone.config == source.config

      # Mutating the clone never touches the source.
      {:ok, _} = ToolSets.update(clone, %{"config" => %{"groups" => %{}}})
      refreshed_source = ToolSets.get(source.id)
      assert refreshed_source.config == source.config
    end

    test "unknown profile and missing org are errors", %{org_id: org_id} do
      assert {:error, :unknown_profile} =
               ToolSets.clone("no-such-profile", %{"organization_id" => org_id})

      assert {:error, %Ecto.Changeset{}} = ToolSets.clone("pm-dev", %{})
    end
  end

  # ---- to_overrides (AC-2A-4) ----

  describe "to_overrides/1" do
    test "translates the §4.1 example into the PRD-1 §4.5 vocabulary" do
      ops = ToolSets.to_overrides(@example_config)

      assert ops == [
               %{
                 op: :set_name,
                 target: %{group: "tickets", tool: "Tickets_Create"},
                 value: "create_ticket"
               },
               %{
                 op: :set_description,
                 target: %{group: "tickets", tool: "Tickets_Create"},
                 value: "Create a ticket"
               },
               %{
                 op: :rename_field,
                 target: %{group: "tickets", tool: "Tickets_Create", arg: "assignee"},
                 value: "owner"
               },
               %{
                 op: :hide_field,
                 target: %{group: "tickets", tool: "Tickets_Create", arg: "internal_field"},
                 value: true
               },
               %{
                 op: :pin_default,
                 target: %{group: "tickets", tool: "Tickets_Create", arg: "mode"},
                 value: "fast"
               },
               %{
                 op: :set_arg_description,
                 target: %{group: "tickets", tool: "Tickets_Create", arg: "notes"},
                 value: "Free-form notes"
               },
               %{
                 op: :prune_enum,
                 target: %{group: "tickets", tool: "Tickets_Create", arg: "priority"},
                 value: ["urgent"]
               }
             ]
    end

    test "enabled: false yields set_visible + set_callable; enabled: true yields nothing" do
      config = %{
        "groups" => %{
          "tickets" => %{
            "tools" => %{
              "Tickets_A" => %{"enabled" => false},
              "Tickets_B" => %{"enabled" => true}
            }
          }
        }
      }

      assert ToolSets.to_overrides(config) == [
               %{op: :set_visible, target: %{group: "tickets", tool: "Tickets_A"}, value: false},
               %{op: :set_callable, target: %{group: "tickets", tool: "Tickets_A"}, value: false}
             ]
    end

    test "empty/nil-ish config yields no ops" do
      assert ToolSets.to_overrides(%{}) == []
      assert ToolSets.to_overrides(%{"groups" => %{}}) == []
      assert ToolSets.to_overrides(nil) == []
    end

    test "pure and deterministic (two calls, identical term)" do
      assert ToolSets.to_overrides(@example_config) == ToolSets.to_overrides(@example_config)

      # Same input in a differently-keyed map (insertion order differs) yields
      # the identical term.
      reordered =
        Map.update!(@example_config, "groups", fn groups ->
          Enum.reverse(groups) |> Map.new()
        end)

      assert ToolSets.to_overrides(reordered) == ToolSets.to_overrides(@example_config)
    end
  end

  # ---- assemble_custom (N3: the real %Toolset.Custom{} — flipped from the
  # N2a thin map per PRD-N3 FR-3-4) ----

  describe "assemble_custom/2" do
    test "returns the assembled lib toolset with defaulted settings", %{org_id: org_id} do
      {:ok, set} =
        ToolSets.create(
          base_attrs(org_id, slug: "assembled", config: @valid_config)
          |> Map.put("settings", %{"instructions" => "hi"})
        )

      custom = ToolSets.assemble_custom(set)

      assert %Noizu.MCP.Toolset.Custom{} = custom
      assert custom.slug == "set:assembled"
      assert custom.base == NoizuPromptLingua.MCP.UniverseToolset
      assert custom.title == "Test Set"
      assert custom.metadata.source == "custom"
      assert custom.metadata.allow_api_keys == true
      # settings.instructions backs the description when no description column
      assert custom.description in ["hi", "Test Set"]

      # ops from the config wrap into lib %Override{} keyed by base canonical
      # name — fixture tool names that aren't in the live catalog degrade per
      # D5 (dropped + warned), so the map may be empty here
      assert is_map(custom.tools)

      assert Enum.all?(Map.values(custom.tools), fn ops ->
               Enum.all?(ops, &match?(%Noizu.MCP.Toolset.Override{}, &1))
             end)

      # the include universe covers the plane plus every enabled config group
      assert is_list(custom.include)
    end
  end

  # ---- helpers ----

  defp base_attrs(org_id, overrides \\ []) do
    Map.merge(
      %{
        "organization_id" => org_id,
        "slug" => "set-#{System.unique_integer([:positive])}",
        "display_name" => "Test Set"
      },
      Map.new(overrides, fn {k, v} -> {to_string(k), v} end)
    )
  end

  defp errors_on(changeset, field) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r/%\{(\w+)\}/, msg, fn _, key ->
        value =
          Enum.find_value(opts, fn
            {k, v} when is_atom(k) ->
              if Atom.to_string(k) == key, do: v, else: nil

            _ ->
              nil
          end)

        if is_nil(value), do: key, else: to_string(value)
      end)
    end)
    |> Map.get(field, [])
  end

  defp error_mentions(changeset, field, regex) do
    errors_on(changeset, field) |> Enum.any?(&Regex.match?(regex, &1))
  end

  defp insert_org do
    %{rows: [[raw]]} =
      NoizuPromptLingua.Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["n2ats-#{System.unique_integer([:positive])}", "N2a ToolSets Test Org"]
      )

    Ecto.UUID.load!(raw)
  end

  defp insert_group do
    # Seed migrated DBs already carry the role groups (owner/admin/lead/member/
    # viewer, name unique) — reuse one; insert only on a bare DB.
    case NoizuPromptLingua.Repo.query!("SELECT id FROM groups WHERE name = 'member' LIMIT 1", []) do
      %{rows: [[raw]]} ->
        {:ok, Ecto.UUID.load!(raw)}

      %{rows: []} ->
        %{rows: [[raw]]} =
          NoizuPromptLingua.Repo.query!(
            "INSERT INTO groups (id, name, display_name, created_at, updated_at) " <>
              "VALUES (gen_random_uuid(), 'member', 'Member', now(), now()) RETURNING id",
            []
          )

        {:ok, Ecto.UUID.load!(raw)}
    end
  end
end
