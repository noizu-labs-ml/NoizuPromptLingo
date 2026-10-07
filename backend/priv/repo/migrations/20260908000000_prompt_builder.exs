defmodule NoizuPromptLingua.Repo.Migrations.PromptBuilder do
  use Ecto.Migration

  # Web NPL Prompt Builder: singleton config row (admin-editable rate limits,
  # budget caps, and per-token pricing) + per-key/day usage accumulator for the
  # daily spend cap. Liquibase twin: changeset-020.prompt-builder.yaml.

  def up do
    create table(:prompt_builder_configs, primary_key: false) do
      add :id, :string, primary_key: true, null: false
      add :enabled, :boolean, null: false, default: true
      add :provider, :string, null: false, default: "groq"
      add :model, :string, null: false, default: "openai/gpt-oss-120b"
      add :requests_per_minute, :integer, null: false, default: 6
      add :tokens_per_minute, :integer, null: false, default: 6_000
      add :tokens_per_hour, :integer, null: false, default: 40_000
      add :daily_cost_cap_usd, :decimal, null: false, default: "1.00", precision: 12, scale: 6
      add :input_price_per_1k_usd, :decimal, null: false, default: "0.0002", precision: 12, scale: 6
      add :output_price_per_1k_usd, :decimal, null: false, default: "0.0006", precision: 12, scale: 6
      add :max_input_chars, :integer, null: false, default: 4_000
      timestamps(type: :utc_datetime)
    end

    # "0" = the check that refused the request; the caller never supplies a
    # session id that hashes to 0 (sha256 hex, non-empty).
    execute("""
    INSERT INTO prompt_builder_configs (id, inserted_at, updated_at)
    VALUES ('default', NOW(), NOW())
    """)

    create table(:prompt_builder_usage, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false, default: fragment("gen_random_uuid()")
      add :key_hash, :string, null: false
      add :day, :date, null: false
      add :request_count, :integer, null: false, default: 0
      add :rejected_count, :integer, null: false, default: 0
      add :tokens_in, :integer, null: false, default: 0
      add :tokens_out, :integer, null: false, default: 0
      add :est_cost_usd, :decimal, null: false, default: "0", precision: 12, scale: 6
      timestamps(type: :utc_datetime)
    end

    create unique_index(:prompt_builder_usage, [:key_hash, :day],
             name: :uq_prompt_builder_usage_key_day
           )
  end

  def down do
    drop table(:prompt_builder_usage)
    drop table(:prompt_builder_configs)
  end
end
