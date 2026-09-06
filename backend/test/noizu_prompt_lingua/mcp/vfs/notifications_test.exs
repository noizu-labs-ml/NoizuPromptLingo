defmodule NoizuPromptLingua.MCP.VFS.NotificationsTest do
  @moduledoc """
  Wave 3 battery for the `notifications` VFS backend (design §2.10), through
  `Root` + `Features.VFS`.

  Covers: Notify create (self + cross-recipient, ToolGuard-gated, 128-char
  cap), the read/doc + flags/meta files, MarkRead/MarkSeen/Ack field writes
  (JSON or bare word; acked rows leave the listing), per-principal path
  isolation (user A cannot see or read user B's subtree), the no-handle
  principal, §1.3 gate matrix, and the `vfs/subscribe` liveness headline
  (create + flag writes publish vfs events).
  """

  use NoizuPromptLingua.DataCase, async: false

  alias Noizu.MCP.Ctx
  alias Noizu.MCP.Server.Features.VFS
  alias Noizu.MCP.Server.VFSPubSub
  alias Noizu.MCP.VFS.Cache
  alias NoizuPromptLingua.Domains.Notifications
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCP.VFS.Root
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Notification
  alias NoizuPromptLingua.Schema.Organizations.Organization
  alias NoizuPromptLingua.Schema.Users.User
  alias NoizuPromptLingua.TRP.Cache, as: TrpCache
  alias NoizuPromptLingua.TRP.TestStub

  setup do
    TrpCache.clear()
    TestStub.reset()

    suffix = Ecto.UUID.generate() |> binary_part(0, 8)

    org =
      Repo.insert!(%Organization{name: "VFS Notif Org #{suffix}", slug: "vfs-notif-#{suffix}"})

    TestStub.seed_org(org.id, org.slug, org.name)

    on_exit(fn -> Cache.purge(Root) end)

    %{org: org, ctx: key_ctx(%{"groups" => %{"notifications" => %{}}})}
  end

  defp key_ctx(config, claims_extra \\ %{}) do
    uniq = System.unique_integer([:positive])
    handle = "w3bnotif#{uniq}"

    user =
      %User{
        id: Ecto.UUID.generate(),
        email: "#{handle}@example.com",
        user_name: handle,
        handle: handle,
        status: :active
      }
      |> Repo.insert!()

    {:ok, key, _} =
      MCPApiKeys.generate_api_key(user.id, "vfs-notifications", toolset_config: config)

    claims =
      Map.merge(%{"api_key_id" => key.id, "sub" => user.id, "handle" => handle}, claims_extra)

    %Ctx{
      server: NoizuPromptLingua.MCP.VFSServer,
      session_id: "notif-" <> Integer.to_string(uniq),
      assigns: %{auth_claims: claims}
    }
  end

  # The recipient handle a connection resolves to — mirrors the backend rule:
  # the `handle` claim first, else the subject user's `handle`.
  defp handle_of(ctx) do
    claims = ctx.assigns.auth_claims

    case claims["handle"] do
      h when is_binary(h) ->
        h

      _ ->
        case claims["sub"] && Repo.get(User, claims["sub"]) do
          %User{} = user -> user.handle
          _ -> nil
        end
    end
  end

  defp base(org), do: "/tobor/#{org.slug}/notifications"

  defp seed!(org, recipient, kind \\ "dm", body \\ "psst") do
    {:ok, [row]} =
      Notifications.notify(%{
        organization_id: org.id,
        recipient: recipient,
        kind: kind,
        body: body
      })

    row
  end

  # ── Root wiring + Notify create ───────────────────────────────────────────

  test "notify create seeds a row, mounts it, and the doc reads back", %{org: org, ctx: ctx} do
    handle = handle_of(ctx)

    assert {:ok, node} = VFS.create(Root, "#{base(org)}/#{handle}/tell-me.json", "hello me", ctx)
    assert node.type == :file
    assert is_binary(node.xattrs["id"])

    id = node.xattrs["id"]

    assert {:ok, entries, nil} = VFS.list(Root, "#{base(org)}/#{handle}", nil, ctx)
    assert "#{id}.json" in Enum.map(entries, & &1.name)

    {:ok, doc_json, _} = VFS.read(Root, "#{base(org)}/#{handle}/#{id}.json", ctx)
    {:ok, doc} = Jason.decode(doc_json)
    assert doc["body"] == "hello me"
    assert doc["kind"] == "dm"
    assert doc["recipient"] == handle
    assert doc["read"] == false

    {:ok, meta_json, _} = VFS.read(Root, "#{base(org)}/#{handle}/#{id}.meta.json", ctx)
    assert {:ok, %{"read" => false, "acked" => false}} = Jason.decode(meta_json)

    assert %{notifications: 1} = Notifications.stats(org.id)
  end

  test "cross-recipient create delivers; only the recipient can read it", %{org: org, ctx: alice} do
    bob = key_ctx(%{"groups" => %{"notifications" => %{}}})
    bob_handle = handle_of(bob)
    alice_handle = handle_of(alice)

    assert {:ok, node} = VFS.create(Root, "#{base(org)}/#{bob_handle}/hi.json", "hi bob", alice)
    id = node.xattrs["id"]

    # The recipient reads it; the sender cannot (per-principal, no existence leak).
    assert {:ok, doc_json, _} = VFS.read(Root, "#{base(org)}/#{bob_handle}/#{id}.json", bob)
    assert {:ok, %{"sender" => ^alice_handle}} = Jason.decode(doc_json)

    assert {:error, :enoent} = VFS.stat(Root, "#{base(org)}/#{bob_handle}", alice)
    assert {:error, :enoent} = VFS.read(Root, "#{base(org)}/#{bob_handle}/#{id}.json", alice)
    assert {:error, :enoent} = VFS.list(Root, "#{base(org)}/#{bob_handle}", nil, alice)
  end

  test "create is ToolGuard-gated on the Notify tool; body over the DM cap is :eio", %{
    org: org
  } do
    gated =
      key_ctx(%{
        "groups" => %{"notifications" => %{"tools" => %{"Notify" => %{"disabled" => true}}}}
      })

    handle = handle_of(gated)
    assert {:error, :eacces} = VFS.create(Root, "#{base(org)}/#{handle}/x.json", "y", gated)

    ctx = key_ctx(%{"groups" => %{"notifications" => %{}}})
    handle = handle_of(ctx)

    assert {:error, :eio} =
             VFS.create(Root, "#{base(org)}/#{handle}/x.json", String.duplicate("a", 129), ctx)

    assert {:error, :enoent} = VFS.create(Root, "#{base(org)}/#{handle}/noext", "y", ctx)
  end

  # ── mark-read / mark-seen / ack field writes ──────────────────────────────

  test "flag writes update the row; acked rows leave the listing but stay addressable", %{
    org: org,
    ctx: ctx
  } do
    handle = handle_of(ctx)
    row = seed!(org, handle)

    path = "#{base(org)}/#{handle}/#{row.id}.json"
    meta_path = "#{base(org)}/#{handle}/#{row.id}.meta.json"

    assert {:ok, _} = VFS.write(Root, path, ~s({"read": true}), ctx)
    assert {:ok, _} = VFS.write(Root, meta_path, "seen", ctx)

    {:ok, doc_json, _} = VFS.read(Root, path, ctx)
    assert {:ok, %{"read" => true, "seen" => true}} = Jason.decode(doc_json)

    {:ok, meta_json, _} = VFS.read(Root, meta_path, ctx)
    assert {:ok, %{"read" => true, "read_at" => at}} = Jason.decode(meta_json)
    assert is_binary(at)

    # Acked: gone from readdir, still addressable by id.
    assert {:ok, _} = VFS.write(Root, meta_path, ~s({"acked": true}), ctx)
    assert {:ok, entries, nil} = VFS.list(Root, "#{base(org)}/#{handle}", nil, ctx)
    refute "#{row.id}.json" in Enum.map(entries, & &1.name)
    assert {:ok, _, _} = VFS.read(Root, path, ctx)

    row2 = Repo.get!(Notification, row.id)
    assert row2.read and row2.seen and row2.acked
  end

  test "malformed flag writes are refused", %{org: org, ctx: ctx} do
    handle = handle_of(ctx)
    row = seed!(org, handle)

    path = "#{base(org)}/#{handle}/#{row.id}.json"
    assert {:error, :eio} = VFS.write(Root, path, "not json at all", ctx)
    assert {:error, :enosys} = VFS.write(Root, path, ~s({"bogus": true}), ctx)
    assert {:error, :enosys} = VFS.remove(Root, path, ctx)
  end

  # ── per-principal path enforcement ────────────────────────────────────────

  test "the group root lists exactly the principal's own subtree", %{org: org, ctx: alice} do
    bob = key_ctx(%{"groups" => %{"notifications" => %{}}})
    alice_handle = handle_of(alice)
    bob_handle = handle_of(bob)

    assert {:ok, entries, nil} = VFS.list(Root, base(org), nil, alice)
    names = Enum.map(entries, & &1.name)
    assert "overview.md" in names
    assert alice_handle in names
    refute bob_handle in names
  end

  test "a principal with no resolvable handle lists nothing and sees no subtrees", %{org: org} do
    anon = key_ctx(%{"groups" => %{"notifications" => %{}}}, %{"handle" => nil, "sub" => nil})

    assert {:ok, entries, nil} = VFS.list(Root, base(org), nil, anon)
    assert Enum.map(entries, & &1.name) == ["overview.md"]

    seeded = seed!(org, "someone-else")
    assert {:error, :enoent} = VFS.stat(Root, "#{base(org)}/someone-else", anon)
    assert {:error, :enoent} = VFS.read(Root, "#{base(org)}/someone-else/#{seeded.id}.json", anon)
  end

  test "handle-less claims fall back to the subject user's handle", %{org: org} do
    ctx = key_ctx(%{"groups" => %{"notifications" => %{}}}, %{"handle" => nil})
    handle = handle_of(ctx)
    assert is_binary(handle)

    # The sub claim resolves the same user handle, so the own subtree exists.
    assert {:ok, _node} = VFS.create(Root, "#{base(org)}/#{handle}/via-sub.json", "x", ctx)
  end

  # ── overview + gates ──────────────────────────────────────────────────────

  test "overview.md renders from the group's Overview tool", %{org: org, ctx: ctx} do
    assert {:ok, md, _} = VFS.read(Root, "#{base(org)}/overview.md", ctx)
    assert md =~ "notifications"
  end

  test "excluded group is :enoent; disabled group is read-only", %{org: org} do
    excluded = key_ctx(%{"groups" => %{"wiki" => %{}}})
    assert {:error, :enoent} = VFS.stat(Root, base(org), excluded)

    disabled = key_ctx(%{"groups" => %{"notifications" => %{"disabled" => true}}})
    assert {:ok, dir} = VFS.stat(Root, base(org), disabled)
    assert dir.writable == false
  end

  # ── vfs/subscribe liveness (the §2.10 headline) ───────────────────────────

  test "create and flag writes publish vfs events to subtree watchers", %{org: org, ctx: ctx} do
    handle = handle_of(ctx)
    inbox = "#{base(org)}/#{handle}"

    :ok = VFSPubSub.watch(Root, inbox, depth: 1)

    {:ok, node} = VFS.create(Root, "#{inbox}/live.json", "ping", ctx)
    id = node.xattrs["id"]

    assert_receive {:vfs_event, %{op: :create, path: ^inbox <> "/live.json"}}, 1_000

    assert {:ok, _} = VFS.write(Root, "#{inbox}/#{id}.json", ~s({"read": true}), ctx)

    assert_receive {:vfs_event, %{op: :write, path: write_path}}, 1_000
    assert write_path == "#{inbox}/#{id}.json"
  after
    VFSPubSub.unwatch(Root, "/tobor/#{org.slug}/notifications/#{handle_of(ctx)}")
  end

  # ── direct backend call ───────────────────────────────────────────────────

  test "backend works standalone on full absolute paths", %{org: org, ctx: ctx} do
    assert {:ok, dir} =
             NoizuPromptLingua.MCP.VFS.Notifications.stat("/tobor/#{org.slug}/notifications", ctx)

    assert dir.type == :dir

    assert {:error, :enosys} =
             NoizuPromptLingua.MCP.VFS.Notifications.remove(
               "/tobor/#{org.slug}/notifications/x.json",
               ctx
             )
  end
end
