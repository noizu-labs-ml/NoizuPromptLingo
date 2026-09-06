defmodule NoizuPromptLingua.Schema.SchemaResidualTest do
  @moduledoc """
  W4-D residual changeset-branch coverage: MCPToolSet config/settings
  validation folds and slug derivation, unicode special-usage scope matrix,
  and MCPCustomScope config validation folds.
  """

  use NoizuPromptLingua.DataCase, async: true

  alias NoizuPromptLingua.Schema.MCPCustomScope
  alias NoizuPromptLingua.Schema.MCPToolSet
  alias NoizuPromptLingua.Schema.Unicode.SpecialUsage

  # ── MCPToolSet ───────────────────────────────────────────────────

  test "tool set slug falls back to the slugified display name" do
    changeset = MCPToolSet.changeset(%MCPToolSet{}, %{"display_name" => "W4D Fancy Tool"})
    assert Ecto.Changeset.get_field(changeset, :slug) == "w4d-fancy-tool"
  end

  test "tool set slug tolerates non-binary input and errors when unsluggable" do
    changeset = MCPToolSet.changeset(%MCPToolSet{}, %{"slug" => 123, "display_name" => "!!!"})
    assert errors_include?(changeset, :slug)
  end

  test "tool set config must be an object with known keys and map groups" do
    changeset =
      MCPToolSet.changeset(%MCPToolSet{}, %{
        "display_name" => "Cfg",
        "slug" => "cfg",
        "config" => "junk"
      })

    assert errors_include?(changeset, :config)

    changeset2 =
      MCPToolSet.changeset(%MCPToolSet{}, %{
        "display_name" => "Cfg2",
        "slug" => "cfg-2",
        "config" => %{"groups" => "not-a-map"}
      })

    assert errors_include?(changeset2, :config)

    changeset3 =
      MCPToolSet.changeset(%MCPToolSet{}, %{
        "display_name" => "Cfg3",
        "slug" => "cfg-3",
        "config" => %{"unknown_key" => true}
      })

    assert errors_include?(changeset3, :config)
  end

  test "tool set settings validation matrix" do
    base = %{"display_name" => "S", "slug" => "settings-x"}

    non_map =
      MCPToolSet.changeset(%MCPToolSet{}, Map.put(base, "settings", "junk"))

    assert errors_include?(non_map, :settings)

    bad_values =
      MCPToolSet.changeset(%MCPToolSet{}, %{
        "display_name" => "S2",
        "slug" => "settings-y",
        "settings" => %{
          "allow_api_keys" => "yes",
          "description_verbosity" => "shouty",
          "instructions" => 42,
          "unknown_setting" => 1
        }
      })

    errors = Ecto.Changeset.traverse_errors(bad_values, fn {msg, _} -> msg end)
    settings_errors = errors[:settings] || []
    assert Enum.any?(settings_errors, &(&1 =~ "allow_api_keys"))
    assert Enum.any?(settings_errors, &(&1 =~ "description_verbosity"))
    assert Enum.any?(settings_errors, &(&1 =~ "instructions"))
    assert Enum.any?(settings_errors, &(&1 =~ "unknown_setting"))
  end

  # ── Unicode special usage scope matrix ───────────────────────────

  test "special usage slugs are trimmed and downcased" do
    changeset =
      SpecialUsage.changeset(%SpecialUsage{}, %{
        "slug" => "  W4D-Usage  ",
        "scope" => "global"
      })

    assert Ecto.Changeset.get_field(changeset, :slug) == "w4d-usage"
  end

  test "special usage scope matrix validates org/project pairing" do
    ok_global = SpecialUsage.changeset(%SpecialUsage{}, %{"slug" => "u1", "scope" => "global"})
    refute errors_include?(ok_global, :scope)

    global_with_org =
      SpecialUsage.changeset(%SpecialUsage{}, %{
        "slug" => "u2",
        "scope" => "global",
        "organization_id" => Ecto.UUID.generate()
      })

    assert errors_include?(global_with_org, :scope)

    org_without_org =
      SpecialUsage.changeset(%SpecialUsage{}, %{"slug" => "u3", "scope" => "organization"})

    assert errors_include?(org_without_org, :organization_id)

    org_with_project =
      SpecialUsage.changeset(%SpecialUsage{}, %{
        "slug" => "u4",
        "scope" => "organization",
        "organization_id" => Ecto.UUID.generate(),
        "project_id" => Ecto.UUID.generate()
      })

    assert errors_include?(org_with_project, :project_id)

    project_without_org =
      SpecialUsage.changeset(%SpecialUsage{}, %{"slug" => "u5", "scope" => "project"})

    assert errors_include?(project_without_org, :organization_id)

    project_without_project =
      SpecialUsage.changeset(%SpecialUsage{}, %{
        "slug" => "u6",
        "scope" => "project",
        "organization_id" => Ecto.UUID.generate()
      })

    assert errors_include?(project_without_project, :project_id)
  end

  # ── MCPCustomScope config folds ──────────────────────────────────

  test "custom scope config must be an object with known visibility" do
    non_map =
      MCPCustomScope.changeset(%MCPCustomScope{}, %{
        "slug" => "w4d-cs",
        "display_name" => "CS",
        "config" => "junk"
      })

    assert errors_include?(non_map, :config)

    bad_visibility =
      MCPCustomScope.changeset(%MCPCustomScope{}, %{
        "slug" => "w4d-cs-2",
        "display_name" => "CS2",
        "config" => %{"visibility" => "invisible"}
      })

    assert errors_include?(bad_visibility, :visibility)

    # non-map group tool configs fold to empty tool maps without crashing
    ok =
      MCPCustomScope.changeset(%MCPCustomScope{}, %{
        "slug" => "w4d-cs-3",
        "display_name" => "CS3",
        "config" => %{"visibility" => "org", "groups" => "junk"}
      })

    refute errors_include?(ok, :config)
  end

  defp errors_include?(changeset, field) do
    case Keyword.get(changeset.errors, field) do
      nil -> false
      _ -> true
    end
  end
end
