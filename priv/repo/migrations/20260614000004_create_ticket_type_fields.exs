defmodule NoizuPromptLingua.Repo.Migrations.CreateTicketTypeFields do
  use Ecto.Migration

  def change do
    create table(:ticket_type_fields, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :ticket_type_definition_id, references(:ticket_type_definitions, type: :binary_id, on_delete: :delete_all), null: false
      add :ticket_field_definition_id, references(:ticket_field_definitions, type: :binary_id, on_delete: :delete_all), null: false
      add :required, :boolean, default: false, null: false
      add :position, :integer, default: 0, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:ticket_type_fields, [:ticket_type_definition_id])
    create unique_index(:ticket_type_fields, [:ticket_type_definition_id, :ticket_field_definition_id])
  end
end
