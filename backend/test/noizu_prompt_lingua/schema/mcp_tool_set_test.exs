defmodule NoizuPromptLingua.Schema.MCPToolSetTest do
  use NoizuPromptLingua.DataCase, async: true

  @moduledoc """
  MCPToolSet changeset matrix (schema/mcp_tool_set.ex): closed-vocabulary
  config validation, settings whitelist, audience shapes, slug
  derivation/reserved slugs, clone invariant, create-only identity fields.
  """

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Authz.Group
  alias NoizuPromptLingua.Schema.MCPToolSet

  @org Ecto.UUID.generate()

  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
  end

  defp valid_attrs(overrides \\ %{}) do
    Map.merge(
      %{
        organization_id: @org,
        slug: "team-set",
        display_name: "Team Set",
        description: "desc",
        source: "custom"
      },
      overrides
    )
  end

  defp group_row do
    case Repo.get_by(Group, name: "viewer", is_system: true) do
      nil -> Repo.insert!(%Group{name: "viewer", display_name: "viewer", is_system: true})
      g -> g
    end
  end

  # ── happy path + reserved slugs ──────────────────────────────────

  test "valid create passes and defaults hold" do
    cs = MCPToolSet.changeset(%MCPToolSet{}, valid_attrs())
    assert cs.valid?
    assert get_field(cs, :source) == "custom"
    assert get_field(cs, :config) == %{}
    assert get_field(cs, :is_active) == true
    assert MCPToolSet.sources() == ~w(custom clone)
    assert "root" in MCPToolSet.reserved_slugs()
  end

  test "slug is slugified and can derive from display_name" do
    cs = MCPToolSet.changeset(%MCPToolSet{}, valid_attrs(%{slug: "Team Set!", display_name: nil}))
    assert cs.valid?
    assert get_field(cs, :slug) =~ ~r/^[a-z0-9-]+$/

    cs2 =
      MCPToolSet.changeset(%MCPToolSet{}, valid_attrs(%{slug: nil, display_name: "My Cool Set"}))

    assert cs2.valid?
    assert get_field(cs2, :slug) == "my-cool-set"

    # unsluggable display name AND nil slug ⇒ required error
    cs3 = MCPToolSet.changeset(%MCPToolSet{}, valid_attrs(%{slug: nil, display_name: "!!!"}))
    refute cs3.valid?
    assert "can't be blank" in errors_on(cs3).slug
  end

  test "reserved slugs are rejected" do
    for slug <- ["root" | NoizuPromptLingua.MCP.Toolsets.Profiles.slugs()] do
      cs = MCPToolSet.changeset(%MCPToolSet{}, valid_attrs(%{slug: slug}))
      refute cs.valid?, "expected #{slug} to be reserved"
      assert errors_on(cs).slug
    end
  end

  # ── update action: identity fields are create-only ───────────────

  test "update action ignores identity fields and validates config/settings" do
    ts = %MCPToolSet{id: Ecto.UUID.generate(), organization_id: @org, slug: "keep-me"}

    cs =
      MCPToolSet.changeset(
        ts,
        %{
          slug: "hacked",
          source: "clone",
          display_name: "Renamed",
          is_active: false
        },
        :update
      )

    assert cs.valid?
    refute Map.has_key?(cs.changes, :slug)
    refute Map.has_key?(cs.changes, :source)
    assert cs.changes.display_name == "Renamed"
    assert cs.changes.is_active == false
  end

  # ── source / clone invariant ─────────────────────────────────────

  test "unknown source is rejected; clone requires provenance" do
    refute MCPToolSet.changeset(%MCPToolSet{}, valid_attrs(%{source: "bogus"})).valid?

    refute MCPToolSet.changeset(%MCPToolSet{}, valid_attrs(%{source: "clone"})).valid?

    assert MCPToolSet.changeset(
             %MCPToolSet{},
             valid_attrs(%{source: "clone", source_profile: "engineering"})
           ).valid?

    assert MCPToolSet.changeset(
             %MCPToolSet{},
             valid_attrs(%{source: "clone", settings: %{"cloned_from" => "other-set"}})
           ).valid?

    # blank-string cloned_from does not satisfy provenance
    refute MCPToolSet.changeset(
             %MCPToolSet{},
             valid_attrs(%{source: "clone", settings: %{"cloned_from" => ""}})
           ).valid?
  end

  # ── audience shapes ──────────────────────────────────────────────

  test "audience shapes: org-only ok; project+group mutually exclusive" do
    assert MCPToolSet.changeset(%MCPToolSet{}, valid_attrs()).valid?

    assert MCPToolSet.changeset(%MCPToolSet{}, valid_attrs(%{project_id: Ecto.UUID.generate()})).valid?

    g = group_row()
    assert MCPToolSet.changeset(%MCPToolSet{}, valid_attrs(%{group_id: g.id})).valid?

    cs =
      MCPToolSet.changeset(
        %MCPToolSet{},
        valid_attrs(%{project_id: Ecto.UUID.generate(), group_id: g.id})
      )

    refute cs.valid?
    assert errors_on(cs).project_id
  end

  test "group-set requires an existing authz group" do
    cs = MCPToolSet.changeset(%MCPToolSet{}, valid_attrs(%{group_id: Ecto.UUID.generate()}))
    refute cs.valid?
    assert errors_on(cs).group_id
  end

  # ── config: closed vocabulary ────────────────────────────────────

  test "config non-map rejected" do
    cs = MCPToolSet.changeset(%MCPToolSet{}, valid_attrs(%{config: "nope"}))
    refute cs.valid?
    assert errors_on(cs).config
  end

  test "config unknown keys rejected at every level" do
    cs =
      MCPToolSet.changeset(
        %MCPToolSet{},
        valid_attrs(%{
          config: %{
            "bogus_top" => true,
            "groups" => %{
              "tickets" => %{
                "bogus_group" => 1,
                "enabled" => true,
                "tools" => %{
                  "Ticket.List" => %{
                    "bogus_tool" => 1,
                    "enabled" => true,
                    "name" => "Friendly",
                    "description" => "d",
                    "args" => %{
                      "status" => %{
                        "bogus_arg" => 1,
                        "hide" => true,
                        "enum_remove" => ["open"],
                        "rename" => "state",
                        "default" => "open",
                        "description" => "d"
                      }
                    }
                  }
                }
              }
            }
          }
        })
      )

    refute cs.valid?
    errs = errors_on(cs).config
    assert IO.iodata_to_binary(errs) =~ "bogus_top"
    assert IO.iodata_to_binary(errs) =~ "bogus_group"
    assert IO.iodata_to_binary(errs) =~ "bogus_tool"
    assert IO.iodata_to_binary(errs) =~ "bogus_arg"
  end

  test "config type violations produce targeted errors" do
    base = fn cfg -> MCPToolSet.changeset(%MCPToolSet{}, valid_attrs(%{config: cfg})) end

    refute base.(%{"groups" => "not-a-map"}).valid?
    refute base.(%{"groups" => %{"t" => "not-a-map"}}).valid?
    refute base.(%{"groups" => %{"t" => %{"enabled" => "yes"}}}).valid?
    refute base.(%{"groups" => %{"t" => %{"tools" => "nope"}}}).valid?
    refute base.(%{"groups" => %{"t" => %{"tools" => %{"X" => "nope"}}}}).valid?
    refute base.(%{"groups" => %{"t" => %{"tools" => %{"X" => %{"enabled" => 1}}}}}).valid?
    refute base.(%{"groups" => %{"t" => %{"tools" => %{"X" => %{"name" => 5}}}}}).valid?
    refute base.(%{"groups" => %{"t" => %{"tools" => %{"X" => %{"description" => 5}}}}}).valid?
    refute base.(%{"groups" => %{"t" => %{"tools" => %{"X" => %{"args" => "nope"}}}}}).valid?

    refute base.(%{"groups" => %{"t" => %{"tools" => %{"X" => %{"args" => %{"a" => "nope"}}}}}}).valid?
  end

  test "arg-level enum_remove/default/rename validation" do
    arg = fn arg_cfg ->
      MCPToolSet.changeset(
        %MCPToolSet{},
        valid_attrs(%{
          config: %{"groups" => %{"g" => %{"tools" => %{"T" => %{"args" => %{"a" => arg_cfg}}}}}}
        })
      )
    end

    refute arg.(%{"enum_remove" => "nope"}).valid?
    refute arg.(%{"enum_remove" => [%{"deep" => true}]}).valid?
    assert arg.(%{"enum_remove" => [1, "x", true]}).valid?
    refute arg.(%{"default" => %{"map" => true}}).valid?
    assert arg.(%{"default" => 3.5}).valid?
    refute arg.(%{"description" => 9}).valid?

    # empty rename
    refute arg.(%{"rename" => ""}).valid?
    # rename onto a sibling arg collides
    refute MCPToolSet.changeset(
             %MCPToolSet{},
             valid_attrs(%{
               config: %{
                 "groups" => %{
                   "g" => %{
                     "tools" => %{"T" => %{"args" => %{"a" => %{"rename" => "b"}, "b" => %{}}}}
                   }
                 }
               }
             })
           ).valid?

    # rename onto itself is fine
    assert MCPToolSet.changeset(
             %MCPToolSet{},
             valid_attrs(%{
               config: %{
                 "groups" => %{
                   "g" => %{"tools" => %{"T" => %{"args" => %{"a" => %{"rename" => "a"}}}}}
                 }
               }
             })
           ).valid?

    # rename to a fresh target is fine
    assert MCPToolSet.changeset(
             %MCPToolSet{},
             valid_attrs(%{
               config: %{
                 "groups" => %{
                   "g" => %{"tools" => %{"T" => %{"args" => %{"a" => %{"rename" => "fresh"}}}}}
                 }
               }
             })
           ).valid?

    # two args renaming onto the same target collide
    refute MCPToolSet.changeset(
             %MCPToolSet{},
             valid_attrs(%{
               config: %{
                 "groups" => %{
                   "g" => %{
                     "tools" => %{
                       "T" => %{"args" => %{"a" => %{"rename" => "x"}, "b" => %{"rename" => "x"}}}
                     }
                   }
                 }
               }
             })
           ).valid?

    # non-string rename is rejected
    refute arg.(%{"rename" => 5}).valid?
  end

  # ── settings whitelist ───────────────────────────────────────────

  test "settings: system keys ignored, unknown rejected, values typed" do
    ok =
      MCPToolSet.changeset(
        %MCPToolSet{},
        valid_attrs(%{
          settings: %{
            "cloned_from" => "whatever",
            "updated_by" => "admin",
            "_audit" => [%{"at" => "now"}],
            "allow_api_keys" => true,
            "description_verbosity" => "concise",
            "instructions" => "be nice"
          }
        })
      )

    assert ok.valid?

    bad =
      MCPToolSet.changeset(
        %MCPToolSet{},
        valid_attrs(%{
          settings: %{
            "unknown_key" => 1,
            "allow_api_keys" => "yes",
            "description_verbosity" => "loquacious",
            "instructions" => 42
          }
        })
      )

    refute bad.valid?
    errs = IO.iodata_to_binary(errors_on(bad).settings)
    assert errs =~ "unknown_key"
    assert errs =~ "allow_api_keys"
    assert errs =~ "description_verbosity"
    assert errs =~ "instructions"

    refute MCPToolSet.changeset(%MCPToolSet{}, valid_attrs(%{settings: "nope"})).valid?
  end

  # ── misc constraints ─────────────────────────────────────────────

  test "slug length cap unreachable via slugify; display_name length cap enforced" do
    # slugify truncates to the 64-char budget, so an over-long input slug is
    # silently shortened rather than rejected (pinned current behavior)
    cs = MCPToolSet.changeset(%MCPToolSet{}, valid_attrs(%{slug: String.duplicate("a", 65)}))
    assert cs.valid?
    assert String.length(get_field(cs, :slug)) <= 64

    refute MCPToolSet.changeset(
             %MCPToolSet{},
             valid_attrs(%{display_name: String.duplicate("a", 201)})
           ).valid?
  end

  test "organization_id and slug are required" do
    cs = MCPToolSet.changeset(%MCPToolSet{}, %{})
    refute cs.valid?
    errs = errors_on(cs)
    assert errs.organization_id
    assert errs.slug
  end

  test "unique constraint name registered for (slug, organization_id)" do
    cs = MCPToolSet.changeset(%MCPToolSet{}, valid_attrs())
    assert Enum.any?(cs.constraints, &(&1.constraint == "mcp_tool_sets_org_slug_key"))
  end
end
