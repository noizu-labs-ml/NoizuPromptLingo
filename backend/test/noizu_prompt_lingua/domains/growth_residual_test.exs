defmodule NoizuPromptLingua.Domains.GrowthResidualTest do
  @moduledoc """
  Wave-5B residuals across the growth trio — market / customers / campaigns —
  beyond the happy paths in their domain suites: resolver misses, update/delete
  not-found arms, list filter arms, the LLM-backed paths' error passthroughs
  (keyword research, persona drafting, ad-copy + landing-page + report
  generation), and representative MCP tool error arms.
  """
  use NoizuPromptLingua.DataCase, async: false
  @moduletag :db

  alias NoizuPromptLingua.Domains.{Campaigns, Customers, Market}

  alias NoizuPromptLingua.Domains.Campaigns.Tools.{
    AdCopyApprove,
    CampaignCreate,
    DomainNameCreate
  }

  alias NoizuPromptLingua.Domains.Customers.Tools.{PersonaCreate, SegmentCreate}
  alias NoizuPromptLingua.Domains.Market.Tools.{CompetitorCreate, KeywordResearch}

  setup do
    NoizuPromptLingua.TRP.Cache.clear()
    NoizuPromptLingua.TRP.TestStub.reset()
    stub = NoizuPromptLingua.TRP.TestStub

    org_id = insert_org()
    stub_org_id = stub.seed_org(org_id, "growth-#{System.unique_integer([:positive])}")
    %{id: project_id} = stub.seed_project(stub_org_id, %{slug: uniq("proj"), name: "Growth"})

    org_slug =
      Repo.one!(
        from(o in "organizations", select: o.slug, where: o.id == ^Ecto.UUID.dump!(org_id))
      )

    {:ok, org_id: org_id, org_slug: org_slug, project_id: project_id}
  end

  defp uniq(suffix), do: "#{suffix}-#{System.unique_integer([:positive])}"

  # Minimal OpenAI-compatible stub (house Bandit pattern, cf. ContentGeneratorTest):
  # serves one fixed keyword-JSON completion so the LLM-backed paths are HERMETIC —
  # no provider key / network on the host (the pre-fix tests silently depended on a
  # direnv-exported OPENAI_API_KEY and real api.openai.com access, failing CI).
  defmodule StubLLM do
    @keyword_json """
    [{"term": "ci cd tooling", "intent": "informational", "volume": 120, "difficulty": 25, "cpc": 1.5}]
    """

    def init(opts), do: opts

    def call(conn, _opts) do
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.resp(
        200,
        Jason.encode!(%{"choices" => [%{"message" => %{"content" => @keyword_json}}]})
      )
    end
  end

  # Ephemeral-port Bandit server + the OPENAI_API_KEY the provider resolver
  # requires before the endpoint is ever consulted. Returns the stub base URL.
  defp start_llm_stub do
    System.put_env("OPENAI_API_KEY", "test-key")
    on_exit(fn -> System.delete_env("OPENAI_API_KEY") end)

    {:ok, sock} = :gen_tcp.listen(0, ip: {127, 0, 0, 1})
    {:ok, port} = :inet.port(sock)
    :gen_tcp.close(sock)

    {:ok, pid} = Bandit.start_link(plug: StubLLM, scheme: :http, ip: {127, 0, 0, 1}, port: port)

    on_exit(fn ->
      if Process.alive?(pid), do: Process.exit(pid, :shutdown)
    end)

    "http://127.0.0.1:#{port}"
  end

  defp insert_org do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        [uniq("growth-org"), "Growth Residual Org"]
      )

    Ecto.UUID.load!(raw)
  end

  # ── Market ─────────────────────────────────────────────────────────

  test "market resolvers, update misses, and filter arms", %{org_id: org_id} do
    {:ok, c} =
      Market.create_competitor(%{
        organization_id: org_id,
        slug: uniq("comp"),
        name: "Acme",
        tier: "direct"
      })

    assert Market.resolve_competitor(org_id, c.slug).id == c.id
    assert Market.resolve_competitor(org_id, "ghost") |> is_nil()

    assert {:error, :not_found} =
             Market.update_competitor(Ecto.UUID.generate(), %{tier: "indirect"})

    assert match?([_], Market.list_competitors(organization_id: org_id, status: nil))

    {:ok, k} =
      Market.create_keyword(%{
        organization_id: org_id,
        slug: uniq("kw"),
        term: "ci tools",
        intent: "commercial",
        volume: 10
      })

    assert Market.resolve_keyword(org_id, k.slug).id == k.id
    assert Market.resolve_keyword(org_id, "ghost-kw") |> is_nil()
    assert {:error, :not_found} = Market.update_keyword(Ecto.UUID.generate(), %{volume: 5})
    assert match?([_], Market.list_keywords(organization_id: org_id, intent: "commercial"))
  end

  test "report create and the generate miss arm" do
    org_id = insert_org()

    {:ok, r} =
      Market.create_report(%{
        organization_id: org_id,
        slug: uniq("report"),
        title: "SaaS CI landscape",
        report_type: "swot"
      })

    assert r.status != "ready"
    assert {:error, :not_found} = Market.generate_report(Ecto.UUID.generate())
  end

  test "keyword research passes the LLM error through" do
    org_id = insert_org()
    base = start_llm_stub()

    # Happy path through the stubbed completion: parses + bulk-inserts.
    assert {:ok, [_ | _]} = Market.research_keywords(org_id, nil, "ci cd tooling", endpoint: base)

    # Error passthrough: an unreachable endpoint surfaces the transport error.
    assert {:error, {:request_failed, _}} =
             Market.research_keywords(org_id, nil, "retry topic", endpoint: "http://127.0.0.1:1")
  end

  test "competitor tool happy path, org arm, and changeset arm", %{org_slug: org_slug} do
    slug = uniq("competitor")

    assert {:ok, %{id: _, slug: ^slug}} =
             CompetitorCreate.call(
               %{"organization" => org_slug, "slug" => slug, "name" => "Acme"},
               nil
             )

    assert {:error, "Organization 'ghost' not found"} =
             CompetitorCreate.call(
               %{"organization" => "ghost", "slug" => uniq("c2"), "name" => "X"},
               nil
             )

    assert {:error, "Failed: " <> _} =
             CompetitorCreate.call(
               %{"organization" => org_slug, "slug" => slug, "name" => "Dup"},
               nil
             )
  end

  test "keyword research tool org arm" do
    assert {:error, _} =
             KeywordResearch.call(%{"organization" => "ghost-org", "topic" => "devops"}, nil)
  end

  # ── Customers ──────────────────────────────────────────────────────

  test "customer personas: resolver misses, delete, and filter arms", %{org_id: org_id} do
    {:ok, p} =
      Customers.create_persona(%{organization_id: org_id, slug: uniq("pers"), name: "ICP"})

    assert Customers.resolve_persona(org_id, p.slug).id == p.id
    assert Customers.resolve_persona(org_id, "ghost") |> is_nil()
    assert {:ok, _} = Customers.update_persona(p.id, %{name: "ICP v2"})
    assert {:error, :not_found} = Customers.update_persona(Ecto.UUID.generate(), %{name: "x"})
    assert Customers.list_personas(organization_id: org_id) != []
    assert Customers.count_personas(org_id) >= 1
    assert {:ok, _} = Customers.delete_persona(p.id)
    assert {:error, :not_found} = Customers.delete_persona(p.id)
  end

  test "customer segments: resolver + update arms", %{org_id: org_id} do
    {:ok, s} =
      Customers.create_segment(%{organization_id: org_id, slug: uniq("seg"), name: "SMB"})

    assert Customers.resolve_segment(org_id, s.slug).id == s.id
    assert Customers.resolve_segment(org_id, "ghost-seg") |> is_nil()
    assert {:ok, _} = Customers.update_segment(s.id, %{name: "Mid-Market"})
    assert {:error, :not_found} = Customers.update_segment(Ecto.UUID.generate(), %{name: "x"})
    assert match?([_], Customers.list_segments(organization_id: org_id))
  end

  test "draft_persona passes the LLM error through", %{org_id: org_id} do
    assert {:error, :not_found} = Customers.draft_persona(Ecto.UUID.generate())

    {:ok, p} =
      Customers.create_persona(%{organization_id: org_id, slug: uniq("draft"), name: "Draft"})

    base = start_llm_stub()

    # Happy path through the stubbed completion: persists the persona artifact.
    assert {:ok, _} = Customers.draft_persona(p.id, endpoint: base)

    # Error passthrough: transport failure surfaces verbatim.
    assert {:error, {:request_failed, _}} =
             Customers.draft_persona(p.id, endpoint: "http://127.0.0.1:1")
  end

  test "persona + segment tool arms", %{org_slug: org_slug} do
    slug = uniq("tool-pers")

    assert {:ok, %{id: _}} =
             PersonaCreate.call(
               %{"organization" => org_slug, "slug" => slug, "name" => "ICP"},
               nil
             )

    assert {:error, _} =
             PersonaCreate.call(
               %{"organization" => "ghost", "slug" => uniq("p9"), "name" => "X"},
               nil
             )

    seg_slug = uniq("tool-seg")

    assert {:ok, %{id: _}} =
             SegmentCreate.call(
               %{"organization" => org_slug, "slug" => seg_slug, "name" => "SMB"},
               nil
             )

    assert {:error, _} =
             SegmentCreate.call(
               %{"organization" => org_slug, "slug" => seg_slug, "name" => "Dup"},
               nil
             )
  end

  # ── Campaigns ──────────────────────────────────────────────────────

  test "campaigns: resolver misses, ad groups, ad copy lifecycle, filter arms", %{org_id: org_id} do
    {:ok, campaign} =
      Campaigns.create_campaign(%{
        organization_id: org_id,
        slug: uniq("camp"),
        name: "Launch",
        channel: "ppc",
        objective: "signups"
      })

    assert Campaigns.resolve_campaign(org_id, "ghost-camp") |> is_nil()

    assert {:error, :not_found} =
             Campaigns.update_campaign(Ecto.UUID.generate(), %{status: "active"})

    assert Campaigns.count_campaigns(org_id) >= 1

    {:ok, group} =
      Campaigns.create_ad_group(%{
        organization_id: org_id,
        campaign_id: campaign.id,
        slug: uniq("grp"),
        name: "Core"
      })

    assert Campaigns.get_ad_group(group.id).id == group.id
    assert {:ok, _} = Campaigns.update_ad_group(group.id, %{name: "Core v2"})
    assert {:error, :not_found} = Campaigns.update_ad_group(Ecto.UUID.generate(), %{name: "x"})
    assert match?([_], Campaigns.list_ad_groups(campaign.id))

    {:ok, copy} =
      Campaigns.create_ad_copy(%{
        organization_id: org_id,
        campaign_id: campaign.id,
        ad_group_id: group.id,
        variant: "A",
        headline: "Ship faster",
        body: "CI that scales"
      })

    assert Campaigns.get_ad_copy(copy.id).id == copy.id
    assert match?([_], Campaigns.list_ad_copy(campaign.id))
    assert {:ok, %{status: "approved"}} = Campaigns.approve_ad_copy(copy.id)
    assert {:error, :not_found} = Campaigns.approve_ad_copy(Ecto.UUID.generate())

    {:ok, copy2} =
      Campaigns.create_ad_copy(%{
        organization_id: org_id,
        campaign_id: campaign.id,
        ad_group_id: group.id,
        variant: "B",
        headline: "Ship even faster",
        body: "CI that scales"
      })

    assert {:ok, %{status: "rejected"}} = Campaigns.reject_ad_copy(copy2.id)
    assert {:error, :not_found} = Campaigns.reject_ad_copy(Ecto.UUID.generate())
  end

  test "landing pages and domain names: resolvers + update arms", %{org_id: org_id} do
    {:ok, page} =
      Campaigns.create_landing_page(%{
        organization_id: org_id,
        slug: uniq("lp"),
        title: "Launch LP",
        headline: "Go fast"
      })

    assert Campaigns.resolve_landing_page(org_id, page.slug).id == page.id
    assert Campaigns.resolve_landing_page(org_id, "ghost-lp") |> is_nil()
    assert {:ok, _} = Campaigns.update_landing_page(page.id, %{headline: "Go faster"})
    assert {:error, :not_found} = Campaigns.update_landing_page(Ecto.UUID.generate(), %{})
    assert {:error, :not_found} = Campaigns.generate_landing_page(Ecto.UUID.generate())

    {:ok, domain} =
      Campaigns.create_domain_name(%{
        organization_id: org_id,
        slug: uniq("dom"),
        name: "GoFast",
        domain: "gofast.example"
      })

    assert Campaigns.resolve_domain_name(org_id, domain.slug).id == domain.id
    assert Campaigns.resolve_domain_name(org_id, "ghost-dom") |> is_nil()
    assert {:ok, _} = Campaigns.update_domain_name(domain.id, %{status: "registered"})
    assert {:error, :not_found} = Campaigns.update_domain_name(Ecto.UUID.generate(), %{})
  end

  test "campaign tool arms: create happy, domain changeset, approve miss", %{org_slug: org_slug} do
    assert {:ok, %{id: _}} =
             CampaignCreate.call(
               %{
                 "organization" => org_slug,
                 "slug" => uniq("tool-camp"),
                 "name" => "Tool Campaign",
                 "channel" => "ppc",
                 "objective" => "signups"
               },
               nil
             )

    assert {:error, _} =
             CampaignCreate.call(
               %{"organization" => "ghost", "slug" => uniq("c9"), "name" => "X"},
               nil
             )

    assert {:error, _} =
             DomainNameCreate.call(%{"organization" => org_slug, "domain" => "!!bad!!"}, nil)

    assert {:error, _} = AdCopyApprove.call(%{"id" => Ecto.UUID.generate()}, nil)
  end
end
