defmodule Codefresh.Otel.Log do
  @moduledoc """
  OpenTelemetry log record landing in the `otel_logs` TimescaleDB hypertable.

  Composite primary key `(id, timestamp)` — TimescaleDB requires the
  partitioning column in every unique index / PK. See Ecto composite-keys
  guide: https://hexdocs.pm/ecto/composite-keys.html.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @foreign_key_type :binary_id

  @type t :: %__MODULE__{}

  schema "otel_logs" do
    field :id, Ecto.UUID, primary_key: true, autogenerate: true
    field :timestamp, :utc_datetime_usec, primary_key: true

    field :trace_id, :string
    field :span_id, :string
    field :severity_number, :integer
    field :severity_text, :string
    field :body, :string
    field :attributes, :map, default: %{}
    field :resource_attributes, :map, default: %{}

    belongs_to :organization, Codefresh.Organizations.Organization
    belongs_to :run, Codefresh.Runs.Run
    belongs_to :run_step, Codefresh.Runs.RunStep

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def create_changeset(log, attrs) do
    log
    |> cast(attrs, [
      :organization_id,
      :run_id,
      :run_step_id,
      :trace_id,
      :span_id,
      :timestamp,
      :severity_number,
      :severity_text,
      :body,
      :attributes,
      :resource_attributes
    ])
    |> validate_required([:timestamp, :body])
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:run_id)
    |> foreign_key_constraint(:run_step_id)
  end
end
