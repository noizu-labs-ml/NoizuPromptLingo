defmodule NoizuPromptLingua.AuthzTestSchema do
  @moduledoc """
  Idempotently brings the PBAC role tier up to ADR-015 / Liquibase 053 on the test DB:
  adds 'lead' to role_name_enum and inserts the 'lead' group row. Mirrors the other
  *TestSchema helpers. 053 is committed + in master, so prod has it — this only
  reconciles the test DB.

  Runs in test_helper (autocommit, outside the sandbox), so ALTER TYPE ADD VALUE — which
  cannot run inside a transaction — is safe here; IF NOT EXISTS makes it re-runnable.
  """
  alias NoizuPromptLingua.Repo

  def ensure! do
    Ecto.Adapters.SQL.query!(
      Repo,
      "ALTER TYPE role_name_enum ADD VALUE IF NOT EXISTS 'lead' BEFORE 'member'",
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      "INSERT INTO groups (name, display_name, description, is_system) " <>
        "VALUES ('lead', 'Lead', 'member + management/moderation (ADR-015)', true) " <>
        "ON CONFLICT (name) DO NOTHING",
      []
    )

    :ok
  end
end
