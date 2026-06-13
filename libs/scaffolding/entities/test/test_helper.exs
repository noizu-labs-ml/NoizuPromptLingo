#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

Application.ensure_all_started(:telemetry_app)

# http://elixir-lang.org/docs/stable/ex_unit/ExUnit.html#start/1



# Danger Will Robinson.
use  Noizu.Database.Scaffolding.Test.Fixture.FooTable
use  Noizu.Database.Scaffolding.Test.Fixture.FooV2Table
use  Noizu.Database.Scaffolding.Test.Fixture.FooV1_1Table
alias Noizu.Database.Scaffolding.Test.Fixture.FooTable
alias Noizu.Database.Scaffolding.Test.Fixture.FooV2Table
alias Noizu.Database.Scaffolding.Test.Fixture.FooV1_1Table

if Mix.env == :test do
  Amnesia.stop
  Amnesia.Schema.destroy
  Amnesia.Schema.create()
end
Amnesia.start

if !Amnesia.Table.exists?(FooTable), do: FooTable.create(memory: [node()])
if !Amnesia.Table.exists?(FooV2Table), do: FooV2Table.create(memory: [node()])
if !Amnesia.Table.exists?(FooV1_1Table), do: FooV1_1Table.create(memory: [node()])


ExUnit.start(capture_log: true)
