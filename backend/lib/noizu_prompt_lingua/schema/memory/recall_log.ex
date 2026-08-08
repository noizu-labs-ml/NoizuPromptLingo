defmodule NoizuPromptLingua.Schema.Memory.RecallLog do
  @moduledoc "Append-only log of recall requests (latency, paths, results) for observability/eval."
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "memory_recall_log" do
    field :requester_id, :string
    field :organization_id, Ecto.UUID
    field :scope_type, Ecto.Enum, values: [:persona, :weego, :team_member]
    field :scope_id, Ecto.UUID
    field :mode, :string
    field :query, :string
    field :total_candidates, :integer
    field :returned_count, :integer
    field :hot_index_hit, :boolean, default: false
    field :duration_ms, :integer
    field :result_memory_ids, {:array, Ecto.UUID}, default: []
    field :path_breakdown, :map, default: %{}
    field :occurred_at, :utc_datetime_usec
  end

  def changeset(log, attrs) do
    log
    |> cast(attrs, ~w(requester_id organization_id scope_type scope_id mode query total_candidates
                      returned_count hot_index_hit duration_ms result_memory_ids path_breakdown
                      occurred_at)a)
    |> validate_required([:requester_id, :organization_id, :scope_type, :scope_id, :mode])
  end
end
