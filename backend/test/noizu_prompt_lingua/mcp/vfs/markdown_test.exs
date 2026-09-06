defmodule NoizuPromptLingua.MCP.VFS.MarkdownTest do
  @moduledoc """
  Wave 4 battery for the `markdown` query-dir VFS backend (design §2.20),
  through the backend directly (full absolute paths) and the cache-aware
  `Features.VFS` wrappers.

  Covers: the query-dir tree (request.json/result.md node shapes), the
  Convert/View request document variants (html / markdown-passthrough /
  url, explicit op, view params), malformed-request `:eio` arms, the
  per-connection consume-once result buffer (isolation between sessions),
  read-only enforcement, pagination cursor policy, and the §1.3 gate matrix.

  URL conversions are exercised only through the offline transport-failure
  arm — no test touches the network.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias Noizu.MCP.Ctx
  alias Noizu.MCP.Server.Features.VFS
  alias Noizu.MCP.VFS.Cache
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCP.VFS.Markdown, as: Backend
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Organizations.Organization
  alias NoizuPromptLingua.TRP.Cache, as: TrpCache
  alias NoizuPromptLingua.TRP.TestStub

  @group "markdown"

  setup do
    TrpCache.clear()
    TestStub.reset()

    suffix = Ecto.UUID.generate() |> binary_part(0, 8)
    org = Repo.insert!(%Organization{name: "VFS MD Org #{suffix}", slug: "vfs-md-#{suffix}"})
    TestStub.seed_org(org.id, org.slug, org.name)

    on_exit(fn -> Cache.purge(Backend) end)

    %{org: org, ctx: key_ctx(%{"groups" => %{@group => %{}}})}
  end

  defp key_ctx(config, session \\ nil) do
    uniq = System.unique_integer([:positive])

    user =
      %NoizuPromptLingua.Schema.Users.User{
        id: Ecto.UUID.generate(),
        email: "vfsmd-#{uniq}@example.com",
        user_name: "vfsmd#{uniq}",
        handle: "vfsmd#{uniq}",
        status: :active
      }
      |> Repo.insert!()

    {:ok, key, _} = MCPApiKeys.generate_api_key(user.id, "vfs-markdown", toolset_config: config)

    %Ctx{
      server: NoizuPromptLingua.MCP.VFSServer,
      session_id: session || "md-" <> Integer.to_string(uniq),
      assigns: %{auth_claims: %{"api_key_id" => key.id, "sub" => user.id}}
    }
  end

  defp base(org), do: "/tobor/#{org.slug}/markdown"
  defp convert(org), do: "#{base(org)}/convert"

  # ── tree shape ────────────────────────────────────────────────────────────

  test "the query tree lists overview and convert; nodes have their shapes", %{org: org, ctx: ctx} do
    assert {:ok, dir} = VFS.stat(Backend, base(org), ctx)
    assert dir.type == :dir and dir.writable == false

    assert {:ok, entries, nil} = VFS.list(Backend, base(org), nil, ctx)
    assert Enum.map(entries, & &1.name) == ["overview.md", "convert"]

    assert {:ok, md, _} = VFS.read(Backend, "#{base(org)}/overview.md", ctx)
    assert md =~ "Markdown"

    assert {:ok, entries, nil} = VFS.list(Backend, convert(org), nil, ctx)
    assert Enum.map(entries, & &1.name) == ["request.json"]

    assert {:ok, node} = VFS.stat(Backend, "#{convert(org)}/request.json", ctx)
    assert node.type == :control and node.writable == true

    # result.md does not exist until this connection runs a request.
    assert {:error, :enoent} = VFS.stat(Backend, "#{convert(org)}/result.md", ctx)
    assert {:error, :enoent} = VFS.read(Backend, "#{convert(org)}/result.md", ctx)
  end

  test "reading request.json returns the self-describing schema document", %{org: org, ctx: ctx} do
    assert {:ok, doc, _} = VFS.read(Backend, "#{convert(org)}/request.json", ctx)
    {:ok, schema} = Jason.decode(doc)
    assert schema["node"] == "convert/request.json"
    assert schema["fields"]["url"] != nil
    assert schema["fields"]["filter"] != nil
    assert schema["read"] =~ "result.md"
  end

  # ── convert / view request variants ──────────────────────────────────────

  test "an html request converts and buffers the markdown result", %{org: org, ctx: ctx} do
    request = Jason.encode!(%{"html" => "<h1>Greeting</h1><p>Hello <b>vfs</b>.</p>"})

    assert {:ok, node} = VFS.write(Backend, "#{convert(org)}/request.json", request, ctx)
    assert node.type == :file and node.size > 0

    # result.md appears for THIS connection only after the write.
    assert {:ok, result} = VFS.stat(Backend, "#{convert(org)}/result.md", ctx)
    assert result.type == :file

    assert {:ok, entries, nil} = VFS.list(Backend, convert(org), nil, ctx)
    assert Enum.map(entries, & &1.name) == ["request.json", "result.md"]

    assert {:ok, md, version} = VFS.read(Backend, "#{convert(org)}/result.md", ctx)
    assert md =~ "# Greeting"
    assert md =~ "**vfs**"
    assert is_integer(version)

    # Consume-once (direct backend op — the wire wrapper may replay its cache,
    # which is the documented P1 identity-blind-cache caveat).
    assert {:error, :enoent} = Backend.read("#{convert(org)}/result.md", ctx)
    assert {:error, :enoent} = Backend.stat("#{convert(org)}/result.md", ctx)
  end

  test "markdown passthrough + view params filter to matched sections", %{org: org, ctx: ctx} do
    doc = """
    # API

    api body

    # Notes

    notes body
    """

    request = Jason.encode!(%{"markdown" => doc, "filter" => "API", "bare" => true})

    assert {:ok, _} = VFS.write(Backend, "#{convert(org)}/request.json", request, ctx)
    assert {:ok, md, _} = Backend.read("#{convert(org)}/result.md", ctx)
    assert md =~ "# API"
    assert md =~ "api body"
    refute md =~ "notes body"
  end

  test "depth collapses deeper headings in view mode", %{org: org, ctx: ctx} do
    doc = "# Top\n\nintro\n\n## Sub\n\nsub body\n\n### Deep\n\nhidden\n"

    request = Jason.encode!(%{"markdown" => doc, "depth" => 2})

    assert {:ok, _} = VFS.write(Backend, "#{convert(org)}/request.json", request, ctx)
    assert {:ok, md, _} = Backend.read("#{convert(org)}/result.md", ctx)
    assert md =~ "## Sub"
    assert md =~ "Deep 📦"
    refute md =~ "hidden"
  end

  test "an explicit op beats param-based inference", %{org: org, ctx: ctx} do
    # "filter" alone would select view; op forces the convert passthrough.
    request =
      Jason.encode!(%{"markdown" => "# Doc\n\nbody", "filter" => "Doc", "op" => "convert"})

    assert {:ok, _} = VFS.write(Backend, "#{convert(org)}/request.json", request, ctx)
    assert {:ok, md, _} = Backend.read("#{convert(org)}/result.md", ctx)
    assert md == "# Doc\n\nbody"
  end

  test "a url request runs the fetch server-side; transport failure is :eio", %{
    org: org,
    ctx: ctx
  } do
    # Port 1 on loopback refuses immediately — offline transport-failure arm.
    request = Jason.encode!(%{"url" => "http://127.0.0.1:1/unreachable"})

    assert {:error, :eio} = VFS.write(Backend, "#{convert(org)}/request.json", request, ctx)

    # The failed request buffered nothing.
    assert {:error, :enoent} = Backend.stat("#{convert(org)}/result.md", ctx)
  end

  test "creating request.json mirrors writing it (mounter new-file push)", %{org: org, ctx: ctx} do
    request = Jason.encode!(%{"html" => "<p>created</p>"})

    assert {:ok, _} = VFS.create(Backend, "#{convert(org)}/request.json", request, ctx)
    assert {:ok, md, _} = Backend.read("#{convert(org)}/result.md", ctx)
    assert md =~ "created"
  end

  # ── malformed requests ⇒ :eio ────────────────────────────────────────────

  test "malformed requests are :eio and buffer nothing", %{org: org, ctx: ctx} do
    path = "#{convert(org)}/request.json"

    assert {:error, :eio} = VFS.write(Backend, path, "not json", ctx)
    assert {:error, :eio} = VFS.write(Backend, path, "[]", ctx)
    assert {:error, :eio} = VFS.write(Backend, path, "{}", ctx)
    assert {:error, :eio} = VFS.write(Backend, path, Jason.encode!(%{"url" => 42}), ctx)

    assert {:error, :eio} =
             VFS.write(
               Backend,
               path,
               Jason.encode!(%{"html" => "<p>x</p>", "type" => "bogus"}),
               ctx
             )

    assert {:error, :eio} =
             VFS.write(Backend, path, Jason.encode!(%{"markdown" => "# d", "depth" => "9"}), ctx)

    assert {:error, :eio} =
             VFS.write(
               Backend,
               path,
               Jason.encode!(%{"markdown" => "# d", "op" => "explode"}),
               ctx
             )

    assert {:error, :enoent} = Backend.stat("#{convert(org)}/result.md", ctx)
  end

  # ── per-connection buffer isolation ──────────────────────────────────────

  test "result buffers are isolated per connection and consume-once", %{org: org, ctx: ctx_a} do
    ctx_b = key_ctx(%{"groups" => %{@group => %{}}})
    path = "#{convert(org)}/request.json"

    assert {:ok, _} = Backend.write(path, Jason.encode!(%{"html" => "<p>for-a</p>"}), ctx_a)

    # Connection A sees (and consumes) its result.
    assert {:ok, md_a, _} = Backend.read("#{convert(org)}/result.md", ctx_a)
    assert md_a =~ "for-a"
    assert {:error, :enoent} = Backend.read("#{convert(org)}/result.md", ctx_a)

    # Connection B never saw A's buffer.
    assert {:error, :enoent} = Backend.stat("#{convert(org)}/result.md", ctx_b)
    assert {:error, :enoent} = Backend.read("#{convert(org)}/result.md", ctx_b)

    # A fresh write re-buffers; B's own write shadows nothing of A's.
    assert {:ok, _} = Backend.write(path, Jason.encode!(%{"html" => "<p>for-b</p>"}), ctx_b)
    assert {:ok, md_b, _} = Backend.read("#{convert(org)}/result.md", ctx_b)
    assert md_b =~ "for-b"
    assert {:error, :enoent} = Backend.read("#{convert(org)}/result.md", ctx_a)
  end

  # ── read-only enforcement ────────────────────────────────────────────────

  test "the rest of the tree is read-only; only request.json mutates", %{org: org, ctx: ctx} do
    assert {:error, :enosys} = VFS.write(Backend, "#{base(org)}/overview.md", "x", ctx)
    assert {:error, :enosys} = VFS.write(Backend, "#{convert(org)}/result.md", "x", ctx)
    assert {:error, :enosys} = VFS.create(Backend, "#{convert(org)}/result.md", "x", ctx)
    assert {:error, :enosys} = VFS.create(Backend, convert(org), :dir, ctx)
    assert {:error, :enosys} = VFS.remove(Backend, "#{convert(org)}/request.json", ctx)
    assert {:error, :enosys} = VFS.search(Backend, base(org), "x", ctx)
    assert {:error, :eisdir} = VFS.read(Backend, base(org), ctx)
    assert {:error, :eisdir} = VFS.read(Backend, convert(org), ctx)
    assert {:error, :enotdir} = VFS.list(Backend, "#{convert(org)}/request.json", nil, ctx)
    assert {:error, :enoent} = VFS.read(Backend, "#{convert(org)}/nope.json", ctx)
  end

  test "cursor policy: valid empty cursor, foreign cursor rejected", %{org: org, ctx: ctx} do
    assert {:ok, _entries, nil} = VFS.list(Backend, base(org), nil, ctx)
    assert {:ok, _entries, nil} = VFS.list(Backend, base(org), "", ctx)
    assert {:error, %Noizu.MCP.Error{}} = VFS.list(Backend, base(org), "bogus-cursor", ctx)
  end

  # ── gating (§1.3) ────────────────────────────────────────────────────────

  test "excluded group is :enoent everywhere", %{org: org} do
    ctx = key_ctx(%{"groups" => %{"unicode" => %{}}})

    assert {:error, :enoent} = VFS.stat(Backend, base(org), ctx)
    assert {:error, :enoent} = VFS.list(Backend, base(org), nil, ctx)
    assert {:error, :enoent} = VFS.read(Backend, "#{base(org)}/overview.md", ctx)
    assert {:error, :enoent} = VFS.write(Backend, "#{convert(org)}/request.json", "{}", ctx)
  end

  test "included-but-disabled group reads; the request write is :eacces", %{org: org} do
    ctx = key_ctx(%{"groups" => %{@group => %{"disabled" => true}}})

    assert {:ok, dir} = VFS.stat(Backend, base(org), ctx)
    assert dir.writable == false

    assert {:ok, node} = VFS.stat(Backend, "#{convert(org)}/request.json", ctx)
    assert node.writable == false

    assert {:ok, _, _} = VFS.read(Backend, "#{convert(org)}/request.json", ctx)

    assert {:error, :eacces} =
             VFS.write(
               Backend,
               "#{convert(org)}/request.json",
               Jason.encode!(%{"html" => "<p>x</p>"}),
               ctx
             )
  end

  test "an org the principal cannot see is :enoent", %{org: _org} do
    suffix = Ecto.UUID.generate() |> binary_part(0, 8)
    Repo.insert!(%Organization{name: "Hidden #{suffix}", slug: "vfs-md-hidden-#{suffix}"})
    ctx = key_ctx(%{"groups" => %{@group => %{}}})

    # Seeded into the DB but not in the principal's TRP view — no existence leak.
    assert {:error, :enoent} = VFS.stat(Backend, "/tobor/vfs-md-hidden-#{suffix}/#{@group}", ctx)
    assert {:error, :enoent} = VFS.stat(Backend, "/tobor/no-such-org/#{@group}", ctx)
  end

  # ── direct backend op (standalone conformance arm) ────────────────────────

  test "backend works standalone on full absolute paths", %{org: org, ctx: ctx} do
    assert {:ok, _node} =
             Backend.write(
               "#{convert(org)}/request.json",
               Jason.encode!(%{"html" => "<h2>standalone</h2>"}),
               ctx
             )

    assert {:ok, md, _} = Backend.read("#{convert(org)}/result.md", ctx)
    assert md =~ "standalone"
  end
end
