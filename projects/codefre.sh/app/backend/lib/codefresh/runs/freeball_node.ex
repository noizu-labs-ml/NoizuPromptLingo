defmodule Codefresh.Runs.FreeballNode do
  @moduledoc """
  A runtime-generated node produced when the runner could not match any
  authored edge leaving the current script_node (US-022). Anchored at a
  parent_script_node; may nest another freeball_node (parent_freeball_node_id).

  `confidence` is the runner's self-reported confidence in its generated prompt
  (0..1). `review_status` drives the later promotion workflow (out of scope
  here, defaults to `pending`).

  Mirrors migration `20260421000012_create_freeball_nodes_and_expectations.exs`
  + adaptive fields from `20260421000043_add_freeball_nodes_adaptive_fields.exs`.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @review_statuses ~w(pending approved rejected promoted)

  schema "freeball_nodes" do
    field :sequence, :integer
    field :prompt_text, :string
    field :confidence, :decimal
    field :runner_model, :string
    field :review_status, :string, default: "pending"
    field :metadata, :map, default: %{}
    field :adaptive_depth_policy, :string
    field :learning_examples, :map

    belongs_to :run, Codefresh.Runs.Run
    belongs_to :organization, Codefresh.Organizations.Organization
    belongs_to :parent_script_node, Codefresh.Scripts.ScriptNode
    belongs_to :parent_freeball_node, __MODULE__, foreign_key: :parent_freeball_node_id

    belongs_to :runner_prompt_version, Codefresh.Prompts.PromptVersion,
      foreign_key: :runner_prompt_version_id

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def review_statuses, do: @review_statuses

  def create_changeset(fn_node, attrs) do
    fn_node
    |> cast(attrs, [
      :run_id,
      :organization_id,
      :parent_script_node_id,
      :parent_freeball_node_id,
      :sequence,
      :prompt_text,
      :confidence,
      :runner_model,
      :runner_prompt_version_id,
      :review_status,
      :metadata,
      :adaptive_depth_policy,
      :learning_examples
    ])
    |> validate_required([
      :run_id,
      :organization_id,
      :parent_script_node_id,
      :sequence,
      :prompt_text,
      :confidence
    ])
    |> validate_inclusion(:review_status, @review_statuses)
    |> foreign_key_constraint(:run_id)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:parent_script_node_id)
  end
end
