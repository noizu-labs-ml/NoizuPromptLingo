defmodule NoizuPromptLingua.MCP.VFS.OrganizationsTest do
  @moduledoc """
  Wave 2 battery for the §2.5 Organizations entity-dir (`org.json` read /
  admin-gated write / create), exercised through `Noizu.MCP.Server.Features.VFS`
  so errno mapping and generation stamping are covered on the wire path.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias Noizu.MCP.Server.Features.VFS
  alias Noizu.MCP.VFS.Cache
  alias Noizu.MCP.Ctx
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCP.VFS.Organizations
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Users.User
  alias NoizuPromptLingua.TRP.Cache, as: TrpCache
  alias NoizuPromptLingua.TRP.TestStub

  setup do
    TrpCache.clear()
    TestStub.reset()
    on_exit(fn -> Cache.purge(Organizations) end)
    :ok
  end

  defp key_ctx(config, overrides \\ []) do
    uniq = System.unique_integer([:positive])

    user =
      %User{
        id: Ecto.UUID.generate(),
        email: "vfsorg-#{uniq}@example.com",
        user_name: "vfsorg#{uniq}",
        handle: "vfsorg#{uniq}",
        status: :active
      }
      |> Repo.insert!()

    {:ok, key, _raw} = MCPApiKeys.generate_api_key(user.id, "vfs-org", toolset_config: config)

    claims =
      %{"api_key_id" => key.id, "sub" => user.id}
      |> Map.merge(Map.new(overrides))

    %Ctx{
      server: NoizuPromptLingua.MCP.VFSServer,
      session_id: "org-" <> Integer.to_string(uniq),
      assigns: %{auth_claims: claims}
    }
  end

  # Owner ctx + a local org row (owner membership included) + the matching
  # TRP stub org (key-scope visibility).
  defp owned_org(ctx, slug) do
    owner_id = ctx.assigns.auth_claims["sub"]

    TestStub.seed_org(Ecto.UUID.generate(), slug, "Org " <> slug)

    {:ok, org} =
      NoizuPromptLingua.Organizations.create_organization_with_owner(
        %{"slug" => slug, "name" => "Org " <> slug},
        owner_id
      )

    org
  end

  defp add_member(ctx, org, role) do
    NoizuPromptLingua.Authz.ScopedMemberships.add_member(
      "organization",
      org.id,
      ctx.assigns.auth_claims["sub"],
      role
    )
  end

  defp org_path(slug), do: "/tobor/" <> slug <> "/org.json"

  @org_config %{"groups" => %{"organizations" => %{}}}

  test "read org.json serves the org record; admins see writable: true" do
    ctx = key_ctx(@org_config)
    slug = "vfsorg-#{System.unique_integer([:positive])}"
    org = owned_org(ctx, slug)

    path = org_path(slug)
    assert {:ok, node} = VFS.stat(Organizations, path, ctx)
    assert node.type == :file
    assert node.writable == true

    assert {:ok, body, version} = VFS.read(Organizations, path, ctx)
    assert version == node.version
    assert {:ok, doc} = Jason.decode(body)
    assert doc["id"] == org.id
    assert doc["slug"] == slug
    assert doc["name"] == "Org " <> slug
    assert is_map(doc["settings"])
  end

  test "org outside the key scope is :enoent (no existence leak)" do
    ctx = key_ctx(@org_config)
    owned_org(ctx, "vfsorg-visible-#{System.unique_integer([:positive])}")

    hidden = org_path("vfsorg-hidden-#{System.unique_integer([:positive])}")
    assert {:error, :enoent} = VFS.stat(Organizations, hidden, ctx)
    assert {:error, :enoent} = VFS.read(Organizations, hidden, ctx)
  end

  test "excluded organizations group hides the record entirely" do
    ctx = key_ctx(%{"groups" => %{"wiki" => %{}}})
    slug = "vfsorg-excl-#{System.unique_integer([:positive])}"
    owned_org(ctx, slug)

    assert {:error, :enoent} = VFS.stat(Organizations, org_path(slug), ctx)
  end

  test "owner (admin) write merges the canonical doc" do
    ctx = key_ctx(@org_config)
    slug = "vfsorg-#{System.unique_integer([:positive])}"
    owned_org(ctx, slug)

    assert {:ok, _node} =
             VFS.write(Organizations, org_path(slug), Jason.encode!(%{"name" => "Renamed"}), ctx)

    {:ok, body, _} = VFS.read(Organizations, org_path(slug), ctx)
    assert {:ok, %{"name" => "Renamed"}} = Jason.decode(body)
  end

  test "non-admin member write is :eacces, read still allowed" do
    owner = key_ctx(@org_config)
    slug = "vfsorg-#{System.unique_integer([:positive])}"
    org = owned_org(owner, slug)

    member = key_ctx(@org_config)
    assert {:ok, _} = add_member(member, org, "member")

    path = org_path(slug)
    assert {:ok, node} = VFS.stat(Organizations, path, member)
    assert node.writable == false
    assert {:ok, _, _} = VFS.read(Organizations, path, member)
    assert {:error, :eacces} = VFS.write(Organizations, path, ~s({"name":"x"}), member)
  end

  test "write is refused :eacces when the group is disabled (read-only)" do
    ctx = key_ctx(%{"groups" => %{"organizations" => %{"disabled" => true}}})
    slug = "vfsorg-#{System.unique_integer([:positive])}"
    owned_org(ctx, slug)

    path = org_path(slug)
    assert {:ok, node} = VFS.stat(Organizations, path, ctx)
    assert node.writable == false
    assert {:error, :eacces} = VFS.write(Organizations, path, ~s({"name":"x"}), ctx)
  end

  test "slug is the stable key: a slug write is ignored, malformed body is :eio" do
    ctx = key_ctx(@org_config)
    slug = "vfsorg-#{System.unique_integer([:positive])}"
    owned_org(ctx, slug)

    path = org_path(slug)

    # Unknown/ignored keys round-trip cleanly (daemon echo safety).
    assert {:ok, _} =
             VFS.write(Organizations, path, Jason.encode!(%{"slug" => "renamed"}), ctx)

    {:ok, body, _} = VFS.read(Organizations, path, ctx)
    assert {:ok, %{"slug" => ^slug}} = Jason.decode(body)

    assert {:error, :eio} = VFS.write(Organizations, path, "not json", ctx)
  end

  test "create mints a new org (owner = caller); duplicate slug is :eexist" do
    ctx = key_ctx(@org_config)
    slug = "vfsorg-new-#{System.unique_integer([:positive])}"
    path = org_path(slug)

    assert {:ok, node} =
             VFS.create(Organizations, path, Jason.encode!(%{"name" => "Fresh"}), ctx)

    assert node.xattrs["slug"] == slug
    assert node.xattrs["created_by"] == ctx.assigns.auth_claims["sub"]

    # Local row + owner membership exist.
    assert {:ok, _id} = NoizuPromptLingua.Organizations.resolve_org_id(slug)
    org_id = NoizuPromptLingua.Organizations.get_id_by_slug(slug)

    assert match?(
             {:ok, _},
             NoizuPromptLingua.Authz.authorize(
               ctx.assigns.auth_claims["sub"],
               "organization",
               org_id,
               "owner"
             )
           )

    assert {:error, :eexist} =
             VFS.create(Organizations, path, Jason.encode!(%{"name" => "Fresh"}), ctx)
  end

  test "create requires a name and refuses dir creates" do
    ctx = key_ctx(@org_config)
    slug = "vfsorg-noname-#{System.unique_integer([:positive])}"

    assert {:error, :eio} =
             VFS.create(Organizations, org_path(slug), ~s({"nope":1}), ctx)

    assert {:error, :enosys} = VFS.create(Organizations, "/tobor/" <> slug, :dir, ctx)
  end
end
