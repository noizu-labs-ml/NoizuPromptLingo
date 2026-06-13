defmodule NoizuPromptLingua.Repo.Migrations.AddProjectIdToTickets do
  use Ecto.Migration

  def change do
    alter table(:tickets) do
      add :project_id, references(:projects, type: :binary_id, on_delete: :nilify_all)
    end

    create index(:tickets, [:project_id])
  end
end
