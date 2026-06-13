defmodule Codefresh.Repo.Migrations.CreateApiTokens do
  use Ecto.Migration

  def change do
    create table(:api_tokens) do
      add :organization_id, references(:organizations, type: :uuid, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :token_hash, :binary, null: false
      add :key_prefix, :string, null: false
      add :role, :string, null: false
      add :created_by_user_id, references(:users, type: :uuid, on_delete: :nilify_all)
      add :expires_at, :utc_datetime
      add :last_used_at, :utc_datetime
      add :revoked_at, :utc_datetime
      timestamps(type: :utc_datetime)
    end

    create unique_index(:api_tokens, [:token_hash])
    create unique_index(:api_tokens, [:organization_id, :name])
    create index(:api_tokens, [:key_prefix])
  end
end
