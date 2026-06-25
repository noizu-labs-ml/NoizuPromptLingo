defmodule NoizuPromptLingua.Schema.Memory.AssociationEdge do
  @moduledoc "A weighted, typed association between two memories. Directional rows, traversed both ways."
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "association_edges" do
    field :source_memory_id, Ecto.UUID
    field :target_memory_id, Ecto.UUID
    field :weight, :float, default: 0.5

    field :edge_type, Ecto.Enum,
      values: [:semantic, :emotional, :temporal, :causal, :co_occurrence, :synthetic, :contextual, :tangent]

    field :created_by, :string, default: "weaver"
    field :reinforcement_count, :integer, default: 0
    field :denforcement_count, :integer, default: 0
    field :reason, :string
    field :emotional_similarity, :float
    field :temporal_proximity, :float
    field :last_reinforced_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(edge, attrs) do
    edge
    |> cast(attrs, ~w(source_memory_id target_memory_id weight edge_type created_by
                      reinforcement_count denforcement_count reason emotional_similarity
                      temporal_proximity last_reinforced_at)a)
    |> validate_required([:source_memory_id, :target_memory_id, :edge_type])
    |> validate_number(:weight, greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0)
    |> unique_constraint([:source_memory_id, :target_memory_id, :edge_type], name: :uq_edge)
  end
end
