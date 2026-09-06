defmodule NoizuPromptLingua.MCP.VFS.ChatTest do
  @moduledoc """
  Wave 3 conformance suite for the Chat VFS backend (`NoizuPromptLingua.MCP.VFS.Chat`,
  MCP-VFS-GROUP-MOUNTS.md §2.9).

  Exercises the backend through the lib's cache-aware wrappers
  (`Noizu.MCP.Server.Features.VFS`) so errno mapping, generation stamping, and
  cursor plumbing are verified on the composed surface, against the real chat
  domain: append-log message files (create-new, readdir-sorted, cursor-paginated),
  threaded replies, membership-gated room subtrees, reactions/pins, scheduled
  sends (incl. the Wave-4 `release_due_scheduled/0` move), attachments, and DM
  pair-key rooms.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias Noizu.MCP.Server.Features.VFS
  alias Noizu.MCP.VFS.Cache
  alias Noizu.MCP.{Ctx, Error}
  alias NoizuPromptLingua.Domains.Chat, as: ChatDomain
  alias NoizuPromptLingua.MCP.VFS.Chat
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.ChatMessage
  alias NoizuPromptLingua.Schema.ChatNotification
  alias NoizuPromptLingua.Schema.Users.User
  alias NoizuPromptLingua.TRP.Cache, as: TrpCache
  alias NoizuPromptLingua.TRP.TestStub

  @scope %{"groups" => %{"chat" => %{}}}

  setup do
    TrpCache.clear()
    TestStub.reset()

    slug = "vfs-chat-org-#{System.unique_integer([:positive])}"
    TestStub.seed_org(Ecto.UUID.generate(), slug, "VFS Chat Org")

    org_id = insert_org(slug)

    on_exit(fn -> Cache.purge(Chat) end)

    %{slug: slug, org_id: org_id, alice: key_ctx("alice"), bob: key_ctx("bob")}
  end

  # ── fixtures ──────────────────────────────────────────────────────────────

  defp insert_org(slug) do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        [slug, "VFS Chat Org"]
      )

    Ecto.UUID.load!(raw)
  end

  defp key_ctx(persona, scope \\ @scope) do
    uniq = System.unique_integer([:positive])

    user =
      %User{
        id: Ecto.UUID.generate(),
        email: "vfschat-#{uniq}@example.com",
        user_name: persona,
        handle: persona,
        status: :active
      }
      |> Repo.insert!()

    {:ok, key, _raw} = MCPApiKeys.generate_api_key(user.id, "vfs-chat", toolset_config: scope)

    %Ctx{
      server: NoizuPromptLingua.MCP.VFSServer,
      session_id: "sess-" <> Integer.to_string(uniq),
      assigns: %{auth_claims: %{"api_key_id" => key.id, "sub" => user.id}}
    }
  end

  defp room(org_id, name, members) do
    {:ok, room} = ChatDomain.create_room(%{organization_id: org_id, name: name})

    Enum.each(members, fn persona ->
      ChatDomain.add_member(%{room_id: room.id, persona: persona})
    end)

    room
  end

  defp send(room_id, sender, content) do
    {:ok, msg} = ChatDomain.send_message(%{room_id: room_id, sender: sender, content: content})
    msg
  end

  defp chat(slug, rest \\ ""), do: "/tobor/" <> slug <> "/chat" <> rest

  defp message_names(slug, room_slug, ctx) do
    {:ok, entries, _} = VFS.list(Chat, chat(slug, "/" <> room_slug <> "/messages"), nil, ctx)
    Enum.map(entries, & &1.name)
  end

  # ── namespace & gates ─────────────────────────────────────────────────────

  describe "namespace & gates" do
    test "stat/3 serves the chat dir, overview, and rooms index", %{slug: slug, alice: ctx} do
      assert {:ok, dir} = VFS.stat(Chat, chat(slug), ctx)
      assert dir.type == :dir

      assert {:ok, ov} = VFS.stat(Chat, chat(slug, "/overview.md"), ctx)
      assert ov.type == :file and ov.size > 0

      assert {:ok, idx} = VFS.stat(Chat, chat(slug, "/rooms.json"), ctx)
      assert idx.type == :file

      assert {:ok, content, _} = VFS.read(Chat, chat(slug, "/overview.md"), ctx)
      assert content =~ "Chat"
    end

    test "readdir /chat lists rooms.json, overview.md, and org channels", %{
      slug: slug,
      org_id: org_id,
      alice: ctx
    } do
      room(org_id, "general", [])
      room(org_id, "random", [])

      assert {:ok, entries, nil} = VFS.list(Chat, chat(slug), nil, ctx)
      names = Enum.map(entries, & &1.name)
      assert names == Enum.sort(names)
      assert names == ["general", "overview.md", "random", "rooms.json"]
    end

    test "rooms.json is the per-principal index with unread counts", %{
      slug: slug,
      org_id: org_id,
      alice: ctx
    } do
      r = room(org_id, "indexed", ["alice"])
      send(r.id, "visitor", "knock knock")

      Repo.insert!(%ChatNotification{room_id: r.id, persona: "alice", message: "ping"})

      {:ok, json, _} = VFS.read(Chat, chat(slug, "/rooms.json"), ctx)
      assert {:ok, index} = Jason.decode(json)
      assert index["principal"] == "alice"

      entry = Enum.find(index["rooms"], &(&1["slug"] == r.slug))
      assert entry
      assert entry["unread"] == 1
      assert entry["kind"] == "channel"
    end

    test "rooms.json only lists the principal's own rooms", %{
      slug: slug,
      org_id: org_id,
      bob: ctx
    } do
      room(org_id, "mine", ["bob"])
      room(org_id, "theirs", ["alice"])

      {:ok, json, _} = VFS.read(Chat, chat(slug, "/rooms.json"), ctx)
      {:ok, index} = Jason.decode(json)

      assert [%{"slug" => "mine"}] = index["rooms"]
    end

    test "dot segments are refused (traversal guard)", %{slug: slug, alice: ctx} do
      assert {:error, :enoent} = VFS.stat(Chat, chat(slug, "/../../etc"), ctx)
      assert {:error, :enoent} = VFS.stat(Chat, "/tobor/../etc", ctx)
    end

    test "a principal without the chat group sees :enoent for the subtree", %{slug: slug} do
      ctx = key_ctx("gateless", %{"groups" => %{}})

      assert {:error, :enoent} = VFS.stat(Chat, chat(slug), ctx)
      assert {:error, :enoent} = VFS.list(Chat, chat(slug), nil, ctx)
    end

    test "an invisible org's chat subtree is :enoent", %{alice: ctx} do
      assert {:error, :enoent} = VFS.stat(Chat, chat("no-such-org"), ctx)
    end

    test "invalid cursors are invalid params", %{slug: slug, org_id: org_id, alice: ctx} do
      r = room(org_id, "cursor-org", ["alice"])

      assert {:error, %Error{}} =
               VFS.list(Chat, chat(slug, "/" <> r.slug <> "/messages"), "bogus", ctx)
    end
  end

  # ── membership gating ─────────────────────────────────────────────────────

  describe "membership gating" do
    test "room dirs are visible to non-members; content subtrees are :enoent", %{
      slug: slug,
      org_id: org_id,
      bob: ctx
    } do
      r = room(org_id, "members-only", ["alice"])
      send(r.id, "alice", "secret")

      assert {:ok, dir} = VFS.stat(Chat, chat(slug, "/" <> r.slug), ctx)
      assert dir.type == :dir

      assert {:ok, [], nil} = VFS.list(Chat, chat(slug, "/" <> r.slug), nil, ctx)

      for path <- [
            "/record.json",
            "/messages",
            "/events",
            "/members",
            "/attachments",
            "/reactions.json",
            "/pinned.json",
            "/scheduled",
            "/notifications"
          ] do
        assert {:error, :enoent} = VFS.stat(Chat, chat(slug, "/" <> r.slug <> path), ctx),
               path
      end

      assert {:error, :enoent} = VFS.read(Chat, chat(slug, "/" <> r.slug <> "/record.json"), ctx)
    end

    test "members see the full room shell", %{slug: slug, org_id: org_id, alice: ctx} do
      r = room(org_id, "shell", ["alice"])

      {:ok, entries, nil} = VFS.list(Chat, chat(slug, "/" <> r.slug), nil, ctx)
      names = Enum.map(entries, & &1.name)

      assert Enum.sort(names) ==
               Enum.sort([
                 "attachments",
                 "events",
                 "members",
                 "messages",
                 "notifications",
                 "pinned.json",
                 "reactions.json",
                 "record.json",
                 "scheduled"
               ])

      assert {:ok, rec} = VFS.stat(Chat, chat(slug, "/" <> r.slug <> "/record.json"), ctx)
      assert rec.writable == true
    end
  end

  # ── rooms ─────────────────────────────────────────────────────────────────

  describe "rooms" do
    test "CreateRoom = create {room}/record.json (plain-text body is the name)", %{
      slug: slug,
      org_id: org_id,
      alice: ctx
    } do
      assert {:ok, node} =
               VFS.create(Chat, chat(slug, "/general-2/record.json"), "General Two", ctx)

      assert node.type == :file and node.writable == true

      assert {:ok, room} = ChatDomain.resolve_room("general-2", org_id)
      assert room.name == "General Two"

      {:ok, json, _} = VFS.read(Chat, chat(slug, "/general-2/record.json"), ctx)
      {:ok, doc} = Jason.decode(json)
      assert doc["slug"] == "general-2"
      assert doc["name"] == "General Two"
    end

    test "CreateRoom accepts a JSON body and an :dir create at the room path", %{
      slug: slug,
      org_id: org_id,
      alice: ctx
    } do
      body = Jason.encode!(%{"name" => "Deep", "description" => "topic"})

      assert {:ok, _} = VFS.create(Chat, chat(slug, "/deep-room/record.json"), body, ctx)
      assert {:ok, room} = ChatDomain.resolve_room("deep-room", org_id)
      assert room.description == "topic"

      assert {:ok, _} = VFS.create(Chat, chat(slug, "/mkdir-room"), :dir, ctx)
      assert {:ok, _} = ChatDomain.resolve_room("mkdir-room", org_id)
    end

    test "duplicate room create is :eexist; bad slug segment is invalid params", %{
      slug: slug,
      org_id: org_id,
      alice: ctx
    } do
      room(org_id, "dup-base", [])

      assert {:error, :eexist} =
               VFS.create(Chat, chat(slug, "/dup-base/record.json"), "Dup Base", ctx)

      assert {:error, %Error{}} =
               VFS.create(Chat, chat(slug, "/Bad Slug/record.json"), "Bad Slug", ctx)
    end

    test "record.json write merges name/description and supports attach_wiki", %{
      slug: slug,
      org_id: org_id,
      alice: ctx
    } do
      r = room(org_id, "merge-me", ["alice"])

      body =
        Jason.encode!(%{
          "description" => "new topic",
          "attach_wiki" => %{"url" => "https://wiki.example/p/1"}
        })

      assert {:ok, _} = VFS.write(Chat, chat(slug, "/" <> r.slug <> "/record.json"), body, ctx)

      {:ok, json, _} = VFS.read(Chat, chat(slug, "/" <> r.slug <> "/record.json"), ctx)
      {:ok, doc} = Jason.decode(json)
      assert doc["description"] == "new topic"
      assert doc["name"] == r.name

      assert [%{"url" => "https://wiki.example/p/1", "artifact_type" => "wiki"}] =
               doc["attachments"]

      assert {:error, :eio} =
               VFS.write(Chat, chat(slug, "/" <> r.slug <> "/record.json"), "{bad", ctx)
    end

    test "DeleteRoom guards with :enotempty; empty rooms delete; record.json is not removable", %{
      slug: slug,
      org_id: org_id,
      alice: ctx
    } do
      full = room(org_id, "full-room", ["alice"])
      send(full.id, "alice", "content")

      assert {:error, :enotempty} = VFS.remove(Chat, chat(slug, "/" <> full.slug), ctx)

      assert {:error, :eacces} =
               VFS.remove(Chat, chat(slug, "/" <> full.slug <> "/record.json"), ctx)

      empty = room(org_id, "empty-room", ["alice"])
      assert :ok = VFS.remove(Chat, chat(slug, "/" <> empty.slug), ctx)
      assert {:error, :not_found} = ChatDomain.resolve_room(empty.slug, org_id)
    end
  end

  # ── append-log messages ───────────────────────────────────────────────────

  describe "messages (append-log)" do
    test "SendMessage = create-new file with the canonical {ts}-{seq}.json name", %{
      slug: slug,
      org_id: org_id,
      alice: ctx
    } do
      r = room(org_id, "log", ["alice"])

      assert {:ok, node} =
               VFS.create(
                 Chat,
                 chat(slug, "/" <> r.slug <> "/messages/wish.json"),
                 "hello world",
                 ctx
               )

      assert node.type == :file and node.writable == false

      assert [name] = message_names(slug, r.slug, ctx)
      assert name =~ ~r/^\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}Z-\d{6}\.json$/

      {:ok, json, _} = VFS.read(Chat, chat(slug, "/" <> r.slug <> "/messages/" <> name), ctx)
      {:ok, doc} = Jason.decode(json)
      assert doc["content"] == "hello world"
      assert doc["sender"] == "alice"
      assert doc["pinned"] == false
    end

    test "JSON create bodies carry sender/parent overrides; malformed JSON is :eio", %{
      slug: slug,
      org_id: org_id,
      alice: ctx
    } do
      r = room(org_id, "json-body", ["alice"])
      root = send(r.id, "alice", "root")

      body = Jason.encode!(%{"content" => "a reply", "sender" => "carol", "parent_id" => root.id})

      assert {:ok, _} =
               VFS.create(Chat, chat(slug, "/" <> r.slug <> "/messages/x.json"), body, ctx)

      assert {:error, :eio} =
               VFS.create(Chat, chat(slug, "/" <> r.slug <> "/messages/y.json"), "{oops", ctx)
    end

    test "message files are immutable (write is :eacces)", %{
      slug: slug,
      org_id: org_id,
      alice: ctx
    } do
      r = room(org_id, "immutable", ["alice"])
      send(r.id, "alice", "keep me")

      [name] = message_names(slug, r.slug, ctx)

      assert {:error, :eacces} =
               VFS.write(Chat, chat(slug, "/" <> r.slug <> "/messages/" <> name), "tamper", ctx)
    end

    test "readdir is sorted oldest→newest", %{slug: slug, org_id: org_id, alice: ctx} do
      r = room(org_id, "sorted", ["alice"])

      for i <- 1..5, do: send(r.id, "alice", "m#{i}")

      names = message_names(slug, r.slug, ctx)
      assert names == Enum.sort(names)
      assert length(names) == 5
    end

    test "ListMessages cursor pagination", %{slug: slug, org_id: org_id, alice: ctx} do
      r = room(org_id, "paged", ["alice"])

      for _ <- 1..55, do: send(r.id, "alice", "page me")

      path = chat(slug, "/" <> r.slug <> "/messages")

      {:ok, page1, cursor} = VFS.list(Chat, path, nil, ctx)
      assert length(page1) == 50
      assert cursor == "50"

      {:ok, page2, nil} = VFS.list(Chat, path, cursor, ctx)
      assert length(page2) == 5

      assert {:error, %Error{}} = VFS.list(Chat, path, "not-a-cursor", ctx)
    end

    test "threaded replies live under {msg-id}.replies/", %{
      slug: slug,
      org_id: org_id,
      alice: ctx
    } do
      r = room(org_id, "threads", ["alice"])
      root = send(r.id, "alice", "root")
      parent = root.id

      assert {:ok, _} =
               VFS.create(
                 Chat,
                 chat(slug, "/" <> r.slug <> "/messages/" <> parent <> ".replies/reply.json"),
                 "a reply",
                 ctx
               )

      replies_dir = chat(slug, "/" <> r.slug <> "/messages/" <> parent <> ".replies")
      assert {:ok, dir} = VFS.stat(Chat, replies_dir, ctx)
      assert dir.type == :dir

      assert {:ok, [entry], nil} = VFS.list(Chat, replies_dir, nil, ctx)
      assert entry.name =~ ~r/\.json$/

      # The reply is NOT in the top-level listing.
      refute Enum.any?(message_names(slug, r.slug, ctx), &(&1 == entry.name))

      {:ok, json, _} = VFS.read(Chat, replies_dir <> "/" <> entry.name, ctx)
      {:ok, doc} = Jason.decode(json)
      assert doc["content"] == "a reply"
      assert doc["parent_id"] == parent

      # Unknown parent's thread dir is :enoent.
      assert {:error, :enoent} =
               VFS.stat(
                 Chat,
                 chat(slug, "/" <> r.slug <> "/messages/" <> Ecto.UUID.generate() <> ".replies"),
                 ctx
               )
    end
  end

  # ── events ────────────────────────────────────────────────────────────────

  describe "events" do
    test "CreateEvent/ListEvents map to events/", %{slug: slug, org_id: org_id, alice: ctx} do
      r = room(org_id, "events", ["alice"])

      body = Jason.encode!(%{"event_type" => "todo", "content" => "ship it"})
      assert {:ok, _} = VFS.create(Chat, chat(slug, "/" <> r.slug <> "/events/e.json"), body, ctx)

      dir = chat(slug, "/" <> r.slug <> "/events")
      assert {:ok, [entry], nil} = VFS.list(Chat, dir, nil, ctx)
      assert entry.name =~ ~r/\.json$/

      {:ok, json, _} = VFS.read(Chat, dir <> "/" <> entry.name, ctx)
      {:ok, doc} = Jason.decode(json)
      assert doc["event_type"] == "todo"
      assert doc["content"] == "ship it"
    end

    test "event validation: unknown type or missing content is :eio", %{
      slug: slug,
      org_id: org_id,
      alice: ctx
    } do
      r = room(org_id, "events-invalid", ["alice"])

      assert {:error, :eio} =
               VFS.create(
                 Chat,
                 chat(slug, "/" <> r.slug <> "/events/a.json"),
                 Jason.encode!(%{"event_type" => "nope", "content" => "x"}),
                 ctx
               )

      assert {:error, :eio} =
               VFS.create(
                 Chat,
                 chat(slug, "/" <> r.slug <> "/events/b.json"),
                 Jason.encode!(%{"event_type" => "todo"}),
                 ctx
               )
    end
  end

  # ── members ───────────────────────────────────────────────────────────────

  describe "members" do
    test "AddMember = create members/{persona}.json; ListMembers readdir", %{
      slug: slug,
      org_id: org_id,
      alice: ctx
    } do
      r = room(org_id, "roster", ["alice"])

      assert {:ok, _} =
               VFS.create(Chat, chat(slug, "/" <> r.slug <> "/members/bobp.json"), "", ctx)

      dir = chat(slug, "/" <> r.slug <> "/members")
      assert {:ok, entries, nil} = VFS.list(Chat, dir, nil, ctx)
      assert Enum.map(entries, & &1.name) |> Enum.sort() == ["alice.json", "bobp.json"]

      assert {:error, :eexist} =
               VFS.create(Chat, chat(slug, "/" <> r.slug <> "/members/bobp.json"), "", ctx)
    end

    test "non-members cannot add others (:eacces)", %{slug: slug, org_id: org_id, bob: ctx} do
      r = room(org_id, "closed", ["alice"])

      # Bob (non-member) cannot add CAROL — only his own join file is writable.
      assert {:error, :eacces} =
               VFS.create(Chat, chat(slug, "/" <> r.slug <> "/members/carol.json"), "", ctx)
    end

    test "JoinRoom = create members/{me}.json — the one non-member create", %{
      slug: slug,
      org_id: org_id,
      bob: ctx
    } do
      r = room(org_id, "open-door", ["alice"])
      path = chat(slug, "/" <> r.slug <> "/members/bob.json")

      assert {:ok, node} = VFS.create(Chat, path, "", ctx)
      assert node.writable == true

      # Subtree opens for the new member.
      assert {:ok, _} = VFS.stat(Chat, chat(slug, "/" <> r.slug <> "/record.json"), ctx)

      # Already a member → :eexist.
      assert {:error, :eexist} = VFS.create(Chat, path, "", ctx)
    end

    test "JoinRoom create accepts initial mute flags", %{slug: slug, org_id: org_id, bob: ctx} do
      r = room(org_id, "quiet-join", ["alice"])

      body = Jason.encode!(%{"muted" => true})

      assert {:ok, _} =
               VFS.create(Chat, chat(slug, "/" <> r.slug <> "/members/bob.json"), body, ctx)

      {:ok, json, _} = VFS.read(Chat, chat(slug, "/" <> r.slug <> "/members/bob.json"), ctx)
      {:ok, doc} = Jason.decode(json)
      assert doc["muted"] == true
      assert doc["role"] == "member"
    end

    test "MuteRoom = write own member-file flags; others' files are :eacces", %{
      slug: slug,
      org_id: org_id,
      alice: ctx,
      bob: bob_ctx
    } do
      r = room(org_id, "mute-flags", ["alice"])
      ChatDomain.add_member(%{room_id: r.id, persona: "bob"})

      assert {:ok, _} =
               VFS.write(
                 Chat,
                 chat(slug, "/" <> r.slug <> "/members/alice.json"),
                 Jason.encode!(%{"muted" => true, "mute_unless_mentioned" => true}),
                 ctx
               )

      {:ok, json, _} = VFS.read(Chat, chat(slug, "/" <> r.slug <> "/members/alice.json"), ctx)
      {:ok, doc} = Jason.decode(json)
      assert doc["muted"] == true
      assert doc["mute_unless_mentioned"] == true

      # Bob cannot edit alice's flags.
      assert {:error, :eacces} =
               VFS.write(
                 Chat,
                 chat(slug, "/" <> r.slug <> "/members/alice.json"),
                 Jason.encode!(%{"muted" => false}),
                 bob_ctx
               )

      # Writes with no recognized keys are malformed.
      assert {:error, :eio} =
               VFS.write(Chat, chat(slug, "/" <> r.slug <> "/members/alice.json"), "{}", ctx)
    end

    test "LeaveRoom = remove own member file; the subtree closes again", %{
      slug: slug,
      org_id: org_id,
      bob: ctx
    } do
      r = room(org_id, "revolving", ["alice", "bob"])
      path = chat(slug, "/" <> r.slug <> "/members/bob.json")

      assert :ok = VFS.remove(Chat, path, ctx)
      assert {:error, :enoent} = VFS.stat(Chat, chat(slug, "/" <> r.slug <> "/record.json"), ctx)

      # Rejoin reopens it.
      assert {:ok, _} = VFS.create(Chat, path, "", ctx)
      assert {:ok, _} = VFS.stat(Chat, chat(slug, "/" <> r.slug <> "/record.json"), ctx)

      # Cannot remove another persona's membership.
      assert {:error, :eacces} =
               VFS.remove(Chat, chat(slug, "/" <> r.slug <> "/members/alice.json"), ctx)
    end
  end

  # ── reactions & pins ──────────────────────────────────────────────────────

  describe "reactions & pins" do
    test "reactions.json write adds/removes; read aggregates the room set", %{
      slug: slug,
      org_id: org_id,
      alice: ctx
    } do
      r = room(org_id, "reacts", ["alice"])
      send(r.id, "alice", "react to me")
      [msg_name] = message_names(slug, r.slug, ctx)
      path = chat(slug, "/" <> r.slug <> "/reactions.json")

      assert {:ok, _} =
               VFS.write(Chat, path, Jason.encode!(%{"target" => msg_name, "emoji" => "👍"}), ctx)

      {:ok, json, _} = VFS.read(Chat, path, ctx)
      {:ok, doc} = Jason.decode(json)
      assert [%{"persona" => "alice", "emoji" => "👍"}] = doc["reactions"]

      # Idempotent re-add.
      assert {:ok, _} =
               VFS.write(Chat, path, Jason.encode!(%{"target" => msg_name, "emoji" => "👍"}), ctx)

      {:ok, json, _} = VFS.read(Chat, path, ctx)
      assert length(Jason.decode!(json)["reactions"]) == 1

      # Remove.
      assert {:ok, _} =
               VFS.write(
                 Chat,
                 path,
                 Jason.encode!(%{"target" => msg_name, "emoji" => "👍", "remove" => true}),
                 ctx
               )

      {:ok, json, _} = VFS.read(Chat, path, ctx)
      assert Jason.decode!(json)["reactions"] == []

      # Removing an absent reaction is :enoent; a bad target is :enoent too.
      assert {:error, :enoent} =
               VFS.write(
                 Chat,
                 path,
                 Jason.encode!(%{"target" => msg_name, "emoji" => "👍", "remove" => true}),
                 ctx
               )

      assert {:error, :enoent} =
               VFS.write(
                 Chat,
                 path,
                 Jason.encode!(%{"target" => "nope.json", "emoji" => "👍"}),
                 ctx
               )

      # Missing emoji is malformed.
      assert {:error, :eio} = VFS.write(Chat, path, Jason.encode!(%{"target" => msg_name}), ctx)
    end

    test "pinned.json write toggles pins and highlights; read lists both", %{
      slug: slug,
      org_id: org_id,
      alice: ctx
    } do
      r = room(org_id, "pins", ["alice"])
      send(r.id, "alice", "pin me")
      [msg_name] = message_names(slug, r.slug, ctx)
      path = chat(slug, "/" <> r.slug <> "/pinned.json")

      assert {:ok, _} =
               VFS.write(
                 Chat,
                 path,
                 Jason.encode!(%{"target" => msg_name, "pinned" => true}),
                 ctx
               )

      {:ok, json, _} = VFS.read(Chat, path, ctx)
      {:ok, doc} = Jason.decode(json)
      assert [%{"file" => ^msg_name}] = doc["pinned"]
      assert doc["highlighted"] == []

      # The message doc reflects the flag.
      {:ok, mjson, _} = VFS.read(Chat, chat(slug, "/" <> r.slug <> "/messages/" <> msg_name), ctx)
      assert Jason.decode!(mjson)["pinned"] == true

      # Highlight via the same file; neither key is malformed; unknown target :enoent.
      assert {:ok, _} =
               VFS.write(
                 Chat,
                 path,
                 Jason.encode!(%{"target" => msg_name, "highlighted" => true}),
                 ctx
               )

      {:ok, json, _} = VFS.read(Chat, path, ctx)
      assert length(Jason.decode!(json)["highlighted"]) == 1

      assert {:error, :eio} = VFS.write(Chat, path, Jason.encode!(%{"target" => msg_name}), ctx)

      assert {:error, :enoent} =
               VFS.write(
                 Chat,
                 path,
                 Jason.encode!(%{"target" => "ghost.json", "pinned" => true}),
                 ctx
               )
    end
  end

  # ── scheduled sends ───────────────────────────────────────────────────────

  describe "scheduled sends" do
    test "ScheduleMessage = create scheduled/{send-at}.json; hidden from messages/", %{
      slug: slug,
      org_id: org_id,
      alice: ctx
    } do
      r = room(org_id, "scheduler", ["alice"])

      assert {:ok, _} =
               VFS.create(
                 Chat,
                 chat(slug, "/" <> r.slug <> "/scheduled/2099-01-01T12-00-01Z.json"),
                 "later!",
                 ctx
               )

      dir = chat(slug, "/" <> r.slug <> "/scheduled")
      assert {:ok, [entry], nil} = VFS.list(Chat, dir, nil, ctx)
      assert entry.name =~ ~r/^2099-01-01T12-00-01Z-[0-9a-f]{8}\.json$/

      # Not in messages/ until released.
      assert message_names(slug, r.slug, ctx) == []

      {:ok, json, _} = VFS.read(Chat, dir <> "/" <> entry.name, ctx)
      {:ok, doc} = Jason.decode(json)
      assert doc["content"] == "later!"
      assert doc["scheduled_for"] == "2099-01-01T12:00:01Z"
    end

    test "the Wave-4 runner move: release_due_scheduled promotes files to messages/", %{
      slug: slug,
      org_id: org_id,
      alice: ctx
    } do
      r = room(org_id, "due", ["alice"])

      assert {:ok, _} =
               VFS.create(
                 Chat,
                 chat(slug, "/" <> r.slug <> "/scheduled/2099-01-01T00-00-00Z.json"),
                 "due!",
                 ctx
               )

      # Future send-at: invisible under messages/, present under scheduled/.
      assert message_names(slug, r.slug, ctx) == []
      {:ok, [entry], nil} = VFS.list(Chat, chat(slug, "/" <> r.slug <> "/scheduled"), nil, ctx)

      # Simulate the clock reaching send-at: flip the row due, then let the
      # Wave-4 runner (`Chat.release_due_scheduled/0`) send + move it.
      scheduled = Repo.get_by!(ChatMessage, room_id: r.id)

      scheduled
      |> Ecto.Changeset.change(
        scheduled_for:
          DateTime.utc_now() |> DateTime.add(-1, :second) |> DateTime.truncate(:second)
      )
      |> Repo.update!()

      assert {:ok, 1} = ChatDomain.release_due_scheduled()

      assert [_] = message_names(slug, r.slug, ctx)
      assert {:ok, [], nil} = VFS.list(Chat, chat(slug, "/" <> r.slug <> "/scheduled"), nil, ctx)
    end

    test "scheduled remove = cancel; bad send-at is invalid params", %{
      slug: slug,
      org_id: org_id,
      alice: ctx
    } do
      r = room(org_id, "cancel", ["alice"])

      assert {:ok, _} =
               VFS.create(
                 Chat,
                 chat(slug, "/" <> r.slug <> "/scheduled/2099-01-01T00-00-00Z.json"),
                 "x",
                 ctx
               )

      {:ok, [entry], nil} = VFS.list(Chat, chat(slug, "/" <> r.slug <> "/scheduled"), nil, ctx)
      assert :ok = VFS.remove(Chat, chat(slug, "/" <> r.slug <> "/scheduled/" <> entry.name), ctx)
      assert {:ok, [], nil} = VFS.list(Chat, chat(slug, "/" <> r.slug <> "/scheduled"), nil, ctx)

      assert {:error, %Error{}} =
               VFS.create(
                 Chat,
                 chat(slug, "/" <> r.slug <> "/scheduled/not-a-time.json"),
                 "x",
                 ctx
               )
    end
  end

  # ── attachments & notifications ───────────────────────────────────────────

  describe "attachments & notifications" do
    test "Chat.Attach maps to attachments/ create; remove unattaches", %{
      slug: slug,
      org_id: org_id,
      alice: ctx
    } do
      r = room(org_id, "attaching", ["alice"])

      body = Jason.encode!(%{"url" => "https://cdn.example/a.svg", "description" => "chart"})

      assert {:ok, _} =
               VFS.create(
                 Chat,
                 chat(slug, "/" <> r.slug <> "/attachments/whatever.json"),
                 body,
                 ctx
               )

      dir = chat(slug, "/" <> r.slug <> "/attachments")
      assert {:ok, [entry], nil} = VFS.list(Chat, dir, nil, ctx)

      {:ok, json, _} = VFS.read(Chat, dir <> "/" <> entry.name, ctx)
      {:ok, doc} = Jason.decode(json)
      assert doc["url"] == "https://cdn.example/a.svg"

      assert :ok = VFS.remove(Chat, dir <> "/" <> entry.name, ctx)
      assert {:ok, [], nil} = VFS.list(Chat, dir, nil, ctx)
    end

    test "room notifications are per-principal; remove = clear; unread counts drop", %{
      slug: slug,
      org_id: org_id,
      alice: ctx
    } do
      r = room(org_id, "notify", ["alice"])

      Repo.insert!(%ChatNotification{room_id: r.id, persona: "alice", message: "hi"})
      Repo.insert!(%ChatNotification{room_id: r.id, persona: "someone-else", message: "not mine"})

      dir = chat(slug, "/" <> r.slug <> "/notifications")
      assert {:ok, [entry], nil} = VFS.list(Chat, dir, nil, ctx)

      {:ok, json, _} = VFS.read(Chat, dir <> "/" <> entry.name, ctx)
      assert Jason.decode!(json)["message"] == "hi"

      # Unread surfaces in record.json too.
      {:ok, rec, _} = VFS.read(Chat, chat(slug, "/" <> r.slug <> "/record.json"), ctx)
      assert Jason.decode!(rec)["unread"] == 1

      assert :ok = VFS.remove(Chat, dir <> "/" <> entry.name, ctx)
      assert {:ok, [], nil} = VFS.list(Chat, dir, nil, ctx)

      {:ok, rec, _} = VFS.read(Chat, chat(slug, "/" <> r.slug <> "/record.json"), ctx)
      assert Jason.decode!(rec)["unread"] == 0
    end
  end

  # ── DM rooms ──────────────────────────────────────────────────────────────

  describe "DM rooms" do
    test "DM create = :dir at dm/{pair-key}; pair key is the sorted member set", %{
      slug: slug,
      alice: ctx,
      bob: bob_ctx
    } do
      carol = key_ctx("carol")

      assert {:ok, node} = VFS.create(Chat, chat(slug, "/dm/alice+bob"), :dir, bob_ctx)
      assert node.type == :dir

      # Non-participants cannot see the pair; participants can.
      assert {:error, :enoent} = VFS.stat(Chat, chat(slug, "/dm/alice+bob"), carol)
      assert {:ok, _} = VFS.stat(Chat, chat(slug, "/dm/alice+bob"), ctx)
      assert {:ok, _} = VFS.stat(Chat, chat(slug, "/dm/alice+bob"), bob_ctx)

      # readdir dm/ shows only own DMs.
      assert {:ok, entries, nil} = VFS.list(Chat, chat(slug, "/dm"), nil, ctx)
      assert Enum.map(entries, & &1.name) == ["alice+bob"]

      assert {:ok, entries, nil} = VFS.list(Chat, chat(slug, "/dm"), nil, carol)
      assert entries == []

      # Duplicate pair key is :eexist; a degenerate pair is invalid; a pair
      # that excludes the creator is :eacces.
      assert {:error, :eexist} = VFS.create(Chat, chat(slug, "/dm/alice+bob"), :dir, ctx)
      assert {:error, %Error{}} = VFS.create(Chat, chat(slug, "/dm/alice+alice"), :dir, ctx)
      assert {:error, :eacces} = VFS.create(Chat, chat(slug, "/dm/alice+carol"), :dir, bob_ctx)
    end

    test "DM rooms carry the full room shape (record, messages)", %{slug: slug, alice: ctx} do
      assert {:ok, _} = VFS.create(Chat, chat(slug, "/dm/alice+zoe"), :dir, ctx)

      assert {:ok, _} = VFS.create(Chat, chat(slug, "/dm/alice+zoe/messages/m.json"), "psst", ctx)

      assert {:ok, rec} = VFS.stat(Chat, chat(slug, "/dm/alice+zoe/record.json"), ctx)
      assert rec.writable == true

      assert {:ok, [entry], nil} = VFS.list(Chat, chat(slug, "/dm/alice+zoe/messages"), nil, ctx)
      assert entry.name =~ ~r/\.json$/
    end
  end

  # ── wire-level semantics ──────────────────────────────────────────────────

  describe "wire-level semantics" do
    test "successful mutations bump the backend cache generation", %{
      slug: slug,
      org_id: org_id,
      alice: ctx
    } do
      r = room(org_id, "generation", ["alice"])
      gen0 = Cache.generation(Chat)

      assert {:ok, _} =
               VFS.create(Chat, chat(slug, "/" <> r.slug <> "/messages/g.json"), "gen", ctx)

      assert Cache.generation(Chat) > gen0
    end

    test "list entries carry versions; misses map to :enoent through Features.VFS", %{
      slug: slug,
      org_id: org_id,
      alice: ctx
    } do
      r = room(org_id, "wire", ["alice"])

      assert {:ok, entries, nil} = VFS.list(Chat, chat(slug, "/" <> r.slug), nil, ctx)
      assert Enum.all?(entries, &is_integer(&1.version))

      assert {:error, :enoent} =
               VFS.stat(Chat, chat(slug, "/" <> r.slug <> "/record.json"), key_ctx("stranger"))
    end
  end
end
