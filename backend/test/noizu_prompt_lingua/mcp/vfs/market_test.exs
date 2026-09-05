defmodule NoizuPromptLingua.MCP.VFS.MarketTest do
  @moduledoc """
  Wave 2 battery for the `market` VFS backend (design §2.15), through `Root` +
  `Features.VFS`.

  Covers: competitor/keyword/report create + read, record.json write on the
  two subtrees with Update tools, the read-only report record.json, the
  `report.md` natural file (absent until the body artifact exists), the
  `:enosys` generation surface (ReportGenerate / KeywordResearch), errnos,
  cursor policy, and the §1.3 gate matrix.
  """

  use NoizuPromptLingua.DataCase, async: false

  alias Noizu.MCP.Ctx
  alias Noizu.MCP.Server.Features.VFS
  alias Noizu.MCP.VFS.Cache
  alias NoizuPromptLingua.Domains.Artifacts
  alias NoizuPromptLingua.MCPApiKeys
  alias NoizuPromptLingua.MCP.VFS.{Market, Root}
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Organizations.Organization
  alias NoizuPromptLingua.TRP.Cache, as: TrpCache
  alias NoizuPromptLingua.TRP.TestStub

  setup do
    TrpCache.clear()
    TestStub.reset()

    suffix = Ecto.UUID.generate() |> binary_part(0, 8)

    org =
      Repo.insert!(%Organization{name: "VFS Mkt Org #{suffix}", slug: "vfs-mkt-#{suffix}"})

    TestStub.seed_org(org.id, org.slug, org.name)

    on_exit(fn -> Cache.purge(Root) end)

    %{org: org, ctx: key_ctx(%{"groups" => %{"market" => %{}}})}
  end

  defp key_ctx(config) do
    uniq = System.unique_integer([:positive])

    user =
      %NoizuPromptLingua.Schema.Users.User{
        id: Ecto.UUID.generate(),
        email: "vfsmkt-#{uniq}@example.com",
        user_name: "vfsmkt#{uniq}",
        handle: "vfsmkt#{uniq}",
        status: :active
      }
      |> Repo.insert!()

    {:ok, key, _} = MCPApiKeys.generate_api_key(user.id, "vfs-market", toolset_config: config)

    %Ctx{
      server: NoizuPromptLingua.MCP.VFSServer,
      session_id: "mkt-" <> Integer.to_string(uniq),
      assigns: %{auth_claims: %{"api_key_id" => key.id, "sub" => user.id}}
    }
  end

  defp base(org), do: "/tobor/#{org.slug}/market"

  defp create!(org, ctx, subtree, slug, attrs \\ %{}) do
    {:ok, _} =
      VFS.create(Root, "#{base(org)}/#{subtree}/#{slug}", Jason.encode!(attrs), ctx)

    slug
  end

  # ── competitors + keywords (Update-tool subtrees) ─────────────────────────

  test "competitor CRUD round trip", %{org: org, ctx: ctx} do
    create!(org, ctx, "competitors", "rival", %{"name" => "Rival Co", "tier" => "direct"})

    {:ok, record_json, _} = VFS.read(Root, "#{base(org)}/competitors/rival/record.json", ctx)
    {:ok, record} = Jason.decode(record_json)
    assert record["name"] == "Rival Co"
    assert record["tier"] == "direct"
    assert record["status"] == "active"

    assert {:ok, _} =
             VFS.write(
               Root,
               "#{base(org)}/competitors/rival/record.json",
               Jason.encode!(%{"description" => "The main rival", "slug" => "hijack"}),
               ctx
             )

    {:ok, record_json, _} = VFS.read(Root, "#{base(org)}/competitors/rival/record.json", ctx)
    {:ok, record} = Jason.decode(record_json)
    assert record["description"] == "The main rival"
    assert record["slug"] == "rival"

    assert {:error, :eexist} = VFS.create(Root, "#{base(org)}/competitors/rival", "{}", ctx)
    assert {:error, :eio} = VFS.create(Root, "#{base(org)}/competitors/bad", "{nope", ctx)
  end

  test "keyword defaults term from slug; cpc serializes as a JSON number", %{org: org, ctx: ctx} do
    create!(org, ctx, "keywords", "crm-software")

    {:ok, record_json, _} = VFS.read(Root, "#{base(org)}/keywords/crm-software/record.json", ctx)
    {:ok, record} = Jason.decode(record_json)
    assert record["term"] == "crm-software"

    assert {:ok, _} =
             VFS.write(
               Root,
               "#{base(org)}/keywords/crm-software/record.json",
               Jason.encode!(%{"volume" => 1200, "cpc" => 3}),
               ctx
             )

    {:ok, record_json, _} = VFS.read(Root, "#{base(org)}/keywords/crm-software/record.json", ctx)
    {:ok, record} = Jason.decode(record_json)
    assert record["volume"] == 1200
    assert record["cpc"] == 3.0
  end

  # ── reports: read-only record.json + artifact-backed report.md ────────────

  test "report create; record.json is read-only (no ReportUpdate tool)", %{org: org, ctx: ctx} do
    create!(org, ctx, "reports", "q3-analysis")

    {:ok, record_json, _} = VFS.read(Root, "#{base(org)}/reports/q3-analysis/record.json", ctx)
    {:ok, record} = Jason.decode(record_json)
    assert record["title"] == "q3-analysis"
    assert record["status"] == "draft"

    assert {:error, :enosys} =
             VFS.write(
               Root,
               "#{base(org)}/reports/q3-analysis/record.json",
               Jason.encode!(%{"status" => "ready"}),
               ctx
             )
  end

  test "report.md appears only once a body artifact exists; reads latest revision", %{
    org: org,
    ctx: ctx
  } do
    slug = create!(org, ctx, "reports", "doc")

    path = "#{base(org)}/reports/#{slug}/report.md"
    assert {:error, :enoent} = VFS.stat(Root, path, ctx)
    assert {:error, :enoent} = VFS.read(Root, path, ctx)

    # Before the artifact the dir lists only record.json.
    assert {:ok, entries, nil} = VFS.list(Root, "#{base(org)}/reports/#{slug}", nil, ctx)
    assert Enum.map(entries, & &1.name) == ["record.json"]

    # Qualified: the short `Market` alias is this VFS backend, not the domain.
    report = NoizuPromptLingua.Domains.Market.resolve_report(org.id, slug)
    assert report

    {:ok, artifact} =
      Artifacts.create(%{
        organization_id: org.id,
        kind: "document",
        title: "Q3",
        content: "## Market analysis\nSteady growth."
      })

    # Attach via the repo (there is deliberately no ReportUpdate tool — the
    # backend must still expose the artifact body once one exists).
    {:ok, _} =
      report
      |> Ecto.Changeset.change(artifact_id: artifact.id)
      |> Repo.update()

    assert {:ok, node} = VFS.stat(Root, path, ctx)
    assert node.type == :file

    assert {:ok, "## Market analysis\nSteady growth.", _} = VFS.read(Root, path, ctx)

    assert {:ok, entries, nil} = VFS.list(Root, "#{base(org)}/reports/#{slug}", nil, ctx)
    assert Enum.map(entries, & &1.name) == ["record.json", "report.md"]

    # ReportGenerate is a generation op — the write surface refuses until the
    # Wave 4 job-dir convention lands.
    assert {:error, :enosys} = VFS.write(Root, path, "generated", ctx)
    assert {:error, :enoent} = VFS.write(Root, "#{base(org)}/reports/ghost/report.md", "g", ctx)
  end

  # ── listing shape, cursors, refusals ──────────────────────────────────────

  test "subtree listings, errnos, cursor policy, remove refusals", %{org: org, ctx: ctx} do
    create!(org, ctx, "competitors", "rival")

    assert {:ok, entries, nil} = VFS.list(Root, base(org), nil, ctx)
    names = Enum.map(entries, & &1.name)
    assert names == ["overview.md", "competitors", "keywords", "reports"]

    assert {:error, %Noizu.MCP.Error{}} = VFS.list(Root, base(org), "junk", ctx)
    assert {:error, :eisdir} = VFS.read(Root, "#{base(org)}/competitors/rival", ctx)
    assert {:error, :enotdir} = VFS.list(Root, base(org) <> "/overview.md", nil, ctx)
    assert {:error, :enoent} = VFS.read(Root, "#{base(org)}/competitors/ghost/record.json", ctx)

    # No Delete tools — removal refuses on existing entities.
    assert {:error, :enosys} = VFS.remove(Root, "#{base(org)}/competitors/rival", ctx)
    assert {:error, :enoent} = VFS.remove(Root, "#{base(org)}/competitors/ghost", ctx)

    # KeywordResearch has no file-plane node.
    assert {:error, :enosys} = VFS.write(Root, "#{base(org)}/keywords/research", "topic", ctx)
  end

  test "overview.md renders from the group's Overview tool", %{org: org, ctx: ctx} do
    assert {:ok, md, _} = VFS.read(Root, "#{base(org)}/overview.md", ctx)
    assert md =~ "Market"
  end

  # ── gating (§1.3) ─────────────────────────────────────────────────────────

  test "excluded group is :enoent; disabled group is read-only with :eacces mutations", %{
    org: org
  } do
    excluded = key_ctx(%{"groups" => %{"wiki" => %{}}})
    assert {:error, :enoent} = VFS.stat(Root, base(org), excluded)

    disabled = key_ctx(%{"groups" => %{"market" => %{"disabled" => true}}})
    assert {:ok, dir} = VFS.stat(Root, base(org), disabled)
    assert dir.writable == false

    assert {:error, :eacces} =
             VFS.create(Root, "#{base(org)}/competitors/blocked", "{}", disabled)

    assert {:ok, _, _} = VFS.read(Root, "#{base(org)}/overview.md", disabled)
  end

  # ── direct backend call ───────────────────────────────────────────────────

  test "backend works standalone on full absolute paths", %{org: org, ctx: ctx} do
    assert {:ok, dir} = Market.stat("/tobor/#{org.slug}/market", ctx)
    assert dir.type == :dir
    assert {:error, :enosys} = Market.write("/tobor/#{org.slug}/market/x", "y", ctx)
  end
end
