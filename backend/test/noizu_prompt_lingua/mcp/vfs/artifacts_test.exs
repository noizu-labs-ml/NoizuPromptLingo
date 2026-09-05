defmodule NoizuPromptLingua.MCP.VFS.ArtifactsTest do
  @moduledoc """
  Wave 1 battery for the `artifacts` VFS backend (design §2.2), exercised
  through `Root` + `Noizu.MCP.Server.Features.VFS` so errno mapping, gating,
  and generation stamping are verified on the composed surface — plus direct
  backend calls to prove independent conformance-ability.

  Covers: stat/list/read/create/write/remove + errnos, revision immutability
  (`:eexist` on overwrite, next-only creates), the `current.txt` pointer,
  segment resolution (short8 / UUID / title), pagination, and the §1.3 gate
  matrix for the group.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias Noizu.MCP.Ctx
  alias Noizu.MCP.Server.Features.VFS
  alias Noizu.MCP.VFS.Cache
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCP.VFS.{Artifacts, Root}
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Organizations.Organization
  alias NoizuPromptLingua.TRP.Cache, as: TrpCache
  alias NoizuPromptLingua.TRP.TestStub

  setup do
    TrpCache.clear()
    TestStub.reset()

    suffix = Ecto.UUID.generate() |> binary_part(0, 8)
    org = Repo.insert!(%Organization{name: "VFS Art Org #{suffix}", slug: "vfs-art-#{suffix}"})
    TestStub.seed_org(org.id, org.slug, org.name)

    on_exit(fn -> Cache.purge(Root) end)

    %{org: org, ctx: key_ctx(%{"groups" => %{"artifacts" => %{}}})}
  end

  defp key_ctx(config) do
    uniq = System.unique_integer([:positive])

    user =
      %NoizuPromptLingua.Schema.Users.User{
        id: Ecto.UUID.generate(),
        email: "vfsart-#{uniq}@example.com",
        user_name: "vfsart#{uniq}",
        handle: "vfsart#{uniq}",
        status: :active
      }
      |> Repo.insert!()

    {:ok, key, _raw} =
      MCPApiKeys.generate_api_key(user.id, "vfs-artifacts", toolset_config: config)

    %Ctx{
      server: NoizuPromptLingua.MCP.VFSServer,
      session_id: "art-" <> Integer.to_string(uniq),
      assigns: %{auth_claims: %{"api_key_id" => key.id, "sub" => user.id}}
    }
  end

  defp base(org), do: "/tobor/#{org.slug}/artifacts"

  defp artifact!(org, title, content \\ "rev one") do
    {:ok, node} =
      VFS.create(
        Root,
        "#{base(org)}/#{title}",
        content,
        key_ctx(%{"groups" => %{"artifacts" => %{}}})
      )

    node.xattrs["id"]
  end

  # ── group root ────────────────────────────────────────────────────────────

  test "group root stats and lists with overview.md first", %{org: org, ctx: ctx} do
    assert {:ok, dir} = VFS.stat(Root, base(org), ctx)
    assert dir.type == :dir and dir.writable == true

    assert {:ok, [overview | rest], nil} = VFS.list(Root, base(org), nil, ctx)
    assert overview.name == "overview.md"
    assert rest == []

    assert {:ok, md, _} = VFS.read(Root, "#{base(org)}/overview.md", ctx)
    assert md =~ "Artifacts"
  end

  # ── create + record.json + revisions ──────────────────────────────────────

  test "create seeds title/mime defaults, revision v1, and the current pointer", %{
    org: org,
    ctx: ctx
  } do
    assert {:ok, node} = VFS.create(Root, "#{base(org)}/my-notes", "hello world", ctx)
    assert node.type == :dir
    id = node.xattrs["id"]
    assert id

    # Canonical dir name derives from the UUID: {type}-{short8} (§1.1).
    segment = "artifact-" <> binary_part(id, 0, 8)
    assert {:ok, entries, nil} = VFS.list(Root, base(org), nil, ctx)
    assert Enum.map(entries, & &1.name) == ["overview.md", segment]

    {:ok, record_json, _} = VFS.read(Root, "#{base(org)}/#{segment}/record.json", ctx)
    {:ok, record} = Jason.decode(record_json)
    assert record["id"] == id
    assert record["title"] == "my-notes"
    assert record["kind"] == "document"
    assert record["mime_type"] == "text/plain"
    assert record["path_segment"] == segment
    assert record["revision_count"] == 1
    assert record["current_revision"]["number"] == 1

    # text/plain → .txt extension.
    assert {:ok, "hello world", _} = VFS.read(Root, "#{base(org)}/#{segment}/revs/v1.txt", ctx)
    assert {:ok, "v1.txt", _} = VFS.read(Root, "#{base(org)}/#{segment}/current.txt", ctx)

    assert {:ok, revs, nil} = VFS.list(Root, "#{base(org)}/#{segment}/revs", nil, ctx)
    assert Enum.map(revs, & &1.name) == ["v1.txt"]
  end

  test "revisions are immutable: overwrite :eexist, next-only create", %{org: org, ctx: ctx} do
    id = artifact!(org, "immutable")

    segment = "artifact-" <> binary_part(id, 0, 8)
    rev_root = "#{base(org)}/#{segment}/revs"

    assert {:error, :eexist} = VFS.create(Root, "#{rev_root}/v1.txt", "nope", ctx)
    assert {:error, :eexist} = VFS.write(Root, "#{rev_root}/v1.txt", "nope", ctx)

    assert {:ok, _} = VFS.create(Root, "#{rev_root}/v2.txt", "rev two", ctx)
    assert {:ok, "rev two", _} = VFS.read(Root, "#{rev_root}/v2.txt", ctx)
    assert {:ok, "v2.txt", _} = VFS.read(Root, "#{base(org)}/#{segment}/current.txt", ctx)

    # Only the next revision can be created; gaps are refused.
    assert {:error, :enoent} = VFS.create(Root, "#{rev_root}/v5.txt", "skip", ctx)
    # Only the artifact's derived extension is accepted.
    assert {:error, :enoent} = VFS.create(Root, "#{rev_root}/v3.json", "wrong ext", ctx)

    assert {:ok, _} = VFS.create(Root, "#{rev_root}/v3.txt", "rev three", ctx)

    assert {:ok, revs, nil} = VFS.list(Root, "#{rev_root}", nil, ctx)
    assert Enum.map(revs, & &1.name) == ["v1.txt", "v2.txt", "v3.txt"]
  end

  test "duplicate titles collide on create (:eexist)", %{org: org, ctx: ctx} do
    artifact!(org, "dup")

    assert {:error, :eexist} = VFS.create(Root, "#{base(org)}/dup", "again", ctx)
    assert {:error, :eexist} = VFS.create(Root, "#{base(org)}/overview.md", "reserved", ctx)
  end

  # ── segment resolution ────────────────────────────────────────────────────

  test "artifacts resolve by short8 segment, full UUID, and title", %{org: org, ctx: ctx} do
    id = artifact!(org, "resolvable")
    short8 = binary_part(id, 0, 8)

    for segment <- ["artifact-#{short8}", id, "resolvable"] do
      assert {:ok, dir} = VFS.stat(Root, "#{base(org)}/#{segment}", ctx)
      assert dir.type == :dir

      assert {:ok, _, _} = VFS.read(Root, "#{base(org)}/#{segment}/record.json", ctx)
    end

    assert {:error, :enoent} = VFS.stat(Root, "#{base(org)}/artifact-beef0000", ctx)
    assert {:error, :enoent} = VFS.stat(Root, "#{base(org)}/missing-title", ctx)
  end

  # ── errnos ────────────────────────────────────────────────────────────────

  test "no delete surface: remove is :enosys everywhere", %{org: org, ctx: ctx} do
    id = artifact!(org, "undeletable")
    segment = "artifact-" <> binary_part(id, 0, 8)

    assert {:error, :enosys} = VFS.remove(Root, "#{base(org)}/#{segment}", ctx)
    assert {:error, :enosys} = VFS.remove(Root, "#{base(org)}/#{segment}/revs/v1.txt", ctx)

    # No update tool: record.json/current.txt writes are refused.
    assert {:error, :enosys} = VFS.write(Root, "#{base(org)}/#{segment}/record.json", "{}", ctx)

    assert {:error, :enosys} =
             VFS.write(Root, "#{base(org)}/#{segment}/current.txt", "v1.txt", ctx)

    assert {:error, :enosys} = VFS.create(Root, "#{base(org)}/#{segment}", :dir, ctx)
  end

  test "structural errnos: dirs are :eisdir, files list :enotdir, unknown :enoent", %{
    org: org,
    ctx: ctx
  } do
    id = artifact!(org, "errno")
    segment = "artifact-" <> binary_part(id, 0, 8)

    assert {:error, :eisdir} = VFS.read(Root, "#{base(org)}/#{segment}", ctx)
    assert {:error, :eisdir} = VFS.read(Root, "#{base(org)}/#{segment}/revs", ctx)
    assert {:error, :enotdir} = VFS.list(Root, "#{base(org)}/#{segment}/record.json", nil, ctx)
    assert {:error, :enoent} = VFS.stat(Root, "#{base(org)}/#{segment}/revs/v9.txt", ctx)
    assert {:error, :enoent} = VFS.read(Root, "#{base(org)}/#{segment}/nope.json", ctx)
  end

  test "invalid cursors are rejected; empty cursor is nil", %{org: org, ctx: ctx} do
    assert {:error, %Noizu.MCP.Error{}} = VFS.list(Root, base(org), "bogus", ctx)
    assert {:ok, _, nil} = VFS.list(Root, base(org), "", ctx)
  end

  test "readdir paginates with opaque offset cursors", %{org: org} do
    ctx = key_ctx(%{"groups" => %{"artifacts" => %{}}})

    for i <- 1..101 do
      {:ok, _} = VFS.create(Root, "#{base(org)}/page-#{i}", "row #{i}", ctx)
    end

    {:ok, page1, cursor} = VFS.list(Root, base(org), nil, ctx)
    assert length(page1) == 101
    assert cursor

    {:ok, page2, nil} = VFS.list(Root, base(org), cursor, ctx)
    # overview.md is re-synthesized per page; one artifact remains.
    assert length(page2) == 2
    assert Enum.any?(page2, &(&1.name == "overview.md"))
  end

  # ── gating (§1.3) ─────────────────────────────────────────────────────────

  test "excluded group subtree is :enoent (no existence leak)", %{org: org} do
    ctx = key_ctx(%{"groups" => %{"wiki" => %{}}})

    assert {:error, :enoent} = VFS.stat(Root, base(org), ctx)
    assert {:error, :enoent} = VFS.list(Root, base(org), nil, ctx)
    assert {:error, :enoent} = VFS.read(Root, "#{base(org)}/overview.md", ctx)

    {:ok, org_entries, _} = VFS.list(Root, "/tobor/#{org.slug}", nil, ctx)
    refute Enum.any?(org_entries, &(&1.name == "artifacts"))
  end

  test "included-but-disabled group lists read-only; mutations are :eacces", %{org: org} do
    ctx = key_ctx(%{"groups" => %{"artifacts" => %{"disabled" => true}}})

    assert {:ok, dir} = VFS.stat(Root, base(org), ctx)
    assert dir.writable == false

    assert {:ok, _, _} = VFS.read(Root, "#{base(org)}/overview.md", ctx)
    assert {:error, :eacces} = VFS.create(Root, "#{base(org)}/blocked", "x", ctx)
  end

  test "unresolvable principal fails closed at the group gate", %{org: org} do
    ctx = %Ctx{
      server: NoizuPromptLingua.MCP.VFSServer,
      session_id: "anon-art-" <> Integer.to_string(System.unique_integer([:positive])),
      assigns: %{auth_claims: %{"sub" => "someone"}}
    }

    assert {:error, :enoent} = VFS.stat(Root, base(org), ctx)
  end

  # ── direct backend call (independent conformance) ─────────────────────────

  test "backend works standalone on full absolute paths", %{org: org, ctx: ctx} do
    assert {:ok, dir} = Artifacts.stat("/tobor/#{org.slug}/artifacts", ctx)
    assert dir.type == :dir

    assert {:error, :enoent} = Artifacts.stat("/tobor/#{org.slug}/nope", ctx)
    assert {:error, :enosys} = Artifacts.remove("/tobor/#{org.slug}/artifacts", ctx)
  end
end
