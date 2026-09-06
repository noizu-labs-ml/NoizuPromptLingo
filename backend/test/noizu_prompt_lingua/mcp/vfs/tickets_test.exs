defmodule NoizuPromptLingua.MCP.VFS.TicketsTest do
  @moduledoc """
  Wave 2 conformance battery for the `tickets` group's file plane
  (MCP-VFS-GROUP-MOUNTS.md §2.8), driven through the lib's server-level
  wrappers (`Noizu.MCP.Server.Features.VFS`) so errno mapping and generation
  stamping are verified on the composed surface.

  Coverage: the §2.8 op↔file table end to end — record.json as the canonical
  write target with projection merges (§3.4), server-assigned identity on
  create (KEY / canonical file names returned in xattrs), cursor-paginated
  TicketList readdir with the §3.2 `_all/` full set, feed-log readdir
  semantics, TRP-stubbed item flows, deletion unexposed (§3.5), and the §1.3
  gate matrix (excluded ⇒ :enoent, disabled ⇒ writable:false + :eacces).
  """

  use NoizuPromptLingua.DataCase, async: false

  alias Noizu.MCP.Server.Features.VFS
  alias Noizu.MCP.VFS.Cache
  alias Noizu.MCP.{Ctx, Error}
  alias NoizuPromptLingua.Domains.{Links, Tickets}
  alias NoizuPromptLingua.Domains.Tickets.{Definitions, Queues}
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCP.VFS.Tickets, as: Backend
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Users.User
  alias NoizuPromptLingua.Services.{Attach, Comment, Watch}
  alias NoizuPromptLingua.TRP.Cache, as: TrpCache
  alias NoizuPromptLingua.TRP.TestStub

  @org "vfs-w2-tickets"

  # `2026-09-05T12-00-01Z-{short8}.json` (§1.1 filesystem-safe ts names).
  @feed_name ~r/^\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}Z-[0-9a-fA-F-]{8}(-\d+)?\.json$/

  setup do
    TrpCache.clear()
    TestStub.reset()

    slug = "#{@org}-#{System.unique_integer([:positive])}"
    # The org slug→id cache is Redis-backed (1h TTL) and slugs repeat across
    # VM boots — drop any stale entry so resolution hits the stub fresh.
    NoizuPromptLingua.Cache.invalidate(NoizuPromptLingua.Cache.slug_key(slug))
    org_id = TestStub.seed_org(Ecto.UUID.generate(), slug, "VFS W2 Tickets Org")

    ctx = key_ctx(%{"groups" => %{"tickets" => %{}}})

    on_exit(fn -> Cache.purge(Backend) end)

    %{slug: slug, org_id: org_id, ctx: ctx}
  end

  # ── fixtures ──────────────────────────────────────────────────────────────

  defp key_ctx(
         config,
         session \\ "sess-" <> Integer.to_string(System.unique_integer([:positive]))
       ) do
    uniq = System.unique_integer([:positive])

    user =
      %User{
        id: Ecto.UUID.generate(),
        email: "vfstkt-#{uniq}@example.com",
        user_name: "vfstkt#{uniq}",
        handle: "vfstkt#{uniq}",
        status: :active
      }
      |> Repo.insert!()

    {:ok, key, _raw} =
      MCPApiKeys.generate_api_key(user.id, "vfs-w2-tickets", toolset_config: config)

    %Ctx{
      server: NoizuPromptLingua.MCP.VFSServer,
      session_id: session,
      assigns: %{auth_claims: %{"api_key_id" => key.id, "sub" => user.id}}
    }
  end

  defp seed_ticket(org_id, attrs), do: TestStub.seed_item(org_id, Map.new(attrs))

  defp seed_ticket(org_id), do: TestStub.seed_item(org_id, %{})

  # Mirrors the backend's canonical server-assigned name (`{ts}-{short8}.json`).
  defp comment_name(comment) do
    ts =
      comment.inserted_at
      |> DateTime.truncate(:second)
      |> DateTime.to_iso8601()
      |> String.replace(":", "-")

    "#{ts}-#{binary_part(comment.id, 0, 8)}.json"
  end

  defp tickets_root(slug), do: "/tobor/#{slug}/tickets"

  defp read_json!(backend, path, ctx) do
    {:ok, json, _version} = VFS.read(backend, path, ctx)
    Jason.decode!(json)
  end

  # ── stat: namespace mapping ───────────────────────────────────────────────

  test "stat/3 maps the tickets namespace", %{slug: slug, org_id: org_id, ctx: ctx} do
    assert {:ok, root} = VFS.stat(Backend, tickets_root(slug), ctx)
    assert root.type == :dir

    for reserved <- ~w(_all _fields _queues _types) do
      assert {:ok, dir} = VFS.stat(Backend, tickets_root(slug) <> "/#{reserved}", ctx)
      assert dir.type == :dir
    end

    ticket = seed_ticket(org_id, title: "Mapped", key: "MAP-001")
    key_dir = tickets_root(slug) <> "/#{ticket.key}"

    assert {:ok, dir} = VFS.stat(Backend, key_dir, ctx)
    assert dir.type == :dir

    assert {:ok, record} = VFS.stat(Backend, key_dir <> "/record.json", ctx)
    assert record.type == :file
    assert record.size > 0
    assert record.writable == true

    for child <- ~w(comments attachments fields feed.log) do
      assert {:ok, d} = VFS.stat(Backend, "#{key_dir}/#{child}", ctx)
      assert d.type == :dir
    end

    for child <- ~w(watchers.json links.json) do
      assert {:ok, f} = VFS.stat(Backend, "#{key_dir}/#{child}", ctx)
      assert f.type == :file
    end
  end

  test "stat/3 on unknown keys, malformed segments and deep paths is :enoent", %{
    slug: slug,
    org_id: org_id,
    ctx: ctx
  } do
    seed_ticket(org_id, key: "KNW-001")

    assert {:error, :enoent} = VFS.stat(Backend, tickets_root(slug) <> "/KNW-999", ctx)
    # Not the human-key grammar ⇒ not a ticket path at all.
    assert {:error, :enoent} = VFS.stat(Backend, tickets_root(slug) <> "/garbage", ctx)
    assert {:error, :enoent} = VFS.stat(Backend, tickets_root(slug) <> "/_new", ctx)

    assert {:error, :enoent} =
             VFS.stat(Backend, tickets_root(slug) <> "/KNW-001/record.json.bak", ctx)

    # Traversal is rejected outright (stable-key segments only).
    assert {:error, :enoent} = VFS.stat(Backend, tickets_root(slug) <> "/../wiki/x.md", ctx)
  end

  test "xattr/3 exposes ticket identity on the KEY dir and record.json", %{
    slug: slug,
    org_id: org_id,
    ctx: ctx
  } do
    ticket = seed_ticket(org_id, key: "XAT-001", status: "open")

    assert {:ok, xattrs} = VFS.xattr(Backend, tickets_root(slug) <> "/#{ticket.key}", ctx)
    assert xattrs["key"] == "XAT-001"
    assert xattrs["id"] == ticket.id
    assert xattrs["status"] == "open"

    assert {:ok, _} = VFS.xattr(Backend, tickets_root(slug) <> "/#{ticket.key}/record.json", ctx)
    assert {:ok, xattrs} = VFS.xattr(Backend, tickets_root(slug) <> "/_queues", ctx)
    assert xattrs == %{}
  end

  # ── list: TicketList readdir + pagination ─────────────────────────────────

  test "list/4 enumerates reserved dirs plus ticket KEY dirs", %{
    slug: slug,
    org_id: org_id,
    ctx: ctx
  } do
    a = seed_ticket(org_id, key: "LST-001")
    b = seed_ticket(org_id, key: "LST-002")

    {:ok, entries, nil} = VFS.list(Backend, tickets_root(slug), nil, ctx)
    names = Enum.map(entries, & &1.name)

    for reserved <- ~w(_all _fields _queues _types) do
      assert reserved in names
    end

    assert a.key in names and b.key in names

    # KEY dir readdir: the fixed §2.8 projection shape.
    {:ok, children, nil} = VFS.list(Backend, tickets_root(slug) <> "/#{a.key}", nil, ctx)

    assert Enum.map(children, & &1.name) == [
             "record.json",
             "comments",
             "attachments",
             "fields",
             "watchers.json",
             "links.json",
             "feed.log"
           ]
  end

  test "list/4 pages the ticket listing with opaque cursors (§3.2)", %{
    slug: slug,
    org_id: org_id,
    ctx: ctx
  } do
    for i <- 1..60 do
      seed_ticket(org_id, key: "PGN-#{String.pad_leading(Integer.to_string(i), 4, "0")}")
    end

    {:ok, page1, cursor} = VFS.list(Backend, tickets_root(slug), nil, ctx)
    assert length(page1) == 50
    assert is_binary(cursor)

    {:ok, page2, nil} = VFS.list(Backend, tickets_root(slug), cursor, ctx)
    assert length(page2) == 14

    names = (page1 ++ page2) |> Enum.map(& &1.name) |> Enum.frequencies()
    assert names |> Map.values() |> Enum.all?(&(&1 == 1)), "pages must not overlap"
    assert Enum.count(names, fn {name, _} -> String.starts_with?(name, "PGN-") end) == 60

    # `_all/` carries the same full set — window vs full listing (§3.2).
    {:ok, all1, cursor2} = VFS.list(Backend, tickets_root(slug) <> "/_all", nil, ctx)
    assert length(all1) == 50
    {:ok, all2, nil} = VFS.list(Backend, tickets_root(slug) <> "/_all", cursor2, ctx)
    assert length(all2) == 10

    # A stale/foreign cursor is rejected, not mis-paginated.
    assert {:error, %Error{}} = VFS.list(Backend, tickets_root(slug), "bogus-cursor", ctx)
  end

  test "list/4 projects comments, attachments and custom fields", %{
    slug: slug,
    org_id: org_id,
    ctx: ctx
  } do
    ticket = seed_ticket(org_id, key: "PRJ-001", custom_fields: %{"story_points" => 5})
    key_dir = tickets_root(slug) <> "/#{ticket.key}"

    {:ok, comment} = Comment.add("ticket", ticket.id, %{content: "first"})

    {:ok, _att} =
      Attach.add("ticket", ticket.id, %{artifact_type: "url", url: "https://x.example"})

    {:ok, comments, nil} = VFS.list(Backend, key_dir <> "/comments", nil, ctx)
    assert [%{name: name, type: :file}] = comments
    assert name == comment_name(comment)

    {:ok, attachments, nil} = VFS.list(Backend, key_dir <> "/attachments", nil, ctx)
    assert [%{name: att_name, type: :file}] = attachments
    assert att_name =~ "-"

    {:ok, fields, nil} = VFS.list(Backend, key_dir <> "/fields", nil, ctx)
    assert [%{name: "story_points.json", type: :file}] = fields
  end

  # ── read: record.json + projections ───────────────────────────────────────

  test "read/3 serves the canonical record.json (TicketGet over TRP)", %{
    slug: slug,
    org_id: org_id,
    ctx: ctx
  } do
    ticket =
      seed_ticket(org_id, key: "RED-001", title: "Read me", status: "open", priority: "high")

    path = tickets_root(slug) <> "/#{ticket.key}/record.json"

    assert {:ok, node} = VFS.stat(Backend, path, ctx)
    assert {:ok, content, version} = VFS.read(Backend, path, ctx)
    assert version == node.version

    record = Jason.decode!(content)
    assert record["key"] == "RED-001"
    assert record["title"] == "Read me"
    assert record["status"] == "open"
    assert record["priority"] == "high"

    # Case-insensitive human-key addressing, as on the MCP surface.
    assert {:ok, _, _} = VFS.read(Backend, tickets_root(slug) <> "/red-001/record.json", ctx)
  end

  test "read/3 serves watchers.json, links.json, comments and field projections", %{
    slug: slug,
    org_id: org_id,
    ctx: ctx
  } do
    ticket = seed_ticket(org_id, key: "PRJ2-01", custom_fields: %{"story_points" => 8})
    other = seed_ticket(org_id, key: "PRJ2-02")
    key_dir = tickets_root(slug) <> "/#{ticket.key}"

    {:ok, _} = Watch.watch("ticket", ticket.id, "alice", nil)
    {:ok, _} = Tickets.link(ticket.id, other.id, "blocks")
    {:ok, _} = Links.link_entity(ticket.id, "customer_persona", Ecto.UUID.generate())
    {:ok, comment} = Comment.add("ticket", ticket.id, %{content: "hello", author: "bob"})

    assert %{"personas" => %{"alice" => %{"filter" => nil}}} =
             read_json!(Backend, key_dir <> "/watchers.json", ctx)

    links = read_json!(Backend, key_dir <> "/links.json", ctx)
    other_id = other.id
    ticket_id = ticket.id

    assert [%{"target" => ^other_id, "type" => "blocks"}] = links["outgoing"]

    assert [%{"source" => ^ticket_id, "type" => "blocks"}] =
             read_json!(Backend, tickets_root(slug) <> "/PRJ2-02/links.json", ctx)["incoming"]

    assert [%{"entity_type" => "customer_persona"}] = links["entities"]

    assert %{"content" => "hello", "author" => "bob"} =
             read_json!(Backend, "#{key_dir}/comments/#{comment_name(comment)}", ctx)

    assert 8 = read_json!(Backend, key_dir <> "/fields/story_points.json", ctx)
  end

  test "read/3 on a dir is :eisdir, on unknown paths :enoent", %{
    slug: slug,
    org_id: org_id,
    ctx: ctx
  } do
    ticket = seed_ticket(org_id, key: "ERR-001")
    key_dir = tickets_root(slug) <> "/#{ticket.key}"

    assert {:error, :eisdir} = VFS.read(Backend, key_dir, ctx)
    assert {:error, :eisdir} = VFS.read(Backend, key_dir <> "/comments", ctx)
    assert {:error, :enoent} = VFS.read(Backend, key_dir <> "/comments/nope.json", ctx)
    assert {:error, :enoent} = VFS.read(Backend, key_dir <> "/fields/nope.json", ctx)
    assert {:error, :enoent} = VFS.read(Backend, tickets_root(slug) <> "/_queues/nope.json", ctx)
  end

  # ── feed.log readdir semantics ────────────────────────────────────────────

  test "feed.log lists per-entry files synthesized from real activity", %{
    slug: slug,
    org_id: org_id,
    ctx: ctx
  } do
    now = DateTime.utc_now()

    ticket =
      seed_ticket(org_id,
        key: "FED-001",
        title: "Feed me",
        inserted_at: DateTime.add(now, -10, :second),
        updated_at: DateTime.add(now, -5, :second)
      )

    key_dir = tickets_root(slug) <> "/#{ticket.key}"

    {:ok, comment} = Comment.add("ticket", ticket.id, %{content: "one\ntwo"})

    {:ok, _} =
      Attach.add("ticket", ticket.id, %{artifact_type: "git_branch", git_branch: "feat/x"})

    {:ok, entries, nil} = VFS.list(Backend, key_dir <> "/feed.log", nil, ctx)
    names = Enum.map(entries, & &1.name)

    # created + updated + comment + attachment — one file per event.
    assert length(names) == 4
    assert Enum.all?(names, &Regex.match?(@feed_name, &1))

    # Newest first.
    assert List.first(names) == comment_name(comment)

    # Each entry reads back as an event document.
    {:ok, entry, _} = VFS.read(Backend, "#{key_dir}/feed.log/#{List.first(names)}", ctx)
    doc = Jason.decode!(entry)
    assert doc["kind"] == "comment.created"
    assert doc["ref"] == List.first(names)
    assert doc["summary"] == "one"

    kinds =
      for name <- names do
        {:ok, raw, _} = VFS.read(Backend, "#{key_dir}/feed.log/#{name}", ctx)
        Jason.decode!(raw)["kind"]
      end

    assert Enum.sort(kinds) ==
             Enum.sort(~w(ticket.created ticket.updated comment.created attachment.added))

    # stat + unknown entry
    assert {:ok, %{type: :file}} =
             VFS.stat(Backend, "#{key_dir}/feed.log/#{List.first(names)}", ctx)

    assert {:error, :enoent} = VFS.stat(Backend, key_dir <> "/feed.log/nope.json", ctx)
    assert {:error, :enoent} = VFS.read(Backend, key_dir <> "/feed.log/nope.json", ctx)
    assert {:error, :eisdir} = VFS.read(Backend, key_dir <> "/feed.log", ctx)
  end

  test "queue feed.log projects its board's tickets (QueueFeed)", %{
    slug: slug,
    org_id: org_id,
    ctx: ctx
  } do
    {:ok, board} =
      Queues.create(%{
        name: "Feed Board",
        slug: "feed-board",
        methodology: "kanban",
        organization_id: org_id
      })

    seed_ticket(org_id, key: "QFD-001", title: "Queued", queue_id: board.id)
    seed_ticket(org_id, key: "QFD-002", title: "Unqueued")

    feed_dir = tickets_root(slug) <> "/_queues/feed-board.feed.log"

    assert {:ok, dir} = VFS.stat(Backend, feed_dir, ctx)
    assert dir.type == :dir

    {:ok, entries, nil} = VFS.list(Backend, feed_dir, nil, ctx)
    assert length(entries) == 1

    {:ok, raw, _} = VFS.read(Backend, "#{feed_dir}/#{hd(entries).name}", ctx)

    assert %{"kind" => "ticket.updated", "ref" => "QFD-001", "summary" => "Queued"} =
             Jason.decode!(raw)

    assert {:error, :enoent} =
             VFS.list(Backend, tickets_root(slug) <> "/_queues/nope.feed.log", nil, ctx)

    assert {:error, :enoent} = VFS.read(Backend, tickets_root(slug) <> "/_queues/nope.json", ctx)
  end

  # ── create: server-assigned identity ──────────────────────────────────────

  test "create on _new/record.json assigns the KEY and returns the real path", %{
    slug: slug,
    org_id: org_id,
    ctx: ctx
  } do
    payload =
      Jason.encode!(%{
        "title" => "Filed from the mount",
        "description" => "via VFS",
        "ticket_type" => "bug",
        "priority" => "high"
      })

    assert {:ok, node} =
             VFS.create(Backend, tickets_root(slug) <> "/_new/record.json", payload, ctx)

    assert node.xattrs["key"] =~ ~r/^[A-Z0-9]{2,6}-\d{3,}$/
    assert node.xattrs["path"] == "#{tickets_root(slug)}/#{node.xattrs["key"]}/record.json"
    assert is_binary(node.xattrs["id"])

    # The assigned path is immediately addressable (TRP flow).
    assert {:ok, _} = VFS.stat(Backend, node.xattrs["path"], ctx)

    assert %{"title" => "Filed from the mount", "ticket_type" => "bug"} =
             read_json!(Backend, node.xattrs["path"], ctx)

    # Creating at the now-real path collides.
    assert {:error, :eexist} = VFS.create(Backend, node.xattrs["path"], payload, ctx)
  end

  test "create rejects malformed payloads with :eio", %{slug: slug, ctx: ctx} do
    assert {:error, :eio} =
             VFS.create(Backend, tickets_root(slug) <> "/_new/record.json", "not json", ctx)

    assert {:error, :eio} =
             VFS.create(
               Backend,
               tickets_root(slug) <> "/_new/record.json",
               ~s({"description": "no title"}),
               ctx
             )
  end

  test "create appends comments and attachments (TicketComment / TicketAttach)", %{
    slug: slug,
    org_id: org_id,
    ctx: ctx
  } do
    ticket = seed_ticket(org_id, key: "CMT-001")
    key_dir = tickets_root(slug) <> "/#{ticket.key}"

    assert {:ok, node} =
             VFS.create(
               Backend,
               key_dir <> "/comments/my-note.json",
               Jason.encode!(%{"content" => "a comment", "author" => "me"}),
               ctx
             )

    # Canonical name is server-assigned and returned in xattrs (§2.8).
    assert node.xattrs["name"] =~ @feed_name
    assert node.xattrs["path"] == "tickets/#{ticket.key}/comments/#{node.xattrs["name"]}"

    comments = Comment.list("ticket", ticket.id)
    assert [%{content: "a comment"}] = comments

    assert {:ok, _node} = VFS.stat(Backend, key_dir <> "/comments/#{node.xattrs["name"]}", ctx)
    assert {:error, :enoent} = VFS.stat(Backend, key_dir <> "/comments/my-note.json", ctx)

    assert {:ok, _att} =
             VFS.create(
               Backend,
               key_dir <> "/attachments/spec-url.json",
               Jason.encode!(%{"artifact_type" => "url", "url" => "https://example.com/spec"}),
               ctx
             )

    assert [%{artifact_type: "url"}] = Attach.list("ticket", ticket.id)

    # Unsafe names are not addresses at all.
    assert {:error, :enoent} =
             VFS.create(Backend, key_dir <> "/comments/../evil.json", "{}", ctx)
  end

  test "create maps queues, type and field definitions", %{slug: slug, org_id: org_id, ctx: ctx} do
    assert {:ok, board_node} =
             VFS.create(
               Backend,
               tickets_root(slug) <> "/_queues/dev.json",
               Jason.encode!(%{"name" => "Dev", "methodology" => "scrum"}),
               ctx
             )

    board = Queues.get("dev", org_id, nil)
    assert board.name == "Dev"
    assert board_node.xattrs["id"] == board.id
    assert length(board.stages) == 4

    assert {:error, :eexist} =
             VFS.create(Backend, tickets_root(slug) <> "/_queues/dev.json", "{}", ctx)

    assert {:ok, type_node} =
             VFS.create(
               Backend,
               tickets_root(slug) <> "/_types/bug.json",
               Jason.encode!(%{"name" => "Bug", "status_workflow" => ["open", "done"]}),
               ctx
             )

    assert %{"name" => "Bug"} = read_json!(Backend, tickets_root(slug) <> "/_types/bug.json", ctx)
    assert type_node.xattrs["id"] == Definitions.resolve_type(org_id, nil, "bug").id

    assert {:error, :eexist} =
             VFS.create(
               Backend,
               tickets_root(slug) <> "/_types/bug.json",
               ~s({"name": "Bug"}),
               ctx
             )

    assert {:ok, _field_node} =
             VFS.create(
               Backend,
               tickets_root(slug) <> "/_fields/story_points.json",
               Jason.encode!(%{"label" => "Story Points", "field_type" => "number"}),
               ctx
             )

    assert %{"field_type" => "number"} =
             read_json!(Backend, tickets_root(slug) <> "/_fields/story_points.json", ctx)
  end

  # ── write: record.json is the canonical merge target (§3.4) ──────────────

  test "write record.json merges top-level fields (TicketUpdate; status rides edits)", %{
    slug: slug,
    org_id: org_id,
    ctx: ctx
  } do
    ticket =
      seed_ticket(org_id, key: "WRT-001", title: "Original", status: "open", priority: "low")

    path = tickets_root(slug) <> "/#{ticket.key}/record.json"

    assert {:ok, _node} =
             VFS.write(
               Backend,
               path,
               Jason.encode!(%{"status" => "in_progress", "priority" => "high"}),
               ctx
             )

    record = read_json!(Backend, path, ctx)
    assert record["status"] == "in_progress"
    assert record["priority"] == "high"
    # Merge semantics: fields absent from the write are untouched.
    assert record["title"] == "Original"

    assert {:error, :eio} = VFS.write(Backend, path, "not json", ctx)
  end

  test "write fields/{slug}.json merges the custom_fields projection", %{
    slug: slug,
    org_id: org_id,
    ctx: ctx
  } do
    ticket = seed_ticket(org_id, key: "FLD-001", custom_fields: %{"kept" => "yes"})
    path = tickets_root(slug) <> "/#{ticket.key}/fields/story_points.json"

    assert {:ok, _} = VFS.write(Backend, path, "5", ctx)

    assert 5 = read_json!(Backend, path, ctx)
    record = read_json!(Backend, tickets_root(slug) <> "/#{ticket.key}/record.json", ctx)
    assert record["custom_fields"] == %{"kept" => "yes", "story_points" => 5}
  end

  test "write watchers.json reconciles the watch set (TicketWatch)", %{
    slug: slug,
    org_id: org_id,
    ctx: ctx
  } do
    ticket = seed_ticket(org_id, key: "WCH-001")
    path = tickets_root(slug) <> "/#{ticket.key}/watchers.json"

    {:ok, _} = Watch.watch("ticket", ticket.id, "carol", nil)

    assert {:ok, _} =
             VFS.write(Backend, path, Jason.encode!(%{"personas" => ["alice", "bob"]}), ctx)

    assert %{"personas" => personas} = read_json!(Backend, path, ctx)
    # Full-set reconcile: carol (seeded before the write) falls out immediately.
    assert Map.keys(personas) |> Enum.sort() == ["alice", "bob"]

    # Full-set reconcile: carol (seeded) falls out, filters land on the new set.
    assert {:ok, _} =
             VFS.write(
               Backend,
               path,
               Jason.encode!(%{"personas" => %{"alice" => %{"filter" => "urgent"}}}),
               ctx
             )

    # String filters are stored normalized as substring maps (schema convention).
    assert %{
             "personas" => %{
               "alice" => %{"filter" => %{"type" => "substring", "value" => "urgent"}}
             }
           } =
             read_json!(Backend, path, ctx)

    refute Watch.watching?("ticket", ticket.id, "carol")

    # Single-op form.
    assert {:ok, _} =
             VFS.write(
               Backend,
               path,
               Jason.encode!(%{"persona" => "alice", "action" => "unwatch"}),
               ctx
             )

    assert %{"personas" => %{}} = read_json!(Backend, path, ctx)
  end

  test "write links.json drives TicketLink/Unlink and typed entity links", %{
    slug: slug,
    org_id: org_id,
    ctx: ctx
  } do
    ticket = seed_ticket(org_id, key: "LNK-001")
    other = seed_ticket(org_id, key: "LNK-002")
    path = tickets_root(slug) <> "/#{ticket.key}/links.json"

    assert {:ok, _} =
             VFS.write(
               Backend,
               path,
               Jason.encode!(%{"link" => %{"target" => "LNK-002", "type" => "blocks"}}),
               ctx
             )

    other_id = other.id

    assert [%{"target" => ^other_id, "type" => "blocks"}] =
             read_json!(Backend, path, ctx)["outgoing"]

    # Duplicate link is a collision.
    assert {:error, :eexist} =
             VFS.write(
               Backend,
               path,
               Jason.encode!(%{"link" => %{"target" => "LNK-002", "type" => "blocks"}}),
               ctx
             )

    assert {:error, :enoent} =
             VFS.write(Backend, path, Jason.encode!(%{"link" => %{"target" => "LNK-999"}}), ctx)

    entity_id = Ecto.UUID.generate()

    assert {:ok, _} =
             VFS.write(
               Backend,
               path,
               Jason.encode!(%{
                 "link_entity" => %{"entity_type" => "customer_persona", "entity_id" => entity_id}
               }),
               ctx
             )

    assert [%{"entity_id" => ^entity_id}] = read_json!(Backend, path, ctx)["entities"]

    assert {:ok, _} =
             VFS.write(
               Backend,
               path,
               Jason.encode!(%{
                 "unlink_entity" => %{
                   "entity_type" => "customer_persona",
                   "entity_id" => entity_id
                 }
               }),
               ctx
             )

    assert [] = read_json!(Backend, path, ctx)["entities"]

    assert {:ok, _} =
             VFS.write(
               Backend,
               path,
               Jason.encode!(%{"unlink" => %{"target" => "LNK-002", "type" => "blocks"}}),
               ctx
             )

    assert %{outgoing: [], incoming: []} = Tickets.get_links(ticket.id)
  end

  test "write drives Definition/FieldDefinition updates by slug", %{
    slug: slug,
    org_id: org_id,
    ctx: ctx
  } do
    TestStub.seed_type(org_id, %{slug: "task", name: "Task"})
    TestStub.seed_field(org_id, %{slug: "severity", label: "Severity"})

    assert {:ok, _} =
             VFS.write(
               Backend,
               tickets_root(slug) <> "/_types/task.json",
               Jason.encode!(%{"name" => "Task (renamed)"}),
               ctx
             )

    assert %{"name" => "Task (renamed)"} =
             read_json!(Backend, tickets_root(slug) <> "/_types/task.json", ctx)

    assert {:ok, _} =
             VFS.write(
               Backend,
               tickets_root(slug) <> "/_fields/severity.json",
               Jason.encode!(%{"label" => "Sev"}),
               ctx
             )

    assert %{"label" => "Sev"} =
             read_json!(Backend, tickets_root(slug) <> "/_fields/severity.json", ctx)

    assert {:error, :enoent} =
             VFS.write(Backend, tickets_root(slug) <> "/_types/nope.json", ~s({"name": "x"}), ctx)
  end

  test "write on dirs is :eisdir, on unmapped paths :enosys", %{
    slug: slug,
    org_id: org_id,
    ctx: ctx
  } do
    ticket = seed_ticket(org_id, key: "WSE-001")
    key_dir = tickets_root(slug) <> "/#{ticket.key}"

    assert {:error, :eisdir} = VFS.write(Backend, key_dir, "x", ctx)
    assert {:error, :eisdir} = VFS.write(Backend, key_dir <> "/comments", "x", ctx)
    assert {:error, :enosys} = VFS.write(Backend, key_dir <> "/comments/x.json", "x", ctx)

    assert {:error, :enosys} =
             VFS.write(Backend, tickets_root(slug) <> "/_queues/dev.json", "x", ctx)
  end

  # ── remove: definitions only; deletion stays unexposed (§3.5) ────────────

  test "remove serves type/field definitions and nothing else", %{
    slug: slug,
    org_id: org_id,
    ctx: ctx
  } do
    TestStub.seed_type(org_id, %{slug: "spike", name: "Spike"})
    TestStub.seed_field(org_id, %{slug: "tmp", label: "Tmp"})
    ticket = seed_ticket(org_id, key: "RMV-001")
    key_dir = tickets_root(slug) <> "/#{ticket.key}"

    assert :ok = VFS.remove(Backend, tickets_root(slug) <> "/_types/spike.json", ctx)
    assert {:error, :enoent} = VFS.stat(Backend, tickets_root(slug) <> "/_types/spike.json", ctx)
    assert :ok = VFS.remove(Backend, tickets_root(slug) <> "/_fields/tmp.json", ctx)

    assert {:error, :enoent} =
             VFS.remove(Backend, tickets_root(slug) <> "/_types/spike.json", ctx)

    # §3.5: ticket deletion is absent from the tool surface and stays absent.
    assert {:error, :enosys} = VFS.remove(Backend, tickets_root(slug) <> "/#{ticket.key}", ctx)
    assert {:error, :enosys} = VFS.remove(Backend, key_dir <> "/record.json", ctx)
    assert {:error, :enosys} = VFS.remove(Backend, key_dir <> "/watchers.json", ctx)
    assert {:error, :enosys} = VFS.remove(Backend, tickets_root(slug) <> "/_queues/dev.json", ctx)

    # ...and the ticket itself survives.
    assert {:ok, _} = VFS.stat(Backend, key_dir, ctx)
  end

  # ── gating (§1.3) ─────────────────────────────────────────────────────────

  test "a principal without the tickets group sees no subtree (no existence leak)", %{
    slug: slug,
    org_id: org_id
  } do
    ctx = key_ctx(%{"groups" => %{"wiki" => %{}}})
    seed_ticket(org_id, key: "GTE-001")
    key_dir = tickets_root(slug) <> "/GTE-001"

    assert {:error, :enoent} = VFS.stat(Backend, tickets_root(slug), ctx)
    assert {:error, :enoent} = VFS.list(Backend, tickets_root(slug), nil, ctx)
    assert {:error, :enoent} = VFS.read(Backend, key_dir <> "/record.json", ctx)
    assert {:error, :enoent} = VFS.write(Backend, key_dir <> "/record.json", "{}", ctx)

    assert {:error, :enoent} =
             VFS.create(Backend, tickets_root(slug) <> "/_new/record.json", "{}", ctx)

    assert {:error, :enoent} = VFS.remove(Backend, key_dir <> "/record.json", ctx)
  end

  test "a foreign org's tickets subtree is :enoent", %{slug: slug, org_id: org_id, ctx: ctx} do
    seed_ticket(org_id, key: "GTF-001")
    other = "other-org-#{System.unique_integer([:positive])}"

    assert {:error, :enoent} = VFS.stat(Backend, tickets_root(other), ctx)
    assert {:error, :enoent} = VFS.list(Backend, tickets_root(other), nil, ctx)

    assert {:error, :enoent} =
             VFS.read(Backend, tickets_root(other) <> "/GTF-001/record.json", ctx)
  end

  test "an included-but-disabled group lists read-only; mutations are :eacces", %{
    slug: slug,
    org_id: org_id
  } do
    ctx = key_ctx(%{"groups" => %{"tickets" => %{"disabled" => true}}})
    ticket = seed_ticket(org_id, key: "GTD-001")
    key_dir = tickets_root(slug) <> "/#{ticket.key}"

    assert {:ok, dir} = VFS.stat(Backend, key_dir, ctx)
    assert dir.type == :dir
    assert {:ok, _, _} = VFS.read(Backend, key_dir <> "/record.json", ctx)
    assert {:ok, _, _} = VFS.list(Backend, tickets_root(slug), nil, ctx)

    assert {:error, :eacces} =
             VFS.write(Backend, key_dir <> "/record.json", ~s({"status": "done"}), ctx)

    assert {:error, :eacces} =
             VFS.create(Backend, tickets_root(slug) <> "/_new/record.json", "{}", ctx)

    assert {:error, :eacces} = VFS.remove(Backend, key_dir <> "/record.json", ctx)
  end

  # ── TRP failure surface ───────────────────────────────────────────────────

  test "a TRP backend failure maps to :eio on writes", %{slug: slug, org_id: org_id, ctx: ctx} do
    ticket = seed_ticket(org_id, key: "TRP-001")
    path = tickets_root(slug) <> "/#{ticket.key}/record.json"

    # Warm every cached leg (principal org list, slug→id, item lookup) so the
    # injected failure lands on the update request itself.
    assert {:ok, _} = VFS.write(Backend, path, ~s({"status": "open"}), ctx)
    assert {:ok, _, _} = VFS.read(Backend, path, ctx)

    # The client retries 5xx twice (3 attempts total) — exhaust it.
    for _ <- 1..3, do: TestStub.queue_response({500, %{"error" => "backend boom"}})

    assert {:error, :eio} = VFS.write(Backend, path, ~s({"status": "done"}), ctx)
  end

  # ── wire-level versioning ─────────────────────────────────────────────────

  test "versions embed the backend cache generation; writes bump it", %{
    slug: slug,
    org_id: org_id,
    ctx: ctx
  } do
    ticket = seed_ticket(org_id, key: "VER-001")
    path = tickets_root(slug) <> "/#{ticket.key}/record.json"

    gen = Cache.generation(Backend)
    assert {:ok, node} = VFS.stat(Backend, path, ctx)
    assert node.version > gen

    assert {:ok, _} = VFS.write(Backend, path, ~s({"status": "done"}), ctx)
    assert Cache.generation(Backend) > gen
  end
end
