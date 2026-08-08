defmodule Noizu.PM.Schema.Items.Item do
  @moduledoc """
  The universal work primitive: items (todo/task/bug/epic/etc.). This is the
  TRP superset of npl's `tickets` table (npl `ticket_*` → `item_*`): org
  required, project optional, with personal-todo ownership, tags, rank,
  scheduling, sizing, and an immutable human key. The table is named `items`.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @priorities ~w(low medium high critical)

  schema "items" do
    field :organization_id, :binary_id
    field :title, :string
    field :description, :string
    field :item_type, :string
    field :status, :string, default: "open"
    field :priority, :string
    field :assignee, :string
    field :reporter, :string
    field :custom_fields, :map, default: %{}

    # Personal-todo ownership: a personal item is
    # `owner_user_id IS NOT NULL AND project_id IS NULL` — scoped to a user,
    # not a project. Project items keep this NULL.
    field :owner_user_id, :binary_id
    # Free-form, cross-scope tags (first-class text[] + GIN index, NOT a
    # multi_select custom field) — cleaned (trim/downcase/uniq) on write.
    field :tags, {:array, :string}, default: []

    # Board ordering (lexorank string) + scheduling + sizing.
    field :rank, :string
    field :start_date, :date
    field :due_date, :date
    field :estimate, :decimal

    # Human key (e.g. NOZINF-023): immutable, assigned on insert by the domain (NOT cast).
    field :number, :integer
    field :key, :string

    belongs_to :project, Noizu.PM.Schema.Projects.Project
    belongs_to :queue, Noizu.PM.Schema.Items.ItemQueue
    belongs_to :parent, Noizu.PM.Schema.Items.Item
    belongs_to :stage, Noizu.PM.Schema.Items.BoardStage
    belongs_to :iteration, Noizu.PM.Schema.Items.BoardIteration

    # Optimistic-concurrency guardrail (shared-core table).
    field :lock_version, :integer, default: 0

    timestamps(type: :utc_datetime)
  end

  def changeset(item, attrs) do
    item
    |> cast(attrs, [
      :organization_id,
      :title,
      :description,
      :item_type,
      :status,
      :priority,
      :assignee,
      :reporter,
      :project_id,
      :queue_id,
      :parent_id,
      :custom_fields,
      :stage_id,
      :iteration_id,
      :rank,
      :start_date,
      :due_date,
      :estimate,
      :owner_user_id,
      :tags,
      :lock_version
    ])
    |> clean_tags()
    |> validate_required([:organization_id, :title, :item_type])
    |> validate_inclusion(:priority, @priorities ++ [nil])
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:owner_user_id)
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:queue_id)
    |> foreign_key_constraint(:parent_id)
    |> foreign_key_constraint(:stage_id)
    |> foreign_key_constraint(:iteration_id)
    # Human-key uniqueness: the domain put_changes :number/:key; a 23505 from any
    # of the three partial indexes maps back to a changeset error so the key-gen
    # txn rolls back cleanly instead of raising.
    |> unique_constraint(:number, name: :idx_items_proj_number)
    |> unique_constraint(:number, name: :idx_items_org_number)
    |> unique_constraint(:key, name: :idx_items_org_key)
    |> optimistic_lock(:lock_version)
  end

  def update_changeset(item, attrs) do
    item
    |> cast(attrs, [
      :title,
      :description,
      :status,
      :priority,
      :assignee,
      :project_id,
      :queue_id,
      :parent_id,
      :custom_fields,
      :stage_id,
      :iteration_id,
      :rank,
      :start_date,
      :due_date,
      :estimate,
      :owner_user_id,
      :tags,
      :lock_version
    ])
    |> clean_tags()
    |> validate_inclusion(:priority, @priorities ++ [nil])
    |> foreign_key_constraint(:owner_user_id)
    |> foreign_key_constraint(:stage_id)
    |> foreign_key_constraint(:iteration_id)
    |> optimistic_lock(:lock_version)
  end

  def priorities, do: @priorities

  # Free-form tags are normalized on every write: trim surrounding whitespace,
  # downcase, drop empties, and de-duplicate (order-preserving). Only touches the
  # changeset when :tags was actually cast, so untouched updates keep their value.
  defp clean_tags(changeset) do
    case fetch_change(changeset, :tags) do
      {:ok, tags} when is_list(tags) ->
        cleaned =
          tags
          |> Enum.map(fn t -> t |> to_string() |> String.trim() |> String.downcase() end)
          |> Enum.reject(&(&1 == ""))
          |> Enum.uniq()

        put_change(changeset, :tags, cleaned)

      _ ->
        changeset
    end
  end
end
