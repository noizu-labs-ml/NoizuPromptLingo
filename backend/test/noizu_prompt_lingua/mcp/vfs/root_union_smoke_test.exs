defmodule NoizuPromptLingua.MCP.VFS.RootUnionSmokeTest do
  @moduledoc """
  Round-4 integration smoke (merge gate): the union of ALL delivered group
  backends serves /vfs through `Root`.

  For every entry in `Root.@group_backends` this suite proves, through the
  lib's wire facade (`Noizu.MCP.Server.Features.VFS`), that
    * the org readdir lists the group dir (gate-driven listing ⊆ wired map), and
    * at least one WRITE (create) and one READ round-trip on that group's
      subtree lands on the real backend — not the Wave 0 placeholder.

  Read-only planes (unicode) assert the wired backend's deliberate `:enosys`
  mutation contract instead of a write round-trip. Fixtures mirror each
  backend's own conformance suite, reduced to the minimal happy path.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias Noizu.MCP.Server.Features.VFS
  alias Noizu.MCP.VFS.Cache
  alias Noizu.MCP.Ctx
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCP.VFS.Root
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Users.User
  alias NoizuPromptLingua.TRP.Cache, as: TrpCache
  alias NoizuPromptLingua.TRP.TestStub

  @groups ~w(artifacts campaigns chat customers instructions market memory notifications pubsub review sessions tickets unicode)

  setup do
    TrpCache.clear()
    TestStub.reset()

    uniq = System.unique_integer([:positive])
    handle = "vfsunion#{uniq}"
    slug = "vfs-union-#{uniq}"

    # The org slug→id cache is Redis-backed — drop stale entries for reuse.
    NoizuPromptLingua.Cache.invalidate(NoizuPromptLingua.Cache.slug_key(slug))

    user =
      %User{
        id: Ecto.UUID.generate(),
        email: "#{handle}@example.com",
        user_name: handle,
        handle: handle,
        status: :active
      }
      |> Repo.insert!()

    # Real, user-owned org (entity backends gate on ownership) + matching TRP
    # stub org so slug resolution and visibility agree everywhere.
    {:ok, org} =
      NoizuPromptLingua.Organizations.create_organization_with_owner(
        %{"slug" => slug, "name" => "VFS Union Org"},
        user.id
      )

    TestStub.seed_org(org.id, org.slug, org.name)

    ctx = key_ctx(user, %{"groups" => Map.new(@groups, &{&1, %{}})})

    on_exit(fn -> Cache.purge(Root) end)

    %{slug: slug, org_id: org.id, handle: handle, ctx: ctx}
  end

  defp key_ctx(user, config) do
    {:ok, key, _raw} =
      MCPApiKeys.generate_api_key(user.id, "vfs-union", toolset_config: config)

    %Ctx{
      server: NoizuPromptLingua.MCP.VFSServer,
      session_id: "sess-" <> Integer.to_string(System.unique_integer([:positive])),
      assigns: %{
        auth_claims: %{"api_key_id" => key.id, "sub" => user.id, "handle" => user.handle}
      }
    }
  end

  defp base(slug, group), do: "/tobor/#{slug}/#{group}"

  # ── readdir: every implemented group dir shows under the org ──────────────

  test "readdir /tobor/{org} lists every wired group dir", %{slug: slug, ctx: ctx} do
    assert {:ok, entries, nil} = VFS.list(Root, "/tobor/#{slug}", nil, ctx)
    names = Enum.map(entries, & &1.name)

    assert "_meta" in names
    assert Enum.sort(@groups) -- names == []
  end

  # ── per-backend write + read round-trips (Root dispatch, wire facade) ─────

  test "artifacts: create doc + read record.json", %{slug: slug, ctx: ctx} do
    assert {:ok, _} = VFS.create(Root, base(slug, "artifacts") <> "/smoke-doc", "rev one", ctx)

    assert {:ok, body, _} =
             VFS.read(Root, base(slug, "artifacts") <> "/smoke-doc/record.json", ctx)

    assert %{"title" => "smoke-doc"} = Jason.decode!(body)
  end

  test "instructions: create slug + read v1 body", %{slug: slug, ctx: ctx} do
    assert {:ok, _} =
             VFS.create(Root, base(slug, "instructions") <> "/smoke-inst", "hi {{name}}", ctx)

    assert {:ok, "hi {{name}}", _} =
             VFS.read(Root, base(slug, "instructions") <> "/smoke-inst/versions/v1.md", ctx)
  end

  test "unicode: reference plane reads; mutations are :enosys", %{slug: slug, org_id: org_id, ctx: ctx} do
    # The unicode tree is generated from UnicodeCodex rows — seed one element.
    {:ok, _} =
      NoizuPromptLingua.Domains.UnicodeCodex.upsert_element(%{
        scope: "organization",
        organization_id: org_id,
        project_id: nil,
        slug: slug,
        codepoint: "U+231C",
        char: "x",
        name: "SMOKE CORNER",
        title: "Smoke Corner",
        description: "Smoke Corner element",
        flags: ["npl"]
      })

    path = base(slug, "unicode") <> "/plane-0/U+231C.json"
    assert {:ok, body, _} = VFS.read(Root, path, ctx)
    assert %{"title" => "Smoke Corner"} = Jason.decode!(body)

    assert {:error, :enosys} = VFS.write(Root, path, "{}", ctx)
  end

  test "campaigns: create campaign + read record.json", %{slug: slug, ctx: ctx} do
    path = base(slug, "campaigns") <> "/campaigns/smoke-camp"

    assert {:ok, _} =
             VFS.create(
               Root,
               path,
               Jason.encode!(%{"name" => "smoke-camp", "channel" => "seo"}),
               ctx
             )

    assert {:ok, body, _} = VFS.read(Root, path <> "/record.json", ctx)
    assert %{"name" => "smoke-camp"} = Jason.decode!(body)
  end

  test "customers: create persona + read record.json", %{slug: slug, ctx: ctx} do
    path = base(slug, "customers") <> "/personas/smoke-persona"

    assert {:ok, _} = VFS.create(Root, path, Jason.encode!(%{"name" => "Smoke"}), ctx)

    assert {:ok, _, _} = VFS.read(Root, path <> "/record.json", ctx)
  end

  test "market: create competitor + read record.json", %{slug: slug, ctx: ctx} do
    path = base(slug, "market") <> "/competitors/smoke-comp"

    assert {:ok, _} =
             VFS.create(Root, path, Jason.encode!(%{"name" => "Rival Smoke"}), ctx)

    assert {:ok, _, _} = VFS.read(Root, path <> "/record.json", ctx)
  end

  test "memory: register agent + read registry entry", %{slug: slug, ctx: ctx} do
    path = base(slug, "memory") <> "/agents/smoke-agent.json"

    assert {:ok, _} =
             VFS.create(Root, path, ~s({"kind": "team_member"}), ctx)

    assert {:ok, body, _} = VFS.read(Root, path, ctx)
    assert %{"kind" => "team_member"} = Jason.decode!(body)
  end

  test "notifications: notify create mounts + doc reads back", %{slug: slug, handle: handle, ctx: ctx} do
    assert {:ok, node} =
             VFS.create(Root, base(slug, "notifications") <> "/#{handle}/tell.json", "hello me", ctx)

    assert is_binary(id = node.xattrs["id"])

    assert {:ok, doc_json, _} =
             VFS.read(Root, base(slug, "notifications") <> "/#{handle}/#{id}.json", ctx)

    assert %{"body" => "hello me"} = Jason.decode!(doc_json)
  end

  test "pubsub: publish message + read it back", %{slug: slug, org_id: org_id, ctx: ctx} do
    # Messages mount under an existing channel — seed it first.
    {:ok, _} =
      NoizuPromptLingua.Domains.PubSub.create_channel(%{
        organization_id: org_id,
        slug: "alerts",
        name: "Alerts"
      })

    assert {:ok, _} =
             VFS.create(Root, base(slug, "pubsub") <> "/alerts/messages/smoke-hello.json", "first body", ctx)

    # Publishes land under server-assigned feed names, served as event docs.
    assert {:ok, entries, nil} =
             VFS.list(Root, base(slug, "pubsub") <> "/alerts/messages", nil, ctx)

    assert {:ok, doc_json, _} =
             VFS.read(Root, base(slug, "pubsub") <> "/alerts/messages/#{hd(entries).name}", ctx)

    assert doc_json =~ "first body"
  end

  test "tickets: _new/record.json assigns key + record reads back", %{slug: slug, ctx: ctx} do
    payload =
      Jason.encode!(%{
        "title" => "Smoke ticket",
        "description" => "via VFS union smoke",
        "ticket_type" => "bug",
        "priority" => "high"
      })

    assert {:ok, node} =
             VFS.create(Root, base(slug, "tickets") <> "/_new/record.json", payload, ctx)

    assert node.xattrs["key"] =~ ~r/^[A-Z0-9]{2,6}-\d{3,}$/

    assert {:ok, body, _} = VFS.read(Root, node.xattrs["path"], ctx)
    assert %{"title" => "Smoke ticket"} = Jason.decode!(body)
  end

  test "review: review a seeded artifact + record reads back", %{slug: slug, org_id: org_id, ctx: ctx} do
    {:ok, artifact} =
      NoizuPromptLingua.Domains.Artifacts.create(%{
        organization_id: org_id,
        kind: "document",
        title: "Smoke review doc",
        content: "v1"
      })

    revision_id = artifact.revisions |> hd() |> Map.get(:id)

    # The review path token is a client handle — the backend mints the id.
    assert {:ok, node} =
             VFS.create(
               Root,
               base(slug, "review") <> "/smoke-tok/record.json",
               Jason.encode!(%{
                 "artifact_id" => artifact.id,
                 "revision_id" => revision_id,
                 "reviewer_persona" => "smoke-reviewer",
                 "title" => "Union smoke review"
               }),
               ctx
             )

    assert {:ok, body, _} =
             VFS.read(Root, base(slug, "review") <> "/#{node.xattrs["id"]}/record.json", ctx)

    assert %{"title" => "Union smoke review"} = Jason.decode!(body)
  end

  test "sessions: create session + record reads back", %{slug: slug, ctx: ctx} do
    # Sessions mint server-assigned UUIDs — canonical_path carries the real one.
    assert {:ok, node} =
             VFS.create(
               Root,
               base(slug, "sessions") <> "/smoke-sess/record.json",
               Jason.encode!(%{"title" => "Union smoke session"}),
               ctx
             )

    assert {:ok, body, _} = VFS.read(Root, node.xattrs["canonical_path"], ctx)
    assert %{"title" => "Union smoke session"} = Jason.decode!(body)
  end

  test "chat: create room + record reads back", %{slug: slug, ctx: ctx} do
    # CreateRoom IS create {room}/record.json with a plain-text name (§2.x).
    assert {:ok, node} =
             VFS.create(
               Root,
               base(slug, "chat") <> "/smoke-room/record.json",
               "smoke-room",
               ctx
             )

    path = node.xattrs["path"] || base(slug, "chat") <> "/smoke-room/record.json"

    assert {:ok, body, _} = VFS.read(Root, path, ctx)
    assert %{"name" => "smoke-room"} = Jason.decode!(body)
  end
end
