defmodule Derobot.Repo.Migrations.UpgradeUsersForSSO do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add_if_not_exists :user_name, :string
      add_if_not_exists :handle, :string
      add_if_not_exists :status, :string, default: "active"
      add_if_not_exists :verified, :boolean, default: false
      add_if_not_exists :flagged, :boolean, default: false
      add_if_not_exists :deleted_at, :utc_datetime_usec

      modify :hashed_password, :string, null: true
      modify :inserted_at, :utc_datetime_usec, from: :utc_datetime
      modify :updated_at, :utc_datetime_usec, from: :utc_datetime
    end

    create_if_not_exists unique_index(:users, [:handle])
    create_if_not_exists unique_index(:users, [:user_name])
  end
end
