defmodule NoizuPromptLingua.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :description, :text
      add :status, :string, null: false, default: "active"
      add :user_id, :binary_id

      timestamps(type: :utc_datetime)
    end

    create index(:sessions, [:status])
    create index(:sessions, [:user_id])
  end
end
