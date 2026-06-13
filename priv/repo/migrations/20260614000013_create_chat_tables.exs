defmodule NoizuPromptLingua.Repo.Migrations.CreateChatTables do
  use Ecto.Migration

  def change do
    create table(:chat_rooms, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text
      add :session_id, :binary_id

      timestamps(type: :utc_datetime)
    end

    create index(:chat_rooms, [:session_id])

    create table(:chat_messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :room_id, references(:chat_rooms, type: :binary_id, on_delete: :delete_all), null: false
      add :content, :text, null: false
      add :sender, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:chat_messages, [:room_id])
    create index(:chat_messages, [:room_id, :inserted_at])

    create table(:chat_events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :room_id, references(:chat_rooms, type: :binary_id, on_delete: :delete_all), null: false
      add :event_type, :string, null: false
      add :content, :text, null: false
      add :sender, :string, null: false
      add :metadata, :map

      timestamps(type: :utc_datetime)
    end

    create index(:chat_events, [:room_id])
    create index(:chat_events, [:room_id, :event_type])

    create table(:chat_members, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :room_id, references(:chat_rooms, type: :binary_id, on_delete: :delete_all), null: false
      add :persona, :string, null: false
      add :role, :string, null: false, default: "member"

      timestamps(type: :utc_datetime)
    end

    create unique_index(:chat_members, [:room_id, :persona])

    create table(:chat_notifications, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :room_id, references(:chat_rooms, type: :binary_id, on_delete: :delete_all), null: false
      add :persona, :string, null: false
      add :message, :string, null: false
      add :read, :boolean, null: false, default: false

      timestamps(type: :utc_datetime)
    end

    create index(:chat_notifications, [:persona, :read])
  end
end
