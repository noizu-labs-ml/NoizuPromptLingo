defmodule Noizu.PM.Schema.Items.BoardIteration do
  @moduledoc """
  A time-box or cycle on a board — a Scrum sprint or a Spiral cycle. Kanban and
  Waterfall boards typically have none. `status` is planned | active | completed.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @statuses ~w(planned active completed)

  schema "board_iterations" do
    field :queue_id, :binary_id
    field :name, :string
    field :sequence, :integer, default: 0
    field :status, :string, default: "planned"
    field :goal, :string
    field :starts_on, :date
    field :ends_on, :date
    field :config, :map, default: %{}

    timestamps(type: :utc_datetime)
  end

  def changeset(iteration, attrs) do
    iteration
    |> cast(attrs, [:queue_id, :name, :sequence, :status, :goal, :starts_on, :ends_on, :config])
    |> validate_required([:queue_id, :name])
    |> validate_inclusion(:status, @statuses)
    |> foreign_key_constraint(:queue_id)
  end

  def statuses, do: @statuses
end
