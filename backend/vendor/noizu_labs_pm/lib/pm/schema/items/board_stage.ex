defmodule Noizu.PM.Schema.Items.BoardStage do
  @moduledoc """
  An ordered stage on a board — a Kanban column, a Waterfall/Spiral phase, or a
  Scrum board lane. `kind` is a free hint (e.g. backlog, todo, in_progress,
  in_review, done, phase). `wip_limit` is an optional work-in-progress cap.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "board_stages" do
    field :queue_id, :binary_id
    field :slug, :string
    field :name, :string
    field :kind, :string, default: "stage"
    field :position, :integer, default: 0
    field :wip_limit, :integer
    field :config, :map, default: %{}

    timestamps(type: :utc_datetime)
  end

  def changeset(stage, attrs) do
    stage
    |> cast(attrs, [:queue_id, :slug, :name, :kind, :position, :wip_limit, :config])
    |> validate_required([:queue_id, :slug, :name])
    |> foreign_key_constraint(:queue_id)
    |> unique_constraint([:queue_id, :slug], name: :idx_board_stages_queue_slug)
  end
end
