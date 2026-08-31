defmodule NoizuPromptLingua.Domains.Tickets.Definitions do
  @moduledoc """
  Ticket field and type definitions, now served by the TRP shared-key plane
  (`/api/v1/organizations/:org_id/definitions/*`, docs/api/shared-key-api.md
  §4.4/§4.5) through `NoizuPromptLingua.TRP` (read-through cache, 300s TTL,
  write-bust).

  Scope model unchanged: global / org / project with resolution precedence
  project > org > global and `disabled: true` tombstones. TRP owns the rows;
  this module re-applies the local resolution rules over the returned scoped
  rows so `resolve_*` / `effective_*` semantics are identical.

  Shapes: rows return as atom-keyed maps in the old
  `TicketFieldDefinition` / `TicketTypeDefinition` struct shapes (see
  `NoizuPromptLingua.TRP.Shapes`), so controllers/MCP tools keep rendering the
  same fields. Validation failures return `{:error, %TRP.Error{}}` (422) where
  changesets used to be returned.
  """

  alias NoizuPromptLingua.TRP

  @doc "Scope atom for a definition row: :global | :org | :project."
  def scope_of(%{project_id: pid}) when not is_nil(pid), do: :project
  def scope_of(%{organization_id: oid}) when not is_nil(oid), do: :org
  def scope_of(_), do: :global

  defp rank(:project), do: 3
  defp rank(:org), do: 2
  defp rank(:global), do: 1

  # ── Field Definitions ─────────────────────────────────────────

  @doc "Create a field definition. Requires `:organization_id` (TRP has no shared-key global writes)."
  def create_field(attrs) do
    org(attrs) |> org_error() |> do_create_field(attrs)
  end

  defp do_create_field({:error, _} = err, _attrs), do: err

  defp do_create_field(org_id, attrs) do
    TRP.create_field(org_id, body(attrs))
  end

  @doc "Get a field definition by id. Org is resolved from the TRP key scope."
  def get_field(id), do: scan_orgs(fn org -> TRP.get_field(org, id) end)

  def update_field(id, attrs) do
    with_scanned_org(fn org ->
      case TRP.update_field(org, id, body(attrs)) do
        {:error, %NoizuPromptLingua.TRP.Error{status: 404}} -> {:error, :not_found}
        other -> other
      end
    end)
  end

  def delete_field(id) do
    with_scanned_org(fn org ->
      case TRP.delete_field(org, id) do
        {:ok, _} -> {:ok, nil}
        {:error, :not_found} -> {:error, :not_found}
        {:error, _} = err -> err
      end
    end)
  end

  @doc "All field definitions visible in a context (global ∪ org ∪ project), including disabled tombstones."
  def list_fields(org_id, project_id \\ nil) do
    case TRP.list_fields(org_id, project_id) do
      rows when is_list(rows) ->
        rows |> filter_visible(org_id, project_id) |> Enum.sort_by(& &1.slug)

      {:error, _} ->
        []
    end
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
    org_id = attrs[:organization_id] || attrs["organization_id"]
    project_id = attrs[:project_id] || attrs["project_id"]
    slug = attrs[:slug] || attrs["slug"]

    case get_field_in_scope(org_id, project_id, slug) do
      nil -> create_field(attrs)
      existing -> update_field(existing.id, attrs)
    end
  end

  @doc "The field defined at exactly this scope (not inherited), or nil."
  def get_field_in_scope(org_id, project_id, slug) do
    list_fields(org_id, project_id)
    |> Enum.find(fn f ->
      f.slug == slug and f.organization_id == org_id and f.project_id == project_id
    end)
  end

  # ── Type Definitions ──────────────────────────────────────────

  @doc "Create a type definition. Requires `:organization_id`."
  def create_type(attrs) do
    org(attrs) |> org_error() |> do_create_type(attrs)
  end

  defp do_create_type({:error, _} = err, _attrs), do: err

  defp do_create_type(org_id, attrs) do
    TRP.create_type(org_id, body(attrs))
  end

  @doc "Get a (non-deleted) type definition with fields preloaded. Org resolved from key scope."
  def get_type(id), do: scan_orgs(fn org -> TRP.get_type(org, id) end)

  def update_type(id, attrs) do
    with_scanned_org(fn org ->
      case TRP.update_type(org, id, body(attrs)) do
        {:error, %NoizuPromptLingua.TRP.Error{status: 404}} -> {:error, :not_found}
        other -> other
      end
    end)
  end

  @doc "Soft delete via TRP (deleted_at). `{:error, :not_found}` when absent."
  def delete_type(id) do
    with_scanned_org(fn org ->
      case TRP.delete_type(org, id) do
        {:ok, _} -> {:ok, nil}
        {:error, :not_found} -> {:error, :not_found}
        {:error, _} = err -> err
      end
    end)
  end

  @doc "All type definitions visible in a context, including disabled tombstones."
  def list_types(org_id, project_id \\ nil) do
    case TRP.list_types(org_id, project_id) do
      rows when is_list(rows) ->
        rows |> filter_visible(org_id, project_id) |> reject_deleted() |> Enum.sort_by(& &1.name)

      {:error, _} ->
        []
    end
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
    org_id = attrs[:organization_id] || attrs["organization_id"]
    project_id = attrs[:project_id] || attrs["project_id"]
    slug = attrs[:slug] || attrs["slug"]

    case get_type_in_scope(org_id, project_id, slug) do
      nil -> create_type(attrs)
      existing -> update_type(existing.id, attrs)
    end
  end

  @doc "The type defined at exactly this scope (not inherited), or nil."
  def get_type_in_scope(org_id, project_id, slug) do
    list_types(org_id, project_id)
    |> Enum.find(fn t ->
      t.slug == slug and t.organization_id == org_id and t.project_id == project_id
    end)
  end

  # ── Type-Field Associations (by id) ───────────────────────────

  @doc """
  Attach a field to a type. TRP's `fields` body REPLACES the association set
  (spec §4.4), so this is a read-modify-write: current set + the new entry.
  """
  def add_field_to_type(type_id, field_id, opts \\ []) do
    required = Keyword.get(opts, :required, false)
    position = Keyword.get(opts, :position, 0)

    with_scanned_org(fn org ->
      case TRP.get_type(org, type_id) do
        nil ->
          {:error, :not_found}

        {:error, _} = err ->
          err

        type_def ->
          entry = %{id: field_id, required: required, position: position}
          fields = merge_type_field(type_def.type_fields, entry)
          TRP.add_type_fields(org, type_id, fields)
      end
    end)
  end

  def remove_field_from_type(type_id, field_id) do
    with_scanned_org(fn org ->
      case TRP.remove_type_field(org, type_id, field_id) do
        {:ok, _} -> {:ok, 1}
        {:error, :not_found} -> {:ok, 0}
        {:error, _} = err -> err
      end
    end)
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

  # Legacy visible_scope semantics: global ∪ (org, nil) ∪ (org, project) — the
  # project half only when a project context is given. TRP may return a wider
  # set (its ?project_id= filter is advisory), so re-filter client-side.
  defp filter_visible(rows, org_id, project_id) do
    Enum.filter(rows, fn row ->
      (is_nil(row.organization_id) and is_nil(row.project_id)) or
        (row.organization_id == org_id and is_nil(row.project_id)) or
        (not is_nil(project_id) and row.organization_id == org_id and
           row.project_id == project_id)
    end)
  end

  defp reject_deleted(rows), do: Enum.reject(rows, &(!is_nil(&1.deleted_at)))

  defp merge_type_field(current, entry) do
    existing =
      Enum.map(current, fn tf ->
        %{id: tf.ticket_field_definition.id, required: tf.required, position: tf.position}
      end)

    idx = Enum.find_index(existing, &(&1.id == entry.id))

    case idx do
      nil -> existing ++ [entry]
      i -> List.replace_at(existing, i, entry)
    end
  end

  defp org(attrs), do: Map.get(attrs, :organization_id) || Map.get(attrs, "organization_id")

  # Global-scope (org NULL) writes have no shared-key surface on TRP v1 — spec gap.
  defp org_error(nil), do: {:error, :trp_org_required}
  defp org_error(org_id), do: org_id

  defp body(attrs) do
    attrs |> Enum.reject(fn {k, _} -> k in [:organization_id, "organization_id"] end) |> Map.new()
  end

  # Legacy signatures took bare ids; TRP is org-pathed, so id-only accessors
  # walk the cached key-scope org list (30s TTL) — same strategy as PMBridge.
  defp with_scanned_org(fun), do: scan_orgs(fun)

  defp scan_orgs(fun) do
    case TRP.list_organizations() do
      {:error, _} = err ->
        err

      orgs ->
        orgs
        |> Enum.reduce_while(nil, fn org, _acc ->
          case fun.(org.id) do
            nil -> {:cont, nil}
            {:error, %NoizuPromptLingua.TRP.Error{status: 404}} -> {:cont, nil}
            value -> {:halt, value}
          end
        end)
    end
  end
end
