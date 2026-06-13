defmodule Derobot.Repo.Migrations.CreateAuthProviders do
  use Ecto.Migration

  def change do
    create table(:auth_providers) do
      add :title, :string, null: false
      add :description, :string
      add :settings, :binary
      add :deleted_at, :utc_datetime_usec
      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:auth_providers, [:title])
  end
end
