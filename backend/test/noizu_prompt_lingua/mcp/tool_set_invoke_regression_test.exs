defmodule NoizuPromptLingua.MCP.ToolSetInvokeRegressionTest do
  use NoizuPromptLingua.DataCase, async: true

  @moduledoc """
  Stage live-battery regressions (B12/B13/B14) on the set-gateway invoke path
  (ToolSetEndpoint → select_toolset → ToolsetResolver → assemble_custom → lib
  compose).

    * B12 — arg_overrides renames keep the unsatisfiable contract away: the
      wire key is the ONLY accepted spelling (canonical-key calls rejected)
      and the handler receives ORIGINAL canonical args (wire-only rename
      through the effective cast plan).
    * B13 — hide_field must REJECT the hidden key (invalid-args), not silently
      drop it; schemas without hidden fields stay permissive (root parity).
    * B14 — ToolCall on a set surface resolves the SAME set universe:
      listed tools delegate cleanly (MCP-visible refusal), hidden universe
      tools dispatch, tools outside the set stay not-found (ceiling).
    * B15 plane ruling — the always-served set plane is DISCOVERY + READ
      BASICS only; Key_* and all other root-plane tools are neither listed
      nor callable on a set surface.
  """

  alias Noizu.MCP.Ctx
  alias Noizu.MCP.Types.ToolResult
  alias NoizuPromptLingua.MCP.PrincipalMapper
  alias NoizuPromptLingua.MCP.ToolSetEndpoint
  alias NoizuPromptLingua.MCP.ToolSets
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Organizations.Organization

  @org_id Ecto.UUID.generate()

  # Live battery repro shape: tool rename (OrgFetch) + required-arg rename
  # (organization → org). Organization.Get's own handler resolves via the TRP
  # plane (nil in unit tests → graceful handler-level error), which makes it
  # the perfect dispatch probe: the handler's OWN answer proves the call
  # reached it with canonical args.
  @org_rename_config %{
    "groups" => %{
      "organizations" => %{
        "enabled" => true,
        "tools" => %{
          "Organization_Get" => %{
            "name" => "OrgFetch",
            "args" => %{"organization" => %{"rename" => "org"}}
          }
        }
      }
    }
  }

  @md_rename_config %{
    "groups" => %{
      "markdown" => %{
        "enabled" => true,
        "tools" => %{
          "Markdown.Convert" => %{"args" => %{"source" => %{"rename" => "input"}}}
        }
      }
    }
  }

  @hide_config %{
    "groups" => %{
      # Plane tools are override-targetable regardless of the group container.
      "organizations" => %{
        "enabled" => true,
        "tools" => %{"ToolSearch" => %{"args" => %{"mode" => %{"hide" => true}}}}
      }
    }
  }

  @toolcall_config %{
    "groups" => %{"sessions" => %{"enabled" => true}}
  }

  setup do
    Repo.insert!(%Organization{id: @org_id, name: "Set Invoke Org", slug: "set-invoke-org"})
    :ok
  end

  defp ctx_for_set(slug) do
    {:ok, principal} =
      PrincipalMapper.from_claims(%{
        "sub" => "user-1",
        "api_key_id" => "key-1",
        "set_slug" => slug,
        "set_org_id" => @org_id
      })

    %Ctx{server: ToolSetEndpoint, auth: principal}
  end

  defp create_set(slug, config) do
    {:ok, _set} =
      ToolSets.create(%{
        "organization_id" => @org_id,
        "slug" => slug,
        "display_name" => slug,
        "config" => config
      })

    slug
  end

  # ── B12 — renamed args stay callable (wire-only rename) ──────────────────

  test "B12: wire-key args reach the handler on a renamed required arg" do
    create_set("b12-wire", @org_rename_config)
    ctx = ctx_for_set("b12-wire")

    result = ToolSetEndpoint.handle_call_tool("OrgFetch", %{"org" => @org_id}, ctx)

    assert %ToolResult{} = result
    # The handler's OWN answer (TRP-unavailable ⇒ graceful not-found) proves
    # dispatch reached it — not the validator, not a crash.
    assert text_of(result) =~ "not found"
    refute text_of(result) =~ "Invalid arguments"
  end

  test "B12: canonical-key args are rejected — the wire key is the only spelling" do
    create_set("b12-canonical", @org_rename_config)
    ctx = ctx_for_set("b12-canonical")

    result = ToolSetEndpoint.handle_call_tool("OrgFetch", %{"organization" => @org_id}, ctx)

    assert %ToolResult{} = result
    assert result.is_error
    assert text_of(result) =~ "Invalid arguments"
    assert text_of(result) =~ "property 'org' is required"
  end

  test "B12: locally-resolvable handler succeeds through the renamed required arg" do
    create_set("b12-md", @md_rename_config)
    ctx = ctx_for_set("b12-md")

    result = ToolSetEndpoint.handle_call_tool("Markdown.Convert", %{"input" => "# hi"}, ctx)

    refute result.is_error
    # The handler produced converted markdown ⇒ it received :source under the
    # canonical key (wire-only rename, original-keyed handler args).
    assert text_of(result) =~ "hi"
  end

  # ── B13 — hidden fields are rejected, not dropped ─────────────────────────

  test "B13: passing a hidden field is rejected as invalid args" do
    create_set("b13-hidden", @hide_config)
    ctx = ctx_for_set("b13-hidden")

    result =
      ToolSetEndpoint.handle_call_tool(
        "ToolSearch",
        %{"query" => "session", "mode" => "everything"},
        ctx
      )

    assert %ToolResult{} = result
    assert result.is_error
    assert text_of(result) =~ "Invalid arguments"
  end

  test "B13: normal calls without the hidden field are unaffected" do
    create_set("b13-normal", @hide_config)
    ctx = ctx_for_set("b13-normal")

    result = ToolSetEndpoint.handle_call_tool("ToolSearch", %{"query" => "session"}, ctx)

    refute result.is_error
    assert text_of(result) =~ "\"mode\":\"text\""
  end

  test "B13: the hidden field is absent from the advertised wire schema" do
    create_set("b13-wire", @hide_config)
    ctx = ctx_for_set("b13-wire")

    assert {:ok, tools, _cursor} = ToolSetEndpoint.handle_list_tools(nil, ctx)

    search = Enum.find(tools, &(&1.name == "ToolSearch"))
    refute Map.has_key?(search.input_schema["properties"], "mode")
  end

  test "B13: schemas without hidden fields stay permissive (root parity)" do
    create_set("b13-open", @md_rename_config)
    ctx = ctx_for_set("b13-open")

    result =
      ToolSetEndpoint.handle_call_tool(
        "Markdown.Convert",
        %{"input" => "# hi", "totally_unknown_key" => 1},
        ctx
      )

    refute result.is_error
  end

  # ── B14 — ToolCall resolves the SET universe ──────────────────────────────

  test "B14: ToolCall for a listed tool delegates cleanly (MCP-visible refusal)" do
    create_set("b14-listed", @toolcall_config)
    ctx = ctx_for_set("b14-listed")

    assert {:ok, %{status: "mcp", message: message}} =
             tool_call_via_meta(ctx, "Session_Create")

    assert message =~ "MCP-visible"
    assert message =~ "call it directly"
  end

  test "B14: ToolCall accepts the dotted spelling of a listed tool" do
    create_set("b14-dotted", @toolcall_config)
    ctx = ctx_for_set("b14-dotted")

    assert {:ok, %{status: "mcp", message: message}} = tool_call_via_meta(ctx, "Session.Create")
    assert message =~ "MCP-visible"
  end

  test "B14: ToolCall for a tool outside the set is not found (ceiling holds)" do
    create_set("b14-ceiling", @toolcall_config)
    ctx = ctx_for_set("b14-ceiling")

    assert {:error, "Tool 'Wiki_List' not found"} = tool_call_via_meta(ctx, "Wiki_List")
  end

  test "B14: ToolCall dispatches a hidden tool from an ENABLED group through the lib pipeline" do
    config = %{
      "groups" => %{
        "organizations" => %{"enabled" => true},
        "sessions" => %{"enabled" => true}
      }
    }

    create_set("b14-dispatch", config)
    ctx = ctx_for_set("b14-dispatch")

    # Organization.Create is spec-hidden (ToolCall's whole purpose) and its
    # group is enabled: empty args flow through the lib invoke pipeline, which
    # rejects them against the EFFECTIVE schema — deterministic dispatch
    # proof (validator message, no DB), not "not found", not "MCP-visible".
    assert {:error, message} = tool_call_via_meta(ctx, "Organization_Create")
    refute message =~ "not found"
    refute message =~ "MCP-visible"
    assert message =~ "Invalid arguments for tool Organization.Create"
  end

  # ── B15 plane ruling — the set plane is discovery + read basics only ──────

  @plane_names [
    "ToolCall",
    "ToolDefinition",
    "ToolHelp",
    "ToolSearch",
    "ToolSummary",
    "NPLLoad",
    "NPLSpec",
    "Organization.Get",
    "Organization.Overview",
    "Session.Get",
    "Session_Manifest",
    "Notifications.Get"
  ]

  test "B15: an empty-group set lists EXACTLY the discovery + read-basics plane" do
    create_set("b15-floor", %{"groups" => %{}})
    ctx = ctx_for_set("b15-floor")

    assert {:ok, tools, _cursor} = ToolSetEndpoint.handle_list_tools(nil, ctx)
    names = Enum.map(tools, & &1.name) |> Enum.sort()
    assert names == Enum.sort(@plane_names)
  end

  test "B15: Key_* are neither listed NOR callable on a set (plane exclusion)" do
    create_set("b15-keys", @toolcall_config)
    ctx = ctx_for_set("b15-keys")

    assert {:ok, tools, _cursor} = ToolSetEndpoint.handle_list_tools(nil, ctx)
    names = Enum.map(tools, & &1.name)
    refute "Key_List" in names
    refute "Key_Create" in names

    assert {:error, "Tool 'Key_List' not found"} = tool_call_via_meta(ctx, "Key_List")

    # Direct (non-meta) calls hit the same wall at resolve — identical
    # unknown-tool error, no oracle between absent and excluded.
    assert {:error, %Noizu.MCP.Error{reason: :invalid_params}} =
             ToolSetEndpoint.handle_call_tool("Key_Create", %{"label" => "x"}, ctx)
  end

  test "B15: root-plane extras (mcp_overview) are excluded from set universes" do
    create_set("b15-overview", @toolcall_config)
    ctx = ctx_for_set("b15-overview")

    assert {:ok, tools, _cursor} = ToolSetEndpoint.handle_list_tools(nil, ctx)
    refute "mcp_overview" in Enum.map(tools, & &1.name)

    assert {:error, "Tool 'Organization_Create' not found"} =
             tool_call_via_meta(ctx, "Organization_Create")
  end

  # ── helpers ───────────────────────────────────────────────────────────────

  defp tool_call_via_meta(ctx, tool, arguments \\ %{}) do
    result =
      ToolSetEndpoint.handle_call_tool(
        "ToolCall",
        %{"tool" => tool, "arguments" => arguments},
        ctx
      )

    case result do
      %ToolResult{is_error: true} = r -> {:error, text_of(r)}
      %ToolResult{structured: %{} = s} -> {:ok, s}
      %ToolResult{} = r -> {:error, text_of(r)}
      other -> other
    end
  end

  defp text_of(%ToolResult{content: [%{text: text} | _]}) when is_binary(text), do: text
  defp text_of(%ToolResult{content: content}), do: inspect(content)
end
