defmodule Mix.Tasks.Chat.BackfillSlugs do
  @shortdoc "Backfill chat-room slugs for pre-deploy rooms (Liquibase 052 / ADR-013)"
  @moduledoc """
  Fills `slug` for any `chat_rooms` row still missing one, using the single
  canonical `NoizuPromptLingua.Domains.Chat.slugify/1` (the same function the
  on-insert path uses — no divergent SQL normalization).

  Idempotent and re-runnable: only NULL slugs are touched, and the collision
  suffix is assigned by retrying on the live partial unique index (23505), never
  a select-then-insert. Run AFTER 052a + 052c (column + indexes) and BEFORE 052d
  (the NOT NULL flip, which is gated on a zero-null precondition).

      mix chat.backfill_slugs
  """
  use Mix.Task

  @requirements ["app.start"]

  @impl Mix.Task
  def run(_args) do
    filled = NoizuPromptLingua.Domains.Chat.backfill_slugs()
    Mix.shell().info("Backfilled #{filled} chat-room slug(s).")
  end
end
