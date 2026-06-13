defmodule Codefresh.Repo.Migrations.AddBranchPromotionsTargetKind do
  use Ecto.Migration

  def change do
    alter table(:branch_promotions) do
      add :target_kind, :string, null: false, default: "script_version"
    end

    execute(
      """
      ALTER TABLE branch_promotions ADD CONSTRAINT branch_promotions_target_kind_valid
      CHECK (target_kind IN ('script_version', 'persona_version'))
      """,
      "ALTER TABLE branch_promotions DROP CONSTRAINT branch_promotions_target_kind_valid"
    )
  end
end
