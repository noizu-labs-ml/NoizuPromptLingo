defmodule NoizuPromptLingua.MCP.WindowEndpointResolverBranchesTest do
  @moduledoc """
  Residual branches on the set-gateway path and the F3 window helper:
  Window's non-map guards + fields/0, the ToolsetResolver per-request
  selection ladder (set / profile / binding-seam / none), and the
  ToolSetEndpoint toolset-layer passthroughs (both the per-request-set branch
  and the static-surface fallback). Pure/ctx-level — async: true.
  """

  use NoizuPromptLingua.DataCase, async: true

  alias Noizu.MCP.Auth.Principal
  alias Noizu.MCP.Ctx
  alias Noizu.MCP.Toolset.Custom
  alias NoizuPromptLingua.MCP.{ToolSetEndpoint, ToolSets, ToolsetResolver, Window}
  alias NoizuPromptLingua.MCP.Toolsets.Profiles
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Organizations.Organization

  # ── Window ─────────────────────────────────────────────────────────────────

  describe "Window" do
    test "fields/0 exposes the stored field names" do
      assert %{until: "hide_until", hours: "enable_for_hours"} = Window.fields()
      assert is_binary(Window.fields().anchor)
    end

    test "non-map entries are guarded on every entrypoint" do
      assert {:error, :invalid_entry} = Window.parse("nope")
      assert Window.validate_entry(42) == ["entry must be an object"]
      assert Window.normalize_entry(:base, %{}, []) == :base
      assert Window.state("nope", DateTime.utc_now()) == {true, nil, false}
      assert Window.evaluate("nope") == {true, nil}
      refute Window.lifting?("nope")
    end
  end

  # ── ToolsetResolver (per-request set selection) ────────────────────────────

  defp org do
    Repo.insert!(%Organization{
      id: Ecto.UUID.generate(),
      name: "WER Org",
      slug: "wer-org-#{System.unique_integer([:positive])}"
    })
  end

  defp principal_ctx(metadata) do
    {:ok, principal} = NoizuPromptLingua.MCP.PrincipalMapper.from_claims(%{"sub" => "user-1"})
    principal = %{principal | metadata: metadata}
    %Ctx{server: ToolSetEndpoint, auth: principal}
  end

  defp ctx_with_metadata(metadata), do: principal_ctx(metadata)

  defp anon_ctx, do: %Ctx{server: ToolSetEndpoint}

  describe "ToolsetResolver" do
    test "resolves an active set to a Custom toolset (set_slug metadata)" do
      organization = org()

      slug = "wer-set-#{System.unique_integer([:positive])}"

      {:ok, _} =
        ToolSets.create(%{
          "organization_id" => organization.id,
          "slug" => slug,
          "display_name" => "WER Set"
        })

      custom =
        ToolsetResolver.resolve(ctx_with_metadata(%{set_slug: slug, set_org_id: organization.id}))

      assert %Custom{} = custom

      # unknown set -> D5 :none (fail-closed per set, fail-open per server)
      assert :none =
               ToolsetResolver.resolve(
                 ctx_with_metadata(%{set_slug: "ghost", set_org_id: organization.id})
               )

      # a set_slug without an org coordinate is also :none
      assert :none = ToolsetResolver.resolve(ctx_with_metadata(%{set_slug: slug}))
    end

    test "profile slugs wrap the N2a profile data; unknown profiles are :none" do
      [known | _] = Profiles.slugs()
      assert %Custom{} = ToolsetResolver.resolve(ctx_with_metadata(%{profile_slug: known}))
      assert :none = ToolsetResolver.resolve(ctx_with_metadata(%{profile_slug: "ghost"}))
    end

    test "the tool_set_slug claim seam rides the same set resolution" do
      organization = org()
      slug = "wer-seam-#{System.unique_integer([:positive])}"

      {:ok, _} =
        ToolSets.create(%{
          "organization_id" => organization.id,
          "slug" => slug,
          "display_name" => "Seam Set"
        })

      custom =
        ToolsetResolver.resolve(
          ctx_with_metadata(%{tool_set_slug: slug, set_org_id: organization.id})
        )

      assert %Custom{} = custom
    end

    test "no binding and no principal resolve to :none" do
      assert :none = ToolsetResolver.resolve(ctx_with_metadata(%{}))
      assert :none = ToolsetResolver.resolve(anon_ctx())
    end
  end

  # ── ToolSetEndpoint passthroughs ───────────────────────────────────────────

  describe "ToolSetEndpoint passthroughs" do
    test "catalog/resolve take the per-request-set branch under set claims" do
      organization = org()
      slug = "wer-endpoint-#{System.unique_integer([:positive])}"

      {:ok, _} =
        ToolSets.create(%{
          "organization_id" => organization.id,
          "slug" => slug,
          "display_name" => "Endpoint Set"
        })

      ctx =
        ctx_with_metadata(%{set_slug: slug, set_org_id: organization.id})

      assert {:ok, _tools, _cursor} = ToolSetEndpoint.catalog(ToolSetEndpoint, ctx, [])

      # a listed plane tool resolves through the selected set
      assert {:ok, _spec} = ToolSetEndpoint.resolve(ToolSetEndpoint, "ToolSearch", ctx, [])
    end

    test "catalog/resolve fall back to the static surface without set claims" do
      ctx = ctx_with_metadata(%{"sub" => "user-1"})

      assert {:ok, _tools, _cursor} = ToolSetEndpoint.catalog(ToolSetEndpoint, ctx, [])
      assert {:error, _} = ToolSetEndpoint.resolve(ToolSetEndpoint, "NoSuch.Tool", ctx, [])
    end
  end
end
