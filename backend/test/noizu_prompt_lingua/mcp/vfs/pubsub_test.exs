defmodule NoizuPromptLingua.MCP.VFS.PubSubTest do
  @moduledoc """
  Wave 3 battery for the `pubsub` VFS backend (design §2.11), through `Root` +
  `Features.VFS`.

  Covers: channel listing (FetchAll), Publish-as-create (sender derived from
  the principal, ToolGuard-gated, server `seq` in xattrs), message readdir +
  read, the per-principal `pointer.json` lifecycle (create = follow, read =
  pointer state, write = Ack to head + availability-pointer clearing, remove =
  unfollow), ring-buffer pruning with `:remove` events, and the
  `vfs/subscribe` liveness of publishes.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias Noizu.MCP.Ctx
  alias Noizu.MCP.Server.Features.VFS
  alias Noizu.MCP.Server.VFSPubSub
  alias Noizu.MCP.VFS.Cache
  alias NoizuPromptLingua.Domains.Notifications
  alias NoizuPromptLingua.Domains.PubSub
  alias NoizuPromptLingua.MCP.VFS.Root
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Organizations.Organization
  alias NoizuPromptLingua.Schema.PubSubMessage
  alias NoizuPromptLingua.Schema.Users.User
  alias NoizuPromptLingua.TRP.Cache, as: TrpCache
  alias NoizuPromptLingua.TRP.TestStub

  import Ecto.Query

  setup do
    TrpCache.clear()
    TestStub.reset()

    suffix = Ecto.UUID.generate() |> binary_part(0, 8)

    org =
      Repo.insert!(%Organization{name: "VFS PubSub Org #{suffix}", slug: "vfs-pubsub-#{suffix}"})

    TestStub.seed_org(org.id, org.slug, org.name)

    on_exit(fn -> Cache.purge(Root) end)

    ctx = key_ctx(%{"groups" => %{"pubsub" => %{}}})

    {:ok, channel} =
      PubSub.create_channel(%{organization_id: org.id, slug: "alerts", name: "Alerts"})

    %{org: org, ctx: ctx, channel: channel}
  end

  defp key_ctx(config) do
    uniq = System.unique_integer([:positive])
    handle = "w3bpubsub#{uniq}"

    user =
      %User{
        id: Ecto.UUID.generate(),
        email: "#{handle}@example.com",
        user_name: handle,
        handle: handle,
        status: :active
      }
      |> Repo.insert!()

    {:ok, key, _} = MCPApiKeys.generate_api_key(user.id, "vfs-pubsub", toolset_config: config)

    %Ctx{
      server: NoizuPromptLingua.MCP.VFSServer,
      session_id: "pubsub-" <> Integer.to_string(uniq),
      assigns: %{auth_claims: %{"api_key_id" => key.id, "sub" => user.id, "handle" => handle}}
    }
  end

  defp handle_of(ctx), do: ctx.assigns.auth_claims["handle"]
  defp base(org), do: "/tobor/#{org.slug}/pubsub"

  # ── channels plane (FetchAll) ─────────────────────────────────────────────

  test "the group root lists channels; overview renders", %{org: org, ctx: ctx} do
    assert {:ok, dir} = VFS.stat(Root, "#{base(org)}/alerts", ctx)
    assert dir.type == :dir

    assert {:ok, entries, nil} = VFS.list(Root, base(org), nil, ctx)
    names = Enum.map(entries, & &1.name)
    assert "overview.md" in names
    assert "alerts" in names

    assert {:ok, md, _} = VFS.read(Root, "#{base(org)}/overview.md", ctx)
    assert md =~ "pubsub"
  end

  # ── Publish as create ─────────────────────────────────────────────────────

  test "publish creates a message file with the server seq; fetch + read it back", %{
    org: org,
    ctx: ctx,
    channel: channel
  } do
    assert {:ok, node} =
             VFS.create(Root, "#{base(org)}/alerts/messages/hello.json", "first body", ctx)

    seq = node.xattrs["seq"]
    assert is_integer(seq)

    assert {:ok, entries, nil} = VFS.list(Root, "#{base(org)}/alerts/messages", nil, ctx)
    names = Enum.map(entries, & &1.name)
    assert length(names) == 1
    assert hd(names) =~ "-#{seq}.json"

    # The file name carries a filesystem-safe stamp + the seq (§1.1).
    {:ok, doc_json, _} = VFS.read(Root, "#{base(org)}/alerts/messages/#{hd(names)}", ctx)
    {:ok, doc} = Jason.decode(doc_json)
    assert doc["body"] == "first body"
    assert doc["sender"] == handle_of(ctx)
    assert doc["seq"] == seq
    refute String.contains?(hd(names), ":")

    assert Repo.one!(
             from(m in PubSubMessage, where: m.channel_id == ^channel.id, select: count(m.id))
           ) == 1
  end

  test "publish is ToolGuard-gated on PubSub.Publish", %{org: org} do
    gated =
      key_ctx(%{
        "groups" => %{"pubsub" => %{"tools" => %{"PubSub.Publish" => %{"disabled" => true}}}}
      })

    assert {:error, :eacces} =
             VFS.create(Root, "#{base(org)}/alerts/messages/blocked.json", "x", gated)
  end

  # ── pointer.json lifecycle: follow → ack → unfollow ───────────────────────

  test "pointer lifecycle: follow, unread growth, ack to head, unfollow", %{
    org: org,
    ctx: ctx
  } do
    pointer = "#{base(org)}/alerts/pointer.json"

    # Not following yet: the pointer does not exist.
    assert {:error, :enoent} = VFS.read(Root, pointer, ctx)
    assert {:error, :enoent} = VFS.write(Root, pointer, "ack", ctx)

    # Follow (create) — pointer starts at 0.
    assert {:ok, node} = VFS.create(Root, pointer, "", ctx)
    assert node.type == :file

    {:ok, json, _} = VFS.read(Root, pointer, ctx)
    assert {:ok, %{"last_acked_seq" => 0}} = Jason.decode(json)

    # Publishes move the head; the pointer reads unread against it and the
    # domain surfaces an availability notification to the follower.
    assert {:ok, _} = VFS.create(Root, "#{base(org)}/alerts/messages/m1.json", "one", ctx)
    assert {:ok, _} = VFS.create(Root, "#{base(org)}/alerts/messages/m2.json", "two", ctx)

    {:ok, json, _} = VFS.read(Root, pointer, ctx)
    {:ok, state} = Jason.decode(json)
    assert state["unread"] == 2

    assert Notifications.count(org.id, handle_of(ctx)) == 1

    # Ack (write) advances to head and clears the availability pointer.
    assert {:ok, _} = VFS.write(Root, pointer, "ack", ctx)
    {:ok, json, _} = VFS.read(Root, pointer, ctx)
    assert {:ok, %{"last_acked_seq" => head, "unread" => 0}} = Jason.decode(json)
    assert head == state["head_seq"]
    assert Notifications.count(org.id, handle_of(ctx)) == 0

    # Unfollow (remove) — the pointer disappears again.
    assert :ok = VFS.remove(Root, pointer, ctx)
    assert {:error, :enoent} = VFS.read(Root, pointer, ctx)
  end

  test "duplicate follow is :eexist; pointer read is per-principal", %{org: org, ctx: ctx} do
    pointer = "#{base(org)}/alerts/pointer.json"
    assert {:ok, _} = VFS.create(Root, pointer, "", ctx)
    assert {:error, :eexist} = VFS.create(Root, pointer, "", ctx)

    # A different principal has their own pointer state (absent until they follow).
    other = key_ctx(%{"groups" => %{"pubsub" => %{}}})
    assert {:error, :enoent} = VFS.read(Root, pointer, other)
    assert {:ok, _} = VFS.create(Root, pointer, "", other)
  end

  # ── ring-buffer retention with remove events (§2.11) ──────────────────────

  test "pruning keeps the newest N and emits :remove events", %{org: org, ctx: ctx} do
    Application.put_env(:noizu_prompt_lingua, :vfs_pubsub_ring_size, 2)

    messages = "#{base(org)}/alerts/messages"
    :ok = VFSPubSub.watch(NoizuPromptLingua.MCP.VFS.PubSub, messages, depth: 1)

    seqs =
      for i <- 1..3 do
        assert {:ok, node} = VFS.create(Root, "#{messages}/m#{i}.json", "body #{i}", ctx)
        {i, node.xattrs["seq"]}
      end
      |> Map.new()

    assert {:ok, entries, nil} = VFS.list(Root, messages, nil, ctx)
    assert length(entries) == 2

    kept =
      Enum.map(entries, fn e ->
        [_, s] = Regex.run(~r/-(\d+)\.json$/, e.name)
        String.to_integer(s)
      end)

    # The oldest was retired; the two newest remain — and mirrors learned of
    # the removal through a vfs event.
    published = for i <- 1..3, do: seqs[i]
    assert Enum.sort(kept) == Enum.sort(published -- [Enum.min(published)])
    assert_receive {:vfs_event, %{op: :remove, path: remove_path}}, 1_000
    assert String.starts_with?(remove_path, messages <> "/")
  after
    Application.delete_env(:noizu_prompt_lingua, :vfs_pubsub_ring_size)

    VFSPubSub.unwatch(
      NoizuPromptLingua.MCP.VFS.PubSub,
      "/tobor/#{org.slug}/pubsub/alerts/messages"
    )
  end

  # ── errnos + window ───────────────────────────────────────────────────────

  test "errnos: unknown channel/file, dir reads, structural creates", %{org: org, ctx: ctx} do
    assert {:error, :enoent} = VFS.stat(Root, "#{base(org)}/nope", ctx)

    assert {:error, :enoent} =
             VFS.read(Root, "#{base(org)}/alerts/messages/2026-01-01T00-00-00Z-999.json", ctx)

    assert {:error, :enoent} = VFS.read(Root, "#{base(org)}/alerts/messages/junk.json", ctx)
    assert {:error, :eisdir} = VFS.read(Root, "#{base(org)}/alerts/messages", ctx)
    assert {:error, :enotdir} = VFS.list(Root, "#{base(org)}/alerts/pointer.json", nil, ctx)
    assert {:error, :enosys} = VFS.create(Root, "#{base(org)}/alerts/newdir", :dir, ctx)
    assert {:error, :enosys} = VFS.remove(Root, "#{base(org)}/alerts/messages/x.json", ctx)
    assert {:error, :enosys} = VFS.remove(Root, "#{base(org)}/alerts", ctx)
  end

  # ── vfs/subscribe liveness ────────────────────────────────────────────────

  test "publishes surface as create events to channel watchers", %{org: org, ctx: ctx} do
    channel_dir = "#{base(org)}/alerts"
    :ok = VFSPubSub.watch(Root, channel_dir, depth: 2)

    assert {:ok, _} = VFS.create(Root, "#{channel_dir}/messages/live.json", "live body", ctx)

    assert_receive {:vfs_event, %{op: :create, path: path}}, 1_000
    assert String.starts_with?(path, channel_dir <> "/messages/")
  after
    VFSPubSub.unwatch(Root, "/tobor/#{org.slug}/pubsub/alerts")
  end

  # ── direct backend call ───────────────────────────────────────────────────

  test "backend works standalone on full absolute paths", %{org: org, ctx: ctx} do
    assert {:ok, dir} = NoizuPromptLingua.MCP.VFS.PubSub.stat("#{base(org)}", ctx)
    assert dir.type == :dir
    assert {:error, :enosys} = NoizuPromptLingua.MCP.VFS.PubSub.remove("#{base(org)}/alerts", ctx)
  end
end
