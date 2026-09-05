defmodule NoizuPromptLingua.MCP.MCPResidualTest do
  @moduledoc """
  W4-D residual coverage for the MCP layer: Session_Manifest's effective-state
  seams (missing impl module, raising impl) and manifest_tool metadata, plus
  Urls' slug/id shape tolerance across the human-facing URL builders.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.MCP.SessionManifest
  alias NoizuPromptLingua.MCP.Urls

  # F2 (CI round-2 gate): the old on_exit restore ran `if prev` — with the
  # normal nil prev (the impl env is unset outside these tests) NOTHING was
  # restored, so :effective_toolset_impl stayed poisoned (Not.A.Real.Module /
  # RaisingEffectiveToolset) for every LATER suite; SessionManifest silently
  # degraded to defaults and the parity suite's client-layer pin failed far
  # from the cause. Puts now restore synchronously in an after-block, and the
  # on_exit backstop deletes unconditionally (unset = the documented default).
  setup do
    on_exit(fn -> Application.delete_env(:noizu_prompt_lingua, :effective_toolset_impl) end)
    :ok
  end

  # ── Session_Manifest ─────────────────────────────────────────────

  test "manifest_tool exposes its canonical name" do
    assert SessionManifest.manifest_tool() == "Session_Manifest"
  end

  test "generate falls back to defaults when the effective-toolset impl is absent" do
    prev = Application.get_env(:noizu_prompt_lingua, :effective_toolset_impl)
    Application.put_env(:noizu_prompt_lingua, :effective_toolset_impl, Not.A.Real.Module)

    try do
      %{tools: tools} = SessionManifest.generate(%Noizu.MCP.Ctx{server: NoizuPromptLingua.MCP})
      assert tools != []

      assert Enum.all?(
               tools,
               &(&1.included == true and &1.enabled == true and &1.visible == true)
             )
    after
      restore_impl_env(prev)
    end
  end

  test "generate survives an impl whose resolve/4 raises" do
    prev = Application.get_env(:noizu_prompt_lingua, :effective_toolset_impl)
    Application.put_env(:noizu_prompt_lingua, :effective_toolset_impl, RaisingEffectiveToolset)

    try do
      %{tools: tools} = SessionManifest.generate(%Noizu.MCP.Ctx{server: NoizuPromptLingua.MCP})
      assert tools != []
    after
      restore_impl_env(prev)
    end
  end

  defp restore_impl_env(nil),
    do: Application.delete_env(:noizu_prompt_lingua, :effective_toolset_impl)

  defp restore_impl_env(prev),
    do: Application.put_env(:noizu_prompt_lingua, :effective_toolset_impl, prev)

  test "scope-bound ctx with an unknown scope degrades to an empty universe" do
    %{tools: tools} =
      SessionManifest.generate(%Noizu.MCP.Ctx{
        server: NoizuPromptLingua.MCP,
        assigns: %{custom_scope_slug: "no-such-scope-w4d"}
      })

    assert tools == []
  end

  # ── Urls shape tolerance ─────────────────────────────────────────

  test "set / admin / project urls tolerate slug and struct shapes" do
    org = %{slug: "w4d-org"}
    set = %{slug: "my-set", id: Ecto.UUID.generate()}

    assert Urls.set_url(set, org) =~ "/org/w4d-org/set/my-set/mcp"
    assert Urls.set_url("my-set", "w4d-org") =~ "/org/w4d-org/set/my-set/mcp"

    project = %{slug: "proj"}

    assert Urls.set_project_url(set, org, project) =~ "set/my-set"
    assert Urls.set_project_url("my-set", org, "proj") =~ "set/my-set"

    assert Urls.tool_set_admin_url("w4d-org", "my-set") =~
             "/app/w4d-org/settings/tool-sets/my-set"
  end

  test "chat / session / ticket / artifact urls resolve org slugs via the DB" do
    org_slug = "w4d-urls-#{System.unique_integer([:positive])}"

    org =
      Repo.insert!(%NoizuPromptLingua.Schema.Organizations.Organization{
        name: "URLs Org",
        slug: org_slug
      })

    room = %{id: Ecto.UUID.generate(), organization_id: org.id}

    assert url = Urls.chat_room_url(room)
    assert url =~ "/app/#{org_slug}/chat/"

    # unknown org → nil (no existence leak)
    assert Urls.chat_room_url(%{id: Ecto.UUID.generate(), organization_id: Ecto.UUID.generate()}) ==
             nil

    # non-record shapes fold to nil
    assert Urls.chat_room_url("junk") == nil

    # record-shaped inputs without an org reference raise on slug resolution
    assert_raise(ArgumentError, fn -> Urls.user_url(%{}) end)
  end
end

defmodule RaisingEffectiveToolset do
  @moduledoc "Impl seam stand-in whose resolve/4 raises (rescue-path coverage)."

  def resolve(_scope, _client, _user, _at), do: raise("boom")
end
