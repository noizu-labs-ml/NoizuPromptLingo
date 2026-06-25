defmodule NoizuPromptLingua.Schema.Memory.AgentState do
  @moduledoc """
  Per-scope emotional/hormonal harness state, keyed by (organization_id, scope_type, scope_id).
  The 7-d emotional state is stored as a json list of floats (no pgvector). Read from config
  defaults by the Monitor stub in Phase 0; maintained/checkpointed by the Monitor later.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "memory_agent_state" do
    field :organization_id, Ecto.UUID, primary_key: true
    field :scope_type, Ecto.Enum, values: [:persona, :weego, :team_member], primary_key: true
    field :scope_id, Ecto.UUID, primary_key: true
    field :status, :string, default: "active"
    field :current_emotional, {:array, :float}
    field :baseline_emotional, {:array, :float}
    field :current_bucket, :string
    field :last_bucket_refresh, :utc_datetime_usec
    field :metrics, :map, default: %{}

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(state, attrs) do
    state
    |> cast(attrs, ~w(organization_id scope_type scope_id status current_emotional
                      baseline_emotional current_bucket last_bucket_refresh metrics)a)
    |> validate_required([:organization_id, :scope_type, :scope_id])
  end
end
