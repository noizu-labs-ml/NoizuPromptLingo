defmodule NoizuPromptLingua.Domains.Personas do
  @moduledoc """
  Persona management. A persona has a name, bio/role, a work log/journal
  (append-only `PersonaJournalEntry` rows), and a personal knowledge base
  (`PersonaKnowledgeEntry` rows). Personas are keyed to an organization
  (required) or to an org.project (optional `project_id`).

  The *effective* list for a project is the union of that project's personas
  and the org-level personas (those with no `project_id`). Pass
  `project_id:` together with `include_org_level: true` to `list/1` to get it.
  Slugs are unique within an organization, so the two scopes never collide.
  """
  import Ecto.Query, except: [update: 2]
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{Persona, PersonaJournalEntry, PersonaKnowledgeEntry}

  # ── Persona CRUD ──────────────────────────────────────────────

  def create(attrs, _opts \\ []) do
    %Persona{} |> Persona.changeset(attrs) |> Repo.insert()
  end

  def get(id), do: Repo.get(Persona, id)

  @doc "Resolve an id or (org-scoped) slug to a persona."
  def resolve(org_id, id_or_slug) do
    case NoizuPromptLingua.UUID.cast(id_or_slug) do
      {:ok, uuid} ->
        Repo.get(Persona, uuid) || Repo.get_by(Persona, organization_id: org_id, slug: id_or_slug)

      :error ->
        Repo.get_by(Persona, organization_id: org_id, slug: id_or_slug)
    end
  end

  def update(id, attrs, _opts \\ []) do
    case get(id) do
      nil -> {:error, :not_found}
      persona -> persona |> Persona.changeset(attrs) |> Repo.update()
    end
  end

  def delete(id) do
    case get(id) do
      nil -> {:error, :not_found}
      persona -> Repo.delete(persona)
    end
  end

  def set_status(id, status) do
    case get(id) do
      nil -> {:error, :not_found}
      persona -> persona |> Persona.changeset(%{status: status}) |> Repo.update()
    end
  end

  def archive(id), do: set_status(id, "archived")
  def activate(id), do: set_status(id, "active")

  def list(opts \\ []) do
    Persona
    |> maybe_filter(:organization_id, opts[:organization_id])
    |> scope_project(opts[:project_id], opts[:include_org_level])
    |> maybe_filter(:status, opts[:status])
    |> maybe_filter_tag(opts[:tag])
    |> order_by([p], asc: p.name)
    |> limit(^(opts[:limit] || 100))
    |> offset(^(opts[:offset] || 0))
    |> Repo.all()
  end

  # Project scoping. By default `project_id:` matches that project exactly.
  # With `include_org_level: true` the result is the *effective* list for the
  # project: its own personas plus org-level (no-project) personas. With no
  # `project_id` the org-level + every-project listing is returned unchanged.
  defp scope_project(q, nil, _), do: q

  defp scope_project(q, project_id, true),
    do: where(q, [r], r.project_id == ^project_id or is_nil(r.project_id))

  defp scope_project(q, project_id, _),
    do: where(q, [r], r.project_id == ^project_id)

  def count(org_id) do
    Persona |> where([p], p.organization_id == ^org_id) |> Repo.aggregate(:count, :id)
  end

  # ── Journal / work log ────────────────────────────────────────

  def add_journal_entry(persona_id, attrs) do
    attrs = Map.put(attrs, :persona_id, persona_id)
    %PersonaJournalEntry{} |> PersonaJournalEntry.changeset(attrs) |> Repo.insert()
  end

  def list_journal(persona_id, opts \\ []) do
    PersonaJournalEntry
    |> where([j], j.persona_id == ^persona_id)
    |> maybe_filter(:category, opts[:category])
    |> order_by([j], desc: j.inserted_at)
    |> limit(^(opts[:limit] || 50))
    |> offset(^(opts[:offset] || 0))
    |> Repo.all()
  end

  def delete_journal_entry(id) do
    case Repo.get(PersonaJournalEntry, id) do
      nil -> {:error, :not_found}
      entry -> Repo.delete(entry)
    end
  end

  # ── Knowledge base ────────────────────────────────────────────

  def add_knowledge(persona_id, attrs) do
    attrs = Map.put(attrs, :persona_id, persona_id)
    %PersonaKnowledgeEntry{} |> PersonaKnowledgeEntry.changeset(attrs) |> Repo.insert()
  end

  def update_knowledge(id, attrs) do
    case Repo.get(PersonaKnowledgeEntry, id) do
      nil -> {:error, :not_found}
      entry -> entry |> PersonaKnowledgeEntry.changeset(attrs) |> Repo.update()
    end
  end

  def get_knowledge(persona_id, id_or_slug) do
    case NoizuPromptLingua.UUID.cast(id_or_slug) do
      {:ok, uuid} ->
        Repo.get(PersonaKnowledgeEntry, uuid) ||
          Repo.get_by(PersonaKnowledgeEntry, persona_id: persona_id, slug: id_or_slug)

      :error ->
        Repo.get_by(PersonaKnowledgeEntry, persona_id: persona_id, slug: id_or_slug)
    end
  end

  def list_knowledge(persona_id, opts \\ []) do
    PersonaKnowledgeEntry
    |> where([k], k.persona_id == ^persona_id)
    |> maybe_filter_tag(opts[:tag])
    |> order_by([k], asc: k.title)
    |> limit(^(opts[:limit] || 100))
    |> Repo.all()
  end

  def delete_knowledge(id) do
    case Repo.get(PersonaKnowledgeEntry, id) do
      nil -> {:error, :not_found}
      entry -> Repo.delete(entry)
    end
  end

  # ── Private ───────────────────────────────────────────────────

  defp maybe_filter(q, _field, nil), do: q
  defp maybe_filter(q, :organization_id, v), do: where(q, [r], r.organization_id == ^v)
  defp maybe_filter(q, :status, v), do: where(q, [r], r.status == ^v)
  defp maybe_filter(q, :category, v), do: where(q, [r], r.category == ^v)

  defp maybe_filter_tag(q, nil), do: q
  defp maybe_filter_tag(q, tag), do: where(q, [r], ^tag in r.tags)
end
