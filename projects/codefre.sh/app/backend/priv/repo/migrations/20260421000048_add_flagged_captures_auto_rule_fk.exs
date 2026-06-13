defmodule Codefresh.Repo.Migrations.AddFlaggedCapturesAutoRuleFk do
  use Ecto.Migration

  def change do
    alter table(:flagged_captures) do
      add :auto_rule_id, references(:auto_flag_rules, type: :uuid, on_delete: :nilify_all)
    end

    create index(:flagged_captures, [:auto_rule_id])
  end
end
