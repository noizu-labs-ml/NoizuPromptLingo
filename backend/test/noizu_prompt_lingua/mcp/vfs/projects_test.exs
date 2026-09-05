defmodule NoizuPromptLingua.MCP.VFS.ProjectsTest do
  @moduledoc """
  Wave 2 battery for the §2.6 Projects entity-dir — TRP shared-key backed via
  the `NoizuPromptLingua.TRP.TestStub`, exercised through
  `Noizu.MCP.Server.Features.VFS` (wire-level errno/generation behavior).
  """

  use NoizuPromptLingua.DataCase, async: false

  alias Noizu.MCP.Server.Features.VFS
  alias Noizu.MCP.VFS.Cache
  alias Noizu.MCP.Ctx
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCP.VFS.Projects
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Users.User
  alias NoizuPromptLingua.TRP.Cache, as: TrpCache
  alias NoizuPromptLingua.TRP.TestStub

  @org_config %{"groups" => %{"projects" => %{}}}

  setup do
    TrpCache.clear()
    TestStub.reset()
    on_exit(fn -> Cache.purge(Projects) end)
    :ok
  end

  defp key_ctx(config) do
    uniq = System.unique_integer([:positive])

    user =
      %User{
        id: Ecto.UUID.generate(),
        email: "vfsproj-#{uniq}@example.com",
        user_name: "vfsproj#{uniq}",
        handle: "vfsproj#{uniq}",
        status: :active
      }
      |> Repo.insert!()

    {:ok, key, _raw} = MCPApiKeys.generate_api_key(user.id, "vfs-proj", toolset_config: config)

    %Ctx{
      server: NoizuPromptLingua.MCP.VFSServer,
      session_id: "proj-" <> Integer.to_string(uniq),
      assigns: %{auth_claims: %{"api_key_id" => key.id, "sub" => user.id}}
    }
  end

  defp seeded_org do
    slug = "vfsproj-#{System.unique_integer([:positive])}"
    org_id = TestStub.seed_org(Ecto.UUID.generate(), slug, "Project Org")
    %{slug: slug, id: org_id}
  end

  defp seeded_project(org, suffix \\ "one") do
    slug = "proj-#{suffix}-#{System.unique_integer([:positive])}"

    TestStub.seed_project(org.id, %{
      slug: slug,
      name: "Project #{suffix}",
      description: "seeded"
    })

    slug
  end

  defp record_path(org_slug, project_slug),
    do: "/tobor/#{org_slug}/projects/#{project_slug}/record.json"

  test "readdir lists project slugs; stat maps the subtree" do
    ctx = key_ctx(@org_config)
    org = seeded_org()
    slug = seeded_project(org)

    assert {:ok, dir} = VFS.stat(Projects, "/tobor/#{org.slug}/projects", ctx)
    assert dir.type == :dir and dir.writable == true

    assert {:ok, entries, nil} = VFS.list(Projects, "/tobor/#{org.slug}/projects", nil, ctx)
    assert Enum.any?(entries, &match?(%{name: ^slug, type: :dir}, &1))

    assert {:ok, entries, nil} = VFS.list(Projects, "/tobor/#{org.slug}/projects/#{slug}", nil, ctx)
    assert Enum.map(entries, & &1.name) == ["record.json"]

    assert {:ok, node} = VFS.stat(Projects, record_path(org.slug, slug), ctx)
    assert node.type == :file and node.writable == true
    assert node.xattrs["id"]
  end

  test "record.json read serves the TRP-shaped project doc" do
    ctx = key_ctx(@org_config)
    org = seeded_org()
    slug = seeded_project(org)

    {:ok, body, _} = VFS.read(Projects, record_path(org.slug, slug), ctx)
    assert {:ok, doc} = Jason.decode(body)
    assert doc["slug"] == slug
    assert doc["name"] == "Project one"
    assert doc["status"] == "active"
    assert doc["organization_id"] == org.id
  end

  test "write merges accepted fields (slug ignored) via TRP" do
    ctx = key_ctx(@org_config)
    org = seeded_org()
    slug = seeded_project(org)
    path = record_path(org.slug, slug)

    body = Jason.encode!(%{"name" => "Renamed", "status" => "archived", "slug" => "hijack"})
    assert {:ok, _} = VFS.write(Projects, path, body, ctx)

    {:ok, body, _} = VFS.read(Projects, path, ctx)
    assert {:ok, doc} = Jason.decode(body)
    assert doc["name"] == "Renamed"
    assert doc["status"] == "archived"
    assert doc["slug"] == slug
  end

  test "unknown project is :enoent; malformed write is :eio" do
    ctx = key_ctx(@org_config)
    org = seeded_org()
    # Seed before any TRP read — the read-through cache pins the project
    # list for 30s, so a mid-test seed would be invisible to later calls.
    slug = seeded_project(org)

    assert {:error, :enoent} =
             VFS.stat(Projects, record_path(org.slug, "missing-project"), ctx)

    assert {:error, :enoent} =
             VFS.read(Projects, record_path(org.slug, "missing-project"), ctx)

    assert {:error, :eio} =
             VFS.write(Projects, record_path(org.slug, slug), "not json", ctx)
  end

  test "create a project at {slug}/record.json; duplicate slug is :eexist" do
    ctx = key_ctx(@org_config)
    org = seeded_org()
    slug = "proj-new-#{System.unique_integer([:positive])}"

    assert {:ok, node} =
             VFS.create(
               Projects,
               record_path(org.slug, slug),
               Jason.encode!(%{"name" => "New Project", "description" => "d"}),
               ctx
             )

    assert node.xattrs["canonical_path"] == record_path(org.slug, slug)

    assert {:error, :eexist} =
             VFS.create(
               Projects,
               record_path(org.slug, slug),
               Jason.encode!(%{"name" => "Dup"}),
               ctx
             )

    assert {:ok, entries, nil} = VFS.list(Projects, "/tobor/#{org.slug}/projects", nil, ctx)
    assert Enum.any?(entries, &(&1.name == slug))
  end

  test "gating: excluded group is :enoent; disabled group is read-only" do
    excluded = key_ctx(%{"groups" => %{"wiki" => %{}}})
    org = seeded_org()
    slug = seeded_project(org)

    assert {:error, :enoent} = VFS.stat(Projects, "/tobor/#{org.slug}/projects", excluded)

    readonly = key_ctx(%{"groups" => %{"projects" => %{"disabled" => true}}})
    path = record_path(org.slug, slug)

    assert {:ok, node} = VFS.stat(Projects, path, readonly)
    assert node.writable == false
    assert {:error, :eacces} = VFS.write(Projects, path, ~s({"name":"x"}), readonly)
    assert {:error, :eacces} = VFS.create(Projects, path, ~s({"name":"x"}), readonly)
  end

  test "TRP failures: listings fail soft to empty, failed update writes are :eio" do
    ctx = key_ctx(@org_config)
    org = seeded_org()
    slug = seeded_project(org)

    # Warm the org list so the queued failure below hits the projects call.
    assert {:ok, _, _} = VFS.list(Projects, "/tobor/#{org.slug}/projects", nil, ctx)

    # A failed shared-key read renders an empty listing (Principal precedent).
    NoizuPromptLingua.TRP.Cache.bust_prefix([:projects_list, org.id])
    TestStub.queue_response({:transport, :closed})
    assert {:ok, [], nil} = VFS.list(Projects, "/tobor/#{org.slug}/projects", nil, ctx)

    # A write whose TRP PATCH fails did NOT land — :eio, not silent success.
    # Prime the project list first (stat), so the write's fetch is cache-served
    # and the queued 500s land on the PATCH itself, exhausting its 2 retries.
    path = record_path(org.slug, slug)
    assert {:ok, _} = VFS.stat(Projects, path, ctx)

    Enum.each(1..3, fn _ -> TestStub.queue_response({500, %{"error" => "boom"}}) end)
    assert {:error, :eio} = VFS.write(Projects, path, ~s({"name":"x"}), ctx)
  end
end
