defmodule Codefresh.Runs.Run do
  @moduledoc """
  A single execution of a published script against a pinned agent version.
  Lifecycle:

    pending  -> running  -> (passed | failed | warned | cancelled | errored)

  `status` is stored as a string; terminal states include `passed`, `failed`,
  `warned`, `cancelled`, `errored`. `summary_metrics` holds the computed
  verdict + any aggregate score after finalize.

  Mirrors migration `20260421000010_create_runs_and_personas.exs` and
  `20260421000039_add_runs_wave3_fields.exs` (retry lineage + cost).
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @statuses ~w(pending running passed failed warned cancelled errored)
  @trigger_sources ~w(manual scheduled api cli)

  schema "runs" do
    field :trigger_source, :string, default: "manual"
    field :status, :string, default: "pending"
    field :started_at, :utc_datetime
    field :finished_at, :utc_datetime
    field :run_config, :map, default: %{}
    field :trace_id, :string
    field :summary_metrics, :map, default: %{}
    field :cost_estimate_usd, :decimal
    field :cost_cap_usd, :decimal

    belongs_to :organization, Codefresh.Organizations.Organization
    belongs_to :script_version, Codefresh.Scripts.ScriptVersion
    belongs_to :agent_version, Codefresh.Agents.AgentVersion

    belongs_to :triggered_by, Codefresh.Accounts.User,
      foreign_key: :triggered_by_user_id

    belongs_to :retry_parent_run, __MODULE__, foreign_key: :retry_parent_run_id

    field :regression_suite_dataset_version_id, Ecto.UUID

    # inserted_at only (migration does not add updated_at)
    timestamps(type: :utc_datetime, updated_at: false)
  end

  def statuses, do: @statuses
  def trigger_sources, do: @trigger_sources

  def terminal_statuses, do: ~w(passed failed warned cancelled errored)

  def create_changeset(run, attrs) do
    run
    |> cast(attrs, [
      :organization_id,
      :script_version_id,
      :agent_version_id,
      :triggered_by_user_id,
      :trigger_source,
      :status,
      :run_config,
      :trace_id,
      :cost_cap_usd,
      :retry_parent_run_id,
      :regression_suite_dataset_version_id
    ])
    |> validate_required([
      :organization_id,
      :script_version_id,
      :agent_version_id
    ])
    |> validate_inclusion(:status, @statuses)
    |> validate_inclusion(:trigger_source, @trigger_sources)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:script_version_id)
    |> foreign_key_constraint(:agent_version_id)
  end

  def status_changeset(run, new_status, attrs \\ %{}) when is_binary(new_status) do
    run
    |> cast(attrs, [:started_at, :finished_at, :summary_metrics, :cost_estimate_usd, :trace_id])
    |> put_change(:status, new_status)
    |> validate_inclusion(:status, @statuses)
  end

  def summary_changeset(run, attrs) do
    run
    |> cast(attrs, [:summary_metrics, :finished_at, :status, :cost_estimate_usd])
    |> validate_inclusion(:status, @statuses)
  end
end
