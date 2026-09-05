defmodule NoizuPromptLingua.MCP.VFS.DispatchTest do
  @moduledoc """
  Wave 1 Root wiring: registered group backends take their whole subtree via
  the prefix-dispatch table (`@group_backends`), unregistered groups keep the
  Wave 0 placeholder, `_npl` sits beside the org listing, and op dispatch
  (read AND mutating/search families) lands on the right module.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias Noizu.MCP.Ctx
  alias Noizu.MCP.Server.Features.VFS
  alias Noizu.MCP.VFS.Cache
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCP.VFS.Root
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Organizations.Organization
  alias NoizuPromptLingua.TRP.Cache, as: TrpCache
  alias NoizuPromptLingua.TRP.TestStub

  setup do
    TrpCache.clear()
    TestStub.reset()

    suffix = Ecto.UUID.generate() |> binary_part(0, 8)
    org = Repo.insert!(%Organization{name: "VFS Disp Org #{suffix}", slug: "vfs-disp-#{suffix}"})
    TestStub.seed_org(org.id, org.slug, org.name)

    on_exit(fn -> Cache.purge(Root) end)

    ctx =
      key_ctx(%{
        "groups" => %{
          "artifacts" => %{},
          "instructions" => %{},
          "unicode" => %{},
          "wiki" => %{},
          # Gated but unmapped — exercises the Wave 0 placeholder surface.
          "assets" => %{}
        }
      })

    %{org: org, ctx: ctx}
  end

  defp key_ctx(config) do
    uniq = System.unique_integer([:positive])

    user =
      %NoizuPromptLingua.Schema.Users.User{
        id: Ecto.UUID.generate(),
        email: "vfsdisp-#{uniq}@example.com",
        user_name: "vfsdisp#{uniq}",
        handle: "vfsdisp#{uniq}",
        status: :active
      }
      |> Repo.insert!()

    {:ok, key, _} = MCPApiKeys.generate_api_key(user.id, "vfs-dispatch", toolset_config: config)

    %Ctx{
      server: NoizuPromptLingua.MCP.VFSServer,
      session_id: "disp-" <> Integer.to_string(uniq),
      assigns: %{auth_claims: %{"api_key_id" => key.id, "sub" => user.id}}
    }
  end

  test "/tobor lists _npl plus exactly the visible group subtrees", %{org: org, ctx: ctx} do
    {:ok, entries, _} = VFS.list(Root, "/tobor/#{org.slug}", nil, ctx)
    names = Enum.map(entries, & &1.name)

    assert "_meta" in names
    for group <- ["artifacts", "instructions", "unicode", "wiki"], do: assert(group in names)
    refute "tickets" in names
    refute "chat" in names
  end

  test "registered subtrees serve backend content through Root", %{org: org, ctx: ctx} do
    for group <- ["artifacts", "instructions", "unicode", "wiki"] do
      assert {:ok, dir} = VFS.stat(Root, "/tobor/#{org.slug}/#{group}", ctx)
      assert dir.type == :dir

      # Backend-rendered overview (from the domain's Overview tool), not the
      # Wave 0 placeholder.
      assert {:ok, md, _} = VFS.read(Root, "/tobor/#{org.slug}/#{group}/overview.md", ctx)
      refute md =~ "Wave 0 placeholder"
    end

    # The wiki overview carries the backend's own furniture.
    assert {:ok, wiki_md, _} = VFS.read(Root, "/tobor/#{org.slug}/wiki/overview.md", ctx)
    assert wiki_md =~ "# Wiki"

    # Placeholder groups keep the Wave 0 surface verbatim. (wiki is a mapped
    # backend now — assets is the gated-but-unmapped example.)
    assert {:ok, md, _} = VFS.read(Root, "/tobor/#{org.slug}/assets/overview.md", ctx)
    assert md =~ "Wave 0 placeholder"
    assert {:error, :enoent} = VFS.read(Root, "/tobor/#{org.slug}/assets/deeper.md", ctx)
  end

  test "mutations dispatch to backends; placeholders stay :enosys", %{org: org, ctx: ctx} do
    # Registered: create lands on the instructions backend.
    assert {:ok, _} =
             VFS.create(Root, "/tobor/#{org.slug}/instructions/from-dispatch", "body", ctx)

    # Registered read-only backend: unicode refuses via its :enosys defaults.
    assert {:error, :enosys} =
             VFS.create(Root, "/tobor/#{org.slug}/unicode/plane-0/U+0041.json", "{}", ctx)

    # Placeholder: assets is gated but unmapped (:enosys defaults). wiki is a
    # mapped backend now and dispatches its own mutators.
    assert {:error, :enosys} = VFS.create(Root, "/tobor/#{org.slug}/assets/page.md", "x", ctx)

    # Meta plane stays read-only.
    assert {:error, :enosys} = VFS.write(Root, "/tobor/#{org.slug}/_meta/whoami.json", "x", ctx)
  end

  test "search dispatches to the subtree's backend only", %{org: org, ctx: ctx} do
    {:ok, _} = VFS.create(Root, "/tobor/#{org.slug}/artifacts/searchable", "needle content", ctx)

    # Artifacts implement no search (:enosys default) even with content.
    assert {:error, :enosys} =
             VFS.search(Root, "/tobor/#{org.slug}/artifacts", "needle", ctx)

    # Non-group roots are :enosys.
    assert {:error, :enosys} = VFS.search(Root, "/", "anything", ctx)
    assert {:error, :enosys} = VFS.search(Root, "/tobor/#{org.slug}", "anything", ctx)
  end

  test "dot segments are refused everywhere" do
    ctx = key_ctx(%{"groups" => %{"artifacts" => %{}}})

    assert {:error, :enoent} = VFS.stat(Root, "/tobor/_npl/./spec.md", ctx)
    assert {:error, :enoent} = VFS.read(Root, "/tobor/_npl/../_npl/spec.md", ctx)
  end
end
