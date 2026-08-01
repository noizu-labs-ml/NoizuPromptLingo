defmodule Noizu.PM do
  @moduledoc """
  Shared project-management data layer for the Noizu product family.

  This library owns the `Noizu.PM.Repo` Ecto repository (backed by the
  `pm_core` database) and the consolidated identity-spine + work-item schemas
  that `npl-mcp` and `therobotplans` share. Host applications start the Repo
  themselves; this module stays inert, mirroring `Noizu.Core`.
  """
end
