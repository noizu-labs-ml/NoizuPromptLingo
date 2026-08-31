defmodule NoizuPromptLingua.MCP.CrudDefaultsTest do
  use NoizuPromptLingua.DataCase

  alias Noizu.MCP.Ctx
  alias NoizuPromptLingua.MCP.Custom
  alias NoizuPromptLingua.MCPCustomScopes
  alias NoizuPromptLingua.Schema.MCPCustomScope

  # --- W2 preset: :basic_crud -------------------------------------------------

  test "presets/0 exposes basic_crud over the four PM groups" do
    assert %{"basic_crud" => preset} = MCPCustomScopes.presets()
    assert Enum.sort(preset.groups) == ~w(organizations projects sessions tickets)
  end

  test "preset_config/1 seeds CRUD groups and disables non-CRUD tools" do
    assert %{"groups" => groups} = MCPCustomScopes.preset_config("basic_crud")
    assert MapSet.new(Map.keys(groups)) == MapSet.new(~w(sessions organizations projects tickets))

    # Inverted semantics: enabled tools are absent from the group's `tools`
    # map; the preset records only the disabled (non-CRUD) ones.
    assert disabled_tool_names("sessions", groups) == ["Session.Archive"]
    assert disabled_tool_names("organizations", groups) == []
    assert disabled_tool_names("projects", groups) == []

    ticket_disabled = disabled_tool_names("tickets", groups)

    for gap <- ~w(Ticket.FromEntity Ticket.Comment Ticket.Watch Ticket.Attach
                  Ticket.Feed Ticket.Link Ticket.Unlink Ticket.LinkEntity Ticket.UnlinkEntity
                  Ticket.Queue.Create Ticket.Queue.Get Ticket.Queue.List Ticket.Queue.Feed
                  Ticket.Definition.Create Ticket.Definition.Get Ticket.Definition.Update
                  Ticket.Definition.Delete
                  Ticket.Field.Definition.Create Ticket.Field.Definition.Update
                  Ticket.Field.Definition.Delete),
        do: assert(gap in ticket_disabled, message: "expected #{gap} disabled")

    assert length(ticket_disabled) == 20

    for kept <- ~w(Ticket.Create Ticket.Get Ticket.List Ticket.Update Ticket.Overview),
        do: refute(kept in ticket_disabled, message: "expected #{kept} enabled")
  end

  test "preset_config/1 returns nil for unknown presets" do
    refute MCPCustomScopes.preset_config("nope")
    refute MCPCustomScopes.preset_config(nil)
  end

  test "create with preset seeds config; caller groups win per group id" do
    {:ok, scope} =
      MCPCustomScopes.create(%{
        "slug" => "crud-scoped",
        "name" => "Crud Scoped",
        "preset" => "basic_crud",
        "config" => %{"groups" => %{"tickets" => %{"hidden" => true}}}
      })

    groups = scope.config["groups"]
    assert MapSet.new(Map.keys(groups)) == MapSet.new(~w(sessions organizations projects tickets))
    assert groups["tickets"]["hidden"] == true
    # Caller's tickets entry wins whole-group, so its tools map is empty
    # (everything enabled, nothing disabled).
    assert (groups["tickets"]["tools"] || %{}) == %{}

    # Preset sessions entry survives: only Session.Archive disabled.
    assert disabled_tool_names("sessions", groups) == ["Session.Archive"]
  end

  test "create with preset alone keeps CRUD tools serving on the gateway" do
    {:ok, _} =
      MCPCustomScopes.create(%{
        "slug" => "crud-gw",
        "name" => "Crud Gateway",
        "preset" => "basic_crud"
      })

    names =
      "crud-gw"
      |> ctx()
      |> Custom.catalog_specs()
      |> Enum.map(& &1.definition.name)

    assert "Session.Create" in names
    assert "Ticket.List" in names
    refute "Session.Archive" in names
    refute "Ticket.Comment" in names
    refute "Queue.Create" in names
  end

  # --- W2 visibility ----------------------------------------------------------

  test "visibility defaults to org" do
    {:ok, scope} = MCPCustomScopes.create(%{"slug" => "vis-default", "name" => "Vis"})

    assert scope.config["visibility"] == nil
    assert MCPCustomScope.visibility(scope) == "org"
  end

  test "visibility account/shared persist via top-level attr and resolve from config" do
    {:ok, scope} =
      MCPCustomScopes.create(%{
        "slug" => "vis-account",
        "name" => "Vis Account",
        "visibility" => "account",
        "config" => %{"groups" => %{"sessions" => %{}}}
      })

    assert scope.config["visibility"] == "account"
    assert MCPCustomScope.visibility(scope) == "account"

    {:ok, shared} =
      MCPCustomScopes.create(%{
        "slug" => "vis-shared",
        "name" => "Vis Shared",
        "config" => %{"visibility" => "shared"}
      })

    assert MCPCustomScope.visibility(shared) == "shared"

    # Visibility-only update must not clobber stored groups.
    {:ok, updated} =
      MCPCustomScopes.update("vis-account", %{"visibility" => "shared"})

    assert MCPCustomScope.visibility(updated) == "shared"
    assert Map.has_key?(updated.config["groups"] || %{}, "sessions")
  end

  test "invalid visibility is rejected" do
    assert {:error, %Ecto.Changeset{errors: errors}} =
             MCPCustomScopes.create(%{
               "slug" => "vis-bad",
               "name" => "Vis Bad",
               "visibility" => "world"
             })

    assert Keyword.has_key?(errors, :visibility) or Keyword.has_key?(errors, :config)
  end

  test "invalid visibility stored directly in config is rejected too" do
    assert {:error, %Ecto.Changeset{}} =
             MCPCustomScopes.create(%{
               "slug" => "vis-bad2",
               "name" => "Vis Bad 2",
               "config" => %{"visibility" => "everyone"}
             })
  end

  test "scope_json surfaces visibility" do
    {:ok, scope} =
      MCPCustomScopes.create(%{"slug" => "vis-json", "name" => "Vis Json", "visibility" => "shared"})

    assert MCPCustomScopes.scope_json(scope)[:visibility] == "shared"
  end

  test "normalization preserves visibility across group edits" do
    {:ok, scope} =
      MCPCustomScopes.create(%{
        "slug" => "vis-keep",
        "name" => "Vis Keep",
        "visibility" => "account",
        "config" => %{"groups" => %{"sessions" => %{}}}
      })

    {:ok, updated} =
      MCPCustomScopes.update("vis-keep", %{
        "config" => %{"groups" => %{"sessions" => %{}, "projects" => %{}}}
      })

    assert MCPCustomScope.visibility(updated) == "account"
    assert MapSet.new(Map.keys(updated.config["groups"])) == MapSet.new(~w(sessions projects))
  end

  defp disabled_tool_names(group_id, groups) do
    (groups[group_id]["tools"] || %{})
    |> Enum.filter(fn {_name, cfg} -> cfg["disabled"] end)
    |> Enum.map(fn {name, _} -> name end)
    |> Enum.sort()
  end

  defp ctx(slug), do: %Ctx{server: Custom, assigns: %{custom_scope_slug: slug}}
end
