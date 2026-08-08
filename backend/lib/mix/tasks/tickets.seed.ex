defmodule Mix.Tasks.Tickets.Seed do
  @shortdoc "Seed the default global ticket field & type definitions"
  @moduledoc """
  Seeds the default **global** ticket field and type definitions (the standard
  bug/task/epic/etc. types and their fields). Every organization and project
  inherits these and may override, extend, or disable them at a more-specific
  scope.

  Idempotent — re-running upserts by (scope, slug), so it is safe to run again.

      mix tickets.seed
  """
  use Mix.Task

  @requirements ["app.start"]

  @impl Mix.Task
  def run(_args) do
    :ok = NoizuPromptLingua.Domains.Tickets.Seed.run()
    Mix.shell().info("Seeded global ticket field & type definitions.")
  end
end
