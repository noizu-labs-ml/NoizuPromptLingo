defmodule NoizuPromptLingua.MCP.VFS.SessionsTest do
  @moduledoc """
  Wave 2 battery for the §2.7 Sessions entity-dir + activity log: record.json
  CRUD, the manifest node, the derived append-only `log/`, the
  `actions/archive` control write (§3.5), gating, and readdir pagination.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias Noizu.MCP.Server.Features.VFS
  alias Noizu.MCP.VFS.Cache
  alias Noizu.MCP.Ctx
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCP.VFS.Sessions
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Users.User
  alias NoizuPromptLingua.TRP.Cache, as: TrpCache
  alias NoizuPromptLingua.TRP.TestStub

  @config %{"groups" => %{"sessions" => %{}}}

  setup do
    TrpCache.clear()
    TestStub.reset()
    on_exit(fn -> Cache.purge(Sessions) end)
    on_exit(fn -> Application.delete_env(:noizu_prompt_lingua, :vfs) end)
    :ok
  end

  defp key_ctx(config) do
    uniq = System.unique_integer([:positive])

    user =
      %User{
        id: Ecto.UUID.generate(),
        email: "vfssess-#{uniq}@example.com",
        user_name: "vfssess#{uniq}",
        handle: "vfssess#{uniq}",
        status: :active
      }
      |> Repo.insert!()

    {:ok, key, _raw} = MCPApiKeys.generate_api_key(user.id, "vfs-sess", toolset_config: config)

    %Ctx{
      server: NoizuPromptLingua.MCP.VFSServer,
      session_id: "sess-" <> Integer.to_string(uniq),
      assigns: %{auth_claims: %{"api_key_id" => key.id, "sub" => user.id}}
    }
  end

  # Local org (owner = ctx user) + matching TRP stub org for visibility.
  defp owned_org(ctx, suffix) do
    slug = "vfssess-#{suffix}-#{System.unique_integer([:positive])}"
    TestStub.seed_org(Ecto.UUID.generate(), slug, "Sess Org")

    {:ok, org} =
      NoizuPromptLingua.Organizations.create_organization_with_owner(
        %{"slug" => slug, "name" => "Sess Org"},
        ctx.assigns.auth_claims["sub"]
      )

    %{slug: slug, id: org.id}
  end

  defp create_session(ctx, org, title, body_extra \\ %{}) do
    body = Jason.encode!(Map.merge(%{"title" => title}, body_extra))

    VFS.create(Sessions, "/tobor/#{org.slug}/sessions/s1/record.json", body, ctx)
  end

  # ── create + readdir ──────────────────────────────────────────────────────

  test "create mints a session (server UUID) and readdir lists it" do
    ctx = key_ctx(@config)
    org = owned_org(ctx, "a")

    assert {:ok, node} = create_session(ctx, org, "Wave 2 session", %{"description" => "d"})
    assert id = node.xattrs["id"]
    assert node.xattrs["canonical_path"] == "/tobor/#{org.slug}/sessions/#{id}/record.json"

    assert {:ok, entries, nil} = VFS.list(Sessions, "/tobor/#{org.slug}/sessions", nil, ctx)
    assert [%{name: ^id, type: :dir}] = entries

    assert {:ok, files, nil} = VFS.list(Sessions, "/tobor/#{org.slug}/sessions/#{id}", nil, ctx)

    names = Enum.map(files, & &1.name)
    assert "record.json" in names and "manifest.json" in names
    assert "log" in names and "actions" in names
  end

  test "create requires a title and gates on the writable plane" do
    ctx = key_ctx(@config)
    org = owned_org(ctx, "b")

    assert {:error, :eio} = create_session(ctx, org, "")

    assert {:error, :eio} =
             VFS.create(Sessions, "/tobor/#{org.slug}/sessions/s1/record.json", "not json", ctx)

    assert {:error, :enosys} = VFS.create(Sessions, "/tobor/#{org.slug}/sessions/s1", :dir, ctx)
  end

  # ── record.json round-trip ────────────────────────────────────────────────

  test "record.json read + canonical write merge" do
    ctx = key_ctx(@config)
    org = owned_org(ctx, "c")
    {:ok, node} = create_session(ctx, org, "Original")
    id = node.xattrs["id"]

    path = "/tobor/#{org.slug}/sessions/#{id}/record.json"
    assert {:ok, stat} = VFS.stat(Sessions, path, ctx)
    {:ok, body, version} = VFS.read(Sessions, path, ctx)
    assert version == stat.version

    assert {:ok, doc} = Jason.decode(body)
    assert doc["title"] == "Original"
    assert doc["status"] == "active"

    assert {:ok, _} = VFS.write(Sessions, path, ~s({"title":"Renamed","model":"5.4"}), ctx)

    {:ok, body, _} = VFS.read(Sessions, path, ctx)
    assert {:ok, %{"title" => "Renamed", "model" => "5.4"}} = Jason.decode(body)
  end

  test "manifest.json renders this connection's tool manifest" do
    ctx = key_ctx(@config)
    org = owned_org(ctx, "d")
    {:ok, node} = create_session(ctx, org, "Manifest session")
    id = node.xattrs["id"]

    {:ok, body, _} = VFS.read(Sessions, "/tobor/#{org.slug}/sessions/#{id}/manifest.json", ctx)
    assert {:ok, manifest} = Jason.decode(body)
    assert is_list(manifest["tools"])
    assert manifest["generated_at"]
  end

  # ── log (append-only, derived) ────────────────────────────────────────────

  test "log/ lists immutable lifecycle entries; edits are refused" do
    ctx = key_ctx(@config)
    org = owned_org(ctx, "e")
    {:ok, node} = create_session(ctx, org, "Logged session")
    id = node.xattrs["id"]

    base = "/tobor/#{org.slug}/sessions/#{id}"
    assert {:ok, dir} = VFS.stat(Sessions, base <> "/log", ctx)
    assert dir.type == :dir

    assert {:ok, entries, nil} = VFS.list(Sessions, base <> "/log", nil, ctx)
    [created | _] = entries
    assert created.name =~ "created.json"

    # Entry content is the event doc; the entry is immutable.
    {:ok, body, _} = VFS.read(Sessions, base <> "/log/" <> created.name, ctx)
    assert {:ok, %{"event" => "created", "session" => ^id}} = Jason.decode(body)

    assert {:error, :eacces} = VFS.write(Sessions, base <> "/log/" <> created.name, "x", ctx)

    # Caller-authored entries need a backing store (wave 3).
    assert {:error, :enosys} = VFS.create(Sessions, base <> "/log/9999-note.json", "x", ctx)
  end

  # ── archive is a control write, never a content edit ──────────────────────

  test "status archived via record.json is refused; actions/archive performs it" do
    ctx = key_ctx(@config)
    org = owned_org(ctx, "f")
    {:ok, node} = create_session(ctx, org, "Archive me")
    id = node.xattrs["id"]

    base = "/tobor/#{org.slug}/sessions/#{id}"
    path = base <> "/record.json"

    assert {:error, :eacces} = VFS.write(Sessions, path, ~s({"status":"archived"}), ctx)

    assert {:ok, control} = VFS.stat(Sessions, base <> "/actions/archive", ctx)
    assert control.type == :control
    assert {:ok, _} = VFS.write(Sessions, base <> "/actions/archive", "go", ctx)

    {:ok, body, _} = VFS.read(Sessions, path, ctx)
    assert {:ok, %{"status" => "archived"}} = Jason.decode(body)

    # The transition appended its log entry.
    {:ok, entries, nil} = VFS.list(Sessions, base <> "/log", nil, ctx)
    assert Enum.any?(entries, &(&1.name =~ "archived.json"))
  end

  # ── gating + isolation ────────────────────────────────────────────────────

  test "foreign-org session id and excluded group are :enoent" do
    ctx = key_ctx(@config)
    org_a = owned_org(ctx, "g")
    org_b = owned_org(ctx, "h")
    {:ok, node} = create_session(ctx, org_a, "A session")
    id = node.xattrs["id"]

    # The session hangs off org A; the same id under org B does not exist.
    assert {:error, :enoent} =
             VFS.read(Sessions, "/tobor/#{org_b.slug}/sessions/#{id}/record.json", ctx)

    excluded = key_ctx(%{"groups" => %{"wiki" => %{}}})

    assert {:error, :enoent} = VFS.stat(Sessions, "/tobor/#{org_a.slug}/sessions", excluded)
  end

  test "disabled group lists read-only; mutation is :eacces" do
    ctx = key_ctx(%{"groups" => %{"sessions" => %{"disabled" => true}}})
    org = owned_org(ctx, "i")

    assert {:ok, dir} = VFS.stat(Sessions, "/tobor/#{org.slug}/sessions", ctx)
    assert dir.writable == false

    assert {:error, :eacces} =
             VFS.create(Sessions, "/tobor/#{org.slug}/sessions/s1/record.json", ~s({"title":"x"}), ctx)
  end

  # ── readdir pagination (§3.2) ─────────────────────────────────────────────

  test "readdir pages via an opaque cursor" do
    Application.put_env(:noizu_prompt_lingua, :vfs, list_window: 2)

    ctx = key_ctx(@config)
    org = owned_org(ctx, "j")

    for i <- 1..3, do: {:ok, _} = create_session(ctx, org, "Session #{i}")

    dir = "/tobor/#{org.slug}/sessions"
    assert {:ok, page1, cursor} = VFS.list(Sessions, dir, nil, ctx)
    assert length(page1) == 2 and is_binary(cursor)

    assert {:ok, page2, nil} = VFS.list(Sessions, dir, cursor, ctx)
    assert length(page2) == 1

    # No cross-page duplicates.
    assert MapSet.disjoint?(MapSet.new(page1, & &1.name), MapSet.new(page2, & &1.name))

    assert {:error, %Noizu.MCP.Error{}} = VFS.list(Sessions, dir, "garbage-cursor", ctx)
  end
end
