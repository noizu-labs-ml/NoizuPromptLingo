defmodule Mix.Tasks.Tickets.BackfillKeys do
  @shortdoc "Backfill human keys (PREFIX-NNN) for pre-existing tickets (055 / f8bc7fab)"
  @moduledoc """
  Assigns an immutable human key + per-scope number to every ticket still missing one,
  using the single canonical `NoizuPromptLingua.Domains.Tickets` key generator (the same
  atomic per-scope counter + prefix logic the on-insert path uses).

  Idempotent and re-runnable: only NULL-key tickets are touched, processed oldest-first
  so per-scope numbering follows insertion order. Run AFTER 055 applies and AFTER the
  key-on-insert app code deploys.

      mix tickets.backfill_keys
  """
  use Mix.Task

  @requirements ["app.start"]

  @impl Mix.Task
  def run(_args) do
    filled = NoizuPromptLingua.Domains.Tickets.backfill_keys()
    Mix.shell().info("Backfilled #{filled} ticket key(s).")
  end
end
