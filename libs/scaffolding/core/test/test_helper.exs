# -------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
# -------------------------------------------------------------------------------

ExUnit.configure(formatters: [JUnitFormatter, ExUnit.CLIFormatter])

Application.ensure_started(:semaphore)
Application.ensure_started(:fast_global)

children = [{Task.Supervisor, name: Noizu.FastGlobal.Cluster}]

{:ok, sup} =
  Supervisor.start_link(children,
    strategy: :one_for_one,
    name: Test.Supervisor,
    strategy: :one_for_one
  )

Amnesia.Schema.create()
Amnesia.start()

if Noizu.FastGlobal.Database.Settings.wait(500) != :ok do
  Noizu.FastGlobal.Database.Settings.create(disk: [node()]) |> IO.inspect()
end

if Noizu.FastGlobal.Database.Settings.read!(:fast_global_settings) == nil do
  %Noizu.FastGlobal.Database.Settings{identifier: :fast_global_settings, value: %{}}
  |> Noizu.FastGlobal.Database.Settings.write!()
end

# http://elixir-lang.org/docs/stable/ex_unit/ExUnit.html#start/1
ExUnit.start(capture_log: true)
