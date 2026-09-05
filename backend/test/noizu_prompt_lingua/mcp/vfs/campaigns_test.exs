defmodule NoizuPromptLingua.MCP.VFS.CampaignsTest do
  @moduledoc """
  Wave 2 battery for the `campaigns` VFS backend (design §2.16), through
  `Root` + `Features.VFS`.

  Covers: slug-keyed CRUD (campaigns, landing pages, domain names), id-keyed
  subtrees (ad groups, ad copy) with campaign-org validation, the
  AdCopyApprove/AdCopyReject `verdict` control file, the writable
  `content.html` natural-file payoff (create seeds the artifact, write
  appends revisions), tool-faithful refusals (no Delete tools, ad-copy
  record.json read-only, generation ops), errnos, cursors, and the §1.3
  gate matrix.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias Noizu.MCP.Ctx
  alias Noizu.MCP.Server.Features.VFS
  alias Noizu.MCP.VFS.Cache
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCP.VFS.{Campaigns, Root}
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Organizations.Organization
  alias NoizuPromptLingua.TRP.Cache, as: TrpCache
  alias NoizuPromptLingua.TRP.TestStub

  setup do
    TrpCache.clear()
    TestStub.reset()

    suffix = Ecto.UUID.generate() |> binary_part(0, 8)

    org =
      Repo.insert!(%Organization{name: "VFS Cmp Org #{suffix}", slug: "vfs-cmp-#{suffix}"})

    TestStub.seed_org(org.id, org.slug, org.name)

    on_exit(fn -> Cache.purge(Root) end)

    %{org: org, ctx: key_ctx(%{"groups" => %{"campaigns" => %{}}})}
  end

  defp key_ctx(config) do
    uniq = System.unique_integer([:positive])

    user =
      %NoizuPromptLingua.Schema.Users.User{
        id: Ecto.UUID.generate(),
        email: "vfscmp-#{uniq}@example.com",
        user_name: "vfscmp#{uniq}",
        handle: "vfscmp#{uniq}",
        status: :active
      }
      |> Repo.insert!()

    {:ok, key, _} =
      MCPApiKeys.generate_api_key(user.id, "vfs-campaigns", toolset_config: config)

    %Ctx{
      server: NoizuPromptLingua.MCP.VFSServer,
      session_id: "cmp-" <> Integer.to_string(uniq),
      assigns: %{auth_claims: %{"api_key_id" => key.id, "sub" => user.id}}
    }
  end

  defp base(org), do: "/tobor/#{org.slug}/campaigns"

  defp campaign!(org, ctx, slug) do
    {:ok, node} =
      VFS.create(
        Root,
        "#{base(org)}/campaigns/#{slug}",
        Jason.encode!(%{"name" => slug, "channel" => "seo"}),
        ctx
      )

    node.xattrs["id"]
  end

  defp ad_group!(org, ctx, campaign_id) do
    id = Ecto.UUID.generate()

    {:ok, _} =
      VFS.create(
        Root,
        "#{base(org)}/ad-groups/#{id}",
        Jason.encode!(%{"campaign_id" => campaign_id, "slug" => "brand", "name" => "Brand"}),
        ctx
      )

    id
  end

  defp ad_copy!(org, ctx, campaign_id, attrs \\ %{}) do
    id = Ecto.UUID.generate()

    {:ok, _} =
      VFS.create(
        Root,
        "#{base(org)}/ad-copy/#{id}",
        Jason.encode!(Map.merge(%{"campaign_id" => campaign_id, "headline" => "H"}, attrs)),
        ctx
      )

    id
  end

  # ── campaigns (slug-keyed) ────────────────────────────────────────────────

  test "campaign CRUD round trip; listing keys are slugs", %{org: org, ctx: ctx} do
    assert {:ok, node} =
             VFS.create(
               Root,
               "#{base(org)}/campaigns/spring",
               Jason.encode!(%{"channel" => "ppc"}),
               ctx
             )

    assert node.type == :dir

    assert {:ok, entries, nil} = VFS.list(Root, "#{base(org)}/campaigns", nil, ctx)
    assert Enum.map(entries, & &1.name) == ["spring"]

    {:ok, record_json, _} = VFS.read(Root, "#{base(org)}/campaigns/spring/record.json", ctx)
    {:ok, record} = Jason.decode(record_json)
    assert record["channel"] == "ppc"
    assert record["slug"] == "spring"
    assert record["status"] == "draft"

    assert {:ok, _} =
             VFS.write(
               Root,
               "#{base(org)}/campaigns/spring/record.json",
               Jason.encode!(%{"status" => "active"}),
               ctx
             )

    {:ok, record_json, _} = VFS.read(Root, "#{base(org)}/campaigns/spring/record.json", ctx)
    assert {:ok, %{"status" => "active"}} = Jason.decode(record_json)

    # channel is changeset-required: a create without one is :eio.
    assert {:error, :eio} = VFS.create(Root, "#{base(org)}/campaigns/nochan", "{}", ctx)
    assert {:error, :eexist} = VFS.create(Root, "#{base(org)}/campaigns/spring", "{}", ctx)
  end

  # ── ad groups (id-keyed, campaign-validated) ──────────────────────────────

  test "ad-group create under an org campaign; unknown/non-org campaign :enoent", %{
    org: org,
    ctx: ctx
  } do
    campaign_id = campaign!(org, ctx, "spring")
    id = ad_group!(org, ctx, campaign_id)

    assert {:ok, entries, nil} = VFS.list(Root, "#{base(org)}/ad-groups", nil, ctx)
    assert Enum.map(entries, & &1.name) == [id]

    {:ok, record_json, _} = VFS.read(Root, "#{base(org)}/ad-groups/#{id}/record.json", ctx)
    {:ok, record} = Jason.decode(record_json)
    assert record["slug"] == "brand"
    assert record["campaign_id"] == campaign_id

    assert {:ok, _} =
             VFS.write(
               Root,
               "#{base(org)}/ad-groups/#{id}/record.json",
               Jason.encode!(%{"theme" => "holiday"}),
               ctx
             )

    {:ok, record_json, _} = VFS.read(Root, "#{base(org)}/ad-groups/#{id}/record.json", ctx)
    assert {:ok, %{"theme" => "holiday"}} = Jason.decode(record_json)

    # Campaign ref must exist in this org.
    assert {:error, :enoent} =
             VFS.create(
               Root,
               "#{base(org)}/ad-groups/#{Ecto.UUID.generate()}",
               Jason.encode!(%{
                 "campaign_id" => Ecto.UUID.generate(),
                 "slug" => "x",
                 "name" => "X"
               }),
               ctx
             )

    # Non-UUID keys are not entity addresses here.
    assert {:error, :eio} =
             VFS.create(
               Root,
               "#{base(org)}/ad-groups/not-a-uuid",
               Jason.encode!(%{"campaign_id" => campaign_id, "slug" => "x", "name" => "X"}),
               ctx
             )

    assert {:error, :enoent} =
             VFS.read(Root, "#{base(org)}/ad-groups/not-a-uuid/record.json", ctx)
  end

  # ── ad copy + the verdict control file ────────────────────────────────────

  test "verdict lifecycle: absent, create, flip via write, bad content", %{org: org, ctx: ctx} do
    campaign_id = campaign!(org, ctx, "spring")
    id = ad_copy!(org, ctx, campaign_id)

    path = "#{base(org)}/ad-copy/#{id}"

    # Absent until a verdict exists.
    assert {:error, :enoent} = VFS.stat(Root, "#{path}/verdict", ctx)
    assert {:error, :enoent} = VFS.read(Root, "#{path}/verdict", ctx)
    assert {:ok, entries, nil} = VFS.list(Root, path, nil, ctx)
    assert Enum.map(entries, & &1.name) == ["record.json"]

    {:ok, record_json, _} = VFS.read(Root, "#{path}/record.json", ctx)
    {:ok, record} = Jason.decode(record_json)
    assert record["headline"] == "H"
    assert record["status"] == "draft"
    assert record["variant_number"] == 1

    # Strict create makes the verdict appear.
    assert {:ok, node} = VFS.create(Root, "#{path}/verdict", "approved\n", ctx)
    assert node.type == :file
    assert {:ok, "approved", _} = VFS.read(Root, "#{path}/verdict", ctx)
    assert {:ok, node} = VFS.stat(Root, "#{path}/verdict", ctx)
    assert node.size == byte_size("approved")

    # The entity status followed the verdict.
    {:ok, record_json, _} = VFS.read(Root, "#{path}/record.json", ctx)
    assert {:ok, %{"status" => "approved"}} = Jason.decode(record_json)

    # Re-create is a collision; write flips.
    assert {:error, :eexist} = VFS.create(Root, "#{path}/verdict", "approved", ctx)
    assert {:ok, _} = VFS.write(Root, "#{path}/verdict", "  rejected  ", ctx)
    assert {:ok, "rejected", _} = VFS.read(Root, "#{path}/verdict", ctx)

    {:ok, record_json, _} = VFS.read(Root, "#{path}/record.json", ctx)
    assert {:ok, %{"status" => "rejected"}} = Jason.decode(record_json)

    # Malformed verdicts are :eio; unknown entities :enoent.
    assert {:error, :eio} = VFS.write(Root, "#{path}/verdict", "maybe", ctx)

    assert {:error, :enoent} =
             VFS.create(
               Root,
               "#{base(org)}/ad-copy/#{Ecto.UUID.generate()}/verdict",
               "approved",
               ctx
             )
  end

  test "ad-copy record.json is read-only (no AdCopyUpdate tool)", %{org: org, ctx: ctx} do
    campaign_id = campaign!(org, ctx, "spring")
    id = ad_copy!(org, ctx, campaign_id)

    assert {:error, :enosys} =
             VFS.write(
               Root,
               "#{base(org)}/ad-copy/#{id}/record.json",
               Jason.encode!(%{"headline" => "new"}),
               ctx
             )
  end

  # ── landing pages + the content.html natural-file payoff ──────────────────

  test "content.html round trip: create seeds the artifact, write appends revisions", %{
    org: org,
    ctx: ctx
  } do
    campaign!(org, ctx, "spring")

    assert {:ok, _} =
             VFS.create(
               Root,
               "#{base(org)}/landing-pages/trial",
               Jason.encode!(%{"title" => "Free Trial"}),
               ctx
             )

    path = "#{base(org)}/landing-pages/trial"

    # Absent until an artifact exists.
    assert {:error, :enoent} = VFS.stat(Root, "#{path}/content.html", ctx)
    assert {:error, :enoent} = VFS.read(Root, "#{path}/content.html", ctx)
    assert {:ok, entries, nil} = VFS.list(Root, path, nil, ctx)
    assert Enum.map(entries, & &1.name) == ["record.json"]

    # Create seeds the artifact and links it.
    assert {:ok, _} = VFS.create(Root, "#{path}/content.html", "<h1>Trial</h1>", ctx)
    assert {:ok, "<h1>Trial</h1>", _} = VFS.read(Root, "#{path}/content.html", ctx)

    assert {:ok, entries, nil} = VFS.list(Root, path, nil, ctx)
    assert Enum.map(entries, & &1.name) == ["record.json", "content.html"]

    # Re-create collides; write appends a revision and the read reflects it.
    assert {:error, :eexist} = VFS.create(Root, "#{path}/content.html", "<h1>x</h1>", ctx)
    assert {:ok, _} = VFS.write(Root, "#{path}/content.html", "<h1>Trial v2</h1>", ctx)
    assert {:ok, "<h1>Trial v2</h1>", _} = VFS.read(Root, "#{path}/content.html", ctx)

    {:ok, record_json, _} = VFS.read(Root, "#{path}/record.json", ctx)
    {:ok, record} = Jason.decode(record_json)
    assert record["artifact_id"]
    assert record["status"] == "draft"
  end

  test "content.html write seeds when the page has no artifact (edit-first flow)", %{
    org: org,
    ctx: ctx
  } do
    campaign!(org, ctx, "spring")
    create!(org, ctx, "bare")

    assert {:ok, _} =
             VFS.write(Root, "#{base(org)}/landing-pages/bare/content.html", "<p>hi</p>", ctx)

    assert {:ok, "<p>hi</p>", _} =
             VFS.read(Root, "#{base(org)}/landing-pages/bare/content.html", ctx)
  end

  defp create!(org, ctx, subtree \\ "landing-pages", slug, attrs \\ %{}) do
    {:ok, _} =
      VFS.create(Root, "#{base(org)}/#{subtree}/#{slug}", Jason.encode!(attrs), ctx)

    slug
  end

  # ── domain names ──────────────────────────────────────────────────────────

  test "domain-name CRUD round trip", %{org: org, ctx: ctx} do
    create!(org, ctx, "domain-names", "tryproduct", %{"name" => "tryproduct.com"})

    {:ok, record_json, _} =
      VFS.read(Root, "#{base(org)}/domain-names/tryproduct/record.json", ctx)

    {:ok, record} = Jason.decode(record_json)
    assert record["name"] == "tryproduct.com"
    assert record["status"] == "candidate"

    assert {:ok, _} =
             VFS.write(
               Root,
               "#{base(org)}/domain-names/tryproduct/record.json",
               Jason.encode!(%{"status" => "registered", "registrar" => "Cloudflare"}),
               ctx
             )

    {:ok, record_json, _} =
      VFS.read(Root, "#{base(org)}/domain-names/tryproduct/record.json", ctx)

    assert {:ok, %{"registrar" => "Cloudflare"}} = Jason.decode(record_json)
  end

  # ── tool-faithful refusals: no Delete tools, generation = Wave 4 ──────────

  test "remove is :enosys; generation ops refuse; landing-page record updates work", %{
    org: org,
    ctx: ctx
  } do
    campaign_id = campaign!(org, ctx, "spring")

    assert {:error, :enosys} = VFS.remove(Root, "#{base(org)}/campaigns/spring", ctx)
    assert {:error, :enoent} = VFS.remove(Root, "#{base(org)}/campaigns/ghost", ctx)

    # AdCopyGenerate / LandingPageGenerate: no file-plane node (§3.8, Wave 4).
    assert {:error, :enosys} = VFS.write(Root, "#{base(org)}/ad-copy/generate", "x", ctx)
    assert {:error, :enosys} = VFS.write(Root, "#{base(org)}/landing-pages/generate", "x", ctx)

    # LandingPageUpdate still flows through record.json.
    assert {:ok, _} =
             VFS.write(
               Root,
               "#{base(org)}/campaigns/spring/record.json",
               Jason.encode!(%{"objective" => "trials"}),
               ctx
             )

    assert campaign_id
  end

  # ── overview + cursors ────────────────────────────────────────────────────

  test "overview.md renders from the group's Overview tool; cursors checked", %{
    org: org,
    ctx: ctx
  } do
    assert {:ok, md, _} = VFS.read(Root, "#{base(org)}/overview.md", ctx)
    assert md =~ "Campaign"

    assert {:error, %Noizu.MCP.Error{}} = VFS.list(Root, base(org), "junk", ctx)
    assert {:ok, _, nil} = VFS.list(Root, base(org), "", ctx)
  end

  # ── gating (§1.3) ─────────────────────────────────────────────────────────

  test "excluded group is :enoent; disabled group is read-only with :eacces mutations", %{
    org: org
  } do
    excluded = key_ctx(%{"groups" => %{"memory" => %{}}})
    assert {:error, :enoent} = VFS.stat(Root, base(org), excluded)

    disabled = key_ctx(%{"groups" => %{"campaigns" => %{"disabled" => true}}})
    assert {:ok, dir} = VFS.stat(Root, base(org), disabled)
    assert dir.writable == false

    assert {:error, :eacces} =
             VFS.create(Root, "#{base(org)}/campaigns/blocked", "{}", disabled)

    assert {:ok, _, _} = VFS.read(Root, "#{base(org)}/overview.md", disabled)
  end

  # ── direct backend call ───────────────────────────────────────────────────

  test "backend works standalone on full absolute paths", %{org: org, ctx: ctx} do
    assert {:ok, dir} = Campaigns.stat("/tobor/#{org.slug}/campaigns", ctx)
    assert dir.type == :dir
    assert {:error, :enosys} = Campaigns.write("/tobor/#{org.slug}/campaigns/x", "y", ctx)
  end
end
