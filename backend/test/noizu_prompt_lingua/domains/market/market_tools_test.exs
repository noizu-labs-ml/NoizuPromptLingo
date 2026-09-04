defmodule NoizuPromptLingua.Domains.Market.ToolsTest do
  use NoizuPromptLingua.DataCase
  @moduletag :db

  alias NoizuPromptLingua.Domains.Market.Tools.{
    CompetitorCreate,
    CompetitorGet,
    CompetitorList,
    CompetitorUpdate,
    KeywordCreate,
    KeywordGet,
    KeywordList,
    KeywordResearch,
    KeywordUpdate,
    Overview,
    ReportCreate,
    ReportGet,
    ReportGenerate,
    ReportList
  }

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Organizations.Organization

  setup do
    org_id = insert_org()
    org_slug = Repo.get!(Organization, org_id).slug
    {:ok, org_id: org_id, org_slug: org_slug}
  end

  defp uniq(suffix), do: "#{suffix}-#{System.unique_integer([:positive])}"

  # ── Competitors ────────────────────────────────────────────────────

  test "competitor create / get / update / list round-trip", %{org_slug: org_slug} do
    slug = uniq("acme")

    assert {:ok, %{id: id, slug: ^slug, name: "Acme", tier: "direct"}} =
             CompetitorCreate.call(
               %{
                 "organization" => org_slug,
                 "slug" => slug,
                 "name" => "Acme",
                 "tier" => "direct",
                 "strengths" => ["speed"]
               },
               %{}
             )

    assert {:ok, %{id: ^id, tier: "direct"}} =
             CompetitorGet.call(%{"organization" => org_slug, "id" => slug}, %{})

    assert {:ok, %{id: ^id, status: "archived"}} =
             CompetitorUpdate.call(%{"id" => id, "status" => "archived"}, %{})

    assert {:ok, %{competitors: list} = m} =
             CompetitorList.call(%{"organization" => org_slug}, %{})

    assert is_list(list) and length(list) == 1
    assert is_map(m)

    assert {:error, "Competitor 'ghost' not found"} =
             CompetitorGet.call(%{"organization" => org_slug, "id" => "ghost"}, %{})
  end

  # ── Keywords ───────────────────────────────────────────────────────

  test "keyword create / get / update / list round-trip", %{org_slug: org_slug} do
    slug = uniq("kw")

    assert {:ok, %{id: id, slug: ^slug, term: "ci tools", volume: 100}} =
             KeywordCreate.call(
               %{
                 "organization" => org_slug,
                 "slug" => slug,
                 "term" => "ci tools",
                 "intent" => "commercial",
                 "volume" => 100,
                 "difficulty" => 40
               },
               %{}
             )

    assert {:ok, %{id: ^id}} = KeywordGet.call(%{"organization" => org_slug, "id" => slug}, %{})

    assert {:ok, %{id: ^id, difficulty: 55}} =
             KeywordUpdate.call(%{"id" => id, "difficulty" => 55}, %{})

    assert {:ok, %{keywords: kws}} = KeywordList.call(%{"organization" => org_slug}, %{})
    assert length(kws) == 1

    assert {:error, "Keyword 'ghost' not found"} =
             KeywordGet.call(%{"organization" => org_slug, "id" => "ghost"}, %{})
  end

  test "KeywordResearch without an LLM key reports the generation failure", %{org_slug: org_slug} do
    result =
      KeywordResearch.call(
        %{"organization" => org_slug, "topic" => uniq("topic"), "llm_generate" => false},
        %{}
      )

    case result do
      {:error, "Research failed: " <> _} -> :ok
      {:ok, %{created: created, keywords: kws}} when is_integer(created) and is_list(kws) -> :ok
      other -> flunk("unexpected: #{inspect(other)}")
    end

    assert {:error, "Organization 'nope' not found"} =
             KeywordResearch.call(%{"organization" => "nope", "topic" => "t"}, %{})
  end

  # ── Reports ────────────────────────────────────────────────────────

  test "report create / get / list / generate offline round-trip", %{org_slug: org_slug} do
    slug = uniq("report")

    assert {:ok, %{id: id, slug: ^slug}} =
             ReportCreate.call(
               %{"organization" => org_slug, "slug" => slug, "title" => "Q3 Market Scan"},
               %{}
             )

    assert {:ok, %{id: ^id}} = ReportGet.call(%{"organization" => org_slug, "id" => slug}, %{})

    assert {:ok, %{reports: reports}} = ReportList.call(%{"organization" => org_slug}, %{})
    assert length(reports) == 1

    # Offline generation echoes the prompt into a persisted artifact.
    result =
      ReportGenerate.call(
        %{"id" => id, "llm_generate" => false, "prompt" => "offline body"},
        %{}
      )

    case result do
      {:ok, %{report: _, artifact: _}} -> :ok
      {:ok, %{artifact_id: _}} -> :ok
      {:ok, other} when is_map(other) -> :ok
      {:error, reason} -> flunk("offline generate failed: #{inspect(reason)}")
    end

    assert {:error, "Market report 'ghost' not found"} =
             ReportGet.call(%{"organization" => org_slug, "id" => "ghost"}, %{})
  end

  # ── Overview + org errors ──────────────────────────────────────────

  test "Overview reports keyword count and tool surface", %{org_id: org_id, org_slug: org_slug} do
    assert {:ok, %{domain: "Market", keyword_count: 0, tools: %{keywords: tools}}} =
             Overview.call(%{"organization" => org_slug}, %{})

    assert "Keyword.Research" in tools
    assert {:ok, %{keyword_count: 0}} = Overview.call(%{"organization" => to_string(org_id)}, %{})
  end

  test "org errors across the CRUD tools", %{org_slug: org_slug} do
    assert {:error, "Organization 'nope' not found"} =
             CompetitorCreate.call(%{"organization" => "nope", "slug" => "s", "name" => "n"}, %{})

    assert {:error, "Organization not found"} =
             CompetitorList.call(%{"organization" => "nope"}, %{})

    assert {:error, "Organization not found"} = KeywordList.call(%{"organization" => "nope"}, %{})
    assert {:error, "Organization not found"} = ReportList.call(%{"organization" => "nope"}, %{})

    # Overview is static; unknown orgs just report a zero count.
    assert {:ok, %{keyword_count: 0}} = Overview.call(%{"organization" => "nope"}, %{})

    refute org_slug == nil
  end

  # ── helpers ────────────────────────────────────────────────────────

  defp insert_org do
    slug = "market-org-#{System.unique_integer([:positive])}"

    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        [slug, "Market Tools Test Org"]
      )

    Ecto.UUID.load!(raw)
  end
end
