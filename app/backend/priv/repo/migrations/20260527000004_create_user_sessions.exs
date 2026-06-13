defmodule Derobot.Repo.Migrations.CreateUserSessions do
  use Ecto.Migration

  def change do
    create table(:user_sessions) do
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :credential_id, references(:user_credentials, type: :uuid, on_delete: :nilify_all)
      add :status, :string, null: false, default: "active"
      add :details, :map, default: %{}
      add :deleted_at, :utc_datetime_usec
      timestamps(type: :utc_datetime_usec)
    end

    create index(:user_sessions, [:user_id])
    create index(:user_sessions, [:credential_id])
  end
end
