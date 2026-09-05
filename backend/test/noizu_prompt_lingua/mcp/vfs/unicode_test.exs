defmodule NoizuPromptLingua.MCP.VFS.UnicodeTest do
  @moduledoc """
  Wave 1 battery for the read-only `unicode` VFS backend (design §2.4),
  through `Root` + `Features.VFS`.

  Covers: the generated reference tree (planes/{U+XXXX}.json), effective-layer
  resolution (org overrides global), special-usage markdown docs, search/3
  (elements + usages, root-scoped), read-only enforcement, pagination cursor
  policy, and the §1.3 gate matrix.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias Noizu.MCP.Ctx
  alias Noizu.MCP.Server.Features.VFS
  alias Noizu.MCP.VFS.Cache
  alias NoizuPromptLingua.Domains.UnicodeCodex
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCP.VFS.Root
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Organizations.Organization
  alias NoizuPromptLingua.TRP.Cache, as: TrpCache
  alias NoizuPromptLingua.TRP.TestStub

  @usage_slug "vfs-usage"
  @global_slug "vfs-corner"
  @org_slug "vfs-bell"

  setup do
    TrpCache.clear()
    TestStub.reset()

    suffix = Ecto.UUID.generate() |> binary_part(0, 8)
    org = Repo.insert!(%Organization{name: "VFS Uni Org #{suffix}", slug: "vfs-uni-#{suffix}"})
    TestStub.seed_org(org.id, org.slug, org.name)

    {:ok, _} =
      UnicodeCodex.upsert_special_usage(%{
        scope: "global",
        slug: @usage_slug,
        name: @usage_slug,
        title: "NPL Fence",
        description: "Marks NPL fenced regions.",
        topics: ["npl-syntax"],
        flags: ["npl"],
        references: [%{"source" => "npl.yaml", "note" => "npl.yaml"}]
      })

    element!(@global_slug, "global", nil, nil, "Top Left Corner", "U+231C")
    element!(@org_slug, "organization", org.id, nil, "Bell Alert", "U+1F600")

    on_exit(fn -> Cache.purge(Root) end)

    %{org: org, ctx: key_ctx(%{"groups" => %{"unicode" => %{}}})}
  end

  defp element!(slug, scope, org_id, project_id, title, codepoint) do
    {:ok, _} =
      UnicodeCodex.upsert_element(%{
        scope: scope,
        organization_id: org_id,
        project_id: project_id,
        slug: slug,
        codepoint: codepoint,
        char: codepoint && "x",
        name: String.upcase(slug),
        title: title,
        description: "#{title} element",
        flags: ["npl"],
        topics: ["npl-syntax"]
      })

    :ok
  end

  defp key_ctx(config) do
    uniq = System.unique_integer([:positive])

    user =
      %NoizuPromptLingua.Schema.Users.User{
        id: Ecto.UUID.generate(),
        email: "vfsuni-#{uniq}@example.com",
        user_name: "vfsuni#{uniq}",
        handle: "vfsuni#{uniq}",
        status: :active
      }
      |> Repo.insert!()

    {:ok, key, _} = MCPApiKeys.generate_api_key(user.id, "vfs-unicode", toolset_config: config)

    %Ctx{
      server: NoizuPromptLingua.MCP.VFSServer,
      session_id: "uni-" <> Integer.to_string(uniq),
      assigns: %{auth_claims: %{"api_key_id" => key.id, "sub" => user.id}}
    }
  end

  defp base(org), do: "/tobor/#{org.slug}/unicode"

  # ── tree shape ────────────────────────────────────────────────────────────

  test "the reference tree lists overview, special-usages, and populated planes", %{
    org: org,
    ctx: ctx
  } do
    assert {:ok, dir} = VFS.stat(Root, base(org), ctx)
    assert dir.type == :dir and dir.writable == false

    assert {:ok, entries, nil} = VFS.list(Root, base(org), nil, ctx)
    names = Enum.map(entries, & &1.name)
    assert names == ["overview.md", "special-usages", "plane-0", "plane-1"]

    assert {:ok, md, _} = VFS.read(Root, "#{base(org)}/overview.md", ctx)
    assert md =~ "Unicode"

    # Empty planes do not exist.
    assert {:error, :enoent} = VFS.stat(Root, "#{base(org)}/plane-15", ctx)
  end

  test "{U+XXXX}.json serves the effective element document", %{org: org, ctx: ctx} do
    path = "#{base(org)}/plane-0/U+231C.json"
    assert {:ok, node} = VFS.stat(Root, path, ctx)
    assert node.type == :file and node.size > 0

    assert {:ok, json, _} = VFS.read(Root, path, ctx)
    {:ok, element} = Jason.decode(json)
    assert element["slug"] == @global_slug
    assert element["codepoint"] == "U+231C"
    assert element["title"] == "Top Left Corner"
    assert is_map(element["escape_forms"])

    # Case-insensitive, unpadded codepoint names resolve to the same node.
    assert {:ok, json2, _} = VFS.read(Root, "#{base(org)}/plane-1/U+1f600.json", ctx)
    assert json2 != ""
  end

  test "org layers shadow global rows in the generated tree", %{org: org, ctx: ctx} do
    element!(@global_slug, "organization", org.id, nil, "Org Corner", "U+231C")

    assert {:ok, json, _} = VFS.read(Root, "#{base(org)}/plane-0/U+231C.json", ctx)
    {:ok, element} = Jason.decode(json)
    assert element["title"] == "Org Corner"
    assert element["scope"] == "organization"
    # The effective org row is shadowed by nothing; the global layer is its override.
    assert [%{"scope" => "global"}] = element["overrides"] |> List.wrap()
  end

  # ── special usages ────────────────────────────────────────────────────────

  test "special-usages lists slugs and renders the markdown doc", %{org: org, ctx: ctx} do
    assert {:ok, entries, nil} = VFS.list(Root, "#{base(org)}/special-usages", nil, ctx)
    assert Enum.map(entries, & &1.name) == ["#{@usage_slug}.md"]

    assert {:ok, md, _} = VFS.read(Root, "#{base(org)}/special-usages/#{@usage_slug}.md", ctx)
    assert md =~ "NPL Fence"
    assert md =~ "npl-syntax"
    assert md =~ "npl.yaml"

    assert {:error, :enoent} = VFS.read(Root, "#{base(org)}/special-usages/nope.md", ctx)
  end

  # ── read-only enforcement ─────────────────────────────────────────────────

  test "mutating ops are :enosys; structural errnos hold", %{org: org, ctx: ctx} do
    assert {:error, :enosys} = VFS.write(Root, "#{base(org)}/plane-0/U+231C.json", "{}", ctx)
    assert {:error, :enosys} = VFS.create(Root, "#{base(org)}/plane-0/U+9999.json", "{}", ctx)
    assert {:error, :enosys} = VFS.remove(Root, "#{base(org)}/special-usages", ctx)

    assert {:error, :eisdir} = VFS.read(Root, base(org), ctx)
    assert {:error, :eisdir} = VFS.read(Root, "#{base(org)}/plane-0", ctx)
    assert {:error, :enotdir} = VFS.list(Root, "#{base(org)}/plane-0/U+231C.json", nil, ctx)
    assert {:error, :enoent} = VFS.read(Root, "#{base(org)}/plane-0/U+FFFF.json", ctx)
    assert {:error, :enoent} = VFS.stat(Root, "#{base(org)}/plane-zero", ctx)
  end

  # ── search ────────────────────────────────────────────────────────────────

  test "search/3 matches elements with synthesized reference paths", %{org: org, ctx: ctx} do
    assert {:ok, matches, nil} = VFS.search(Root, base(org), "corner", ctx)
    assert [%{path: path, line: 1, text: text}] = matches
    assert path == "#{base(org)}/plane-0/U+231C.json"
    assert text =~ "Top Left Corner"

    # Root-scoped: a plane root restricts the search space.
    assert {:ok, [], nil} = VFS.search(Root, "#{base(org)}/plane-1", "corner", ctx)

    # Under special-usages the query runs over usage docs instead.
    assert {:ok, [usage_match], nil} =
             VFS.search(Root, "#{base(org)}/special-usages", "fence", ctx)

    assert usage_match.path == "#{base(org)}/special-usages/#{@usage_slug}.md"

    assert {:error, :enosys} = VFS.search(Root, "/tobor", "corner", ctx)
  end

  # ── gating (§1.3) ─────────────────────────────────────────────────────────

  test "excluded group is :enoent despite read-only-ness", %{org: org} do
    ctx = key_ctx(%{"groups" => %{"artifacts" => %{}}})

    assert {:error, :enoent} = VFS.stat(Root, base(org), ctx)
    assert {:error, :enoent} = VFS.read(Root, "#{base(org)}/overview.md", ctx)
    assert {:error, :enoent} = VFS.search(Root, base(org), "corner", ctx)
  end

  # ── direct backend call ───────────────────────────────────────────────────

  test "backend works standalone on full absolute paths", %{org: org, ctx: ctx} do
    {:ok, entries, _} =
      NoizuPromptLingua.MCP.VFS.Unicode.list("/tobor/#{org.slug}/unicode", nil, ctx)

    assert Enum.any?(entries, &(&1.name == "special-usages"))
  end
end
