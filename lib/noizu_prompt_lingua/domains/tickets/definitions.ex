defmodule NoizuPromptLingua.Domains.Tickets.Definitions do
  import Ecto.Query, except: [update: 2]
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{TicketFieldDefinition, TicketTypeDefinition, TicketTypeField}

  # ── Field Definitions ─────────────────────────────────────────

  def create_field(attrs) do
    %TicketFieldDefinition{}
    |> TicketFieldDefinition.changeset(attrs)
    |> Repo.insert()
  end

  def get_field(slug) when is_binary(slug) do
    Repo.get_by(TicketFieldDefinition, slug: slug)
  end

  def update_field(slug, attrs) do
    case get_field(slug) do
      nil -> {:error, :not_found}
      field ->
        field
        |> TicketFieldDefinition.changeset(attrs)
        |> Repo.update()
    end
  end

  def delete_field(slug) do
    case get_field(slug) do
      nil -> {:error, :not_found}
      field -> Repo.delete(field)
    end
  end

  def list_fields do
    TicketFieldDefinition
    |> order_by([f], asc: f.slug)
    |> Repo.all()
  end

  def upsert_field(attrs) do
    case Repo.get_by(TicketFieldDefinition, slug: attrs[:slug] || attrs["slug"]) do
      nil -> create_field(attrs)
      existing ->
        existing
        |> TicketFieldDefinition.changeset(attrs)
        |> Repo.update()
    end
  end

  # ── Type Definitions ──────────────────────────────────────────

  def create_type(attrs) do
    %TicketTypeDefinition{}
    |> TicketTypeDefinition.changeset(attrs)
    |> Repo.insert()
  end

  def get_type(slug) when is_binary(slug) do
    TicketTypeDefinition
    |> where([t], t.slug == ^slug and is_nil(t.deleted_at))
    |> preload(type_fields: :ticket_field_definition)
    |> Repo.one()
  end

  def update_type(slug, attrs) do
    case get_type(slug) do
      nil -> {:error, :not_found}
      type_def ->
        type_def
        |> TicketTypeDefinition.changeset(attrs)
        |> Repo.update()
    end
  end

  def delete_type(slug) do
    case get_type(slug) do
      nil -> {:error, :not_found}
      type_def ->
        type_def
        |> TicketTypeDefinition.changeset(%{deleted_at: DateTime.utc_now()})
        |> Repo.update()
    end
  end

  def list_types do
    TicketTypeDefinition
    |> where([t], is_nil(t.deleted_at))
    |> order_by([t], asc: t.name)
    |> preload(type_fields: :ticket_field_definition)
    |> Repo.all()
  end

  def upsert_type(attrs) do
    case Repo.get_by(TicketTypeDefinition, slug: attrs[:slug] || attrs["slug"]) do
      nil -> create_type(attrs)
      existing ->
        existing
        |> TicketTypeDefinition.changeset(attrs)
        |> Repo.update()
    end
  end

  # ── Type-Field Associations ───────────────────────────────────

  def add_field_to_type(type_slug, field_slug, opts \\ []) do
    with %{id: type_id} <- get_type(type_slug),
         %{id: field_id} <- get_field(field_slug) do
      %TicketTypeField{}
      |> TicketTypeField.changeset(%{
        ticket_type_definition_id: type_id,
        ticket_field_definition_id: field_id,
        required: Keyword.get(opts, :required, false),
        position: Keyword.get(opts, :position, 0)
      })
      |> Repo.insert(on_conflict: :nothing)
    else
      nil -> {:error, :not_found}
    end
  end

  def get_type_fields(type_slug) do
    case get_type(type_slug) do
      nil -> []
      type_def ->
        type_def.type_fields
        |> Enum.sort_by(& &1.position)
        |> Enum.map(fn tf ->
          field = tf.ticket_field_definition
          %{
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
  end

  def get_status_workflow(type_slug) do
    case get_type(type_slug) do
      nil -> nil
      type_def -> type_def.status_workflow
    end
  end
end
