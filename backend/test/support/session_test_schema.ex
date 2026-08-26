defmodule NoizuPromptLingua.SessionTestSchema do
  @moduledoc """
  Idempotently brings the `sessions` table up to the Liquibase 072 + 079 schema
  on the test DB — the nullable `model` / `runner` columns (spec §3) and the
  `last_activity_at` column + widened status CHECK (inactivity sweep) — so the
  sessions suite is self-contained on top of whatever Liquibase state the test
  DB has. Mirrors `BoardTestSchema` / `TicketTestSchema`.

  `sessions` is created at 026, EXTENDED at 072 with the harness/model the
  session's tailored tool descriptions target, and at 079 with the inactivity
  sweep columns/constraint. Both are committed + in master, so prod runs the
  ALTERs via Liquibase — these IF-NOT-EXISTS statements only reconcile the
  test DB.
  """
  alias NoizuPromptLingua.Repo

  @statements [
    "ALTER TABLE sessions ADD COLUMN IF NOT EXISTS model varchar(255)",
    "ALTER TABLE sessions ADD COLUMN IF NOT EXISTS runner varchar(255)",
    "ALTER TABLE sessions ADD COLUMN IF NOT EXISTS last_activity_at timestamptz",
    """
    UPDATE sessions SET last_activity_at = updated_at WHERE last_activity_at IS NULL
    """,
    # 079 widens the status CHECK to include 'inactive'. Postgres has no
    # ADD CONSTRAINT IF NOT EXISTS, and the constraint body can't be tested
    # cheaply, so drop-if-exists + re-add (idempotent, cheap on a test DB).
    "ALTER TABLE sessions DROP CONSTRAINT IF EXISTS sessions_status_check",
    """
    ALTER TABLE sessions ADD CONSTRAINT sessions_status_check
      CHECK (status IN ('active', 'archived', 'completed', 'inactive'))
    """
  ]

  def ensure! do
    Enum.each(@statements, fn sql -> Ecto.Adapters.SQL.query!(Repo, sql, []) end)
    :ok
  end
end
