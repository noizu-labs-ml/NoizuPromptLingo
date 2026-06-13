defmodule Codefresh.Runs.RunStep do
  @moduledoc """
  A single step within a run. Captures the user+agent message for that turn,
  the edge the runner followed (or the freeball_node created when no edge
  matched), token/latency usage, and a row-level status.

  `status` values:
    * `"ok"` — step succeeded and an authored edge matched
    * `"freeball"` — no authored edge matched; a `freeball_nodes` row was
      created and `freeball_node_id` points at it
    * `"error"` — adapter or scoring raised a terminal failure
    * `"terminal"` — step ended at a terminal node (no outgoing edge needed)
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @statuses ~w(ok freeball error terminal)

  schema "run_steps" do
    field :step_index, :integer
    field :user_message, :string
    field :agent_message, :string
    field :agent_raw, :map, default: %{}
    field :latency_ms, :integer
    field :tokens_in, :integer
    field :tokens_out, :integer
    field :trace_id, :string
    field :span_id, :string
    field :status, :string, default: "ok"
    field :error, :map

    belongs_to :run, Codefresh.Runs.Run
    belongs_to :organization, Codefresh.Organizations.Organization
    belongs_to :from_node, Codefresh.Scripts.ScriptNode, foreign_key: :from_node_id
    belongs_to :to_node, Codefresh.Scripts.ScriptNode, foreign_key: :to_node_id
    belongs_to :edge, Codefresh.Scripts.ScriptEdge, foreign_key: :edge_id
    belongs_to :persona_version, Codefresh.Personas.PersonaVersion
    belongs_to :freeball_node, Codefresh.Runs.FreeballNode, foreign_key: :freeball_node_id

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def statuses, do: @statuses

  def create_changeset(step, attrs) do
    step
    |> cast(attrs, [
      :run_id,
      :organization_id,
      :step_index,
      :from_node_id,
      :to_node_id,
      :freeball_node_id,
      :edge_id,
      :persona_version_id,
      :user_message,
      :agent_message,
      :agent_raw,
      :latency_ms,
      :tokens_in,
      :tokens_out,
      :trace_id,
      :span_id,
      :status,
      :error
    ])
    |> validate_required([:run_id, :organization_id, :step_index, :status])
    |> validate_inclusion(:status, @statuses)
    |> unique_constraint([:run_id, :step_index])
    |> foreign_key_constraint(:run_id)
    |> foreign_key_constraint(:organization_id)
  end
end
