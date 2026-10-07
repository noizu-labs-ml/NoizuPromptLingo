defmodule NoizuPromptLingua.Repo.Migrations.PromptLogsAndShowcase do
  use Ecto.Migration

  # Prompt logging (consented, accepted builds only — the fine-tuning corpus and
  # showcase source) + showcase entries (OP-vs-NPL eval results).
  # Liquibase twin: changeset-021.prompt-logs-and-showcase.yaml.

  def up do
    create table(:prompt_logs, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false, default: fragment("gen_random_uuid()")
      add :key_hash, :string, null: false
      add :description, :text, null: false
      add :context, :text
      add :prompt, :text, null: false
      add :tokens_in, :integer, null: false, default: 0
      add :tokens_out, :integer, null: false, default: 0
      add :est_cost_usd, :decimal, null: false, default: "0", precision: 12, scale: 6
      # pending | processed | failed — showcase batch processes pending once.
      add :showcase_status, :string, null: false, default: "pending"
      timestamps(type: :utc_datetime)
    end

    create index(:prompt_logs, [:key_hash])
    create index(:prompt_logs, [:showcase_status])

    create table(:showcase_entries, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false, default: fragment("gen_random_uuid()")
      add :log_id, :uuid, null: false
      add :original_prompt, :text, null: false
      add :original_output, :text
      add :npl_prompt, :text
      add :npl_output, :text
      add :score_original, :integer
      add :score_npl, :integer
      add :winner, :string
      # Context-size comparison (the OP vs NPL input sizes), chars + est tokens.
      add :ctx_original_chars, :integer
      add :ctx_original_tokens, :integer
      add :ctx_npl_chars, :integer
      add :ctx_npl_tokens, :integer
      # Per-dimension rubric breakdown JSON.
      add :rubric, :jsonb
      add :difference_analysis, :text
      add :error, :text
      timestamps(type: :utc_datetime)
    end

    create unique_index(:showcase_entries, [:log_id], name: :uq_showcase_entries_log)

    # Separate SYSTEM budget for showcase runs — never billed to user IP quotas.
    alter table(:prompt_builder_configs) do
      add :showcase_daily_cost_cap_usd, :decimal,
        null: false,
        default: "5.00",
        precision: 12,
        scale: 6
    end
  end

  def down do
    alter table(:prompt_builder_configs) do
      remove :showcase_daily_cost_cap_usd
    end

    drop table(:showcase_entries)
    drop table(:prompt_logs)
  end
end
