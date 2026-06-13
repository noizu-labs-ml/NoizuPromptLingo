defmodule Derobot.Repo.Migrations.CreateUserCredentials do
  use Ecto.Migration

  def change do
    create table(:user_credentials) do
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :auth_provider_id, references(:auth_providers, type: :uuid, on_delete: :restrict), null: false
      add :status, :string, null: false, default: "active"
      add :settings, :map, default: %{}
      add :state, :map, default: %{}
      add :fingerprint, :string
      add :deleted_at, :utc_datetime_usec
      timestamps(type: :utc_datetime_usec)
    end

    create index(:user_credentials, [:user_id])
    create index(:user_credentials, [:auth_provider_id])
    create index(:user_credentials, [:fingerprint])
    create unique_index(:user_credentials, [:user_id, :auth_provider_id, :fingerprint])
  end
end
