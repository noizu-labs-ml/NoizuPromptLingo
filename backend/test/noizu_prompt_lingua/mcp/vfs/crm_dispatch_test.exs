defmodule NoizuPromptLingua.MCP.VFS.CRMDispatchTest do
  @moduledoc """
  Wave 2 Root wiring for the entity-dir groups: the `customers`, `market`,
  and `campaigns` entries in `Root`'s `@group_backends` insertion point take
  their whole subtrees via prefix dispatch — full op families land on the
  backend (including mutators), and the groups appear in the `/tobor/{org}`
  listing beside the Wave 1 backends.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias Noizu.MCP.Ctx
  alias Noizu.MCP.Server.Features.VFS
  alias Noizu.MCP.VFS.Cache
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCP.VFS.Root
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Organizations.Organization
  alias NoizuPromptLingua.TRP.Cache, as: TrpCache
  alias NoizuPromptLingua.TRP.TestStub

  @groups ["customers", "market", "campaigns"]

  setup do
    TrpCache.clear()
    TestStub.reset()

    suffix = Ecto.UUID.generate() |> binary_part(0, 8)

    org = Repo.insert!(%Organization{name: "VFS CRM Org #{suffix}", slug: "vfs-crm-#{suffix}"})
    TestStub.seed_org(org.id, org.slug, org.name)

    on_exit(fn -> Cache.purge(Root) end)

    %{org: org, ctx: key_ctx(%{"groups" => Map.new(@groups, &{&1, %{}})})}
  end

  defp key_ctx(config) do
    uniq = System.unique_integer([:positive])

    user =
      %NoizuPromptLingua.Schema.Users.User{
        id: Ecto.UUID.generate(),
        email: "vfscrm-#{uniq}@example.com",
        user_name: "vfscrm#{uniq}",
        handle: "vfscrm#{uniq}",
        status: :active
      }
      |> Repo.insert!()

    {:ok, key, _} = MCPApiKeys.generate_api_key(user.id, "vfs-crm", toolset_config: config)

    %Ctx{
      server: NoizuPromptLingua.MCP.VFSServer,
      session_id: "crm-" <> Integer.to_string(uniq),
      assigns: %{auth_claims: %{"api_key_id" => key.id, "sub" => user.id}}
    }
  end

  test "the three entity-dir groups are visible in the org listing", %{org: org, ctx: ctx} do
    {:ok, entries, _} = VFS.list(Root, "/tobor/#{org.slug}", nil, ctx)
    names = Enum.map(entries, & &1.name)

    for group <- @groups, do: assert(group in names)
  end

  test "registered subtrees serve backend content through Root (not the placeholder)", %{
    org: org,
    ctx: ctx
  } do
    for group <- @groups do
      assert {:ok, dir} = VFS.stat(Root, "/tobor/#{org.slug}/#{group}", ctx)
      assert dir.type == :dir

      assert {:ok, md, _} = VFS.read(Root, "/tobor/#{org.slug}/#{group}/overview.md", ctx)
      refute md =~ "Wave 0 placeholder"
    end
  end

  test "mutations dispatch to the CRM backends", %{org: org, ctx: ctx} do
    assert {:ok, _} =
             VFS.create(Root, "/tobor/#{org.slug}/customers/personas/dispatched", "{}", ctx)

    assert {:error, :eio} =
             VFS.create(Root, "/tobor/#{org.slug}/market/competitors/bad", "{nope", ctx)

    assert {:error, :eio} =
             VFS.create(Root, "/tobor/#{org.slug}/campaigns/campaigns/nochan", "{}", ctx)

    # Unregistered groups keep the :enosys placeholder surface.
    assert {:error, :enosys} = VFS.create(Root, "/tobor/#{org.slug}/wiki/x", "y", ctx)

    # Dot segments refused everywhere.
    assert {:error, :enoent} =
             VFS.stat(Root, "/tobor/#{org.slug}/customers/../customers", ctx)
  end

  test "search dispatches per subtree (:enosys for entity-dirs)", %{org: org, ctx: ctx} do
    for group <- @groups do
      assert {:error, :enosys} = VFS.search(Root, "/tobor/#{org.slug}/#{group}", "x", ctx)
    end
  end
end
