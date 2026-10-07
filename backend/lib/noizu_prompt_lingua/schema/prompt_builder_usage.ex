defmodule NoizuPromptLingua.Schema.PromptBuilderUsage do
  @moduledoc """
  Per-key, per-UTC-day accumulator for the web NPL Prompt Builder.

  `key_hash` = sha256(ip <> ":" <> session_id) (hex, truncated) — the same key
  the token buckets use, so budget state and rate-limit state address the same
  caller without storing IPs or session ids. Rejections are counted, never
  logged with content.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "prompt_builder_usage" do
    field :key_hash, :string
    field :day, :date

    field :request_count, :integer, default: 0
    field :rejected_count, :integer, default: 0
    field :tokens_in, :integer, default: 0
    field :tokens_out, :integer, default: 0
    field :est_cost_usd, :decimal, default: Decimal.new(0)

    timestamps(type: :utc_datetime)
  end

  def changeset(usage, attrs) do
    usage
    |> cast(attrs, [:key_hash, :day, :request_count, :rejected_count, :tokens_in, :tokens_out, :est_cost_usd])
    |> validate_required([:key_hash, :day])
    |> unique_constraint(:day, name: :uq_prompt_builder_usage_key_day)
  end
end
