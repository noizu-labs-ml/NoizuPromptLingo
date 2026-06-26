defmodule NoizuPromptLingua.Domains.MarketTest do
  use NoizuPromptLingua.DataCase
  @moduletag :db

  alias NoizuPromptLingua.Domains.Market

  setup do
    {:ok, org_id: insert_org()}
  end

  test "competitor CRUD + list", %{org_id: org_id} do
    {:ok, c} = Market.create_competitor(%{organization_id: org_id, slug: "acme", name: "Acme", tier: "direct"})
    assert Market.resolve_competitor(org_id, "acme").id == c.id
    {:ok, c2} = Market.update_competitor(c.id, %{tier: "indirect"})
    assert c2.tier == "indirect"
    assert length(Market.list_competitors(organization_id: org_id)) == 1
  end

  test "keyword create with metrics + intent filter + ordering by volume", %{org_id: org_id} do
    {:ok, _} = Market.create_keyword(%{organization_id: org_id, slug: "k1", term: "ci tools", intent: "commercial", volume: 100, difficulty: 40})
    {:ok, _} = Market.create_keyword(%{organization_id: org_id, slug: "k2", term: "ci pipeline", intent: "informational", volume: 500, difficulty: 20})

    [first | _] = Market.list_keywords(organization_id: org_id)
    assert first.term == "ci pipeline"
    assert [%{term: "ci tools"}] = Market.list_keywords(organization_id: org_id, intent: "commercial")
    assert Market.count_keywords(org_id) == 2
  end

  test "keyword difficulty out of range is rejected", %{org_id: org_id} do
    assert {:error, cs} = Market.create_keyword(%{organization_id: org_id, slug: "bad", term: "x", difficulty: 250})
    assert cs.errors[:difficulty]
  end

  describe "report generation (offline path)" do
    test "generate_report with llm_generate: false stores artifact + sets status ready", %{org_id: org_id} do
      {:ok, report} = Market.create_report(%{organization_id: org_id, slug: "r1", title: "Q3 Landscape", report_type: "market_analysis"})

      assert {:ok, updated} = Market.generate_report(report.id, llm_generate: false)
      assert updated.artifact_id
      assert updated.status == "ready"
      assert is_binary(updated.summary)
    end

    test "research_keywords with llm_generate: false parses an echoed JSON array", %{org_id: org_id} do
      # With llm_generate: false the prompt is echoed; it is not valid JSON, so we
      # expect a clean unparseable error rather than a crash.
      assert {:error, :unparseable_keyword_json} =
               Market.research_keywords(org_id, nil, "ci tools", llm_generate: false)
    end
  end

  defp insert_org do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["mkttest-#{System.unique_integer([:positive])}", "Market Test Org"]
      )

    Ecto.UUID.load!(raw)
  end
end
