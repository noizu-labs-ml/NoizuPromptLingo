defmodule NoizuPromptLingua.Domains.Customers do
  @moduledoc """
  Customer/market audience management: customer personas (ICPs) and customer
  segments. The marketing audience model — distinct from the agent `Personas`
  domain. Org-scoped (required) with an optional project; slugs are unique within
  an organization.

  Customer personas can be linked to tickets via the shared `Domains.Links`
  (polymorphic `ticket_entity_links`), tying product/engineering work to the
  audience it serves. A persona's long-form profile (`summary` + `artifact_id`)
  may be LLM-drafted via `Domains.MarketingContent`.
  """
  import Ecto.Query, except: [update: 2]
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{CustomerPersona, CustomerSegment}
  alias NoizuPromptLingua.Domains.{Links, MarketingContent}

  @entity_type "customer_persona"

  # ── Personas ──────────────────────────────────────────────────

  def create_persona(attrs), do: %CustomerPersona{} |> CustomerPersona.changeset(attrs) |> Repo.insert()

  def get_persona(id), do: Repo.get(CustomerPersona, id)

  def resolve_persona(org_id, id_or_slug) do
    case Ecto.UUID.cast(id_or_slug) do
      {:ok, uuid} ->
        Repo.get(CustomerPersona, uuid) || Repo.get_by(CustomerPersona, organization_id: org_id, slug: id_or_slug)

      :error ->
        Repo.get_by(CustomerPersona, organization_id: org_id, slug: id_or_slug)
    end
  end

  def update_persona(id, attrs) do
    case get_persona(id) do
      nil -> {:error, :not_found}
      persona -> persona |> CustomerPersona.changeset(attrs) |> Repo.update()
    end
  end

  def delete_persona(id) do
    case get_persona(id) do
      nil -> {:error, :not_found}
      persona -> Repo.delete(persona)
    end
  end

  def list_personas(opts \\ []) do
    CustomerPersona
    |> maybe_filter(:organization_id, opts[:organization_id])
    |> maybe_filter(:project_id, opts[:project_id])
    |> maybe_filter(:segment_id, opts[:segment_id])
    |> maybe_filter(:status, opts[:status])
    |> maybe_filter_tag(opts[:tag])
    |> order_by([p], asc: p.name)
    |> limit(^(opts[:limit] || 100))
    |> offset(^(opts[:offset] || 0))
    |> Repo.all()
  end

  def count_personas(org_id) do
    CustomerPersona |> where([p], p.organization_id == ^org_id) |> Repo.aggregate(:count, :id)
  end

  @doc """
  Draft a persona's long-form profile via the LLM, store it as an artifact, and
  update the persona's `summary` + `artifact_id`. Returns `{:ok, persona}` or
  `{:error, reason}`. With `llm_generate: false` the prompt text is echoed (no
  provider needed) so the flow stays exercisable offline.
  """
  def draft_persona(id, opts \\ []) do
    case get_persona(id) do
      nil ->
        {:error, :not_found}

      persona ->
        prompt = opts[:prompt] || default_persona_prompt(persona)

        case MarketingContent.generate_artifact(prompt,
               %{organization_id: persona.organization_id, project_id: persona.project_id,
                 kind: "document", title: "#{persona.name} — customer persona profile"},
               opts) do
          {:ok, %{artifact_id: artifact_id, content: content}} ->
            update_persona(id, %{artifact_id: artifact_id, summary: summarize(content)})

          {:error, reason} ->
            {:error, reason}
        end
    end
  end

  # ── Segments ──────────────────────────────────────────────────

  def create_segment(attrs), do: %CustomerSegment{} |> CustomerSegment.changeset(attrs) |> Repo.insert()

  def get_segment(id), do: Repo.get(CustomerSegment, id)

  def resolve_segment(org_id, id_or_slug) do
    case Ecto.UUID.cast(id_or_slug) do
      {:ok, uuid} ->
        Repo.get(CustomerSegment, uuid) || Repo.get_by(CustomerSegment, organization_id: org_id, slug: id_or_slug)

      :error ->
        Repo.get_by(CustomerSegment, organization_id: org_id, slug: id_or_slug)
    end
  end

  def update_segment(id, attrs) do
    case get_segment(id) do
      nil -> {:error, :not_found}
      segment -> segment |> CustomerSegment.changeset(attrs) |> Repo.update()
    end
  end

  def list_segments(opts \\ []) do
    CustomerSegment
    |> maybe_filter(:organization_id, opts[:organization_id])
    |> maybe_filter(:project_id, opts[:project_id])
    |> maybe_filter(:status, opts[:status])
    |> maybe_filter_tag(opts[:tag])
    |> order_by([s], asc: s.name)
    |> limit(^(opts[:limit] || 100))
    |> offset(^(opts[:offset] || 0))
    |> Repo.all()
  end

  # ── Ticket links ──────────────────────────────────────────────

  def link_ticket(persona_id, ticket_id, opts \\ []),
    do: Links.link_entity(ticket_id, @entity_type, persona_id, opts)

  def unlink_ticket(persona_id, ticket_id, opts \\ []),
    do: Links.unlink_entity(ticket_id, @entity_type, persona_id, opts)

  def linked_tickets(persona_id), do: Links.get_ticket_links_for(@entity_type, persona_id)

  # ── Private ───────────────────────────────────────────────────

  defp default_persona_prompt(persona) do
    """
    Write a detailed customer persona profile in Markdown for "#{persona.name}"#{archetype(persona)}.
    Goals: #{Enum.join(persona.goals, ", ")}.
    Pain points: #{Enum.join(persona.pains, ", ")}.
    Channels: #{Enum.join(persona.channels, ", ")}.
    Cover: a day-in-the-life narrative, buying triggers, objections and how to overcome them,
    preferred messaging tone, and the top 3 value propositions that resonate with this persona.
    """
  end

  defp archetype(%{archetype: a}) when is_binary(a) and a != "", do: " (archetype: #{a})"
  defp archetype(_), do: ""

  defp summarize(content) do
    content |> String.slice(0, 500)
  end

  defp maybe_filter(q, _field, nil), do: q
  defp maybe_filter(q, :organization_id, v), do: where(q, [r], r.organization_id == ^v)
  defp maybe_filter(q, :project_id, v), do: where(q, [r], r.project_id == ^v)
  defp maybe_filter(q, :segment_id, v), do: where(q, [r], r.segment_id == ^v)
  defp maybe_filter(q, :status, v), do: where(q, [r], r.status == ^v)

  defp maybe_filter_tag(q, nil), do: q
  defp maybe_filter_tag(q, tag), do: where(q, [r], ^tag in r.tags)
end
