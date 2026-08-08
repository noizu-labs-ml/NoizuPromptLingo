defmodule Noizu.PM.Schema.Items.ItemQueue do
  @moduledoc """
  A board: a methodology-aware container for items. Holds ordered `stages`
  (columns / phases / lanes) and optional `iterations` (sprints / cycles).
  Tri-scoped (global / org / project) like item definitions.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @methodologies ~w(kanban scrum waterfall spiral)

  schema "item_queues" do
    field :organization_id, :binary_id
    field :project_id, :binary_id
    field :name, :string
    field :slug, :string
    field :description, :string
    field :methodology, :string, default: "kanban"
    field :config, :map, default: %{}

    has_many :stages, Noizu.PM.Schema.Items.BoardStage, foreign_key: :queue_id
    has_many :iterations, Noizu.PM.Schema.Items.BoardIteration, foreign_key: :queue_id

    timestamps(type: :utc_datetime)
  end

  def changeset(board, attrs) do
    board
    |> cast(attrs, [
      :organization_id,
      :project_id,
      :name,
      :slug,
      :description,
      :methodology,
      :config
    ])
    |> validate_required([:name, :slug, :methodology])
    |> validate_inclusion(:methodology, @methodologies)
    |> validate_scope()
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:project_id)
    |> unique_constraint(:slug, name: :idx_item_queues_global_slug)
    |> unique_constraint(:slug, name: :idx_item_queues_org_slug)
    |> unique_constraint(:slug, name: :idx_item_queues_project_slug)
  end

  defp validate_scope(changeset) do
    org = get_field(changeset, :organization_id)
    project = get_field(changeset, :project_id)

    if project && is_nil(org) do
      add_error(changeset, :organization_id, "is required for a project-scoped board")
    else
      changeset
    end
  end

  def methodologies, do: @methodologies
end
