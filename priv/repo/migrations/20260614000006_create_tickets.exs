defmodule NoizuPromptLingua.Repo.Migrations.CreateTickets do
  use Ecto.Migration

  def change do
    create table(:tickets, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :description, :text
      add :ticket_type, :string, null: false
      add :status, :string, null: false, default: "open"
      add :priority, :string
      add :assignee, :string
      add :reporter, :string
      add :queue_id, references(:ticket_queues, type: :binary_id, on_delete: :nilify_all)
      add :parent_id, references(:tickets, type: :binary_id, on_delete: :nilify_all)
      add :custom_fields, :map, default: %{}

      timestamps(type: :utc_datetime)
    end

    create index(:tickets, [:ticket_type])
    create index(:tickets, [:status])
    create index(:tickets, [:priority])
    create index(:tickets, [:assignee])
    create index(:tickets, [:queue_id])
    create index(:tickets, [:parent_id])
  end
end
