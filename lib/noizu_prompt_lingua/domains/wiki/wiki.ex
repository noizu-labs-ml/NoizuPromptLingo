defmodule NoizuPromptLingua.Domains.Wiki do
  import Ecto.Query, except: [update: 2]
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{WikiSpace, WikiPage, WikiPermission}
  alias NoizuPromptLingua.Domains.Artifacts

  # ── Spaces ────────────────────────────────────────────────────

  def create_space(attrs) do
    %WikiSpace{} |> WikiSpace.changeset(attrs) |> Repo.insert()
  end

  def get_space(id_or_slug) do
    case Ecto.UUID.cast(id_or_slug) do
      {:ok, _} -> Repo.get(WikiSpace, id_or_slug)
      :error -> Repo.get_by(WikiSpace, slug: id_or_slug)
    end
  end

  def list_spaces do
    WikiSpace |> order_by([s], asc: s.name) |> Repo.all()
  end

  def space_count, do: Repo.aggregate(WikiSpace, :count)

  def page_count, do: Repo.aggregate(WikiPage, :count)

  # ── Pages ─────────────────────────────────────────────────────

  def create_page(attrs) do
    content = attrs[:content] || attrs["content"]
    tags = attrs[:tags] || attrs["tags"] || []
    page_attrs = Map.drop(attrs, [:content, "content"])

    Repo.transaction(fn ->
      with {:ok, artifact} <- Artifacts.create(%{kind: "wiki", title: attrs[:title] || attrs["title"], content: content}),
           {:ok, page} <- %WikiPage{}
             |> WikiPage.changeset(Map.put(page_attrs, :artifact_id, artifact.id) |> Map.put(:tags, tags))
             |> Repo.insert() do
        page
      else
        {:error, cs} -> Repo.rollback(cs)
      end
    end)
  end

  def get_page(page_id, revision_id \\ nil) do
    case Repo.get(WikiPage, page_id) do
      nil -> nil
      page ->
        case Artifacts.get(page.artifact_id, revision_id) do
          nil -> {page, nil}
          {_artifact, revision} -> {page, revision}
        end
    end
  end

  def edit_page(page_id, attrs) do
    case Repo.get(WikiPage, page_id) do
      nil -> {:error, :not_found}
      page ->
        content = attrs[:content] || attrs["content"]
        note = attrs[:edit_message] || attrs["edit_message"]

        Repo.transaction(fn ->
          {:ok, revision} = Artifacts.add_revision(page.artifact_id, content, note)

          page_updates = %{}
          page_updates = if t = attrs[:title] || attrs["title"], do: Map.put(page_updates, :title, t), else: page_updates
          page_updates = if t = attrs[:tags] || attrs["tags"], do: Map.put(page_updates, :tags, t), else: page_updates

          {:ok, updated_page} =
            if page_updates == %{} do
              {:ok, page}
            else
              page |> WikiPage.changeset(page_updates) |> Repo.update()
            end

          {updated_page, revision}
        end)
    end
  end

  def list_pages(opts \\ []) do
    WikiPage
    |> maybe_filter(:space_id, opts[:space_id])
    |> maybe_filter(:parent_page_id, opts[:parent_page_id])
    |> maybe_filter_tag(opts[:tag])
    |> maybe_search_title(opts[:search])
    |> order_by([p], desc: p.updated_at)
    |> limit(^(opts[:limit] || 50))
    |> offset(^(opts[:offset] || 0))
    |> Repo.all()
  end

  # ── Permissions ───────────────────────────────────────────────

  def grant_permission(attrs) do
    %WikiPermission{}
    |> WikiPermission.changeset(attrs)
    |> Repo.insert(on_conflict: {:replace, [:permission, :updated_at]}, conflict_target: [:entity_type, :entity_id, :persona])
  end

  def revoke_permission(entity_type, entity_id, persona) do
    case Repo.get_by(WikiPermission, entity_type: entity_type, entity_id: entity_id, persona: persona) do
      nil -> {:error, :not_found}
      perm -> Repo.delete(perm)
    end
  end

  def list_permissions(entity_type, entity_id) do
    WikiPermission
    |> where([p], p.entity_type == ^entity_type and p.entity_id == ^entity_id)
    |> Repo.all()
  end

  # ── Private ───────────────────────────────────────────────────

  defp maybe_filter(q, _field, nil), do: q
  defp maybe_filter(q, :space_id, v), do: where(q, [p], p.space_id == ^v)
  defp maybe_filter(q, :parent_page_id, v), do: where(q, [p], p.parent_page_id == ^v)

  defp maybe_filter_tag(q, nil), do: q
  defp maybe_filter_tag(q, tag), do: where(q, [p], ^tag in p.tags)

  defp maybe_search_title(q, nil), do: q
  defp maybe_search_title(q, s), do: where(q, [p], ilike(p.title, ^"%#{s}%"))
end
