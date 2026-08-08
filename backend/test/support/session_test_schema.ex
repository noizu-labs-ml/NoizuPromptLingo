defmodule NoizuPromptLingua.SessionTestSchema do
  @moduledoc """
  Idempotently brings the `sessions` table up to the Liquibase 072 schema on the
  test DB — the nullable `model` / `runner` columns (spec §3) — so the sessions
  suite is self-contained on top of whatever Liquibase state the test DB has.
  Mirrors `BoardTestSchema` / `TicketTestSchema`.

  `sessions` is created at 026 and EXTENDED at 072 with the harness/model the
  session's tailored tool descriptions target. 072 is committed + in master, so
  prod runs the ALTER via Liquibase — these IF-NOT-EXISTS statements only
  reconcile the test DB.
  """
  alias NoizuPromptLingua.Repo

  @statements [
    "ALTER TABLE sessions ADD COLUMN IF NOT EXISTS model varchar(255)",
    "ALTER TABLE sessions ADD COLUMN IF NOT EXISTS runner varchar(255)"
  ]

  def ensure! do
    Enum.each(@statements, fn sql -> Ecto.Adapters.SQL.query!(Repo, sql, []) end)
    :ok
  end
end
