defmodule NoizuPromptLingua.Repo.Migrations.CreateTicketQueues do
  use Ecto.Migration

  def change do
    create table(:ticket_queues, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :slug, :string, null: false
      add :description, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:ticket_queues, [:slug])
  end
end
