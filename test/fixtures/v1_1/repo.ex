#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.Scaffolding.Test.Fixture.FooV1_1Repo do
  use Noizu.Scaffolding.V1_1.RepoBehaviour,
    nmid_generator: Noizu.Scaffolding.Test.Fixture.NmidGenerator
end
