defmodule NoizuPromptLingua.ChatTestSchema do
  @moduledoc """
  Idempotently ensures the chat-room slug column + the two partial unique indexes
  (Liquibase 052; ADR-013) exist on the test DB so the chat suite is self-contained
  on top of whatever Liquibase state the test DB has. Mirrors
  `NoizuPromptLingua.MemoryTestSchema`.

  No SQL backfill here: slug VALUES are produced solely by the canonical Elixir
  `NoizuPromptLingua.Domains.Chat.Slug.slugify/1` (on-insert path + backfill task). A SQL
  slugify would diverge from the app normalization (NFKD != unaccent) and manufacture
  false / missed collisions, so the test schema only provisions DDL — exactly mirroring
  prod's DDL-only 052.
  """
  alias NoizuPromptLingua.Repo

  @statements [
    # Drop the superseded org-wide unique index if a pre-rebalance run left it on the
    # test DB — it rejects the same slug across NULL/X project buckets and would fail
    # the per-bucket uniqueness tests. IF NOT EXISTS on the create won't remove it.
    "DROP INDEX IF EXISTS idx_chat_rooms_org_slug",
    "ALTER TABLE chat_rooms ADD COLUMN IF NOT EXISTS slug text",
    # Threaded replies (054 / ffa2d2f6): nullable self-FK, ON DELETE SET NULL
    # (parent-delete detaches replies to root, never nukes the thread). DROP+re-add the
    # FK each run so a test DB that got the column with a stale ON DELETE rule (e.g. an
    # earlier CASCADE draft) is corrected — ADD COLUMN IF NOT EXISTS alone won't fix it.
    "ALTER TABLE chat_messages ADD COLUMN IF NOT EXISTS parent_message_id uuid",
    "ALTER TABLE chat_messages DROP CONSTRAINT IF EXISTS chat_messages_parent_message_id_fkey",
    "ALTER TABLE chat_messages ADD CONSTRAINT chat_messages_parent_message_id_fkey FOREIGN KEY (parent_message_id) REFERENCES chat_messages(id) ON DELETE SET NULL",
    """
    CREATE UNIQUE INDEX IF NOT EXISTS idx_chat_rooms_slug_proj
    ON chat_rooms (organization_id, project_id, slug)
    WHERE project_id IS NOT NULL
    """,
    """
    CREATE UNIQUE INDEX IF NOT EXISTS idx_chat_rooms_slug_noproj
    ON chat_rooms (organization_id, slug)
    WHERE project_id IS NULL
    """
  ]

  def ensure! do
    Enum.each(@statements, fn sql -> Ecto.Adapters.SQL.query!(Repo, sql, []) end)
    :ok
  end
end
