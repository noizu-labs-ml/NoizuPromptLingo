defmodule Codefresh.Repo.Migrations.CreateInviteTokens do
  use Ecto.Migration

  def change do
    create table(:invite_tokens) do
      # Nullable: platform-wide bootstrap invites (token redeemer creates a fresh org)
      # Set: redeemer joins this existing org with the invite's role
      add :organization_id, references(:organizations, type: :uuid, on_delete: :delete_all)
      add :email, :citext
      add :role, :string, null: false
      add :token_hash, :binary, null: false
      add :key_prefix, :string, null: false
      add :invited_by_user_id, references(:users, type: :uuid, on_delete: :nilify_all)
      add :expires_at, :utc_datetime
      add :max_uses, :integer, null: false, default: 1
      add :use_count, :integer, null: false, default: 0
      add :last_redeemed_at, :utc_datetime
      add :revoked_at, :utc_datetime
      add :metadata, :map, null: false, default: %{}
      timestamps(type: :utc_datetime)
    end

    create unique_index(:invite_tokens, [:token_hash])
    create index(:invite_tokens, [:organization_id])
    create index(:invite_tokens, [:email])
    create index(:invite_tokens, [:key_prefix])

    # Active-invite index (not exhausted, not revoked, not expired)
    execute(
      """
      CREATE INDEX invite_tokens_active_idx ON invite_tokens (organization_id, email)
      WHERE revoked_at IS NULL AND use_count < max_uses
      """,
      "DROP INDEX invite_tokens_active_idx"
    )

    # One active email-bound invite per (org, email) — prevents duplicate pending invites
    execute(
      """
      CREATE UNIQUE INDEX invite_tokens_unique_active_email ON invite_tokens (organization_id, email)
      WHERE email IS NOT NULL AND revoked_at IS NULL AND use_count < max_uses
      """,
      "DROP INDEX invite_tokens_unique_active_email"
    )

    # Sanity: max_uses >= 1
    execute(
      "ALTER TABLE invite_tokens ADD CONSTRAINT invite_tokens_max_uses_positive CHECK (max_uses >= 1)",
      "ALTER TABLE invite_tokens DROP CONSTRAINT invite_tokens_max_uses_positive"
    )

    # Sanity: use_count <= max_uses
    execute(
      "ALTER TABLE invite_tokens ADD CONSTRAINT invite_tokens_use_count_bounded CHECK (use_count >= 0 AND use_count <= max_uses)",
      "ALTER TABLE invite_tokens DROP CONSTRAINT invite_tokens_use_count_bounded"
    )
  end
end
