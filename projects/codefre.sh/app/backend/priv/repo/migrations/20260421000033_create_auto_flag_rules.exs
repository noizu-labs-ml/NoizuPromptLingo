defmodule Codefresh.Repo.Migrations.CreateAutoFlagRules do
  use Ecto.Migration

  def change do
    create table(:auto_flag_rules) do
      add :organization_id, references(:organizations, type: :uuid, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :rule_type, :string, null: false
      add :config, :map, null: false, default: %{}
      add :default_reason, :string, null: false
      add :default_tags, {:array, :string}, null: false, default: []
      add :enabled, :boolean, null: false, default: true
      add :soft_deleted_at, :utc_datetime
      add :match_count, :integer, null: false, default: 0
      timestamps(type: :utc_datetime)
    end

    create index(:auto_flag_rules, [:organization_id, :enabled, :rule_type])
  end
end
