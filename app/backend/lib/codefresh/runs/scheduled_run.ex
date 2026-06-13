defmodule Codefresh.Runs.ScheduledRun do
  @moduledoc """
  Cron-backed recurring run schedule (US-069). Stores a pinned
  `script_version` + `agent_version` that the scheduler will trigger at the
  cadence specified by `cron_expression`.

  The scheduler (`Codefresh.Runs.Scheduler`) ticks once a minute, computes
  which enabled schedules are due, and enqueues runs with
  `trigger_source="scheduled"`.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "scheduled_runs" do
    field :cron_expression, :string
    field :timezone, :string, default: "Etc/UTC"
    field :enabled, :boolean, default: true
    field :next_run_at, :utc_datetime
    field :last_triggered_at, :utc_datetime
    field :metadata, :map, default: %{}

    belongs_to :organization, Codefresh.Organizations.Organization
    belongs_to :script_version, Codefresh.Scripts.ScriptVersion
    belongs_to :agent_version, Codefresh.Agents.AgentVersion
    belongs_to :last_run, Codefresh.Runs.Run, foreign_key: :last_run_id

    belongs_to :created_by, Codefresh.Accounts.User, foreign_key: :created_by_user_id

    timestamps(type: :utc_datetime)
  end

  def create_changeset(sr, attrs) do
    sr
    |> cast(attrs, [
      :organization_id,
      :script_version_id,
      :agent_version_id,
      :cron_expression,
      :timezone,
      :enabled,
      :next_run_at,
      :created_by_user_id,
      :metadata
    ])
    |> validate_required([
      :organization_id,
      :script_version_id,
      :agent_version_id,
      :cron_expression
    ])
    |> validate_cron()
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:script_version_id)
    |> foreign_key_constraint(:agent_version_id)
  end

  def update_changeset(sr, attrs) do
    sr
    |> cast(attrs, [
      :cron_expression,
      :timezone,
      :enabled,
      :next_run_at,
      :last_triggered_at,
      :last_run_id,
      :metadata
    ])
    |> validate_cron()
  end

  defp validate_cron(cs) do
    case get_field(cs, :cron_expression) do
      nil ->
        cs

      expr when is_binary(expr) ->
        case Codefresh.Runs.Scheduler.parse_cron(expr) do
          {:ok, _} -> cs
          {:error, msg} -> add_error(cs, :cron_expression, msg)
        end
    end
  end
end
