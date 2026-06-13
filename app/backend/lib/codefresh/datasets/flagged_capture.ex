defmodule Codefresh.Datasets.FlaggedCapture do
  @moduledoc """
  A flagged production interaction (US-106). Source provenance lives in
  `source_trace_id` / `source_span_id` / `source_run_step_id`. Promotion targets
  (US-108/109) are recorded in `promoted_to_script_node_id` /
  `promoted_to_dataset_entry_id` — one capture may promote many times, but we
  only pin the *last* promotion target per row.

  `reason` canonical values: `deviation`, `bug`, `edge_case`, `good_example`,
  `regression`. Free-text `tags` allow curation-specific grouping.

  Redaction: `input`, `agent_response`, and `captured_attributes` may be
  scrubbed client-side before flagging; the server stores exactly what it's
  given.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @valid_reasons ~w(deviation bug edge_case good_example regression)

  schema "flagged_captures" do
    field :title, :string
    field :notes, :string
    field :tags, {:array, :string}, default: []
    field :reason, :string
    field :source_trace_id, :string
    field :source_span_id, :string
    field :input, :map, default: %{}
    field :agent_response, :map, default: %{}
    field :captured_attributes, :map, default: %{}

    belongs_to :organization, Codefresh.Organizations.Organization
    belongs_to :flagged_by, Codefresh.Accounts.User, foreign_key: :flagged_by_user_id

    # Promotion pins — populated on promote actions (US-108 / US-109).
    field :source_run_step_id, Ecto.UUID
    field :promoted_to_script_node_id, Ecto.UUID
    field :promoted_to_dataset_entry_id, Ecto.UUID
    field :auto_rule_id, Ecto.UUID

    timestamps(type: :utc_datetime)
  end

  def create_changeset(capture, attrs) do
    capture
    |> cast(attrs, [
      :organization_id,
      :title,
      :notes,
      :tags,
      :reason,
      :source_trace_id,
      :source_span_id,
      :source_run_step_id,
      :input,
      :agent_response,
      :captured_attributes,
      :flagged_by_user_id,
      :auto_rule_id
    ])
    |> validate_required([:organization_id, :title, :reason])
    |> validate_length(:title, min: 1, max: 2_000)
    |> validate_length(:notes, max: 8_000)
    |> validate_inclusion(:reason, @valid_reasons)
    |> foreign_key_constraint(:organization_id)
  end

  def promote_to_script_node_changeset(capture, script_node_id) do
    capture
    |> change(promoted_to_script_node_id: script_node_id)
    |> foreign_key_constraint(:promoted_to_script_node_id,
      name: :flagged_captures_promoted_to_script_node_id_fkey
    )
  end

  def promote_to_dataset_entry_changeset(capture, dataset_entry_id) do
    capture
    |> change(promoted_to_dataset_entry_id: dataset_entry_id)
    |> foreign_key_constraint(:promoted_to_dataset_entry_id,
      name: :flagged_captures_promoted_to_dataset_entry_id_fkey
    )
  end

  def valid_reasons, do: @valid_reasons
end
