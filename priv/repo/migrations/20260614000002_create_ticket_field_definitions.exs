defmodule NoizuPromptLingua.Repo.Migrations.CreateTicketFieldDefinitions do
  use Ecto.Migration

  def change do
    create table(:ticket_field_definitions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :slug, :string, null: false
      add :label, :string, null: false
      add :field_type, :string, null: false
      add :options, :map
      add :default_value, :string
      add :description, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:ticket_field_definitions, [:slug])
  end
end
