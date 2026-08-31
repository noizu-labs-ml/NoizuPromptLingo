defmodule NoizuPromptLingua.MCP.KeyToolsetsTest do
  use NoizuPromptLingua.DataCase

  alias Noizu.MCP.Ctx
  alias NoizuPromptLingua.MCP.KeyToolsets
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCPServers

  defp key_ctx(api_key_id) do
    %Ctx{server: NoizuPromptLingua.MCP, assigns: %{auth_claims: %{"api_key_id" => api_key_id}}}
  end

  defp new_key(user_id, config) do
    {:ok, key, _raw} =
      MCPApiKeys.generate_api_key(user_id, "t", toolset_config: config)

    key
  end

  defp user do
    uniq = System.unique_integer([:positive])

    %NoizuPromptLingua.Schema.Users.User{
      id: Ecto.UUID.generate(),
      email: "kt-#{uniq}@example.com",
      user_name: "kt#{uniq}",
      handle: "kt#{uniq}",
      status: :active
    }
    |> NoizuPromptLingua.Repo.insert!()
  end

  describe "state_from_config" do
    test "tool-level flags win over group-level" do
      config = %{
        "groups" => %{
          "tickets" => %{
            "disabled" => true,
            "hidden" => true,
            "tools" => %{"Ticket.Get" => %{"disabled" => false, "hidden" => false}}
          }
        }
      }

      assert KeyToolsets.state_from_config(config, "tickets", "Ticket.List") == %{
               disabled: true,
               hidden: true
             }

      assert KeyToolsets.state_from_config(config, "tickets", "Ticket.Get") == %{
               disabled: false,
               hidden: false
             }
    end

    test "unknown group/tool inherits nothing" do
      config = %{"groups" => %{"sessions" => %{"disabled" => true}}}

      assert KeyToolsets.state_from_config(config, "projects", "Project.List") == %{
               disabled: false,
               hidden: false
             }
    end

    test "empty config inherits everything" do
      assert KeyToolsets.state_from_config(%{}, "sessions", "Session.List") == %{
               disabled: false,
               hidden: false
             }
    end
  end

  describe "overlay (key over scope)" do
    test "key flags override scope flags; absent key fields inherit" do
      scope_config = %{
        "groups" => %{
          "sessions" => %{
            "hidden" => false,
            "tools" => %{
              "Session.List" => %{"hidden" => false},
              "Session.Get" => %{"disabled" => false}
            }
          }
        }
      }

      key_config = %{
        "groups" => %{
          "sessions" => %{
            "hidden" => true,
            "tools" => %{"Session.List" => %{"hidden" => true}}
          }
        }
      }

      merged = KeyToolsets.overlay(scope_config, key_config)
      sessions = merged["groups"]["sessions"]

      assert sessions["hidden"] == true
      # Session.Get not mentioned by key -> scope value survives
      assert sessions["tools"]["Session.Get"]["disabled"] == false
      assert sessions["tools"]["Session.List"]["hidden"] == true
    end

    test "key config cannot add groups to the scope include set" do
      scope_config = %{"groups" => %{"sessions" => %{"tools" => %{}}}}

      key_config = %{"groups" => %{"tickets" => %{"disabled" => true}}}

      merged = KeyToolsets.overlay(scope_config, key_config)
      refute Map.has_key?(merged["groups"], "tickets")
      assert Map.has_key?(merged["groups"], "sessions")
    end

    test "nil key config returns the scope unchanged" do
      scope_config = %{"groups" => %{"sessions" => %{}}}
      assert KeyToolsets.overlay(scope_config, nil) == scope_config
    end
  end

  describe "config_for / state (ctx-driven)" do
    test "no api_key_id claim -> nil config (inherit everything)" do
      assert KeyToolsets.config_for(%Ctx{assigns: %{auth_claims: %{}}}) == nil
      assert KeyToolsets.config_for(%Ctx{assigns: %{}}) == nil
    end

    test "empty toolset config -> nil (inherit everything)" do
      u = user()
      {:ok, key, _raw} = MCPApiKeys.generate_api_key(u.id, "plain")

      assert KeyToolsets.config_for(key_ctx(key.id)) == nil
      assert KeyToolsets.state("tickets", "Ticket.List", key_ctx(key.id)).disabled == false
    end

    test "key flags resolve through ctx" do
      u = user()

      key =
        new_key(u.id, %{
          "groups" => %{
            "tickets" => %{"disabled" => true},
            "projects" => %{"tools" => %{"Project.List" => %{"hidden" => true}}}
          }
        })

      assert KeyToolsets.state("tickets", "Ticket.List", key_ctx(key.id)).disabled == true
      assert KeyToolsets.state("tickets", "Ticket.Get", key_ctx(key.id)).disabled == true

      assert KeyToolsets.state("projects", "Project.List", key_ctx(key.id)).hidden == true
      assert KeyToolsets.state("projects", "Project.Create", key_ctx(key.id)).hidden == false

      # revoked key loses its overrides
      {:ok, _} = MCPApiKeys.revoke(key.id)
      assert KeyToolsets.config_for(key_ctx(key.id)) == nil
    end
  end

  describe "apply_hidden (listing filter)" do
    test "drops key-hidden and key-disabled specs by tool-module group resolution" do
      u = user()

      key =
        new_key(u.id, %{
          "groups" => %{
            "tickets" => %{"tools" => %{"Ticket.List" => %{"hidden" => true}}},
            "sessions" => %{"disabled" => true}
          }
        })

      ctx = key_ctx(key.id)
      tickets_specs = NoizuPromptLingua.Domains.Tickets.MCP.__mcp__(:tools) |> expand()
      sessions_specs = NoizuPromptLingua.MCP.Sessions.__mcp__(:tools) |> expand()

      kept = KeyToolsets.apply_hidden(tickets_specs, ctx, nil)
      names = Enum.map(kept, & &1.definition.name)
      refute "Ticket.List" in names
      assert "Ticket.Get" in names

      # group-level disable on sessions hides the whole group from listing
      kept_sessions = KeyToolsets.apply_hidden(sessions_specs, ctx, "sessions")
      assert kept_sessions == []

      # no key config -> passthrough
      assert KeyToolsets.apply_hidden(tickets_specs, %Ctx{assigns: %{}}, nil) == tickets_specs
    end
  end

  describe "group_id_for_tool_module" do
    test "resolves group ids from server and tool modules" do
      assert MCPServers.group_id_for_tool_module(NoizuPromptLingua.MCP.Organizations) ==
               "organizations"

      assert MCPServers.group_id_for_tool_module(
               NoizuPromptLingua.MCP.Organizations.Tools.OrganizationGet
             ) == "organizations"

      assert MCPServers.group_id_for_tool_module(NoizuPromptLingua.Domains.Tickets.MCP) ==
               "tickets"

      # root-level tools (Discovery/NPL) are not group-gated
      assert MCPServers.group_id_for_tool_module(NoizuPromptLingua.Tools.ToolSummary) == nil
    end
  end

  defp expand(registered) do
    Noizu.MCP.Server.Features.Tools.expand(registered)
  end
end
