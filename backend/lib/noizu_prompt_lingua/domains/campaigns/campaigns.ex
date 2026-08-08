defmodule NoizuPromptLingua.Domains.Campaigns do
  @moduledoc """
  Marketing campaign management: campaigns (SEO/PPC/email/social/content/display),
  ad groups, ad copy, landing pages, and domain names. Org-scoped (required) with
  an optional project; slugs unique within an organization (ad-group slugs unique
  within their campaign). Ad-copy and landing-page bodies are LLM-generated via
  `Domains.MarketingContent` and stored as artifacts.
  """
  import Ecto.Query, except: [update: 2]
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{Campaign, AdGroup, AdCopy, LandingPage, DomainName}
  alias NoizuPromptLingua.Domains.MarketingContent

  # ── Campaigns ─────────────────────────────────────────────────

  def create_campaign(attrs), do: %Campaign{} |> Campaign.changeset(attrs) |> Repo.insert()
  def get_campaign(id), do: Repo.get(Campaign, id)
  def resolve_campaign(org_id, id_or_slug), do: resolve(Campaign, org_id, id_or_slug)
  def update_campaign(id, attrs), do: do_update(Campaign, id, attrs)

  def list_campaigns(opts \\ []) do
    Campaign
    |> base_filters(opts)
    |> maybe_filter(:channel, opts[:channel])
    |> maybe_filter(:status, opts[:status])
    |> order_by([c], desc: c.inserted_at)
    |> paginate(opts)
    |> Repo.all()
  end

  def count_campaigns(org_id) do
    Campaign |> where([c], c.organization_id == ^org_id) |> Repo.aggregate(:count, :id)
  end

  # ── Ad groups ─────────────────────────────────────────────────

  def create_ad_group(attrs), do: %AdGroup{} |> AdGroup.changeset(attrs) |> Repo.insert()
  def get_ad_group(id), do: Repo.get(AdGroup, id)
  def update_ad_group(id, attrs), do: do_update(AdGroup, id, attrs)

  def list_ad_groups(campaign_id, opts \\ []) do
    AdGroup
    |> where([g], g.campaign_id == ^campaign_id)
    |> maybe_filter(:status, opts[:status])
    |> order_by([g], asc: g.name)
    |> paginate(opts)
    |> Repo.all()
  end

  # ── Ad copy ───────────────────────────────────────────────────

  def create_ad_copy(attrs) do
    attrs =
      Map.put_new_lazy(attrs, :variant_number, fn ->
        next_variant(attrs[:campaign_id], attrs[:ad_group_id])
      end)

    %AdCopy{} |> AdCopy.changeset(attrs) |> Repo.insert()
  end

  def get_ad_copy(id), do: Repo.get(AdCopy, id)

  def list_ad_copy(campaign_id, opts \\ []) do
    AdCopy
    |> where([a], a.campaign_id == ^campaign_id)
    |> maybe_filter(:ad_group_id, opts[:ad_group_id])
    |> maybe_filter(:status, opts[:status])
    |> order_by([a], asc: a.variant_number)
    |> paginate(opts)
    |> Repo.all()
  end

  def approve_ad_copy(id), do: set_ad_copy_status(id, "approved")
  def reject_ad_copy(id), do: set_ad_copy_status(id, "rejected")

  @doc """
  LLM-generate `count` ad-copy variants for a campaign (optionally an ad group),
  store the full copy as an artifact, and insert one AdCopy row per variant.
  Returns `{:ok, ad_copies}` or `{:error, reason}`.
  """
  def generate_ad_copy(campaign_id, opts \\ []) do
    case get_campaign(campaign_id) do
      nil ->
        {:error, :not_found}

      campaign ->
        count = opts[:count] || 3
        prompt = opts[:prompt] || default_ad_copy_prompt(campaign, count, opts[:ad_group_id])

        case MarketingContent.generate_artifact(
               prompt,
               %{
                 organization_id: campaign.organization_id,
                 project_id: campaign.project_id,
                 kind: "document",
                 title: "#{campaign.name} — ad copy"
               },
               opts
             ) do
          {:ok, %{artifact_id: artifact_id, content: content}} ->
            rows =
              for n <- 1..count do
                {:ok, row} =
                  create_ad_copy(%{
                    organization_id: campaign.organization_id,
                    project_id: campaign.project_id,
                    campaign_id: campaign_id,
                    ad_group_id: opts[:ad_group_id],
                    headline: "#{campaign.name} — variant #{n}",
                    body: variant_slice(content, n, count),
                    format: opts[:format] || "search",
                    artifact_id: artifact_id,
                    llm_generated: opts[:llm_generate] != false
                  })

                row
              end

            {:ok, rows}

          {:error, reason} ->
            {:error, reason}
        end
    end
  end

  # ── Landing pages ─────────────────────────────────────────────

  def create_landing_page(attrs),
    do: %LandingPage{} |> LandingPage.changeset(attrs) |> Repo.insert()

  def get_landing_page(id), do: Repo.get(LandingPage, id)
  def resolve_landing_page(org_id, id_or_slug), do: resolve(LandingPage, org_id, id_or_slug)
  def update_landing_page(id, attrs), do: do_update(LandingPage, id, attrs)

  def list_landing_pages(opts \\ []) do
    LandingPage
    |> base_filters(opts)
    |> maybe_filter(:campaign_id, opts[:campaign_id])
    |> maybe_filter(:status, opts[:status])
    |> order_by([p], desc: p.inserted_at)
    |> paginate(opts)
    |> Repo.all()
  end

  @doc """
  LLM-generate a landing page body, store it as an artifact, and set the page's
  `artifact_id` (status → generating then preserved). Returns `{:ok, page}`.
  """
  def generate_landing_page(id, opts \\ []) do
    case get_landing_page(id) do
      nil ->
        {:error, :not_found}

      page ->
        prompt = opts[:prompt] || default_landing_prompt(page)

        case MarketingContent.generate_artifact(
               prompt,
               %{
                 organization_id: page.organization_id,
                 project_id: page.project_id,
                 kind: "code",
                 title: page.title,
                 mime_type: "text/html"
               },
               opts
             ) do
          {:ok, %{artifact_id: artifact_id}} ->
            do_update(LandingPage, id, %{artifact_id: artifact_id})

          {:error, reason} ->
            {:error, reason}
        end
    end
  end

  # ── Domain names ──────────────────────────────────────────────

  def create_domain_name(attrs), do: %DomainName{} |> DomainName.changeset(attrs) |> Repo.insert()
  def get_domain_name(id), do: Repo.get(DomainName, id)
  def resolve_domain_name(org_id, id_or_slug), do: resolve(DomainName, org_id, id_or_slug)
  def update_domain_name(id, attrs), do: do_update(DomainName, id, attrs)

  def list_domain_names(opts \\ []) do
    DomainName
    |> base_filters(opts)
    |> maybe_filter(:status, opts[:status])
    |> order_by([d], asc: d.name)
    |> paginate(opts)
    |> Repo.all()
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

  defp set_ad_copy_status(id, status) do
    case get_ad_copy(id) do
      nil -> {:error, :not_found}
      row -> row |> AdCopy.changeset(%{status: status}) |> Repo.update()
    end
  end

  defp next_variant(campaign_id, ad_group_id) do
    query =
      AdCopy
      |> where([a], a.campaign_id == ^campaign_id)

    query =
      if ad_group_id do
        where(query, [a], a.ad_group_id == ^ad_group_id)
      else
        where(query, [a], is_nil(a.ad_group_id))
      end

    (query |> select([a], max(a.variant_number)) |> Repo.one() || 0) + 1
  end

  defp variant_slice(content, n, count) do
    len = max(div(String.length(content), count), 1)
    String.slice(content, (n - 1) * len, len)
  end

  defp default_ad_copy_prompt(campaign, count, ad_group_id) do
    scope = if ad_group_id, do: " for ad group #{ad_group_id}", else: ""

    """
    Write #{count} distinct ad copy variants for the #{campaign.channel} campaign "#{campaign.name}"#{scope}.
    Objective: #{campaign.objective || "drive conversions"}.
    For each variant provide: a punchy headline (<=30 chars), a description (<=90 chars),
    and a clear call to action. Separate variants with a line of three dashes (---).
    """
  end

  defp default_landing_prompt(page) do
    """
    Write the HTML body for a marketing landing page titled "#{page.title}".
    Headline: #{page.headline || page.title}.
    Include a hero section, 3 benefit blocks, social proof, and a prominent call-to-action.
    Return semantic, self-contained HTML (no external assets).
    """
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
  defp maybe_filter(q, :campaign_id, v), do: where(q, [r], r.campaign_id == ^v)
  defp maybe_filter(q, :ad_group_id, v), do: where(q, [r], r.ad_group_id == ^v)
  defp maybe_filter(q, :channel, v), do: where(q, [r], r.channel == ^v)
  defp maybe_filter(q, :status, v), do: where(q, [r], r.status == ^v)

  defp maybe_filter_tag(q, nil), do: q
  defp maybe_filter_tag(q, tag), do: where(q, [r], ^tag in r.tags)
end
