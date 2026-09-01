defmodule NoizuPromptLingua.MCP.VFS.PMTest do
  @moduledoc """
  Sandbox tests for the pm_core VFS backend: file↔record round-trips, generated
  index/rollup control files, slug↔id resolution, artifact revision appends,
  archive-on-remove, and errno paths.
  """
  use NoizuPromptLingua.DataCase

  alias Noizu.MCP.Ctx
  alias Noizu.MCP.Server.Features.VFS
  alias Noizu.PM.{Artifacts, Items, Personas, Wiki}
  alias NoizuPromptLingua.MCP.VFS.PM

  @moduletag :db

  setup do
    # Writes authorize through Noizu.PM.Authz SQL fns in prod; tests stub the
    # injectable seam so the suite does not depend on PBAC stored procedures
    # being present in pm_core_test.
    Application.put_env(:noizu_prompt_lingua, :mcp_vfs_pm,
      authorize: fn _user_id, _org_id -> :ok end
    )

    on_exit(fn -> Application.delete_env(:noizu_prompt_lingua, :mcp_vfs_pm) end)

    org = insert_org("vfsorg")
    project = insert_project(org.id, "vfsproj")
    user = Ecto.UUID.generate()

    %{
      org: org,
      project: project,
      user: user,
      ctx: %Ctx{assigns: %{auth_claims: %{"sub" => user}}},
      anon: %Ctx{}
    }
  end

  # ── stat / list shape ─────────────────────────────────────────────────────

  test "stat/2 returns a dir node for /pm with org children", c do
    assert {:ok, node} = PM.stat("/pm", c.ctx)
    assert node.type == :dir

    assert {:ok, entries, nil} = PM.list("/pm", nil, c.ctx)
    assert Enum.any?(entries, &(&1.name == org_slug(c.org) and &1.type == :dir))
  end

  test "stat/2 on a path outside /pm is :enoent", c do
    assert {:error, :enoent} = PM.stat("/etc/dev", c.ctx)
    assert {:error, :enoent} = PM.stat("/nope/deeper", c.ctx)
  end

  test "project dir lists fixed type dirs + generated controls", c do
    path = proj_path(c)

    assert {:ok, node} = PM.stat(path, c.ctx)
    assert node.type == :dir

    assert {:ok, entries, nil} = PM.list(path, nil, c.ctx)
    names = Enum.map(entries, & &1.name)

    for d <- ~w(personas tickets artifacts wiki), do: assert(d in names)
    for f <- ~w(index.yaml personas.md tickets.md artifacts.md), do: assert(f in names)

    controls = Enum.filter(entries, &(&1.type == :control))
    assert length(controls) == 4
  end

  test "list/3 on a file is :enotdir, on a missing path :enoent", c do
    {:ok, persona} = Personas.create(%{organization_id: c.org.id, project_id: c.project.id, slug: "lister", name: "Lister"})
    path = proj_path(c)

    assert {:error, :enotdir} = PM.list(path <> "/personas/lister.md", nil, c.ctx)
    assert {:error, :enoent} = PM.list(path <> "/personas/nope.md", nil, c.ctx)
    assert {:error, :enoent} = PM.stat(path <> "/personas/nope.md", c.ctx)
    assert String.contains?(persona.name, "List")
  end

  test "list/3 rejects an invalid cursor with an MCP error", c do
    assert {:error, %Noizu.MCP.Error{}} = PM.list(proj_path(c), "not-a-cursor", c.ctx)
  end

  test "list/3 cursor round-trips without dropping or duplicating entries", c do
    for i <- 1..3,
        do:
          Personas.create(%{
            organization_id: c.org.id,
            project_id: c.project.id,
            slug: "cursor-#{i}",
            name: "Cursor #{i}"
          })

    path = proj_path(c) <> "/personas"

    assert {:ok, page1, next} = PM.list(path, nil, c.ctx)
    assert length(Enum.filter(page1, &(&1.type == :file))) == 3
    assert is_nil(next) or is_binary(next)

    if next do
      assert {:ok, page2, nil} = PM.list(path, next, c.ctx)
      files = Enum.filter(page1 ++ page2, &(&1.type == :file))
      assert Enum.map(files, & &1.name) == Enum.uniq(Enum.map(files, & &1.name))
    end
  end

  # ── persona round-trip ────────────────────────────────────────────────────

  test "create → list → read → write → read persona round-trip", c do
    base = proj_path(c)
    doc = persona_doc("Nia Vex", "Harness Operator", "Runs the weave.")

    file = "#{base}/personas/nia-vex.md"
    assert {:ok, node} = PM.create(file, doc, c.ctx)
    assert node.type == :file and node.writable

    # shows up in the listing with the slug filename
    assert {:ok, entries, nil} = PM.list(base <> "/personas", nil, c.ctx)
    assert Enum.any?(entries, &match?(%{name: "nia-vex.md", type: :file}, &1))

    # read back: frontmatter fields + body
    assert {:ok, content, v1} = PM.read(file, c.ctx)
    assert content =~ "name: Nia Vex"
    assert content =~ "role: Harness Operator"
    assert content =~ "Runs the weave."

    # stat size/version match read
    assert {:ok, stat} = PM.stat(file, c.ctx)
    assert stat.size == byte_size(content)
    assert stat.version == v1

    # xattrs
    assert {:ok, x} = PM.xattr(file, c.ctx)
    assert x["pm.role"] == "Harness Operator"
    assert x["pm.status"] == "active"
    assert x["mcp.type"] == "persona"
    assert is_binary(x["mcp.id"])

    # write: update role + status via the same record
    updated = persona_doc("Nia Vex", "Delivery Lead", "Runs the weave.", status: "archived")
    assert {:ok, node2} = PM.write(file, updated, c.ctx)
    assert node2.version >= v1

    assert {:ok, content2, _v2} = PM.read(file, c.ctx)
    assert content2 =~ "role: Delivery Lead"
    assert content2 =~ "status: archived"
  end

  test "create persona without auth is :eacces", c do
    assert {:error, :eacces} =
             PM.create(proj_path(c) <> "/personas/ghost.md", persona_doc("Ghost", nil, nil), c.anon)
  end

  test "create with a missing parent scope is :enoent", c do
    assert {:error, :enoent} =
             PM.create(
               "/pm/does-not-exist/#{c.project.slug}/personas/x.md",
               persona_doc("X", nil, nil),
               c.ctx
             )
  end

  test "create duplicate persona is :eexist", c do
    path = proj_path(c) <> "/personas/dup.md"
    doc = persona_doc("Dup", nil, nil)

    assert {:ok, _} = PM.create(path, doc, c.ctx)
    assert {:error, :eexist} = PM.create(path, doc, c.ctx)
  end

  test "org-level personas resolve inside project dirs (effective list)", c do
    {:ok, _} = Personas.create(%{organization_id: c.org.id, slug: "floater", name: "Floater"})

    path = proj_path(c) <> "/personas/floater.md"
    assert {:ok, _node} = PM.stat(path, c.ctx)
    assert {:ok, content, _} = PM.read(path, c.ctx)
    assert content =~ "Floater"
  end

  # ── tickets (items) ───────────────────────────────────────────────────────

  test "create ticket assigns the real human key; filename resolves by key", c do
    base = proj_path(c)
    doc = ticket_doc("Fix login flow", "open", "high", "Users cannot log in.")

    assert {:ok, _} = PM.create("#{base}/tickets/fix-login-flow.md", doc, c.ctx)

    {:ok, entries, nil} = PM.list("#{base}/tickets", nil, c.ctx)
    entry = Enum.find(entries, &(&1.type == :file and String.contains?(&1.name, "fix-login-flow")))
    assert entry

    # key format: <PREFIX>-<NNN> derived from the org slug
    [filename] = entries |> Enum.map(& &1.name) |> Enum.filter(&String.contains?(&1, "fix-login-flow"))
    key = filename |> String.replace_suffix(".md", "") |> String.split("-") |> Enum.take(2) |> Enum.join("-")
    assert Regex.match?(~r/^[A-Z0-9]+-\d+$/, key)

    path = "#{base}/tickets/#{filename}"
    assert {:ok, content, _} = PM.read(path, c.ctx)
    assert content =~ "key: #{key}"
    assert content =~ "priority: high"
    assert content =~ "Users cannot log in."

    assert {:ok, x} = PM.xattr(path, c.ctx)
    assert x["pm.key"] == key
  end

  test "write ticket updates status; remove archives (soft) by default", c do
    {:ok, item} =
      Items.create(%{organization_id: c.org.id, project_id: c.project.id, title: "Archive me", item_type: "task"})

    path = "#{proj_path(c)}/tickets/#{item.key}-archive-me.md"
    assert {:ok, _, _} = PM.read(path, c.ctx)

    assert {:ok, _} = PM.write(path, ticket_doc("Archive me", "done", nil, nil), c.ctx)
    assert {:ok, content, _} = PM.read(path, c.ctx)
    assert content =~ "status: done"

    assert :ok = PM.remove(path, c.ctx)
    # still resolvable — archived, not deleted
    assert {:ok, stat} = PM.stat(path, c.ctx)
    assert {:ok, x} = PM.xattr(path, c.ctx)
    assert x["pm.status"] == "archived"
    assert stat.type == :file

    reloaded = Items.get(item.id)
    assert reloaded.status == "archived"
  end

  test "ticket file under the wrong project is :enoent", c do
    {:ok, item} =
      Items.create(%{organization_id: c.org.id, project_id: c.project.id, title: "Scoped", item_type: "task"})

    other = insert_project(c.org.id, "other-proj")
    assert {:error, :enoent} = PM.stat("/pm/#{org_slug(c.org)}/#{other.slug}/tickets/#{item.key}-scoped.md", c.ctx)
  end

  # ── artifacts (append-only revisions) ─────────────────────────────────────

  test "artifact write appends a revision instead of mutating content", c do
    base = proj_path(c)

    # the artifact id is assigned by pm_core, so the file lands at its canonical
    # A-<uuid>-<slug>.md name regardless of the requested name
    assert {:ok, _} = PM.create("#{base}/artifacts/spec.md", frontmatter(%{"kind" => "document"}, "revision one"), c.ctx)

    {:ok, entries, _} = PM.list("#{base}/artifacts", nil, c.ctx)
    path = "#{base}/artifacts/" <> Enum.find(entries, &(&1.type == :file)).name

    assert {:ok, x1} = PM.xattr(path, c.ctx)
    assert x1["pm.revision"] == 1

    assert {:ok, _} = PM.write(path, frontmatter(%{"note" => "second pass"}, "revision two"), c.ctx)
    assert {:ok, x2} = PM.xattr(path, c.ctx)
    assert x2["pm.revision"] == 2

    assert {:ok, content, _} = PM.read(path, c.ctx)
    assert content =~ "revision two"
    refute content =~ "revision one"

    artifact_id = x2["mcp.id"]
    {_artifact, rev} = Artifacts.get(artifact_id)
    assert rev.revision_number == 2

    revisions = Artifacts.list_revisions(artifact_id)
    assert length(revisions) == 2

    # remove is :enosys for artifacts (no soft-archive field)
    assert {:error, :enosys} = PM.remove(path, c.ctx)
  end

  test "artifact hard delete when configured", c do
    Application.put_env(:noizu_prompt_lingua, :mcp_vfs_pm,
      authorize: fn _u, _o -> :ok end,
      hard_delete: true
    )

    on_exit(fn -> Application.delete_env(:noizu_prompt_lingua, :mcp_vfs_pm) end)

    base = proj_path(c)
    assert {:ok, _} = PM.create("#{base}/artifacts/doomed.md", frontmatter(%{}, "content"), c.ctx)

    {:ok, entries, _} = PM.list("#{base}/artifacts", nil, c.ctx)
    path = "#{base}/artifacts/" <> Enum.find(entries, &(&1.type == :file)).name
    assert {:ok, x} = PM.xattr(path, c.ctx)
    artifact_id = x["mcp.id"]

    assert :ok = PM.remove(path, c.ctx)
    assert {:error, :enoent} = PM.stat(path, c.ctx)
    assert is_nil(Artifacts.get(artifact_id))
  end

  # ── wiki (project-scoped spaces) ──────────────────────────────────────────

  test "wiki pages round-trip inside project-scoped spaces", c do
    {:ok, space} =
      Wiki.create_space(%{organization_id: c.org.id, project_id: c.project.id, slug: "handbook", name: "Handbook"})

    base = "#{proj_path(c)}/wiki/handbook"
    assert {:ok, node} = PM.stat(base, c.ctx)
    assert node.type == :dir

    path = "#{base}/glossary.md"
    assert {:ok, _} = PM.create(path, frontmatter(%{"title" => "Glossary"}, "VFS means..."), c.ctx)

    assert {:ok, content, _} = PM.read(path, c.ctx)
    assert content =~ "VFS means..."

    assert {:ok, _} = PM.write(path, frontmatter(%{"title" => "Glossary"}, "VFS means virtual filesystem."), c.ctx)
    assert {:ok, content2, _} = PM.read(path, c.ctx)
    assert content2 =~ "virtual filesystem"

    page = Wiki.list_pages(space.id) |> hd()
    assert page.slug == "glossary"
  end

  # ── generated control files ───────────────────────────────────────────────

  test "index.yaml is generated per directory and read-only", c do
    {:ok, _} = Personas.create(%{organization_id: c.org.id, project_id: c.project.id, slug: "indexed", name: "Indexed"})

    base = proj_path(c)

    for path <- [
          "/pm/#{org_slug(c.org)}/index.yaml",
          "#{base}/index.yaml",
          "#{base}/personas/index.yaml"
        ] do
      assert {:ok, node} = PM.stat(path, c.ctx)
      assert node.type == :control
      assert {:ok, content, _} = PM.read(path, c.ctx)
      assert byte_size(content) == node.size
      assert {:error, :erofs} = PM.write(path, "x", c.ctx)
    end

    # type index mirrors the on-disk convention shape
    assert {:ok, type_index, _} = PM.read("#{base}/personas/index.yaml", c.ctx)
    assert type_index =~ "personas:"
    assert type_index =~ "file: indexed.md"
    assert type_index =~ "status: active"
  end

  test "project-root rollups render on demand and are read-only", c do
    base = proj_path(c)
    Personas.create(%{organization_id: c.org.id, project_id: c.project.id, slug: "rolled", name: "Rolled Up"})

    assert {:ok, node} = PM.stat("#{base}/personas.md", c.ctx)
    assert node.type == :control

    assert {:ok, rollup, _} = PM.read("#{base}/personas.md", c.ctx)
    assert rollup =~ "# Personas"
    assert rollup =~ "[rolled](personas/rolled.md)"

    assert {:error, :erofs} = PM.write("#{base}/personas.md", "x", c.ctx)
  end

  # ── errno paths ───────────────────────────────────────────────────────────

  test "errno paths: eisdir / enotdir / enoent / erofs on dirs", c do
    base = proj_path(c)

    assert {:error, :eisdir} = PM.read(base, c.ctx)
    assert {:error, :eisdir} = PM.read("/pm", c.ctx)
    assert {:error, :enoent} = PM.write("#{base}/tickets/NOPE-999-nope.md", "x", c.ctx)
    assert {:error, :enosys} = PM.create("#{base}/newdir", :dir, c.ctx)
    assert {:error, :enoent} = PM.remove("#{base}/personas/ghost.md", c.ctx)
  end

  test "remove on a control root is :erofs (control trees are never removable)", c do
    assert {:error, :erofs} = PM.remove("/pm", c.ctx)
  end

  # ── search ────────────────────────────────────────────────────────────────

  test "search finds line matches over the rendered subtree", c do
    base = proj_path(c)

    PM.create("#{base}/personas/seeker.md", persona_doc("Seeker", "Scout", "the frobnicator par excellence"), c.ctx)

    assert {:ok, matches, nil} = PM.search(base, "frobnicator", c.ctx)
    assert [%{path: path, line: line, text: text}] = matches
    assert String.contains?(path, "seeker.md")
    assert is_integer(line) and line > 0
    assert String.contains?(text, "frobnicator")

    assert {:ok, [], nil} = PM.search(base, "zzz-not-there", c.ctx)
  end

  # ── cache-aware wrapper integration ───────────────────────────────────────

  test "backend works through Features.VFS wrappers (generation stamping)", c do
    path = proj_path(c)

    assert {:ok, node} = VFS.stat(PM, path, c.ctx)
    assert node.type == :dir
    assert node.version > Noizu.MCP.VFS.Cache.generation(PM)

    assert {:ok, entries, _} = VFS.list(PM, path, nil, c.ctx)
    assert Enum.any?(entries, &match?(%{name: "personas", type: :dir}, &1))

    assert {:error, %Noizu.MCP.Error{}} = VFS.list(PM, path, "bogus", c.ctx)
  end

  # ══════════════════════════════ helpers ═══════════════════════════════════

  defp org_slug(org), do: org.slug
  defp proj_path(c), do: "/pm/#{c.org.slug}/#{c.project.slug}"

  defp insert_org(slug) do
    {:ok, org} =
      Noizu.PM.Repo.insert(%Noizu.PM.Schema.Organizations.Organization{
        slug: "#{slug}-#{System.unique_integer([:positive])}",
        name: "VFS Org"
      })

    org
  end

  defp insert_project(org_id, slug) do
    {:ok, project} =
      Noizu.PM.Repo.insert(%Noizu.PM.Schema.Projects.Project{
        organization_id: org_id,
        slug: "#{slug}-#{System.unique_integer([:positive])}",
        name: "VFS Project"
      })

    project
  end

  defp frontmatter(extra, body) do
    fm =
      extra
      |> Map.new(fn {k, v} -> {to_string(k), v} end)
      |> Enum.map(fn {k, v} -> "#{k}: #{v}" end)
      |> Enum.join("\n")

    "---\n#{fm}\n---\n#{body}\n"
  end

  defp persona_doc(name, role, bio, opts \\ []) do
    fm =
      %{"name" => name, "status" => Keyword.get(opts, :status, "active"), "tags" => "[a, b]"}
      |> Map.put_new("role", role)

    fm_lines =
      fm
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Enum.map(fn
        {"tags", v} -> "tags: #{v}"
        {k, v} -> "#{k}: #{v}"
      end)
      |> Enum.join("\n")

    body_part = if bio, do: "\n#{bio}\n", else: "\n"
    "---\n#{fm_lines}\n---\n#{body_part}"
  end

  defp ticket_doc(title, status, priority, desc) do
    fm =
      [{"title", title}, {"status", status}, {"priority", priority}, {"item_type", "task"}]
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Enum.map(fn {k, v} -> "#{k}: #{v}" end)
      |> Enum.join("\n")

    body = if desc, do: "\n#{desc}\n", else: "\n"
    "---\n#{fm}\n---\n#{body}"
  end
end
