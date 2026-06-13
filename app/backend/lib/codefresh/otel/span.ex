defmodule Codefresh.Otel.Span do
  @moduledoc """
  OpenTelemetry span landing in the `otel_spans` TimescaleDB hypertable.

  Composite primary key `(id, start_time)` — TimescaleDB requires the
  partitioning column in every unique index / PK. See Ecto composite-keys
  guide: https://hexdocs.pm/ecto/composite-keys.html.

  Populated by the OTLP receiver (US-081). `run_id` / `run_step_id` are
  set asynchronously by the correlator (US-082) and may be `nil` at ingest.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @foreign_key_type :binary_id

  @kinds ~w(internal server client producer consumer unspecified)
  @status_codes ~w(ok error unset)

  @type t :: %__MODULE__{}

  schema "otel_spans" do
    field :id, Ecto.UUID, primary_key: true, autogenerate: true
    field :start_time, :utc_datetime_usec, primary_key: true

    field :trace_id, :string
    field :span_id, :string
    field :parent_span_id, :string
    field :name, :string
    field :kind, :string, default: "internal"
    field :service_name, :string
    field :end_time, :utc_datetime_usec
    field :duration_ns, :integer
    field :status_code, :string, default: "unset"
    field :status_message, :string
    field :attributes, :map, default: %{}
    field :resource_attributes, :map, default: %{}
    field :events, :map, default: %{}

    # Sampling metadata (migration 20260421000047) — US-132
    field :sampled, :boolean
    field :sample_decision_reason, :string
    field :sample_rate, :decimal

    belongs_to :organization, Codefresh.Organizations.Organization
    belongs_to :run, Codefresh.Runs.Run
    belongs_to :run_step, Codefresh.Runs.RunStep

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def kinds, do: @kinds
  def status_codes, do: @status_codes

  def create_changeset(span, attrs) do
    span
    |> cast(attrs, [
      :organization_id,
      :run_id,
      :run_step_id,
      :trace_id,
      :span_id,
      :parent_span_id,
      :name,
      :kind,
      :service_name,
      :start_time,
      :end_time,
      :duration_ns,
      :status_code,
      :status_message,
      :attributes,
      :resource_attributes,
      :events,
      :sampled,
      :sample_decision_reason,
      :sample_rate
    ])
    |> validate_required([
      :trace_id,
      :span_id,
      :name,
      :start_time,
      :end_time,
      :duration_ns
    ])
    |> validate_inclusion(:kind, @kinds)
    |> validate_inclusion(:status_code, @status_codes)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:run_id)
    |> foreign_key_constraint(:run_step_id)
  end
end
