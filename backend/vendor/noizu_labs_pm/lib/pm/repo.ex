defmodule Noizu.PM.Repo do
  @moduledoc """
  Ecto repository for the shared `pm_core` database.

  Started by the host application (npl-mcp / therobotplans) — not by this
  library's own (non-existent) supervision tree. Each host adds
  `Noizu.PM.Repo` to its children and lists `:noizu_labs_pm` as an
  extra_application so the config below is reachable.
  """
  use Ecto.Repo,
    otp_app: :noizu_labs_pm,
    adapter: Ecto.Adapters.Postgres
end
