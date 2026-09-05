defmodule NoizuPromptLingua.MCP.VFS.ClientsTest do
  @moduledoc """
  Wave 2 battery for the §2.22 Clients entity-dir — the exposure matrix
  (root-plane × org-admin, hidden otherwise), record.json CRUD, and the
  §3.5 rule that lifecycle status values are not file-writable.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias Noizu.MCP.Server.Features.VFS
  alias Noizu.MCP.VFS.Cache
  alias Noizu.MCP.Ctx
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCP.VFS.Clients
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Users.User
  alias NoizuPromptLingua.TRP.Cache, as: TrpCache
  alias NoizuPromptLingua.TRP.TestStub

  @config %{"groups" => %{"clients" => %{}}}

  setup do
    TrpCache.clear()
    TestStub.reset()
    on_exit(fn -> Cache.purge(Clients) end)
    :ok
  end

  defp key_ctx(config, extra_assigns \\ %{}) do
    uniq = System.unique_integer([:positive])

    user =
      %User{
        id: Ecto.UUID.generate(),
        email: "vfscli-#{uniq}@example.com",
        user_name: "vfscli#{uniq}",
        handle: "vfscli#{uniq}",
        status: :active
      }
      |> Repo.insert!()

    {:ok, key, _raw} = MCPApiKeys.generate_api_key(user.id, "vfs-cli", toolset_config: config)

    %Ctx{
      server: NoizuPromptLingua.MCP.VFSServer,
      session_id: "cli-" <> Integer.to_string(uniq),
      assigns:
        %{auth_claims: %{"api_key_id" => key.id, "sub" => user.id}}
        |> Map.merge(extra_assigns)
    }
  end

  defp owned_org(ctx) do
    slug = "vfscli-#{System.unique_integer([:positive])}"
    TestStub.seed_org(Ecto.UUID.generate(), slug, "Cli Org")

    {:ok, org} =
      NoizuPromptLingua.Organizations.create_organization_with_owner(
        %{"slug" => slug, "name" => "Cli Org"},
        ctx.assigns.auth_claims["sub"]
      )

    %{slug: slug, id: org.id}
  end

  defp add_member(ctx, org, role) do
    NoizuPromptLingua.Authz.ScopedMemberships.add_member(
      "organization",
      org.id,
      ctx.assigns.auth_claims["sub"],
      role
    )
  end

  defp record_path(org_slug, client_slug), do: "/tobor/#{org_slug}/clients/#{client_slug}/record.json"

  defp create_client(ctx, org, slug, extra \\ %{}) do
    body =
      Jason.encode!(Map.merge(%{"name" => "Acme " <> slug, "notes" => "n"}, extra))

    VFS.create(Clients, record_path(org.slug, slug), body, ctx)
  end

  test "root-plane org admin sees the subtree and has full CRUD" do
    ctx = key_ctx(@config)
    org = owned_org(ctx)
    slug = "client-a-#{System.unique_integer([:positive])}"

    assert {:ok, dir} = VFS.stat(Clients, "/tobor/#{org.slug}/clients", ctx)
    assert dir.type == :dir

    assert {:ok, node} = create_client(ctx, org, slug)
    assert is_map(node.xattrs)

    assert {:ok, entries, nil} = VFS.list(Clients, "/tobor/#{org.slug}/clients", nil, ctx)
    assert [%{name: ^slug, type: :dir}] = entries

    path = record_path(org.slug, slug)
    {:ok, body, _} = VFS.read(Clients, path, ctx)
    assert {:ok, doc} = Jason.decode(body)
    assert doc["slug"] == slug and doc["status"] == "active"

    assert {:ok, _} =
             VFS.write(Clients, path, ~s({"name":"Acme Renamed","default_hourly_rate_cents":150}), ctx)

    {:ok, body, _} = VFS.read(Clients, path, ctx)
    assert {:ok, %{"name" => "Acme Renamed", "default_hourly_rate_cents" => 150}} =
             Jason.decode(body)
  end

  test "non-admin membership is hidden (:enoent), not read-only" do
    owner = key_ctx(@config)
    org = owned_org(owner)
    slug = "client-b-#{System.unique_integer([:positive])}"
    create_client(owner, org, slug)

    member = key_ctx(@config)
    assert {:ok, _} = add_member(member, org, "member")

    assert {:error, :enoent} = VFS.stat(Clients, "/tobor/#{org.slug}/clients", member)
    assert {:error, :enoent} = VFS.stat(Clients, record_path(org.slug, slug), member)
    assert {:error, :enoent} = VFS.read(Clients, record_path(org.slug, slug), member)
    assert {:error, :enoent} = VFS.write(Clients, record_path(org.slug, slug), ~s({"name":"x"}), member)
  end

  test "custom-scope (non-root-plane) key is hidden even for an admin" do
    slug_scope = "vfscli-scope-#{System.unique_integer([:positive])}"

    {:ok, _} =
      NoizuPromptLingua.MCPCustomScopes.create(%{
        "slug" => slug_scope,
        "name" => "Scoped Key",
        "kind" => "custom",
        "config" => %{"groups" => %{"clients" => %{}}}
      })

    # Same admin user, but the key rides a custom scope → not a root-plane key.
    ctx =
      key_ctx(@config, %{custom_scope_slug: slug_scope})

    org = owned_org(ctx)

    assert {:error, :enoent} = VFS.stat(Clients, "/tobor/#{org.slug}/clients", ctx)

    assert {:error, :enoent} =
             VFS.create(
               Clients,
               record_path(org.slug, "client-c"),
               ~s({"name":"x"}),
               ctx
             )
  end

  test "lifecycle status values are refused through record.json; unchanged status echoes" do
    ctx = key_ctx(@config)
    org = owned_org(ctx)
    slug = "client-d-#{System.unique_integer([:positive])}"
    create_client(ctx, org, slug)

    path = record_path(org.slug, slug)

    assert {:error, :eacces} = VFS.write(Clients, path, ~s({"status":"archived"}), ctx)
    assert {:error, :eacces} = VFS.write(Clients, path, ~s({"status":"deleted"}), ctx)

    # Full-doc echo (read → write-back) with the current status passes.
    {:ok, body, _} = VFS.read(Clients, path, ctx)
    assert {:ok, doc} = Jason.decode(body)
    assert {:ok, _} = VFS.write(Clients, path, Jason.encode!(doc), ctx)
  end

  test "create: duplicate slug is :eexist, malformed body is :eio" do
    ctx = key_ctx(@config)
    org = owned_org(ctx)
    slug = "client-e-#{System.unique_integer([:positive])}"

    create_client(ctx, org, slug)
    assert {:error, :eexist} = create_client(ctx, org, slug)

    assert {:error, :eio} =
             VFS.create(Clients, record_path(org.slug, "client-f"), "not json", ctx)
  end

  test "removal stays off the file plane (§3.5)" do
    ctx = key_ctx(@config)
    org = owned_org(ctx)

    assert {:error, :enosys} =
             VFS.remove(Clients, "/tobor/#{org.slug}/clients/client-g/record.json", ctx)
  end
end
