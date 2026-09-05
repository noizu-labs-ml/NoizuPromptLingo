defmodule NoizuPromptLingua.MCP.VFS.CustomersTest do
  @moduledoc """
  Wave 2 battery for the `customers` VFS backend (design §2.14), through
  `Root` + `Features.VFS` plus one direct-backend conformance call.

  Covers: persona/segment create (slug + JSON attrs), record.json update
  semantics (identity keys ignored), the always-present `tickets.json` with
  link-set sync (PersonaLink/UnlinkTicket fan-out), tool-faithful
  `:enosys` (no Delete tools, PersonaDraft generation), errnos, cursor
  policy, and the §1.3 gate matrix.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias Noizu.MCP.Ctx
  alias Noizu.MCP.Server.Features.VFS
  alias Noizu.MCP.VFS.Cache
  alias NoizuPromptLingua.Domains.Tickets
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCP.VFS.{Customers, Root}
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Organizations.Organization
  alias NoizuPromptLingua.TRP.Cache, as: TrpCache
  alias NoizuPromptLingua.TRP.TestStub

  setup do
    TrpCache.clear()
    TestStub.reset()

    suffix = Ecto.UUID.generate() |> binary_part(0, 8)

    org =
      Repo.insert!(%Organization{name: "VFS Cust Org #{suffix}", slug: "vfs-cust-#{suffix}"})

    TestStub.seed_org(org.id, org.slug, org.name)

    on_exit(fn -> Cache.purge(Root) end)

    %{org: org, ctx: key_ctx(%{"groups" => %{"customers" => %{}}})}
  end

  defp key_ctx(config) do
    uniq = System.unique_integer([:positive])

    user =
      %NoizuPromptLingua.Schema.Users.User{
        id: Ecto.UUID.generate(),
        email: "vfscust-#{uniq}@example.com",
        user_name: "vfscust#{uniq}",
        handle: "vfscust#{uniq}",
        status: :active
      }
      |> Repo.insert!()

    {:ok, key, _} =
      MCPApiKeys.generate_api_key(user.id, "vfs-customers", toolset_config: config)

    %Ctx{
      server: NoizuPromptLingua.MCP.VFSServer,
      session_id: "cust-" <> Integer.to_string(uniq),
      assigns: %{auth_claims: %{"api_key_id" => key.id, "sub" => user.id}}
    }
  end

  defp base(org), do: "/tobor/#{org.slug}/customers"

  defp persona!(org, ctx, slug, attrs \\ %{}) do
    {:ok, _} =
      VFS.create(Root, "#{base(org)}/personas/#{slug}", Jason.encode!(attrs), ctx)

    slug
  end

  # ── create + read ─────────────────────────────────────────────────────────

  test "create seeds the slug; record.json projects the entity; name defaults to slug", %{
    org: org,
    ctx: ctx
  } do
    assert {:ok, node} =
             VFS.create(
               Root,
               "#{base(org)}/personas/buyer",
               Jason.encode!(%{"name" => "Technical Buyer"}),
               ctx
             )

    assert node.type == :dir

    assert {:ok, entries, nil} = VFS.list(Root, "#{base(org)}/personas", nil, ctx)
    assert Enum.map(entries, & &1.name) == ["buyer"]

    {:ok, record_json, _} = VFS.read(Root, "#{base(org)}/personas/buyer/record.json", ctx)
    {:ok, record} = Jason.decode(record_json)
    assert record["slug"] == "buyer"
    assert record["name"] == "Technical Buyer"
    assert record["status"] == "active"
    assert record["organization_id"] == org.id
    assert record["goals"] == []

    # Empty body: name falls back to the slug (changeset requires it).
    assert {:ok, _} = VFS.create(Root, "#{base(org)}/personas/minimal", "{}", ctx)

    {:ok, record_json, _} = VFS.read(Root, "#{base(org)}/personas/minimal/record.json", ctx)
    assert {:ok, %{"name" => "minimal"}} = Jason.decode(record_json)

    assert {:ok, entries, nil} = VFS.list(Root, "#{base(org)}/personas/buyer", nil, ctx)
    assert Enum.map(entries, & &1.name) == ["record.json", "tickets.json"]
  end

  test "uuid keys resolve to the same entity; unknown keys are :enoent", %{org: org, ctx: ctx} do
    persona!(org, ctx, "finder")

    {:ok, record_json, _} = VFS.read(Root, "#{base(org)}/personas/finder/record.json", ctx)
    {:ok, %{"id" => id}} = Jason.decode(record_json)

    assert {:ok, record_json, _} = VFS.read(Root, "#{base(org)}/personas/#{id}/record.json", ctx)
    assert {:ok, %{"slug" => "finder"}} = Jason.decode(record_json)
    assert {:error, :enoent} = VFS.read(Root, "#{base(org)}/personas/ghost/record.json", ctx)
  end

  test "collisions, malformed bodies, and structural errnos", %{org: org, ctx: ctx} do
    persona!(org, ctx, "taken")

    assert {:error, :eexist} = VFS.create(Root, "#{base(org)}/personas/taken", "{}", ctx)
    assert {:error, :eio} = VFS.create(Root, "#{base(org)}/personas/bad", "{nope", ctx)
    assert {:error, :eio} = VFS.create(Root, "#{base(org)}/personas/arr", "[]", ctx)
    assert {:error, :enosys} = VFS.create(Root, "#{base(org)}/personas/dirs", :dir, ctx)

    assert {:error, :eexist} =
             VFS.create(Root, "#{base(org)}/personas/taken/record.json", "{}", ctx)

    assert {:error, :enoent} =
             VFS.create(Root, "#{base(org)}/personas/ghost/record.json", "{}", ctx)

    assert {:error, :eisdir} = VFS.read(Root, "#{base(org)}/personas/taken", ctx)

    assert {:error, :enotdir} =
             VFS.list(Root, "#{base(org)}/personas/taken/record.json", nil, ctx)

    assert {:error, :enoent} = VFS.read(Root, "#{base(org)}/personas/taken/bogus.json", ctx)
  end

  # ── record.json write (PersonaUpdate/SegmentUpdate) ───────────────────────

  test "writing record.json updates the entity; identity keys are ignored", %{org: org, ctx: ctx} do
    persona!(org, ctx, "mutable")

    body =
      Jason.encode!(%{
        "name" => "Renamed Buyer",
        "goals" => ["ship faster"],
        "slug" => "hijack",
        "organization_id" => Ecto.UUID.generate()
      })

    assert {:ok, _} = VFS.write(Root, "#{base(org)}/personas/mutable/record.json", body, ctx)

    assert {:ok, record_json, _} =
             VFS.read(Root, "#{base(org)}/personas/mutable/record.json", ctx)

    {:ok, record} = Jason.decode(record_json)
    assert record["name"] == "Renamed Buyer"
    assert record["goals"] == ["ship faster"]
    assert record["slug"] == "mutable"

    assert {:error, :eio} =
             VFS.write(Root, "#{base(org)}/personas/mutable/record.json", "{bad", ctx)

    assert {:error, :eio} =
             VFS.write(Root, "#{base(org)}/personas/mutable/record.json", "\"scalar\"", ctx)

    assert {:error, :enosys} =
             VFS.write(Root, "#{base(org)}/overview.md", "overwrite", ctx)
  end

  # ── segments ──────────────────────────────────────────────────────────────

  test "segments CRUD mirror personas; segments have no tickets.json", %{org: org, ctx: ctx} do
    assert {:ok, _} =
             VFS.create(
               Root,
               "#{base(org)}/segments/smb",
               Jason.encode!(%{"description" => "Small teams"}),
               ctx
             )

    assert {:ok, entries, nil} = VFS.list(Root, "#{base(org)}/segments", nil, ctx)
    assert Enum.map(entries, & &1.name) == ["smb"]

    assert {:ok, entries, nil} = VFS.list(Root, "#{base(org)}/segments/smb", nil, ctx)
    assert Enum.map(entries, & &1.name) == ["record.json"]

    assert {:error, :enoent} = VFS.read(Root, "#{base(org)}/segments/smb/tickets.json", ctx)

    assert {:ok, _} =
             VFS.write(
               Root,
               "#{base(org)}/segments/smb/record.json",
               Jason.encode!(%{"description" => "Updated"}),
               ctx
             )

    {:ok, record_json, _} = VFS.read(Root, "#{base(org)}/segments/smb/record.json", ctx)
    assert {:ok, %{"description" => "Updated"}} = Jason.decode(record_json)
  end

  # ── tickets.json (PersonaLinkTicket/PersonaUnlinkTicket fan-out) ──────────

  test "tickets.json syncs the link set: add, replace, clear", %{org: org, ctx: ctx} do
    persona!(org, ctx, "linked")

    {:ok, ticket_a} =
      Tickets.create(%{organization_id: org.id, title: "Ticket A", ticket_type: "task"})

    {:ok, ticket_b} =
      Tickets.create(%{organization_id: org.id, title: "Ticket B", ticket_type: "task"})

    # Empty by definition.
    assert {:ok, "[]", _} = VFS.read(Root, "#{base(org)}/personas/linked/tickets.json", ctx)

    # Add one.
    assert {:ok, _} =
             VFS.write(
               Root,
               "#{base(org)}/personas/linked/tickets.json",
               Jason.encode!([ticket_a.id]),
               ctx
             )

    assert {:ok, links_json, _} = VFS.read(Root, "#{base(org)}/personas/linked/tickets.json", ctx)
    assert {:ok, [%{"ticket_id" => tid, "link_type" => "relates_to"}]} = Jason.decode(links_json)
    assert tid == ticket_a.id

    # Replace: A out, B in.
    assert {:ok, _} =
             VFS.write(
               Root,
               "#{base(org)}/personas/linked/tickets.json",
               Jason.encode!([ticket_b.id]),
               ctx
             )

    assert {:ok, links_json, _} = VFS.read(Root, "#{base(org)}/personas/linked/tickets.json", ctx)
    assert {:ok, [%{"ticket_id" => tid}]} = Jason.decode(links_json)
    assert tid == ticket_b.id

    # Clear.
    assert {:ok, _} = VFS.write(Root, "#{base(org)}/personas/linked/tickets.json", "[]", ctx)
    assert {:ok, "[]", _} = VFS.read(Root, "#{base(org)}/personas/linked/tickets.json", ctx)

    # Unknown ticket :enoent; malformed bodies :eio.
    assert {:error, :enoent} =
             VFS.write(
               Root,
               "#{base(org)}/personas/linked/tickets.json",
               Jason.encode!([Ecto.UUID.generate()]),
               ctx
             )

    assert {:error, :eio} =
             VFS.write(Root, "#{base(org)}/personas/linked/tickets.json", "{}", ctx)

    assert {:error, :eio} =
             VFS.write(Root, "#{base(org)}/personas/linked/tickets.json", "[42]", ctx)

    assert {:error, :enoent} =
             VFS.write(Root, "#{base(org)}/personas/ghost/tickets.json", "[]", ctx)
  end

  # ── tool-faithful refusals: no Delete tools, PersonaDraft = Wave 4 ────────

  test "remove is :enosys on entities; draft write is :enosys", %{org: org, ctx: ctx} do
    persona!(org, ctx, "eternal")

    assert {:error, :enosys} = VFS.remove(Root, "#{base(org)}/personas/eternal", ctx)
    assert {:error, :enoent} = VFS.remove(Root, "#{base(org)}/personas/ghost", ctx)
    assert {:error, :enosys} = VFS.remove(Root, "#{base(org)}/segments", ctx)

    assert {:error, :enosys} = VFS.write(Root, "#{base(org)}/personas/eternal/draft", "gen", ctx)
    assert {:error, :enoent} = VFS.write(Root, "#{base(org)}/personas/ghost/draft", "gen", ctx)
  end

  # ── overview + cursors ────────────────────────────────────────────────────

  test "overview.md renders from the group's Overview tool; cursors checked", %{
    org: org,
    ctx: ctx
  } do
    assert {:ok, md, _} = VFS.read(Root, "#{base(org)}/overview.md", ctx)
    assert md =~ "Customers"

    persona!(org, ctx, "paged")

    assert {:error, %Noizu.MCP.Error{}} = VFS.list(Root, base(org), "junk", ctx)
    assert {:ok, _, nil} = VFS.list(Root, base(org), "", ctx)
  end

  # ── gating (§1.3) ─────────────────────────────────────────────────────────

  test "excluded group is :enoent; disabled group is read-only with :eacces mutations", %{
    org: org
  } do
    excluded = key_ctx(%{"groups" => %{"tickets" => %{}}})
    assert {:error, :enoent} = VFS.stat(Root, base(org), excluded)

    disabled = key_ctx(%{"groups" => %{"customers" => %{"disabled" => true}}})
    assert {:ok, dir} = VFS.stat(Root, base(org), disabled)
    assert dir.writable == false
    assert {:error, :eacces} = VFS.create(Root, "#{base(org)}/personas/blocked", "{}", disabled)
    assert {:error, :eacces} = VFS.write(Root, "#{base(org)}/overview.md", "x", disabled)
    assert {:ok, _, _} = VFS.read(Root, "#{base(org)}/overview.md", disabled)
  end

  # ── direct backend call ───────────────────────────────────────────────────

  test "backend works standalone on full absolute paths", %{org: org, ctx: ctx} do
    assert {:ok, dir} = Customers.stat("/tobor/#{org.slug}/customers", ctx)
    assert dir.type == :dir
    assert {:error, :enosys} = Customers.write("/tobor/#{org.slug}/customers/x", "y", ctx)
  end
end
