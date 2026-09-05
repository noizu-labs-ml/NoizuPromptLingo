defmodule NoizuPromptLingua.MCP.VFS.RootTest do
  @moduledoc """
  Wave 0 conformance suite for the composed VFS backend.

  Exercises `NoizuPromptLingua.MCP.VFS.Root` (and the `/etc/dev` control tree
  through `NoizuPromptLingua.MCP.VFS.Router`) through the lib's backend-level
  wrappers (`Noizu.MCP.Server.Features.VFS`), so errno mapping, generation
  stamping, and cache interaction are verified on the composed surface — the
  parts a raw `@behaviour` test would miss. Shaped after the lib's own
  battery (`Noizu.MCP.VFS.Conformance`) but tailored to the NPL namespace:
  the battery's generic tree does not exist here; the meta plane does.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias Noizu.MCP.Server.Features.VFS
  alias Noizu.MCP.VFS.Cache
  alias Noizu.MCP.{Ctx, Error}
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCP.VFS.{Root, Router}
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Users.User
  alias NoizuPromptLingua.TRP.Cache, as: TrpCache
  alias NoizuPromptLingua.TRP.TestStub

  @org "vfs-root-org"

  setup do
    TrpCache.clear()
    TestStub.reset()

    slug = "#{@org}-#{System.unique_integer([:positive])}"
    TestStub.seed_org(Ecto.UUID.generate(), slug, "VFS Root Org")

    ctx = key_ctx(%{"groups" => %{"wiki" => %{}}})

    on_exit(fn -> Cache.purge(Root) end)

    %{slug: slug, ctx: ctx}
  end

  defp key_ctx(
         config,
         session \\ "sess-" <> Integer.to_string(System.unique_integer([:positive]))
       ) do
    uniq = System.unique_integer([:positive])

    user =
      %User{
        id: Ecto.UUID.generate(),
        email: "vfsroot-#{uniq}@example.com",
        user_name: "vfsroot#{uniq}",
        handle: "vfsroot#{uniq}",
        status: :active
      }
      |> Repo.insert!()

    {:ok, key, _raw} = MCPApiKeys.generate_api_key(user.id, "vfs-root", toolset_config: config)

    %Ctx{
      server: NoizuPromptLingua.MCP.VFSServer,
      session_id: session,
      assigns: %{auth_claims: %{"api_key_id" => key.id, "sub" => user.id}}
    }
  end

  defp tobor(slug), do: "/tobor/" <> slug

  # ── stat ──────────────────────────────────────────────────────────────────

  test "stat/3 returns a dir node for /", %{ctx: ctx} do
    assert {:ok, node} = VFS.stat(Root, "/", ctx)
    assert node.type == :dir
    assert is_integer(node.version) and node.version > 0
    assert is_map(node.xattrs)
  end

  test "stat/3 maps the namespace", %{slug: slug, ctx: ctx} do
    assert {:ok, dir} = VFS.stat(Root, "/tobor", ctx)
    assert dir.type == :dir

    assert {:ok, org_dir} = VFS.stat(Root, tobor(slug), ctx)
    assert org_dir.type == :dir

    assert {:ok, meta} = VFS.stat(Root, tobor(slug) <> "/_meta", ctx)
    assert meta.type == :dir

    assert {:ok, file} = VFS.stat(Root, tobor(slug) <> "/_meta/whoami.json", ctx)
    assert file.type == :file
    assert file.size > 0
    assert file.writable == false

    assert {:ok, groups} = VFS.stat(Root, tobor(slug) <> "/_meta/groups", ctx)
    assert groups.type == :dir
  end

  test "stat/3 on a missing path is :enoent", %{slug: slug, ctx: ctx} do
    assert {:error, :enoent} = VFS.stat(Root, "/nope", ctx)
    assert {:error, :enoent} = VFS.stat(Root, tobor(slug) <> "/_meta/nope.json", ctx)
  end

  test "stat/3 refuses dot segments (traversal guard)", %{slug: slug, ctx: ctx} do
    assert {:error, :enoent} = VFS.stat(Root, tobor(slug) <> "/../etc/passwd", ctx)
    assert {:error, :enoent} = VFS.stat(Root, "/tobor/../etc", ctx)
  end

  # ── list ──────────────────────────────────────────────────────────────────

  test "list/4 enumerates the namespace", %{slug: slug, ctx: ctx} do
    assert {:ok, entries, nil} = VFS.list(Root, "/", nil, ctx)
    assert Enum.any?(entries, &match?(%{name: "tobor", type: :dir}, &1))

    assert {:ok, orgs, nil} = VFS.list(Root, "/tobor", nil, ctx)
    assert [%{name: ^slug, type: :dir}] = orgs

    assert {:ok, org_entries, nil} = VFS.list(Root, tobor(slug), nil, ctx)
    assert Enum.any?(org_entries, &match?(%{name: "_meta", type: :dir}, &1))
    # Gated group subtree: only the wiki dir (the only included+visible group).
    assert Enum.any?(org_entries, &match?(%{name: "wiki", type: :dir}, &1))
    refute Enum.any?(org_entries, &match?(%{name: "tickets", type: :dir}, &1))

    assert {:ok, meta_entries, nil} = VFS.list(Root, tobor(slug) <> "/_meta", nil, ctx)
    names = Enum.map(meta_entries, & &1.name)
    assert Enum.sort(names) == ["groups", "toolsets.json", "whoami.json"]
    assert Enum.all?(meta_entries, &(&1.name in ["whoami.json", "toolsets.json", "groups"]))
  end

  test "list/4 on a file is :enotdir, on a missing path :enoent", %{slug: slug, ctx: ctx} do
    assert {:error, :enotdir} = VFS.list(Root, tobor(slug) <> "/_meta/whoami.json", nil, ctx)
    assert {:error, :enoent} = VFS.list(Root, tobor(slug) <> "/_meta/nope", nil, ctx)
  end

  test "list/4 rejects an invalid cursor", %{slug: slug, ctx: ctx} do
    assert {:error, %Error{}} = VFS.list(Root, tobor(slug), "not-a-cursor", ctx)
  end

  # ── read ──────────────────────────────────────────────────────────────────

  test "read/4 returns content and version matching stat", %{slug: slug, ctx: ctx} do
    path = tobor(slug) <> "/_meta/whoami.json"
    assert {:ok, node} = VFS.stat(Root, path, ctx)
    assert {:ok, content, version} = VFS.read(Root, path, ctx)
    assert version == node.version

    assert {:ok, whoami} = Jason.decode(content)
    assert whoami["server"]["name"] == "tobor_fs"
    assert is_binary(whoami["principal"]["api_key_id"])
    assert whoami["orgs"] == [slug]
    assert whoami["groups"]["wiki"]["included"] == true
  end

  test "read/4 serves the effective toolset and group descriptors", %{slug: slug, ctx: ctx} do
    {:ok, toolsets_json, _} = VFS.read(Root, tobor(slug) <> "/_meta/toolsets.json", ctx)
    assert {:ok, toolsets} = Jason.decode(toolsets_json)
    assert toolsets["groups"]["wiki"]["visible"] == true
    assert toolsets["groups"]["tickets"]["included"] == false

    {:ok, wiki_json, _} = VFS.read(Root, tobor(slug) <> "/_meta/groups/wiki.json", ctx)
    assert {:ok, wiki} = Jason.decode(wiki_json)
    assert wiki["id"] == "wiki"
    assert wiki["gate"]["included"] == true

    # Excluded group descriptor: enoent (no existence leak in the meta plane).
    assert {:error, :enoent} = VFS.read(Root, tobor(slug) <> "/_meta/groups/tickets.json", ctx)
  end

  test "read/4 serves group overviews (placeholder vs mapped backend)", %{slug: slug} do
    # Unmapped group: the Wave 0 Overview placeholder.
    ctx = key_ctx(%{"groups" => %{"wiki" => %{}, "tickets" => %{}}})

    {:ok, tickets_md, _} = VFS.read(Root, tobor(slug) <> "/tickets/overview.md", ctx)
    assert tickets_md =~ "wave"
    assert tickets_md =~ "placeholder"

    # Mapped group (wiki): the backend renders its own Overview furniture.
    {:ok, wiki_md, _} = VFS.read(Root, tobor(slug) <> "/wiki/overview.md", ctx)
    assert wiki_md =~ "Wiki"
    assert wiki_md =~ "spaces:"
  end

  test "read/4 on a dir is :eisdir, on a missing path :enoent", %{slug: slug, ctx: ctx} do
    assert {:error, :eisdir} = VFS.read(Root, tobor(slug) <> "/_meta", ctx)
    assert {:error, :enoent} = VFS.read(Root, tobor(slug) <> "/_meta/nope.json", ctx)
  end

  # ── write family: read-only backend ───────────────────────────────────────

  test "mutating ops stay :enosys on the meta plane and unmapped groups", %{slug: slug, ctx: ctx} do
    assert {:error, :enosys} = VFS.write(Root, tobor(slug) <> "/_meta/whoami.json", "x", ctx)
    # tickets has no Wave backend yet — the behaviour default applies.
    assert {:error, :enosys} = VFS.create(Root, tobor(slug) <> "/tickets/page.md", "x", ctx)
    assert {:error, :enosys} = VFS.remove(Root, tobor(slug) <> "/tickets/overview.md", ctx)
    # Wiki furniture is not writable either (mapped group, read-only node).
    assert {:error, :enosys} = VFS.write(Root, tobor(slug) <> "/wiki/overview.md", "x", ctx)
    # Group subtrees are backend-owned; unknown wiki paths raise :enoent.
    assert {:error, :enoent} = VFS.read(Root, tobor(slug) <> "/wiki/deeper.md", ctx)
  end

  test "search is :enosys and xattr defaults to a map", %{slug: slug, ctx: ctx} do
    assert {:error, :enosys} = VFS.search(Root, "/", "wiki", ctx)
    assert {:ok, xattrs} = VFS.xattr(Root, tobor(slug) <> "/_meta/whoami.json", ctx)
    assert is_map(xattrs)
  end

  # ── cache integration ─────────────────────────────────────────────────────

  test "generation embeds into returned versions", %{slug: slug, ctx: ctx} do
    gen = Cache.generation(Root)
    assert {:ok, node} = VFS.stat(Root, tobor(slug), ctx)
    assert node.version > gen
  end

  # ── /etc/dev control tree (through the composed Router) ───────────────────

  test "control tree lists runtime and refuses unknown tool writes", %{ctx: ctx} do
    assert {:ok, dir} = VFS.stat(Router, "/etc/dev", ctx)
    assert dir.type == :dir

    assert {:ok, entries, nil} = VFS.list(Router, "/etc/dev", nil, ctx)
    assert Enum.map(entries, & &1.name) == ["cache", "config", "runtime", "tools"]

    assert {:ok, status_json, _} = VFS.read(Router, "/etc/dev/runtime/status", ctx)
    assert {:ok, status} = Jason.decode(status_json)
    assert status["server"]["name"] == "tobor_fs"

    # Tool-less FS server: every /etc/dev/tools/<tool> node is :enoent — the
    # invocation surface arrives with the tool inventory decision (C1 note).
    assert {:error, :enoent} = VFS.stat(Router, "/etc/dev/tools/ToolSummary", ctx)
    assert {:error, :enoent} = VFS.write(Router, "/etc/dev/tools/ToolSummary", "{}", ctx)
  end

  test "control config toggles read through the composition", %{ctx: ctx} do
    assert {:ok, "false", _} = VFS.read(Router, "/etc/dev/config/trace", ctx)
    assert {:ok, value, _} = VFS.read(Router, "/etc/dev/config/cache_enabled", ctx)
    assert is_boolean(Jason.decode!(value))
  end

  defmodule ReadOnlyRouter do
    use Noizu.MCP.VFS.Control,
      server: NoizuPromptLingua.MCP.VFS.RootTest.ReadOnlyServer,
      real: NoizuPromptLingua.MCP.VFS.Root,
      tool_gate: {NoizuPromptLingua.MCP.VFS.Principal, :tool_gate}
  end

  defmodule ReadOnlyServer do
    use Noizu.MCP.Server, name: "tobor_fs_ro_test", version: "0.0.0", vfs_readonly: true
    vfs(NoizuPromptLingua.MCP.VFS.RootTest.ReadOnlyRouter)
  end

  test "vfs_readonly kill-switch turns control writes into :erofs", %{ctx: ctx} do
    # The production Router (readonly: false default) accepts the toggle write…
    assert {:ok, _node} = VFS.write(Router, "/etc/dev/config/trace", "false", ctx)

    # …while a vfs_readonly server's composition refuses every write.
    assert {:error, :erofs} = VFS.write(ReadOnlyRouter, "/etc/dev/config/trace", "true", ctx)

    assert {:error, :erofs} = VFS.write(ReadOnlyRouter, "/etc/dev/cache/flush", "flush", ctx)
  end
end
