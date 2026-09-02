defmodule NoizuPromptLingua.Domains.Wiki do
  @moduledoc """
  Wiki domain context: spaces, pages, comments, attachments, and reactions.

  Spaces are org-scoped (optionally project-scoped). Pages live in a space and
  may nest. Comments, attachments, and reactions hang off pages; reactions are
  polymorphic over pages and comments.
  """

  import Ecto.Query, except: [update: 2]
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Wiki.{Space, Page, Comment, Attachment, Reaction}

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
    attrs =
      attrs
      |> default_slug(:title)
      |> default_position()

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

  # ── Comments ──────────────────────────────────────────────────────────────

  def list_comments(page_id) do
    Comment
    |> where([c], c.page_id == ^page_id)
    |> order_by([c], asc: c.inserted_at)
    |> Repo.all()
  end

  def get_comment(id), do: Repo.get(Comment, id)

  def create_comment(attrs) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
    |> tap(&dispatch_comment/1)
  end

  # Best-effort notification fan-out for a wiki comment (wiki keeps its own
  # comment table rather than the shared Services.Comment). Never raises into the
  # caller's write path.
  defp dispatch_comment({:ok, %Comment{} = comment}) do
    try do
      NoizuPromptLingua.Domains.Notifications.Dispatch.comment(comment)
    rescue
      _ -> :ok
    end
  end

  defp dispatch_comment(_), do: :ok

  def delete_comment(id) do
    case get_comment(id) do
      nil -> {:error, :not_found}
      comment -> Repo.delete(comment)
    end
  end

  # ── Attachments ───────────────────────────────────────────────────────────

  def list_attachments(page_id) do
    Attachment
    |> where([a], a.page_id == ^page_id)
    |> order_by([a], asc: a.inserted_at)
    |> Repo.all()
  end

  def get_attachment(id), do: Repo.get(Attachment, id)

  def create_attachment(attrs) do
    %Attachment{}
    |> Attachment.changeset(attrs)
    |> Repo.insert()
  end

  def delete_attachment(id) do
    case get_attachment(id) do
      nil -> {:error, :not_found}
      attachment -> Repo.delete(attachment)
    end
  end

  # ── Reactions ─────────────────────────────────────────────────────────────

  def list_reactions(target_type, target_id) do
    Reaction
    |> where([r], r.target_type == ^target_type and r.target_id == ^target_id)
    |> order_by([r], asc: r.inserted_at)
    |> Repo.all()
  end

  @doc "Idempotent: re-adding the same (target, emoji, actor) returns the existing row."
  def add_reaction(attrs) do
    %Reaction{}
    |> Reaction.changeset(attrs)
    |> Repo.insert(
      on_conflict: :nothing,
      conflict_target: [:target_type, :target_id, :emoji, :actor]
    )
    |> case do
      {:ok, %Reaction{id: nil}} ->
        {:ok,
         Repo.get_by(Reaction,
           target_type: attrs[:target_type] || attrs["target_type"],
           target_id: attrs[:target_id] || attrs["target_id"],
           emoji: attrs[:emoji] || attrs["emoji"],
           actor: attrs[:actor] || attrs["actor"]
         )}

      other ->
        other
    end
    |> tap(&dispatch_reaction/1)
  end

  # Best-effort notification fan-out for a wiki reaction. Never raises into the
  # caller's write path.
  defp dispatch_reaction({:ok, %Reaction{} = reaction}) do
    try do
      NoizuPromptLingua.Domains.Notifications.Dispatch.reaction(reaction)
    rescue
      _ -> :ok
    end
  end

  defp dispatch_reaction(_), do: :ok

  def remove_reaction(target_type, target_id, emoji, actor) do
    {count, _} =
      Reaction
      |> where(
        [r],
        r.target_type == ^target_type and r.target_id == ^target_id and
          r.emoji == ^emoji and r.actor == ^actor
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

  # wiki_pages.position is NOT NULL (036-wiki) — a nil position used to raise a
  # Postgrex not_null_violation 500 (stage log c6295). Default to appending at
  # the end of the space: max(position) + 1, or 0 for the first page.
  defp default_position(%{space_id: space_id} = attrs) when not is_nil(space_id) do
    if is_nil(attrs[:position]) do
      max =
        Repo.one(
          from p in Page,
            where: p.space_id == ^space_id,
            select: max(p.position)
        ) || -1

      Map.put(attrs, :position, max + 1)
    else
      attrs
    end
  end

  defp default_position(attrs), do: attrs

  defp slugify(value) do
    value
    |> String.downcase()
    |> String.trim()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
  end
end
