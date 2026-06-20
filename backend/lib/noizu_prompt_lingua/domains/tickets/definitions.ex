defmodule NoizuPromptLingua.Domains.Tickets.Definitions do
  @moduledoc """
  Ticket field and type definitions, scoped at three levels:

    * **global**  — `organization_id` and `project_id` both NULL (system-wide)
    * **org**     — `organization_id` set, `project_id` NULL
    * **project** — both set

  Resolution precedence is project > org > global. A more-specific scope can
  override an inherited definition (same slug) or suppress it entirely with a
  `disabled: true` tombstone. Definitions are managed by id (slug is only unique
  within a scope); they are *resolved* by (org, project, slug).
  """
  import Ecto.Query, except: [update: 2]
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{TicketFieldDefinition, TicketTypeDefinition, TicketTypeField}

  @doc "Scope atom for a definition row: :global | :org | :project."
  def scope_of(%{project_id: pid}) when not is_nil(pid), do: :project
  def scope_of(%{organization_id: oid}) when not is_nil(oid), do: :org
  def scope_of(_), do: :global

  defp rank(:project), do: 3
  defp rank(:org), do: 2
  defp rank(:global), do: 1

  # ── Field Definitions ─────────────────────────────────────────

  def create_field(attrs), do: %TicketFieldDefinition{} |> TicketFieldDefinition.changeset(attrs) |> Repo.insert()

  def get_field(id), do: Repo.get(TicketFieldDefinition, id)

  def update_field(id, attrs) do
    case Repo.get(TicketFieldDefinition, id) do
      nil -> {:error, :not_found}
      field -> field |> TicketFieldDefinition.changeset(attrs) |> Repo.update()
    end
  end

  def delete_field(id) do
    case Repo.get(TicketFieldDefinition, id) do
      nil -> {:error, :not_found}
      field -> Repo.delete(field)
    end
  end

  @doc "All field definitions visible in a context (global ∪ org ∪ project), including disabled tombstones."
  def list_fields(org_id, project_id \\ nil) do
    TicketFieldDefinition
    |> where(^visible_scope(org_id, project_id))
    |> order_by([f], asc: f.slug)
    |> Repo.all()
  end

  @doc "Resolve a field slug for a context — most-specific non-disabled wins, or nil."
  def resolve_field(org_id, project_id, slug) do
    list_fields(org_id, project_id)
    |> Enum.filter(&(&1.slug == slug))
    |> pick_winner()
  end

  @doc "Effective (resolved) field set for a context — one row per slug, tombstones removed."
  def effective_fields(org_id, project_id \\ nil) do
    list_fields(org_id, project_id) |> resolve_set()
  end

  def upsert_field(attrs) do
    case Repo.get_by(TicketFieldDefinition, scope_keys(attrs)) do
      nil -> create_field(attrs)
      existing -> existing |> TicketFieldDefinition.changeset(attrs) |> Repo.update()
    end
  end

  @doc "The field defined at exactly this scope (not inherited), or nil."
  def get_field_in_scope(org_id, project_id, slug) do
    Repo.get_by(TicketFieldDefinition, organization_id: org_id, project_id: project_id, slug: slug)
  end

  # ── Type Definitions ──────────────────────────────────────────

  def create_type(attrs), do: %TicketTypeDefinition{} |> TicketTypeDefinition.changeset(attrs) |> Repo.insert()

  def get_type(id) do
    TicketTypeDefinition
    |> where([t], t.id == ^id and is_nil(t.deleted_at))
    |> preload(type_fields: :ticket_field_definition)
    |> Repo.one()
  end

  def update_type(id, attrs) do
    case get_type(id) do
      nil -> {:error, :not_found}
      type_def -> type_def |> TicketTypeDefinition.changeset(attrs) |> Repo.update()
    end
  end

  def delete_type(id) do
    case get_type(id) do
      nil -> {:error, :not_found}
      type_def -> type_def |> TicketTypeDefinition.changeset(%{deleted_at: DateTime.utc_now()}) |> Repo.update()
    end
  end

  @doc "All type definitions visible in a context, including disabled tombstones."
  def list_types(org_id, project_id \\ nil) do
    TicketTypeDefinition
    |> where([t], is_nil(t.deleted_at))
    |> where(^visible_scope(org_id, project_id))
    |> order_by([t], asc: t.name)
    |> preload(type_fields: :ticket_field_definition)
    |> Repo.all()
  end

  @doc "Resolve a type slug for a context — most-specific non-disabled wins, or nil."
  def resolve_type(org_id, project_id, slug) do
    list_types(org_id, project_id)
    |> Enum.filter(&(&1.slug == slug))
    |> pick_winner()
  end

  @doc "Effective (resolved) type set for a context — one row per slug, tombstones removed."
  def effective_types(org_id, project_id \\ nil) do
    list_types(org_id, project_id) |> resolve_set()
  end

  def upsert_type(attrs) do
    case Repo.get_by(TicketTypeDefinition, Keyword.put(scope_keys(attrs), :deleted_at, nil)) do
      nil -> create_type(attrs)
      existing -> existing |> TicketTypeDefinition.changeset(attrs) |> Repo.update()
    end
  end

  @doc "The type defined at exactly this scope (not inherited), or nil."
  def get_type_in_scope(org_id, project_id, slug) do
    Repo.get_by(TicketTypeDefinition,
      organization_id: org_id,
      project_id: project_id,
      slug: slug,
      deleted_at: nil
    )
  end

  # ── Type-Field Associations (by id) ───────────────────────────

  def add_field_to_type(type_id, field_id, opts \\ []) do
    %TicketTypeField{}
    |> TicketTypeField.changeset(%{
      ticket_type_definition_id: type_id,
      ticket_field_definition_id: field_id,
      required: Keyword.get(opts, :required, false),
      position: Keyword.get(opts, :position, 0)
    })
    |> Repo.insert(on_conflict: :nothing)
  end

  def remove_field_from_type(type_id, field_id) do
    {count, _} =
      TicketTypeField
      |> where([tf], tf.ticket_type_definition_id == ^type_id and tf.ticket_field_definition_id == ^field_id)
      |> Repo.delete_all()

    {:ok, count}
  end

  @doc "Assigned fields for a (preloaded) type definition, sorted by position."
  def type_field_list(%{type_fields: type_fields}) when is_list(type_fields) do
    type_fields
    |> Enum.sort_by(& &1.position)
    |> Enum.map(fn tf ->
      field = tf.ticket_field_definition
      %{
        id: field.id,
        slug: field.slug,
        label: field.label,
        field_type: field.field_type,
        options: field.options,
        default_value: field.default_value,
        required: tf.required,
        position: tf.position
      }
    end)
  end

  def type_field_list(_), do: []

  def get_status_workflow(org_id, project_id, slug) do
    case resolve_type(org_id, project_id, slug) do
      nil -> nil
      type_def -> type_def.status_workflow
    end
  end

  # ── Internals ─────────────────────────────────────────────────

  # Dynamic where: rows whose scope is visible from (org_id, project_id).
  defp visible_scope(nil, _project_id) do
    dynamic([d], is_nil(d.organization_id) and is_nil(d.project_id))
  end

  defp visible_scope(org_id, nil) do
    dynamic(
      [d],
      (is_nil(d.organization_id) and is_nil(d.project_id)) or
        (d.organization_id == ^org_id and is_nil(d.project_id))
    )
  end

  defp visible_scope(org_id, project_id) do
    dynamic(
      [d],
      (is_nil(d.organization_id) and is_nil(d.project_id)) or
        (d.organization_id == ^org_id and is_nil(d.project_id)) or
        (d.organization_id == ^org_id and d.project_id == ^project_id)
    )
  end

  # Most-specific row; returns nil when the winner is a disabled tombstone.
  defp pick_winner([]), do: nil
  defp pick_winner(rows) do
    winner = Enum.max_by(rows, &rank(scope_of(&1)))
    if winner.disabled, do: nil, else: winner
  end

  # Collapse a list of rows to the effective set (one per slug, tombstones out).
  defp resolve_set(rows) do
    rows
    |> Enum.group_by(& &1.slug)
    |> Enum.map(fn {_slug, group} -> pick_winner(group) end)
    |> Enum.reject(&is_nil/1)
    |> Enum.sort_by(& &1.slug)
  end

  defp scope_keys(attrs) do
    [
      organization_id: attrs[:organization_id] || attrs["organization_id"],
      project_id: attrs[:project_id] || attrs["project_id"],
      slug: attrs[:slug] || attrs["slug"]
    ]
  end
end
