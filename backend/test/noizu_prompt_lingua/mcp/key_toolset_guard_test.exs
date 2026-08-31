defmodule NoizuPromptLingua.MCP.KeyToolsetGuardTest do
  use NoizuPromptLingua.DataCase

  # Per-key toolset enforcement in ToolGuard: `disabled` denies in BOTH
  # :mcp_authz_mode modes (capability config, not RBAC rollout).

  alias Noizu.MCP.Ctx
  alias NoizuPromptLingua.MCP.ToolGuard

  setup do
    Application.put_env(:noizu_prompt_lingua, :mcp_authz_mode, :shadow)
    on_exit(fn -> Application.delete_env(:noizu_prompt_lingua, :mcp_authz_mode) end)

    uniq = System.unique_integer([:positive])

    user =
      %NoizuPromptLingua.Schema.Users.User{
        id: Ecto.UUID.generate(),
        email: "guard-#{uniq}@example.com",
        user_name: "guard#{uniq}",
        handle: "g#{uniq}",
        status: :active
      }
      |> NoizuPromptLingua.Repo.insert!()

    {:ok, key, _raw} =
      NoizuPromptLingua.MCPApiKeys.generate_api_key(user.id, "guard",
        toolset_config: %{
          "groups" => %{
            "tickets" => %{"tools" => %{"Ticket.List" => %{"disabled" => true}}}
          }
        }
      )

    ctx = %Ctx{assigns: %{auth_claims: %{"api_key_id" => key.id}}}

    %{
      ctx: ctx,
      spec: %{
        name: "Ticket.List",
        module: NoizuPromptLingua.Domains.Tickets.Tools.TicketList,
        authz: nil
      }
    }
  end

  test "key-disabled tool is denied in shadow mode", %{ctx: ctx, spec: spec} do
    assert {:error, %{code: :forbidden, reason: :tool_disabled_for_key}} =
             ToolGuard.before_call(spec, %{}, ctx)
  end

  test "key-disabled tool is denied in enforce mode too", %{ctx: ctx, spec: spec} do
    Application.put_env(:noizu_prompt_lingua, :mcp_authz_mode, :enforce)

    assert {:error, %{code: :forbidden, reason: :tool_disabled_for_key}} =
             ToolGuard.before_call(spec, %{}, ctx)
  end

  test "non-disabled tool passes the key check (RBAC proceeds separately)", %{ctx: ctx} do
    spec = %{
      name: "Ticket.Get",
      module: NoizuPromptLingua.Domains.Tickets.Tools.TicketGet,
      authz: nil
    }

    case ToolGuard.before_call(spec, %{}, ctx) do
      :ok -> :ok
      # RBAC denial paths are ToolGuard's own concern; the key check must not
      # be the reason. tool_disabled_for_key must never appear.
      {:error, %{reason: reason}} when reason != :tool_disabled_for_key -> :ok
      other -> flunky(other)
    end
  end

  defp flunky(other), do: flunk("unexpected guard result: #{inspect(other)}")

  test "disabled tool is blocked through the hidden-tool call path (ToolCall)",
       %{ctx: ctx} do
    {:error, msg} =
      NoizuPromptLingua.Tools.Catalog.call_hidden_tool(
        "Ticket.List",
        %{},
        NoizuPromptLingua.Domains.Tickets.MCP,
        ctx
      )

    assert msg =~ "disabled for this API key"
  end
end
