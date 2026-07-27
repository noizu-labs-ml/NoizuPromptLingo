defmodule NoizuPromptLingua.Domains.Market do
  @moduledoc """
  Market intelligence: competitors, keyword research, and market/competitor
  analysis reports. Org-scoped (required) with an optional project; slugs unique
  within an organization. Keyword metrics (volume/difficulty/CPC) are manually or
  LLM-populated. Report bodies are LLM-generated via `Domains.MarketingContent`
  and stored as artifacts.
  """
  import Ecto.Query, except: [update: 2]
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{Competitor, Keyword, MarketReport}
  alias NoizuPromptLingua.Domains.MarketingContent

  # ── Competitors ───────────────────────────────────────────────

  def create_competitor(attrs), do: %Competitor{} |> Competitor.changeset(attrs) |> Repo.insert()
  def get_competitor(id), do: Repo.get(Competitor, id)

  def resolve_competitor(org_id, id_or_slug), do: resolve(Competitor, org_id, id_or_slug)

  def update_competitor(id, attrs), do: do_update(Competitor, id, attrs)

  def list_competitors(opts \\ []) do
    Competitor
    |> base_filters(opts)
    |> maybe_filter(:status, opts[:status])
    |> order_by([c], asc: c.name)
    |> paginate(opts)
    |> Repo.all()
  end

  # ── Keywords ──────────────────────────────────────────────────

  def create_keyword(attrs), do: %Keyword{} |> Keyword.changeset(attrs) |> Repo.insert()
  def get_keyword(id), do: Repo.get(Keyword, id)
  def resolve_keyword(org_id, id_or_slug), do: resolve(Keyword, org_id, id_or_slug)
  def update_keyword(id, attrs), do: do_update(Keyword, id, attrs)

  def list_keywords(opts \\ []) do
    Keyword
    |> base_filters(opts)
    |> maybe_filter(:intent, opts[:intent])
    |> order_by([k], desc: k.volume)
    |> paginate(opts)
    |> Repo.all()
  end

  def count_keywords(org_id) do
    Keyword |> where([k], k.organization_id == ^org_id) |> Repo.aggregate(:count, :id)
  end

  @doc """
  LLM-generate a set of candidate keywords (term/intent and rough metric
  estimates) for a topic, and bulk-insert them. Returns `{:ok, keywords}` or
  `{:error, reason}`. With `llm_generate: false` no rows are created (nothing to
  echo meaningfully); callers use `create_keyword/1` directly for manual entry.
  """
  def research_keywords(org_id, project_id, topic, opts \\ []) do
    prompt = """
    Generate a JSON array of up to #{opts[:count] || 15} SEO keyword ideas for the topic: "#{topic}".
    Each item: {"term": string, "intent": one of informational|commercial|transactional|navigational,
    "volume": integer estimate, "difficulty": integer 0-100, "cpc": number}.
    Return ONLY the JSON array, no prose.
    """

    with {:ok, text} <- MarketingContent.generate_text(prompt, opts),
         {:ok, items} <- parse_keyword_json(text) do
      results =
        items
        |> Enum.with_index(1)
        |> Enum.map(fn {item, idx} -> insert_researched_keyword(org_id, project_id, topic, item, idx) end)
        |> Enum.filter(&match?({:ok, _}, &1))
        |> Enum.map(fn {:ok, kw} -> kw end)

      {:ok, results}
    end
  end

  # ── Market reports ────────────────────────────────────────────

  def create_report(attrs), do: %MarketReport{} |> MarketReport.changeset(attrs) |> Repo.insert()
  def get_report(id), do: Repo.get(MarketReport, id)
  def resolve_report(org_id, id_or_slug), do: resolve(MarketReport, org_id, id_or_slug)

  def list_reports(opts \\ []) do
    MarketReport
    |> base_filters(opts)
    |> maybe_filter(:report_type, opts[:report_type])
    |> maybe_filter(:status, opts[:status])
    |> order_by([r], desc: r.inserted_at)
    |> paginate(opts)
    |> Repo.all()
  end

  @doc """
  Generate a market report's body via the LLM, store it as an artifact, and set
  the report's `summary` + `artifact_id` (status → ready). Returns
  `{:ok, report}` or `{:error, reason}`.
  """
  def generate_report(id, opts \\ []) do
    case get_report(id) do
      nil ->
        {:error, :not_found}

      report ->
        prompt = opts[:prompt] || default_report_prompt(report)

        result =
          MarketingContent.generate_artifact(prompt,
            %{organization_id: report.organization_id, project_id: report.project_id,
              kind: "document", title: report.title}, opts)

        case result do
          {:ok, %{artifact_id: artifact_id, content: content}} ->
            do_update(MarketReport, id, %{artifact_id: artifact_id, summary: String.slice(content, 0, 500), status: "ready"})

          {:error, reason} ->
            {:error, reason}
        end
    end
  end

  # ── Private ───────────────────────────────────────────────────

  defp resolve(schema, org_id, id_or_slug) do
    case NoizuPromptLingua.UUID.cast(id_or_slug) do
      {:ok, uuid} ->
        Repo.get(schema, uuid) || Repo.get_by(schema, organization_id: org_id, slug: id_or_slug)

      :error ->
        Repo.get_by(schema, organization_id: org_id, slug: id_or_slug)
    end
  end

  defp do_update(schema, id, attrs) do
    case Repo.get(schema, id) do
      nil -> {:error, :not_found}
      row -> row |> schema.changeset(attrs) |> Repo.update()
    end
  end

  defp insert_researched_keyword(org_id, project_id, topic, item, idx) do
    term = item["term"] || item[:term] || "keyword-#{idx}"

    create_keyword(%{
      organization_id: org_id,
      project_id: project_id,
      slug: slugify("#{topic}-#{term}-#{idx}"),
      term: term,
      intent: item["intent"] || item[:intent],
      volume: to_int(item["volume"] || item[:volume]),
      difficulty: to_int(item["difficulty"] || item[:difficulty]),
      cpc: item["cpc"] || item[:cpc],
      source: "llm"
    })
  end

  defp parse_keyword_json(text) do
    cleaned =
      text
      |> String.replace(~r/```json\s*/, "")
      |> String.replace(~r/```\s*/, "")
      |> String.trim()

    case Jason.decode(cleaned) do
      {:ok, list} when is_list(list) -> {:ok, list}
      {:ok, %{"keywords" => list}} when is_list(list) -> {:ok, list}
      _ -> {:error, :unparseable_keyword_json}
    end
  end

  defp default_report_prompt(report) do
    """
    Write a #{String.replace(report.report_type, "_", " ")} report titled "#{report.title}" in Markdown.
    Include: executive summary, market sizing/landscape, key trends, competitive positioning,
    opportunities and risks, and actionable recommendations.
    """
  end

  defp slugify(s) do
    s
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
    |> String.slice(0, 200)
  end

  defp to_int(nil), do: nil
  defp to_int(v) when is_integer(v), do: v
  defp to_int(v) when is_float(v), do: trunc(v)
  defp to_int(v) when is_binary(v) do
    case Integer.parse(v) do
      {n, _} -> n
      _ -> nil
    end
  end

  defp base_filters(q, opts) do
    q
    |> maybe_filter(:organization_id, opts[:organization_id])
    |> maybe_filter(:project_id, opts[:project_id])
    |> maybe_filter_tag(opts[:tag])
  end

  defp paginate(q, opts) do
    q
    |> limit(^(opts[:limit] || 100))
    |> offset(^(opts[:offset] || 0))
  end

  defp maybe_filter(q, _field, nil), do: q
  defp maybe_filter(q, :organization_id, v), do: where(q, [r], r.organization_id == ^v)
  defp maybe_filter(q, :project_id, v), do: where(q, [r], r.project_id == ^v)
  defp maybe_filter(q, :status, v), do: where(q, [r], r.status == ^v)
  defp maybe_filter(q, :intent, v), do: where(q, [r], r.intent == ^v)
  defp maybe_filter(q, :report_type, v), do: where(q, [r], r.report_type == ^v)

  defp maybe_filter_tag(q, nil), do: q
  defp maybe_filter_tag(q, tag), do: where(q, [r], ^tag in r.tags)
end
