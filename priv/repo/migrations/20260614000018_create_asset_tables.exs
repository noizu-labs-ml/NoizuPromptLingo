defmodule NoizuPromptLingua.Repo.Migrations.CreateAssetTables do
  use Ecto.Migration

  def change do
    create table(:asset_entries, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :slug, :string, null: false
      add :title, :string, null: false
      add :asset_type, :string, null: false
      add :status, :string, null: false, default: "draft"
      add :quality, :string
      add :prompt_yaml, :text, null: false
      add :tags, {:array, :string}, default: []
      add :product_targets, {:array, :string}, default: []
      add :project_id, references(:projects, type: :binary_id, on_delete: :nilify_all)
      add :active_output_id, :binary_id

      timestamps(type: :utc_datetime)
    end

    create unique_index(:asset_entries, [:slug])
    create index(:asset_entries, [:asset_type])
    create index(:asset_entries, [:status])
    create index(:asset_entries, [:project_id])
    create index(:asset_entries, [:tags], using: :gin)

    create table(:asset_outputs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :entry_id, references(:asset_entries, type: :binary_id, on_delete: :delete_all), null: false
      add :artifact_id, :binary_id
      add :provider, :string
      add :model, :string
      add :variant_number, :integer, null: false, default: 1
      add :eval_score, :float
      add :eval_details, :map
      add :eval_status, :string, null: false, default: "pending"
      add :status, :string, null: false, default: "generated"

      timestamps(type: :utc_datetime)
    end

    create index(:asset_outputs, [:entry_id])
    create index(:asset_outputs, [:eval_status])

    create table(:asset_entry_history, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :entry_id, references(:asset_entries, type: :binary_id, on_delete: :delete_all), null: false
      add :action, :string, null: false
      add :actor, :string
      add :details, :map

      timestamps(type: :utc_datetime)
    end

    create index(:asset_entry_history, [:entry_id])
  end
end
