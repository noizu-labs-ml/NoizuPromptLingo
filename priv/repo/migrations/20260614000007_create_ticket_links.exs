defmodule NoizuPromptLingua.Repo.Migrations.CreateTicketLinks do
  use Ecto.Migration

  def change do
    create table(:ticket_links, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :source_ticket_id, references(:tickets, type: :binary_id, on_delete: :delete_all), null: false
      add :target_ticket_id, references(:tickets, type: :binary_id, on_delete: :delete_all), null: false
      add :link_type, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:ticket_links, [:source_ticket_id])
    create index(:ticket_links, [:target_ticket_id])
    create unique_index(:ticket_links, [:source_ticket_id, :target_ticket_id, :link_type])
  end
end
