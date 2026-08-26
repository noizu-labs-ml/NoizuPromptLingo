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
    # reachable, not that the substring never appears.
    assert search.matches |> Enum.map(& &1.name) |> Enum.all?(&String.starts_with?(&1, "Session."))
    refute Enum.any?(search.matches, &String.starts_with?(&1.name, "Project."))

    {:ok, definitions} = ToolDefinition.call(%{tool: "Session.Get,Project.Get"}, c)
    assert [%{name: "Session.Get"}] = definitions.definitions
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

    assert found.tool == "Ticket.Create"

    {:ok, missing} =
      ToolHelp.call(%{tool: "Project.Get", task: "inspect project"}, ctx("tickets-only"))

    assert missing.status == "error"
  end
end
