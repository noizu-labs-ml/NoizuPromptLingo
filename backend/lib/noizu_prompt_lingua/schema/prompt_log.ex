defmodule NoizuPromptLingua.Schema.PromptLog do
  @moduledoc """
  A logged, ACCEPTED prompt-builder build (the builder UI's consent notice
  tells users these are logged and may be used for fine-tuning, evaluation,
  and as public showcase examples). Rejections are never logged with content —
  they stay count-only in prompt_builder_usage.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "prompt_logs" do
    field :key_hash, :string
    field :description, :string
    field :context, :string
    field :prompt, :string
    field :tokens_in, :integer, default: 0
    field :tokens_out, :integer, default: 0
    field :est_cost_usd, :decimal, default: Decimal.new(0)
    field :showcase_status, :string, default: "pending"

    timestamps(type: :utc_datetime)
  end

  def changeset(log, attrs) do
    log
    |> cast(attrs, [:key_hash, :description, :context, :prompt, :tokens_in, :tokens_out, :est_cost_usd, :showcase_status])
    |> validate_required([:key_hash, :description, :prompt])
    |> validate_inclusion(:showcase_status, ["pending", "processed", "failed"])
  end
end
