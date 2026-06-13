defmodule NoizuPromptLingua.Repo.Migrations.CreateTicketTypeDefinitions do
  use Ecto.Migration

  def change do
    create table(:ticket_type_definitions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :slug, :string, null: false
      add :name, :string, null: false
      add :description, :string
      add :icon, :string
      add :status_workflow, :map
      add :deleted_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:ticket_type_definitions, [:slug])
  end
end
