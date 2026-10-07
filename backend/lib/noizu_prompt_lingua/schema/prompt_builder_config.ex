defmodule NoizuPromptLingua.Schema.PromptBuilderConfig do
  @moduledoc """
  Singleton (id = "default") configuration row for the web NPL Prompt Builder.

  All rate-limit, budget, and pricing knobs are admin-editable through this row
  (PUT /api/admin/prompt-builder/config); env vars (PROMPT_BUILDER_*) override at
  boot for ops without DB access. Pricing is stored as config, never hardcoded —
  Groq gpt-oss-120b list pricing changes and the cap math must track it.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  schema "prompt_builder_configs" do
    field :enabled, :boolean, default: true
    field :provider, :string, default: "groq"
    field :model, :string, default: "openai/gpt-oss-120b"

    # Per IP+session-key token bucket thresholds.
    field :requests_per_minute, :integer, default: 6
    field :tokens_per_minute, :integer, default: 6_000
    field :tokens_per_hour, :integer, default: 40_000

    # Daily spend cap (USD) per IP+session key, UTC day boundary.
    field :daily_cost_cap_usd, :decimal, default: Decimal.new("1.00")

    # USD per 1k tokens — configured, not hardcoded (see moduledoc).
    field :input_price_per_1k_usd, :decimal, default: Decimal.new("0.0002")
    field :output_price_per_1k_usd, :decimal, default: Decimal.new("0.0006")

    field :max_input_chars, :integer, default: 4_000

    # Separate SYSTEM budget for showcase batch runs — never billed to users.
    field :showcase_daily_cost_cap_usd, :decimal, default: Decimal.new("5.00")

    timestamps(type: :utc_datetime)
  end

  def changeset(config, attrs) do
    config
    |> cast(attrs, [
      :enabled,
      :provider,
      :model,
      :requests_per_minute,
      :tokens_per_minute,
      :tokens_per_hour,
      :daily_cost_cap_usd,
      :input_price_per_1k_usd,
      :output_price_per_1k_usd,
      :max_input_chars,
      :showcase_daily_cost_cap_usd
    ])
    |> validate_required([:provider, :model])
    |> validate_number(:requests_per_minute, greater_than: 0, less_than_or_equal_to: 120)
    |> validate_number(:tokens_per_minute, greater_than: 0)
    |> validate_number(:tokens_per_hour, greater_than: 0)
    |> validate_number(:daily_cost_cap_usd, greater_than: 0)
    |> validate_number(:input_price_per_1k_usd, greater_than_or_equal_to: 0)
    |> validate_number(:output_price_per_1k_usd, greater_than_or_equal_to: 0)
    |> validate_number(:max_input_chars, greater_than: 0, less_than_or_equal_to: 32_000)
    |> validate_number(:showcase_daily_cost_cap_usd, greater_than: 0)
  end
end
