defmodule NoizuPromptLingua.MCP.ToolSetEndpointTest do
  use NoizuPromptLingua.DataCase, async: true

  @moduledoc """
  PRD-N3 AC-N3-4/5/8 — the enum-prune e2e (listing == enforcement) against the
  LIB protocol path (ToolSetEndpoint → select_toolset → ToolsetResolver →
  assemble_custom → lib compose), plus principal-mapper shapes and the
  mapper→resolver integration through the endpoint fixture.
  """

  alias Noizu.MCP.Ctx
  alias NoizuPromptLingua.MCP.PrincipalMapper
  alias NoizuPromptLingua.MCP.ToolSetEndpoint
  alias NoizuPromptLingua.MCP.ToolSets
  alias NoizuPromptLingua.MCP.ToolsetResolver
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Organizations.Organization

  @org_id Ecto.UUID.generate()

  # Markdown.Convert (markdown group): enum arg `type` + the REQUIRED arg
  # `source`. The enum prunes "html"; the tool is renamed to md_convert;
  # `source` renames to `input` (required ⇒ old-key rejections are observable)
  # and `type` renames to `source_type`.
  @config %{
    "groups" => %{
      "markdown" => %{
        "enabled" => true,
        "tools" => %{
          "Markdown.Convert" => %{
            "name" => "md_convert",
            "args" => %{
              "source" => %{"rename" => "input"},
              "type" => %{"enum_remove" => ["html"], "rename" => "source_type"}
            }
          }
        }
      }
    }
  }

  defp create_set(slug, config) do
    ensure_org!()

    {:ok, set} =
      ToolSets.create(%{
        "organization_id" => @org_id,
        "slug" => slug,
        "display_name" => slug,
        "config" => config
      })

    set
  end

  # Liquibase 083 enforces mcp_tool_sets.organization_id → organizations(id);
  # @org_id is a compile-time random UUID, so materialize the org row first.
  # Sandbox-scoped: rolled back at the end of each test.
  defp ensure_org! do
    case Repo.get(Organization, @org_id) do
      nil ->
        Repo.insert!(%Organization{
          id: @org_id,
          name: "ToolSet Endpoint Org",
          slug: "toolset-endpoint-org"
        })

      _org ->
        :ok
    end
  end

  defp ctx_for_claims(claims) do
    case PrincipalMapper.from_claims(claims) do
      {:ok, principal} -> %Ctx{server: ToolSetEndpoint, auth: principal}
      other -> raise "principal mapping failed: #{inspect(other)}"
    end
  end

  defp ctx_for_set(slug, org_id \\ @org_id) do
    ctx_for_claims(%{
      "sub" => "user-1",
      "api_key_id" => "key-1",
      "set_slug" => slug,
      "set_org_id" => org_id
    })
  end

  # ── listing == enforcement (AC-N3-4) ──────────────────────────────────────

  test "listing shows the renamed tool, renamed arg, and pruned enum value" do
    create_set("prune-set", @config)

    assert {:ok, tools, _cursor} =
             ToolSetEndpoint.handle_list_tools(nil, ctx_for_set("prune-set"))

    names = Enum.map(tools, & &1.name)
    assert "md_convert" in names
    refute "Markdown.Convert" in names

    convert = Enum.find(tools, &(&1.name == "md_convert"))
    props = convert.input_schema["properties"]
    assert Map.has_key?(props, "source_type")
    refute Map.has_key?(props, "type")

    enum = props["source_type"]["enum"]
    assert "html" not in enum
    assert "auto" in enum
  end

  test "call with a pruned enum value is rejected by the EFFECTIVE schema" do
    create_set("prune-call", @config)
    ctx = ctx_for_set("prune-call")

    result =
      ToolSetEndpoint.handle_call_tool(
        "md_convert",
        %{"input" => "# hi", "source_type" => "html"},
        ctx
      )

    assert is_error_result?(result)
    assert message_of(result) =~ "Invalid arguments"
  end

  test "call with an allowed enum value dispatches and the handler sees ORIGINAL arg keys" do
    create_set("prune-ok", @config)
    ctx = ctx_for_set("prune-ok")

    result =
      ToolSetEndpoint.handle_call_tool(
        "md_convert",
        %{"input" => "# hi", "source_type" => "markdown"},
        ctx
      )

    # Dispatch reached the real handler (passthrough conversion) — the renamed
    # wire key was accepted and cast back onto the original :type field.
    refute is_error_result?(result)
  end

  test "the OLD required arg key is rejected — the wire key is the only accepted spelling" do
    create_set("prune-oldkey", @config)
    ctx = ctx_for_set("prune-oldkey")

    # `source` (old key) no longer satisfies the required `input` field; the
    # effective schema is the ONLY validation surface (FR-3-5).
    result = ToolSetEndpoint.handle_call_tool("md_convert", %{"source" => "# hi"}, ctx)

    assert is_error_result?(result)
    assert message_of(result) =~ "Invalid arguments"
  end

  test "absent tool and rejected call are both refusals (no acceptance oracle)" do
    create_set("prune-oracle", @config)
    ctx = ctx_for_set("prune-oracle")

    assert {:error, %Noizu.MCP.Error{reason: :invalid_params}} =
             ToolSetEndpoint.handle_call_tool("totally_absent_tool", %{}, ctx)

    assert is_error_result?(
             ToolSetEndpoint.handle_call_tool(
               "md_convert",
               %{"input" => "x", "source_type" => "html"},
               ctx
             )
           )
  end

  test "a tool outside the allowlist universe is absent from listing and call" do
    create_set("plane-only", %{"groups" => %{}})
    ctx = ctx_for_set("plane-only")

    assert {:ok, tools, _cursor} = ToolSetEndpoint.handle_list_tools(nil, ctx)
    names = Enum.map(tools, & &1.name)
    # R2: empty config ⇒ the plane only — no group-domain tools.
    refute "Markdown.Convert" in names
    assert "ToolSummary" in names

    assert {:error, %Noizu.MCP.Error{reason: :invalid_params}} =
             ToolSetEndpoint.handle_call_tool("Markdown.Convert", %{"input" => "x"}, ctx)
  end

  # ── resolver unit paths (PRD-N3 §4.3) ────────────────────────────────────

  test "resolver: no binding ⇒ :none (endpoint static surface is empty)" do
    ctx = ctx_for_claims(%{"sub" => "user-1", "api_key_id" => "key-1"})

    assert ToolsetResolver.resolve(ctx) == :none

    # Through the endpoint: the static surface (no tools registered).
    assert {:ok, tools, _cursor} = ToolSetEndpoint.handle_list_tools(nil, ctx)
    assert tools == []
  end

  test "resolver: unknown set slug ⇒ :none + warning (D5, never raise)" do
    ctx = ctx_for_set("ghost-set")
    assert ToolsetResolver.resolve(ctx) == :none
  end

  test "resolver: unknown profile slug ⇒ :none + warning (D5)" do
    ctx = ctx_for_claims(%{"sub" => "u", "profile_slug" => "ghost-profile"})
    assert ToolsetResolver.resolve(ctx) == :none
  end

  test "resolver: set_slug wins over profile_slug (precedence)" do
    create_set("precedence-set", %{"groups" => %{"markdown" => %{"enabled" => true}}})

    ctx =
      ctx_for_claims(%{
        "sub" => "u",
        "set_slug" => "precedence-set",
        "set_org_id" => @org_id,
        "profile_slug" => "ghost-profile"
      })

    assert %Noizu.MCP.Toolset.Custom{} = ToolsetResolver.resolve(ctx)
  end

  # ── principal mapper shapes (AC-N3-5) ────────────────────────────────────

  test "mapper: api-key claims ⇒ :api_key principal with route metadata" do
    {:ok, principal} =
      PrincipalMapper.from_claims(%{
        "api_key_id" => "key-9",
        "sub" => "user-9",
        "set_slug" => "the-set",
        "set_org_id" => "org-1",
        "set_org_slug" => "the-org"
      })

    assert principal.subject == "key-9"
    assert principal.authenticator == :api_key
    assert principal.token_id == "key-9"
    assert principal.metadata[:set_slug] == "the-set"
    assert principal.metadata[:set_org_id] == "org-1"
    assert principal.metadata[:set_org_slug] == "the-org"
  end

  test "mapper: oauth claims ⇒ :oauth principal, scopes from the scope claim" do
    {:ok, principal} =
      PrincipalMapper.from_claims(%{
        "client_id" => "client-1",
        "sub" => "user-2",
        "scope" => "mcp tickets:read",
        "set_slug" => "oauth-set"
      })

    assert principal.subject == "client-1"
    assert principal.authenticator == :oauth
    assert Noizu.MCP.Auth.Principal.has_scope?(principal, "tickets:read")
    assert principal.metadata[:set_slug] == "oauth-set"
    assert principal.metadata["user_id"] == "user-2"
  end

  test "mapper: garbage claims ⇒ error tuple (lib fails open to anonymous)" do
    assert {:error, :invalid_claims} = PrincipalMapper.from_claims(%{})
    assert {:error, :invalid_claims} = PrincipalMapper.from_claims("not-a-map")
  end

  # ── helpers ───────────────────────────────────────────────────────────────

  defp is_error_result?(%Noizu.MCP.Types.ToolResult{} = result), do: result.is_error == true
  defp is_error_result?({:error, %Noizu.MCP.Error{}}), do: true
  defp is_error_result?(_), do: false

  defp message_of(%Noizu.MCP.Types.ToolResult{} = result) do
    case result.content do
      %{text: text} when is_binary(text) -> text
      [%{text: text}] when is_binary(text) -> text
      other -> inspect(other)
    end
  end

  defp message_of({:error, %Noizu.MCP.Error{} = err}), do: err.message
end
