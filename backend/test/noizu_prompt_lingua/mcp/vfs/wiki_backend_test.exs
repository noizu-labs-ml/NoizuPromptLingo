defmodule NoizuPromptLingua.MCP.VFS.WikiBackendTest do
  @moduledoc """
  Wave 1 battery for the wiki natural-file backend (MCP-VFS-GROUP-MOUNTS.md
  §2.1), in the shape of the Wave 0 suites: the backend through the lib's
  backend-level wrappers (`Noizu.MCP.Server.Features.VFS` — errno mapping,
  generation stamping), the Root prefix dispatch, the gating matrix, the
  server-level wire ops (`vfs_stat` … `vfs_search` through
  `NoizuPromptLingua.MCP.VFSServer`), and a daemon-shape round trip
  (materialize → local edit → push, per `McpMount.Mounter` semantics).
  """

  use NoizuPromptLingua.DataCase, async: false

  alias Noizu.MCP.Server.Features.VFS
  alias Noizu.MCP.VFS.Cache
  alias Noizu.MCP.{Ctx, Error}
  alias NoizuPromptLingua.Domains.Wiki
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCP.VFS.Root
  alias NoizuPromptLingua.MCP.VFS.Router
  alias NoizuPromptLingua.MCP.VFS.Wiki, as: WikiVFS
  alias NoizuPromptLingua.MCP.VFSServer
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Users.User
  alias NoizuPromptLingua.TRP.Cache, as: TrpCache
  alias NoizuPromptLingua.TRP.TestStub

  setup do
    TrpCache.clear()
    TestStub.reset()

    org_id = seed_org()

    ctx = key_ctx(%{"groups" => %{"wiki" => %{}}})

    on_exit(fn ->
      Cache.purge(Root)
      Cache.purge(WikiVFS)
      Cache.purge(Router)
    end)

    %{org_id: org_id, ctx: ctx}
  end

  # ── fixtures ──────────────────────────────────────────────────────────────

  defp seed_org do
    # Random suffix: org slug → UUID resolution is Redis-cached for an hour
    # (NoizuPromptLingua.Cache via Resolve.organization_id), and the sandbox
    # does NOT roll Redis back — counter-based slugs would collide across
    # runs and resolve to a previous run's (rolled-back) org UUID.
    suffix = Base.encode16(:crypto.strong_rand_bytes(5), case: :lower)
    slug = "vfs-wiki-#{suffix}"
    org_id = Ecto.UUID.generate()

    TestStub.seed_org(org_id, slug, "VFS Wiki Org")

    Repo.query!(
      "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
        "VALUES ($1, $2, $3, now(), now())",
      [Ecto.UUID.dump!(org_id), slug, "VFS Wiki Org"]
    )

    org_id
  end

  defp org_slug!(org_id),
    do:
      Repo.query!("SELECT slug FROM organizations WHERE id = $1", [Ecto.UUID.dump!(org_id)]).rows
      |> hd()
      |> hd()

  defp key_ctx(
         config,
         session \\ "vfs-wiki-" <> Integer.to_string(System.unique_integer([:positive]))
       ) do
    uniq = System.unique_integer([:positive])

    user =
      %User{
        id: Ecto.UUID.generate(),
        email: "vfswiki-#{uniq}@example.com",
        user_name: "vfswiki#{uniq}",
        handle: "vfswiki#{uniq}",
        status: :active
      }
      |> Repo.insert!()

    {:ok, key, _raw} = MCPApiKeys.generate_api_key(user.id, "vfs-wiki", toolset_config: config)

    %Ctx{
      server: VFSServer,
      session_id: session,
      assigns: %{auth_claims: %{"api_key_id" => key.id, "sub" => user.id}}
    }
  end

  defp space_fixture(org_id, name \\ "Handbook") do
    slug = "sp-#{System.unique_integer([:positive])}"
    {:ok, space} = Wiki.create_space(%{organization_id: org_id, slug: slug, name: name})
    space
  end

  defp page_fixture(space, title \\ "Home", content \\ "# Home\n\nWelcome to the wiki.") do
    slug = "pg-#{System.unique_integer([:positive])}"

    {:ok, page} =
      Wiki.create_page(%{space_id: space.id, slug: slug, title: title, content: content})

    page
  end

  defp comment_fixture(page, body \\ "first!") do
    {:ok, comment} = Wiki.create_comment(%{page_id: page.id, author: "kai", body: body})
    comment
  end

  defp attachment_fixture(page, filename \\ "notes.txt", body \\ "attached text") do
    url = "data:text/plain;base64," <> Base.encode64(body)

    {:ok, att} =
      Wiki.create_attachment(%{
        page_id: page.id,
        filename: filename,
        url: url,
        mime_type: "text/plain",
        byte_size: byte_size(body)
      })

    att
  end

  defp wpath(org_id, space, rest \\ nil) do
    base = "/tobor/#{org_slug!(org_id)}/wiki/#{space.slug}"
    if rest, do: base <> "/" <> rest, else: base
  end

  # ══ stat ═══════════════════════════════════════════════════════════════════

  describe "stat" do
    test "maps the wiki namespace", %{org_id: org_id, ctx: ctx} do
      space = space_fixture(org_id)
      page = page_fixture(space)
      comment_fixture(page)
      attachment_fixture(page)

      assert {:ok, root} = VFS.stat(WikiVFS, "/tobor/#{org_slug!(org_id)}/wiki", ctx)
      assert root.type == :dir and root.writable

      assert {:ok, dir} = VFS.stat(WikiVFS, wpath(org_id, space), ctx)
      assert dir.type == :dir
      assert dir.xattrs["id"] == space.id

      assert {:ok, meta} = VFS.stat(WikiVFS, wpath(org_id, space, "_space.json"), ctx)
      assert meta.type == :file and meta.size > 0
      assert meta.xattrs["id"] == space.id

      page_path = wpath(org_id, space, page.slug <> ".md")
      assert {:ok, pf} = VFS.stat(WikiVFS, page_path, ctx)
      assert pf.type == :file and pf.size > 0 and pf.writable
      assert pf.xattrs["title"] == page.title
      # Row version is the row's updated_at; the wrapper stamps the cache
      # generation on top.
      assert pf.version >= DateTime.to_unix(page.updated_at, :millisecond)

      assert {:ok, cdir} = VFS.stat(WikiVFS, wpath(org_id, space, page.slug <> ".comments"), ctx)
      assert cdir.type == :dir

      assert {:ok, cfile} =
               VFS.stat(
                 WikiVFS,
                 wpath(org_id, space, page.slug <> ".comments/#{comment_fixture(page).id}.json"),
                 ctx
               )

      assert cfile.type == :file and cfile.writable == false

      assert {:ok, adir} = VFS.stat(WikiVFS, wpath(org_id, space, page.slug <> ".assets"), ctx)
      assert adir.type == :dir

      assert {:ok, afile} =
               VFS.stat(WikiVFS, wpath(org_id, space, page.slug <> ".assets/notes.txt"), ctx)

      assert afile.type == :file and afile.xattrs["mime_type"] == "text/plain"

      assert {:ok, rx} = VFS.stat(WikiVFS, wpath(org_id, space, "reactions.json"), ctx)
      assert rx.type == :file

      assert {:ok, ov} = VFS.stat(WikiVFS, "/tobor/#{org_slug!(org_id)}/wiki/overview.md", ctx)
      assert ov.type == :file and ov.writable
    end

    test "unknown paths are :enoent, traversal is refused", %{org_id: org_id, ctx: ctx} do
      space = space_fixture(org_id)

      assert {:error, :enoent} = VFS.stat(WikiVFS, wpath(org_id, space, "nope.md"), ctx)

      assert {:error, :enoent} =
               VFS.stat(WikiVFS, "/tobor/#{org_slug!(org_id)}/wiki/no-such-space", ctx)

      assert {:error, :enoent} = VFS.stat(WikiVFS, "/tobor/no-such-org/wiki", ctx)
      assert {:error, :enoent} = VFS.stat(WikiVFS, "/tobor/../etc", ctx)
      assert {:error, :enoent} = VFS.stat(WikiVFS, wpath(org_id, space, "x.md/../y.md"), ctx)

      assert {:error, :enoent} =
               VFS.stat(WikiVFS, wpath(org_id, space, "some/very/deep/node"), ctx)
    end
  end

  # ══ list ═══════════════════════════════════════════════════════════════════

  describe "list" do
    test "group root lists spaces + overview", %{org_id: org_id, ctx: ctx} do
      space = space_fixture(org_id)

      assert {:ok, entries, nil} = VFS.list(WikiVFS, "/tobor/#{org_slug!(org_id)}/wiki", nil, ctx)

      slug = space.slug
      assert Enum.any?(entries, &match?(%{name: ^slug, type: :dir}, &1))
      assert Enum.any?(entries, &match?(%{name: "overview.md", type: :file}, &1))
    end

    test "space lists pages and meta files; collections only when non-empty", %{
      org_id: org_id,
      ctx: ctx
    } do
      space = space_fixture(org_id)
      page = page_fixture(space)
      bare = page_fixture(space, "Bare", "no attachments here")

      assert {:ok, entries, nil} = VFS.list(WikiVFS, wpath(org_id, space), nil, ctx)
      names = Enum.map(entries, & &1.name)

      assert "_space.json" in names
      assert "reactions.json" in names
      assert (page.slug <> ".md") in names
      assert (bare.slug <> ".md") in names
      # No comments/assets yet → their collection dirs are not listed.
      refute (page.slug <> ".comments") in names
      refute (page.slug <> ".assets") in names

      comment_fixture(page)
      attachment_fixture(page)

      assert {:ok, entries, _} = VFS.list(WikiVFS, wpath(org_id, space), nil, ctx)
      names = Enum.map(entries, & &1.name)
      assert (page.slug <> ".comments") in names
      assert (page.slug <> ".assets") in names
    end

    test "collections list items, files are :enotdir, unknown is :enoent", %{
      org_id: org_id,
      ctx: ctx
    } do
      space = space_fixture(org_id)
      page = page_fixture(space)
      comment = comment_fixture(page)
      attachment_fixture(page)

      assert {:ok, entries, nil} =
               VFS.list(WikiVFS, wpath(org_id, space, page.slug <> ".comments"), nil, ctx)

      assert [%{name: name, type: :file}] = entries
      assert name == comment.id <> ".json"

      assert {:ok, entries, nil} =
               VFS.list(WikiVFS, wpath(org_id, space, page.slug <> ".assets"), nil, ctx)

      assert [%{name: "notes.txt", type: :file}] = entries

      assert {:error, :enotdir} =
               VFS.list(WikiVFS, wpath(org_id, space, page.slug <> ".md"), nil, ctx)

      assert {:error, :enotdir} = VFS.list(WikiVFS, wpath(org_id, space, "_space.json"), nil, ctx)
      assert {:error, :enoent} = VFS.list(WikiVFS, wpath(org_id, space, "nope.md/x"), nil, ctx)
    end

    test "large spaces paginate with cursors", %{org_id: org_id, ctx: ctx} do
      space = space_fixture(org_id)

      for i <- 1..60 do
        {:ok, _} = Wiki.create_page(%{space_id: space.id, slug: "bulk-#{i}", title: "Bulk #{i}"})
      end

      assert {:ok, page1, next} = VFS.list(WikiVFS, wpath(org_id, space), nil, ctx)
      assert length(page1) == 50
      assert is_binary(next)

      assert {:ok, page2, nil} = VFS.list(WikiVFS, wpath(org_id, space), next, ctx)
      assert length(page2) == 12
      # 2 meta files + 60 pages, no overlap between the pages.
      names = Enum.map(page1 ++ page2, & &1.name)
      assert length(Enum.uniq(names)) == 62

      assert {:error, %Error{}} = VFS.list(WikiVFS, wpath(org_id, space), "garbage", ctx)
    end
  end

  # ══ read ═══════════════════════════════════════════════════════════════════

  describe "read" do
    test "page.md renders front-matter + body", %{org_id: org_id, ctx: ctx} do
      space = space_fixture(org_id)
      page = page_fixture(space, "Roadmap", "## Now\n- ship")

      assert {:ok, md, version} = VFS.read(WikiVFS, wpath(org_id, space, page.slug <> ".md"), ctx)

      assert String.starts_with?(md, "---\n")
      assert md =~ "title: Roadmap"
      assert md =~ "slug: #{page.slug}"
      assert String.ends_with?(md, "\n---\n## Now\n- ship")
      assert version >= DateTime.to_unix(page.updated_at, :millisecond)
    end

    test "_space.json is the canonical space document", %{org_id: org_id, ctx: ctx} do
      space = space_fixture(org_id, "Team Area")

      {:ok, json, _} = VFS.read(WikiVFS, wpath(org_id, space, "_space.json"), ctx)
      assert {:ok, doc} = Jason.decode(json)

      assert doc["id"] == space.id
      assert doc["slug"] == space.slug
      assert doc["name"] == "Team Area"
      assert doc["organization_id"] == org_id
    end

    test "comment and asset files round-trip", %{org_id: org_id, ctx: ctx} do
      space = space_fixture(org_id)
      page = page_fixture(space)
      comment = comment_fixture(page, "looks good")
      attachment_fixture(page, "data.csv", "a,b\n1,2\n")

      {:ok, cjson, _} =
        VFS.read(WikiVFS, wpath(org_id, space, page.slug <> ".comments/#{comment.id}.json"), ctx)

      assert {:ok, cdoc} = Jason.decode(cjson)
      assert cdoc["body"] == "looks good"
      assert cdoc["author"] == "kai"

      {:ok, csv, _} =
        VFS.read(WikiVFS, wpath(org_id, space, page.slug <> ".assets/data.csv"), ctx)

      assert csv == "a,b\n1,2\n"
    end

    test "externally-hosted attachments read as their URL out-ref", %{org_id: org_id, ctx: ctx} do
      space = space_fixture(org_id)
      page = page_fixture(space)

      {:ok, _} =
        Wiki.create_attachment(%{
          page_id: page.id,
          filename: "logo.png",
          url: "https://cdn.example/logo.png",
          mime_type: "image/png",
          byte_size: 42
        })

      {:ok, content, _} =
        VFS.read(WikiVFS, wpath(org_id, space, page.slug <> ".assets/logo.png"), ctx)

      assert content == "https://cdn.example/logo.png"
    end

    test "reactions.json renders the desired-state document", %{org_id: org_id, ctx: ctx} do
      space = space_fixture(org_id)
      page = page_fixture(space)
      comment = comment_fixture(page)

      {:ok, _} =
        Wiki.add_reaction(%{target_type: "page", target_id: page.id, emoji: "🚀", actor: "kai"})

      {:ok, _} =
        Wiki.add_reaction(%{
          target_type: "comment",
          target_id: comment.id,
          emoji: "👍",
          actor: "kim"
        })

      {:ok, json, _} = VFS.read(WikiVFS, wpath(org_id, space, "reactions.json"), ctx)
      assert {:ok, doc} = Jason.decode(json)
      assert doc["page"][page.id] == [%{"emoji" => "🚀", "actor" => "kai"}]
      assert doc["comment"][comment.id] == [%{"emoji" => "👍", "actor" => "kim"}]
    end

    test "dirs are :eisdir, unknown pages :enoent, overview readable", %{org_id: org_id, ctx: ctx} do
      space = space_fixture(org_id)
      page = page_fixture(space)

      assert {:error, :eisdir} = VFS.read(WikiVFS, "/tobor/#{org_slug!(org_id)}/wiki", ctx)
      assert {:error, :eisdir} = VFS.read(WikiVFS, wpath(org_id, space), ctx)
      assert {:error, :enoent} = VFS.read(WikiVFS, wpath(org_id, space, "nope.md"), ctx)

      assert {:ok, md, _} = VFS.read(WikiVFS, "/tobor/#{org_slug!(org_id)}/wiki/overview.md", ctx)
      assert md =~ "# Wiki"
    end
  end

  # ══ create ═════════════════════════════════════════════════════════════════

  describe "create" do
    test "space via :dir (name defaults to slug) and via JSON", %{org_id: org_id, ctx: ctx} do
      slug = "created-#{System.unique_integer([:positive])}"

      assert {:ok, node} =
               VFS.create(WikiVFS, "/tobor/#{org_slug!(org_id)}/wiki/#{slug}", :dir, ctx)

      assert node.type == :dir

      space = Wiki.get_space_by_slug(org_id, slug)
      assert space.name == slug

      slug2 = "json-#{System.unique_integer([:positive])}"
      body = Jason.encode!(%{"name" => "JSON Space", "description" => "via file create"})

      assert {:ok, _} =
               VFS.create(WikiVFS, "/tobor/#{org_slug!(org_id)}/wiki/#{slug2}", body, ctx)

      space2 = Wiki.get_space_by_slug(org_id, slug2)
      assert space2.name == "JSON Space"
      assert space2.description == "via file create"

      assert {:error, :eexist} =
               VFS.create(WikiVFS, "/tobor/#{org_slug!(org_id)}/wiki/#{slug}", :dir, ctx)
    end

    test "page.md with front-matter, H1 fallback, and humanized fallback", %{
      org_id: org_id,
      ctx: ctx
    } do
      space = space_fixture(org_id)

      data = "---\ntitle: Spec Page\nposition: 7\n---\nThe body\n"

      assert {:ok, _} = VFS.create(WikiVFS, wpath(org_id, space, "spec-page.md"), data, ctx)
      page = Wiki.get_page_by_slug(space.id, "spec-page")
      assert page.title == "Spec Page"
      assert page.position == 7
      assert page.content == "The body\n"

      assert {:ok, _} =
               VFS.create(
                 WikiVFS,
                 wpath(org_id, space, "h1-page.md"),
                 "# Heading Rules\nbody",
                 ctx
               )

      assert Wiki.get_page_by_slug(space.id, "h1-page").title == "Heading Rules"

      assert {:ok, _} = VFS.create(WikiVFS, wpath(org_id, space, "no-title.md"), "just text", ctx)
      assert Wiki.get_page_by_slug(space.id, "no-title").title == "No Title"

      assert {:error, :eexist} =
               VFS.create(WikiVFS, wpath(org_id, space, "spec-page.md"), "again", ctx)

      assert {:error, :enoent} =
               VFS.create(WikiVFS, wpath(org_id, space, "bad/../y.md"), "x", ctx)
    end

    test "comments: server-assigned ids, raw or JSON bodies, author defaults to principal", %{
      org_id: org_id,
      ctx: ctx
    } do
      space = space_fixture(org_id)
      page = page_fixture(space)

      assert {:ok, node} =
               VFS.create(
                 WikiVFS,
                 wpath(org_id, space, page.slug <> ".comments/new-comment.json"),
                 "raw body",
                 ctx
               )

      assert is_binary(node.xattrs["id"])

      comment = Wiki.get_comment(node.xattrs["id"])
      assert comment.body == "raw body"
      assert comment.author == ctx.assigns.auth_claims["sub"]

      doc = Jason.encode!(%{"body" => "json body", "author" => "kai"})

      assert {:ok, node2} =
               VFS.create(
                 WikiVFS,
                 wpath(org_id, space, page.slug <> ".comments/whatever.json"),
                 doc,
                 ctx
               )

      comment2 = Wiki.get_comment(node2.xattrs["id"])
      assert comment2.author == "kai"

      # The materialized filenames do not exist — ids are server-assigned.
      assert {:error, :enoent} =
               VFS.stat(
                 WikiVFS,
                 wpath(org_id, space, page.slug <> ".comments/new-comment.json"),
                 ctx
               )

      assert {:error, :enoent} =
               VFS.create(WikiVFS, wpath(org_id, space, "nope.md.comments/c.json"), "x", ctx)
    end

    test "assets: text stored as data URI, duplicates :eexist, binary :enosys", %{
      org_id: org_id,
      ctx: ctx
    } do
      space = space_fixture(org_id)
      page = page_fixture(space)

      assert {:ok, _} =
               VFS.create(
                 WikiVFS,
                 wpath(org_id, space, page.slug <> ".assets/readme.md"),
                 "# hi",
                 ctx
               )

      att = find_att(page, "readme.md")
      assert att.byte_size == 4
      assert att.mime_type == "text/markdown"
      assert String.starts_with?(att.url, "data:text/markdown;base64,")

      assert {:error, :eexist} =
               VFS.create(
                 WikiVFS,
                 wpath(org_id, space, page.slug <> ".assets/readme.md"),
                 "again",
                 ctx
               )

      assert {:error, :enosys} =
               VFS.create(
                 WikiVFS,
                 wpath(org_id, space, page.slug <> ".assets/blob.bin"),
                 <<0xFF, 0xFE, 0x00>>,
                 ctx
               )

      assert {:error, :enoent} =
               VFS.create(WikiVFS, wpath(org_id, space, "nope.md.assets/x.txt"), "x", ctx)
    end

    test "collection dirs and meta files: implicit", %{org_id: org_id, ctx: ctx} do
      space = space_fixture(org_id)
      page = page_fixture(space)

      assert {:error, :eexist} =
               VFS.create(WikiVFS, wpath(org_id, space, page.slug <> ".comments"), :dir, ctx)

      assert {:error, :eexist} =
               VFS.create(WikiVFS, wpath(org_id, space, "_space.json"), "{}", ctx)

      assert {:error, :eexist} =
               VFS.create(WikiVFS, "/tobor/#{org_slug!(org_id)}/wiki", :dir, ctx)

      assert {:error, :eexist} =
               VFS.create(WikiVFS, "/tobor/#{org_slug!(org_id)}/wiki/overview.md", "x", ctx)

      assert {:error, :enoent} =
               VFS.create(WikiVFS, wpath(org_id, space, "ghost.md.comments"), :dir, ctx)
    end
  end

  # ══ write ══════════════════════════════════════════════════════════════════

  describe "write" do
    test "page.md: front-matter drives title/position, body is replaced", %{
      org_id: org_id,
      ctx: ctx
    } do
      space = space_fixture(org_id)
      parent = page_fixture(space, "Parent")
      page = page_fixture(space, "Original", "old body")

      data = "---\ntitle: Renamed\nposition: 4\nparent: #{parent.slug}\n---\nnew body\n"

      assert {:ok, node} = VFS.write(WikiVFS, wpath(org_id, space, page.slug <> ".md"), data, ctx)
      assert node.type == :file

      fresh = Wiki.get_page(page.id)
      assert fresh.title == "Renamed"
      assert fresh.position == 4
      assert fresh.parent_id == parent.id
      assert fresh.content == "new body\n"
      assert fresh.slug == page.slug
    end

    test "page.md: no front-matter replaces only the body; fm slug is ignored", %{
      org_id: org_id,
      ctx: ctx
    } do
      space = space_fixture(org_id)
      page = page_fixture(space, "Keep Title", "old")

      assert {:ok, _} =
               VFS.write(WikiVFS, wpath(org_id, space, page.slug <> ".md"), "body only", ctx)

      fresh = Wiki.get_page(page.id)
      assert fresh.title == "Keep Title"
      assert fresh.content == "body only"

      data = "---\ntitle: Evil Slug\nslug: other-slug\n---\nx"
      assert {:ok, _} = VFS.write(WikiVFS, wpath(org_id, space, page.slug <> ".md"), data, ctx)
      fresh = Wiki.get_page(page.id)
      assert fresh.slug == page.slug
      assert fresh.title == "Evil Slug"
    end

    test "page.md: malformed front-matter is :eio, unknown page :enoent", %{
      org_id: org_id,
      ctx: ctx
    } do
      space = space_fixture(org_id)
      page = page_fixture(space)

      bad = "---\ntitle: \"unterminated\n---\nx"

      case VFS.write(WikiVFS, wpath(org_id, space, page.slug <> ".md"), bad, ctx) do
        {:error, :eio} -> :ok
        other -> flunk("expected :eio for malformed front-matter, got #{inspect(other)}")
      end

      assert {:error, :enoent} = VFS.write(WikiVFS, wpath(org_id, space, "nope.md"), "x", ctx)
    end

    test "_space.json merges name/description; malformed JSON is :eio", %{
      org_id: org_id,
      ctx: ctx
    } do
      space = space_fixture(org_id)

      doc = Jason.encode!(%{"name" => "Renamed Space", "description" => "updated via VFS"})
      assert {:ok, _} = VFS.write(WikiVFS, wpath(org_id, space, "_space.json"), doc, ctx)

      fresh = Wiki.get_space(space.id)
      assert fresh.name == "Renamed Space"
      assert fresh.description == "updated via VFS"
      assert fresh.slug == space.slug

      assert {:error, :eio} =
               VFS.write(WikiVFS, wpath(org_id, space, "_space.json"), "{not json", ctx)
    end

    test "reactions.json syncs page and comment reactions (add + remove)", %{
      org_id: org_id,
      ctx: ctx
    } do
      space = space_fixture(org_id)
      page = page_fixture(space)
      comment = comment_fixture(page)
      other_space = space_fixture(org_id)
      other_page = page_fixture(other_space, "Other")

      doc =
        Jason.encode!(%{
          "page" => %{
            page.id => [%{"emoji" => "🚀", "actor" => "kai"}, %{"emoji" => "👀", "actor" => "kim"}]
          },
          "comment" => %{comment.id => [%{"emoji" => "👍", "actor" => "kai"}]}
        })

      assert {:ok, _} = VFS.write(WikiVFS, wpath(org_id, space, "reactions.json"), doc, ctx)

      page_reactions = Wiki.list_reactions("page", page.id)

      assert MapSet.new(page_reactions, &{&1.emoji, &1.actor}) ==
               MapSet.new([{"🚀", "kai"}, {"👀", "kim"}])

      assert [%{emoji: "👍"}] = Wiki.list_reactions("comment", comment.id)

      # Desired-state: drop 👀 from the page doc → removed.
      doc2 =
        Jason.encode!(%{
          "page" => %{page.id => [%{"emoji" => "🚀", "actor" => "kai"}]},
          "comment" => %{}
        })

      assert {:ok, _} = VFS.write(WikiVFS, wpath(org_id, space, "reactions.json"), doc2, ctx)
      assert [%{emoji: "🚀"}] = Wiki.list_reactions("page", page.id)
      assert [] == Wiki.list_reactions("comment", comment.id)

      # Out-of-space targets are ignored, malformed docs are :eio.
      doc3 = Jason.encode!(%{"page" => %{other_page.id => [%{"emoji" => "💥", "actor" => "kai"}]}})
      assert {:ok, _} = VFS.write(WikiVFS, wpath(org_id, space, "reactions.json"), doc3, ctx)
      assert [] == Wiki.list_reactions("page", other_page.id)

      assert {:error, :eio} =
               VFS.write(WikiVFS, wpath(org_id, space, "reactions.json"), "[1,2]", ctx)
    end

    test "unwritable node kinds: comments/assets :enosys, dirs :eisdir, overview :enosys", %{
      org_id: org_id,
      ctx: ctx
    } do
      space = space_fixture(org_id)
      page = page_fixture(space)
      comment = comment_fixture(page)

      comment_path = wpath(org_id, space, page.slug <> ".comments/#{comment.id}.json")
      assert {:error, :enosys} = VFS.write(WikiVFS, comment_path, "edited", ctx)

      assert {:error, :enosys} =
               VFS.write(
                 WikiVFS,
                 wpath(org_id, space, page.slug <> ".assets/notes.txt"),
                 "x",
                 ctx
               )

      assert {:error, :eisdir} = VFS.write(WikiVFS, wpath(org_id, space), "x", ctx)
      assert {:error, :eisdir} = VFS.write(WikiVFS, "/tobor/#{org_slug!(org_id)}/wiki", "x", ctx)

      assert {:error, :enosys} =
               VFS.write(WikiVFS, "/tobor/#{org_slug!(org_id)}/wiki/overview.md", "x", ctx)

      assert {:error, :enoent} = VFS.write(WikiVFS, wpath(org_id, space, "nope.md"), "x", ctx)
    end
  end

  # ══ remove ═════════════════════════════════════════════════════════════════

  describe "remove" do
    test "page guards on comments/attachments, then deletes", %{org_id: org_id, ctx: ctx} do
      space = space_fixture(org_id)
      guarded = page_fixture(space)

      comment_fixture(guarded)

      assert {:error, :enotempty} =
               VFS.remove(WikiVFS, wpath(org_id, space, guarded.slug <> ".md"), ctx)

      Wiki.delete_comment(hd(Wiki.list_comments(guarded.id)).id)
      attachment_fixture(guarded)

      assert {:error, :enotempty} =
               VFS.remove(WikiVFS, wpath(org_id, space, guarded.slug <> ".md"), ctx)

      Wiki.delete_attachment(hd(Wiki.list_attachments(guarded.id)).id)
      assert :ok = VFS.remove(WikiVFS, wpath(org_id, space, guarded.slug <> ".md"), ctx)
      assert Wiki.get_page(guarded.id) == nil

      assert {:error, :enoent} =
               VFS.remove(WikiVFS, wpath(org_id, space, guarded.slug <> ".md"), ctx)
    end

    test "comments and assets unlink individually", %{org_id: org_id, ctx: ctx} do
      space = space_fixture(org_id)
      page = page_fixture(space)
      comment = comment_fixture(page)
      attachment_fixture(page, "tmp.txt")

      assert :ok =
               VFS.remove(
                 WikiVFS,
                 wpath(org_id, space, page.slug <> ".comments/#{comment.id}.json"),
                 ctx
               )

      assert Wiki.get_comment(comment.id) == nil

      assert :ok = VFS.remove(WikiVFS, wpath(org_id, space, page.slug <> ".assets/tmp.txt"), ctx)
      assert find_att(page, "tmp.txt") == nil

      assert {:error, :enoent} =
               VFS.remove(
                 WikiVFS,
                 wpath(org_id, space, page.slug <> ".comments/#{comment.id}.json"),
                 ctx
               )
    end

    test "space is :enotempty with pages, removable empty", %{org_id: org_id, ctx: ctx} do
      space = space_fixture(org_id)
      page_fixture(space)

      assert {:error, :enotempty} = VFS.remove(WikiVFS, wpath(org_id, space), ctx)

      Wiki.delete_page(hd(Wiki.list_pages(space.id)).id)
      assert :ok = VFS.remove(WikiVFS, wpath(org_id, space), ctx)
      assert Wiki.get_space(space.id) == nil
    end

    test "collections, meta files, furniture, and the group root refuse", %{
      org_id: org_id,
      ctx: ctx
    } do
      space = space_fixture(org_id)
      page = page_fixture(space)

      assert {:error, :enosys} =
               VFS.remove(WikiVFS, wpath(org_id, space, page.slug <> ".comments"), ctx)

      assert {:error, :enosys} = VFS.remove(WikiVFS, wpath(org_id, space, "_space.json"), ctx)
      assert {:error, :enosys} = VFS.remove(WikiVFS, wpath(org_id, space, "reactions.json"), ctx)

      assert {:error, :enosys} =
               VFS.remove(WikiVFS, "/tobor/#{org_slug!(org_id)}/wiki/overview.md", ctx)

      assert {:error, :eisdir} = VFS.remove(WikiVFS, "/tobor/#{org_slug!(org_id)}/wiki", ctx)
    end

    test "removing a page with reactions succeeds and the doc drops it", %{
      org_id: org_id,
      ctx: ctx
    } do
      space = space_fixture(org_id)
      page = page_fixture(space)

      {:ok, _} =
        Wiki.add_reaction(%{target_type: "page", target_id: page.id, emoji: "🚀", actor: "kai"})

      # Reactions are not structural children (no FK) — the page removes.
      assert :ok = VFS.remove(WikiVFS, wpath(org_id, space, page.slug <> ".md"), ctx)

      {:ok, json, _} = VFS.read(WikiVFS, wpath(org_id, space, "reactions.json"), ctx)
      refute Jason.decode!(json)["page"][page.id]
    end
  end

  # ══ search ═════════════════════════════════════════════════════════════════

  describe "search" do
    test "greps page bodies under a root, case-insensitive, with path/line/text", %{
      org_id: org_id,
      ctx: ctx
    } do
      s1 = space_fixture(org_id)
      s2 = space_fixture(org_id)
      page_fixture(s1, "A", "alpha line\nfind ME here\ntail")
      page_fixture(s2, "B", "nothing\nfind me too")

      wiki_root = "/tobor/#{org_slug!(org_id)}/wiki"
      assert {:ok, matches, nil} = VFS.search(WikiVFS, wiki_root, "find me", ctx)
      assert length(matches) == 2

      assert Enum.any?(matches, fn m ->
               m.path == wpath(org_id, s1, hd(Wiki.list_pages(s1.id)).slug <> ".md") and
                 m.line == 2 and m.text == "find ME here"
             end)

      assert {:ok, scoped, nil} = VFS.search(WikiVFS, wpath(org_id, s2), "find me", ctx)
      assert length(scoped) == 1
      assert hd(scoped).line == 2

      page = hd(Wiki.list_pages(s2.id))

      assert {:ok, single, nil} =
               VFS.search(WikiVFS, wpath(org_id, s2, page.slug <> ".md"), "find me", ctx)

      assert length(single) == 1

      assert {:ok, [], nil} = VFS.search(WikiVFS, wiki_root, "no-such-needle", ctx)
    end

    test "search roots outside/inside file nodes", %{org_id: org_id, ctx: ctx} do
      space = space_fixture(org_id)
      wiki_root = "/tobor/#{org_slug!(org_id)}/wiki"

      assert {:error, :enotdir} =
               VFS.search(WikiVFS, wpath(org_id, space, "_space.json"), "x", ctx)

      assert {:error, :enoent} = VFS.search(WikiVFS, wiki_root <> "/no-space", "x", ctx)
    end
  end

  # ══ gating (§1.3, wiki subtree) ════════════════════════════════════════════

  describe "gating" do
    test "included but disabled group: readable, not writable", %{org_id: org_id} do
      space = space_fixture(org_id)
      page = page_fixture(space)
      ctx = key_ctx(%{"groups" => %{"wiki" => %{"disabled" => true}}})

      assert {:ok, dir} = VFS.stat(WikiVFS, wpath(org_id, space), ctx)
      assert dir.writable == false

      assert {:ok, _, _} = VFS.read(WikiVFS, wpath(org_id, space, page.slug <> ".md"), ctx)
      assert {:error, :eacces} = VFS.create(WikiVFS, wpath(org_id, space, "new.md"), "x", ctx)

      assert {:error, :eacces} =
               VFS.write(WikiVFS, wpath(org_id, space, page.slug <> ".md"), "x", ctx)

      assert {:error, :eacces} =
               VFS.remove(WikiVFS, wpath(org_id, space, page.slug <> ".md"), ctx)
    end

    test "excluded group subtree is :enoent (no existence leak)", %{org_id: org_id} do
      space = space_fixture(org_id)
      ctx = key_ctx(%{"groups" => %{"chat" => %{}}})

      assert {:error, :enoent} = VFS.stat(WikiVFS, wpath(org_id, space), ctx)
      assert {:error, :enoent} = VFS.read(WikiVFS, wpath(org_id, space, "_space.json"), ctx)
      assert {:error, :enoent} = VFS.search(WikiVFS, "/tobor/#{org_slug!(org_id)}/wiki", "x", ctx)
    end

    test "hidden group mirrors excluded; empty TRP scope hides the org", %{org_id: org_id} do
      space = space_fixture(org_id)
      hidden = key_ctx(%{"groups" => %{"wiki" => %{"hidden" => true}}})

      assert {:error, :enoent} = VFS.stat(WikiVFS, wpath(org_id, space), hidden)

      TestStub.reset()
      TrpCache.clear()

      scoped_ctx = key_ctx(%{"groups" => %{"wiki" => %{}}})
      assert {:error, :enoent} = VFS.stat(WikiVFS, wpath(org_id, space), scoped_ctx)
    end
  end

  # ══ Root prefix dispatch ═══════════════════════════════════════════════════

  describe "root dispatch" do
    test "Root serves the wiki subtree with the backend's results", %{org_id: org_id, ctx: ctx} do
      space = space_fixture(org_id)
      page = page_fixture(space, "Dispatched", "reach me through root")

      page_path = wpath(org_id, space, page.slug <> ".md")

      assert {:ok, pf} = VFS.stat(Root, page_path, ctx)
      assert pf.type == :file and pf.xattrs["title"] == "Dispatched"

      assert {:ok, entries, _} = VFS.list(Root, "/tobor/#{org_slug!(org_id)}/wiki", nil, ctx)
      slug = space.slug
      assert Enum.any?(entries, &match?(%{name: ^slug, type: :dir}, &1))
      assert Enum.any?(entries, &match?(%{name: "overview.md", type: :file}, &1))

      assert {:ok, md, _} = VFS.read(Root, page_path, ctx)
      assert md =~ "reach me through root"

      assert {:error, :eisdir} = VFS.read(Root, "/tobor/#{org_slug!(org_id)}/wiki", ctx)
      assert {:error, :enosys} = VFS.search(Root, "/tobor/#{org_slug!(org_id)}/tickets", "x", ctx)

      # Mutations ride the dispatch too.
      assert {:ok, _} = VFS.write(Root, page_path, "edited via root", ctx)
      fresh = Wiki.get_page(page.id)
      assert fresh.content == "edited via root"
    end
  end

  # ══ end-to-end wire (server-level vfs ops through VFSServer → Router) ═════

  describe "wire (vfs_* server ops)" do
    test "stat/list/read/write/remove round trip through the composed Router", %{
      org_id: org_id,
      ctx: ctx
    } do
      space = space_fixture(org_id)
      page_path = wpath(org_id, space, "wire.md")

      assert {:ok, created} =
               VFS.vfs_create(VFSServer, %{"path" => page_path, "data" => "# Wire\nv1"}, ctx)

      assert created["type"] == "file"

      assert {:ok, listed} = VFS.vfs_list(VFSServer, %{"path" => wpath(org_id, space)}, ctx)
      # Entries pass through with the backend's atom-keyed shape.
      assert Enum.any?(listed["entries"], &(&1.name == "wire.md"))

      assert {:ok, st} = VFS.vfs_stat(VFSServer, %{"path" => page_path}, ctx)
      assert st["type"] == "file"

      assert {:ok, read1} = VFS.vfs_read(VFSServer, %{"path" => page_path}, ctx)
      # Reads render the front-matter + body form.
      assert read1["content"] =~ "# Wire"
      assert read1["content"] =~ "v1"
      assert read1["version"] == st["version"]

      assert {:ok, written} =
               VFS.vfs_write(VFSServer, %{"path" => page_path, "data" => "# Wire\nv2"}, ctx)

      assert written["version"] > read1["version"]

      assert {:ok, read2} = VFS.vfs_read(VFSServer, %{"path" => page_path}, ctx)
      assert String.ends_with?(read2["content"], "# Wire\nv2")
      assert read2["version"] == written["version"]

      assert {:ok, found} =
               VFS.vfs_search(VFSServer, %{"root" => wpath(org_id, space), "query" => "v2"}, ctx)

      # Matches pass through with the backend's atom-keyed shape.
      assert [%{path: ^page_path, line: 2, text: "v2"}] = found["matches"]

      assert {:ok, %{"removed" => ^page_path}} =
               VFS.vfs_remove(VFSServer, %{"path" => page_path}, ctx)

      assert {:error, %Error{}} = VFS.vfs_read(VFSServer, %{"path" => page_path}, ctx)
    end

    test "errno → wire code mapping", %{org_id: org_id, ctx: ctx} do
      space = space_fixture(org_id)
      page = page_fixture(space)
      # Children make the page non-empty, so its remove maps to :enotempty.
      comment_fixture(page)

      assert {:error, %Error{code: -32_002}} =
               VFS.vfs_stat(VFSServer, %{"path" => wpath(org_id, space, "nope.md")}, ctx)

      assert {:error, %Error{code: -32_041}} =
               VFS.vfs_create(
                 VFSServer,
                 %{"path" => wpath(org_id, space, page.slug <> ".md"), "data" => "dup"},
                 ctx
               )

      assert {:error, %Error{code: -32_045}} =
               VFS.vfs_remove(
                 VFSServer,
                 %{"path" => wpath(org_id, space, page.slug <> ".md")},
                 ctx
               )

      assert {:error, %Error{code: -32_046}} =
               VFS.vfs_write(
                 VFSServer,
                 %{"path" => "/tobor/#{org_slug!(org_id)}/wiki/overview.md", "data" => "x"},
                 ctx
               )

      assert {:error, %Error{code: -32_046}} =
               VFS.vfs_remove(VFSServer, %{"path" => wpath(org_id, space, "_space.json")}, ctx)
    end

    test "gated principals surface :eacces on the wire", %{org_id: org_id} do
      space = space_fixture(org_id)
      page = page_fixture(space)
      ctx = key_ctx(%{"groups" => %{"wiki" => %{"disabled" => true}}})

      assert {:error, %Error{code: -32_040}} =
               VFS.vfs_write(
                 VFSServer,
                 %{"path" => wpath(org_id, space, page.slug <> ".md"), "data" => "x"},
                 ctx
               )
    end
  end

  # ══ daemon-shape round trip (McpMount.Mounter semantics) ══════════════════

  describe "daemon shape" do
    test "materialize → local edit → vfs_write round trip with versioned pushes", %{
      org_id: org_id,
      ctx: ctx
    } do
      space = space_fixture(org_id)
      page = page_fixture(space, "Mountable", "line one\nline two")
      comment_fixture(page)
      attachment_fixture(page, "doc.txt", "doc body")

      wiki_root = "/tobor/#{org_slug!(org_id)}/wiki"

      # 1) Snapshot: recursive walk (list + paginate), stat + read every file —
      #    the McpMount.Mounter walk/1 + stat/read materialization shape.
      files = walk!(wiki_root, ctx)
      assert page_file = Enum.find(files, &String.ends_with?(&1.path, page.slug <> ".md"))
      assert Enum.any?(files, &String.contains?(&1.path, ".comments/"))
      assert Enum.any?(files, &String.contains?(&1.path, ".assets/doc.txt"))

      local = String.replace(page_file.content, "line one", "line ONE (edited locally)")
      assert local != page_file.content

      # 2) Push: stat-then-write with the manifest version; the server accepts
      #    (no CAS) and the next snapshot version moves forward.
      assert {:ok, _node} = VFS.write(Router, page_file.path, local, ctx)

      # The write lands; the body is the pushed content (the front-matter
      # `updated` stamp moves, which is the server's render — the mounter
      # tracks versions, not whole-file bytes, for its self-echo check).
      assert {:ok, repushed, _v2} = VFS.read(WikiVFS, page_file.path, ctx)
      assert String.ends_with?(repushed, "line ONE (edited locally)\nline two")

      fresh = Wiki.get_page(page.id)
      # The stored row content is the pushed body (front-matter is render).
      assert fresh.content == "line ONE (edited locally)\nline two"

      assert DateTime.to_unix(fresh.updated_at, :millisecond) >=
               DateTime.to_unix(page.updated_at, :millisecond)

      # 3) Out-of-band (web-UI-style) edit: ttl class — visible on the next
      #    read (cache disabled), no pubsub event.
      {:ok, _} = Wiki.update_page(page.id, %{content: "changed out of band"})

      assert {:ok, content, _v3} = VFS.read(WikiVFS, page_file.path, ctx)
      assert String.ends_with?(content, "changed out of band")
    end

    test "materialized space edits land as new rows (space + page create)", %{
      org_id: org_id,
      ctx: ctx
    } do
      space = space_fixture(org_id)

      # A daemon-materialized tree gains a locally-new page file; the push is
      # a vfs_create for locally new files (Mounter semantics).
      new_page_path = wpath(org_id, space, "locally-new.md")

      assert {:error, :enoent} =
               VFS.stat(WikiVFS, new_page_path, key_ctx(%{"groups" => %{"wiki" => %{}}}))

      assert {:ok, _} = VFS.create(Router, new_page_path, "# Local\nmade on disk", ctx)
      assert Wiki.get_page_by_slug(space.id, "locally-new").content == "# Local\nmade on disk"
    end
  end

  # ── helpers ───────────────────────────────────────────────────────────────

  defp find_att(page, filename),
    do: Wiki.list_attachments(page.id) |> Enum.find(&(&1.filename == filename))

  # Recursive list-walk collecting {path, content, version} for every file
  # node under `root`, mirroring McpMount.Mounter.walk/1.
  defp walk!(root, ctx) do
    {:ok, entries, _cursor} = VFS.list(WikiVFS, root, nil, ctx)

    Enum.flat_map(entries, fn entry ->
      path = String.trim_trailing(root, "/") <> "/" <> entry.name

      case entry.type do
        :dir ->
          walk!(path, ctx)

        :file ->
          {:ok, node} = VFS.stat(WikiVFS, path, ctx)
          {:ok, content, version} = VFS.read(WikiVFS, path, ctx)
          [%{path: path, content: content, version: version, size: node.size}]
      end
    end)
  end
end
