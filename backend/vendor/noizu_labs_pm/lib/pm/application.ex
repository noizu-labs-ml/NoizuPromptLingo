defmodule Noizu.PM.Application do
  @moduledoc """
  No-op application callback.

  The `Noizu.PM.Repo` process is owned and supervised by the host application,
  not by this library, so there is nothing for this module to start. The
  callback exists only to satisfy `mod: {Noizu.PM.Application, []}` if a host
  opts into it — mirroring how `:noizu_labs_core` stays inert.
  """
  use Application

  @impl true
  def start(_type, _args) do
    Supervisor.start_link([], strategy: :one_for_one, name: Noizu.PM.Supervisor)
  end
end
