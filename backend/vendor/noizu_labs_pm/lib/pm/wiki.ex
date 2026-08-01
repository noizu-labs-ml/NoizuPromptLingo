defmodule Noizu.PM.Wiki do
  @moduledoc """
  Wiki domain context: spaces and pages.

  Spaces are org-scoped (optionally project-scoped). Pages live in a space and
  may nest. Page comments, attachments, and reactions are NOT stored in dedicated
  wiki_* tables here — they hang off the shared polymorphic `pm_comments` /
  `pm_attachments` / `pm_reactions` tables with entity_type "wiki_page".
  """

  import Ecto.Query, except: [update: 2]
  alias Noizu.PM.Repo
  alias Noizu.PM.Schema.Wiki.{Space, Page}
  alias Noizu.PM.Schema.Polymorphic.{PmComment, PmAttachment, PmReaction}

  @page_entity "wiki_page"

  # ── Spaces ────────────────────────────────────────────────────────────────

  def list_spaces(opts \\ []) do
    Space
    |> maybe_where(:organization_id, opts[:organization_id])
    |> maybe_where(:project_id, opts[:project_id])
    |> maybe_search([:name, :slug], opts[:search])
    |> order_by([s], asc: s.name)
    |> limit(^(opts[:limit] || 100))
    |> offset(^(opts[:offset] || 0))
    |> Repo.all()
  end

  def get_space(id), do: Repo.get(Space, id)

  def get_space_by_slug(org_id, slug),
    do: Repo.get_by(Space, organization_id: org_id, slug: slug)

  def create_space(attrs) do
    attrs = default_slug(attrs, :name)

    %Space{}
    |> Space.changeset(attrs)
    |> Repo.insert()
  end

  def update_space(id, attrs) do
    case get_space(id) do
      nil -> {:error, :not_found}
      space -> space |> Space.changeset(attrs) |> Repo.update()
    end
  end

  def delete_space(id) do
    case get_space(id) do
      nil -> {:error, :not_found}
      space -> Repo.delete(space)
    end
  end

  # ── Pages ─────────────────────────────────────────────────────────────────

  def list_pages(space_id, opts \\ []) do
    Page
    |> where([p], p.space_id == ^space_id)
    |> maybe_where(:parent_id, opts[:parent_id])
    |> maybe_search([:title, :slug], opts[:search])
    |> order_by([p], asc: p.position, asc: p.title)
    |> limit(^(opts[:limit] || 200))
    |> Repo.all()
  end

  def get_page(id), do: Repo.get(Page, id)

  def create_page(attrs) do
    attrs = default_slug(attrs, :title)

    %Page{}
    |> Page.changeset(attrs)
    |> Repo.insert()
  end

  def update_page(id, attrs) do
    case get_page(id) do
      nil -> {:error, :not_found}
      page -> page |> Page.changeset(attrs) |> Repo.update()
    end
  end

  def delete_page(id) do
    case get_page(id) do
      nil -> {:error, :not_found}
      page -> Repo.delete(page)
    end
  end

  # ── Comments (polymorphic pm_comments, entity_type "wiki_page") ───────────

  def list_comments(page_id) do
    PmComment
    |> where([c], c.entity_type == ^@page_entity and c.entity_id == ^page_id)
    |> order_by([c], asc: c.inserted_at)
    |> Repo.all()
  end

  def get_comment(id), do: Repo.get(PmComment, id)

  def create_comment(attrs) do
    %PmComment{}
    |> PmComment.changeset(Map.put(attrs, :entity_type, @page_entity))
    |> Repo.insert()
  end

  def delete_comment(id) do
    case get_comment(id) do
      nil -> {:error, :not_found}
      comment -> Repo.delete(comment)
    end
  end

  # ── Attachments (polymorphic pm_attachments) ──────────────────────────────

  def list_attachments(page_id) do
    PmAttachment
    |> where([a], a.entity_type == ^@page_entity and a.entity_id == ^page_id)
    |> order_by([a], asc: a.inserted_at)
    |> Repo.all()
  end

  def get_attachment(id), do: Repo.get(PmAttachment, id)

  def create_attachment(attrs) do
    %PmAttachment{}
    |> PmAttachment.changeset(Map.put(attrs, :entity_type, @page_entity))
    |> Repo.insert()
  end

  def delete_attachment(id) do
    case get_attachment(id) do
      nil -> {:error, :not_found}
      attachment -> Repo.delete(attachment)
    end
  end

  # ── Reactions (polymorphic pm_reactions) ──────────────────────────────────

  def list_reactions(page_id) do
    PmReaction
    |> where([r], r.entity_type == ^@page_entity and r.entity_id == ^page_id)
    |> order_by([r], asc: r.inserted_at)
    |> Repo.all()
  end

  @doc "Idempotent: re-adding the same (page, emoji, persona) returns the existing row."
  def add_reaction(attrs) do
    %PmReaction{}
    |> PmReaction.changeset(Map.put(attrs, :entity_type, @page_entity))
    |> Repo.insert(
      on_conflict: :nothing,
      conflict_target: [:entity_type, :entity_id, :persona, :emoji]
    )
    |> case do
      {:ok, %PmReaction{id: nil}} ->
        {:ok,
         Repo.get_by(PmReaction,
           entity_type: @page_entity,
           entity_id: attrs[:entity_id] || attrs["entity_id"],
           persona: attrs[:persona] || attrs["persona"],
           emoji: attrs[:emoji] || attrs["emoji"]
         )}

      other ->
        other
    end
  end

  def remove_reaction(page_id, emoji, persona) do
    {count, _} =
      PmReaction
      |> where(
        [r],
        r.entity_type == ^@page_entity and r.entity_id == ^page_id and
          r.emoji == ^emoji and r.persona == ^persona
      )
      |> Repo.delete_all()

    if count > 0, do: :ok, else: {:error, :not_found}
  end

  # ── Counts (overview) ─────────────────────────────────────────────────────

  def count_spaces(org_id) do
    Space |> where([s], s.organization_id == ^org_id) |> Repo.aggregate(:count, :id)
  end

  def count_pages(org_id) do
    Page
    |> join(:inner, [p], s in Space, on: s.id == p.space_id)
    |> where([_p, s], s.organization_id == ^org_id)
    |> Repo.aggregate(:count, :id)
  end

  # ── Helpers ───────────────────────────────────────────────────────────────

  defp maybe_where(query, _field, nil), do: query
  defp maybe_where(query, field, value), do: where(query, [r], field(r, ^field) == ^value)

  defp maybe_search(query, _fields, nil), do: query
  defp maybe_search(query, _fields, ""), do: query

  defp maybe_search(query, [a, b], search) do
    pattern = "%#{search}%"
    where(query, [r], ilike(field(r, ^a), ^pattern) or ilike(field(r, ^b), ^pattern))
  end

  # Derive a slug from the given source field when none is provided.
  defp default_slug(attrs, source) do
    slug = attrs[:slug] || attrs["slug"]
    name = attrs[source] || attrs[Atom.to_string(source)]

    cond do
      is_binary(slug) and slug != "" -> attrs
      is_binary(name) -> Map.put(attrs, :slug, slugify(name))
      true -> attrs
    end
  end

  defp slugify(value) do
    value
    |> String.downcase()
    |> String.trim()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
  end
end
