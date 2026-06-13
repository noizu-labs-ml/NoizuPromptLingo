#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.Scaffolding.Test.Fixture.FooV2Repo do
  use Noizu.Scaffolding.V2.RepoBehaviour,
    nmid_generator: Noizu.Scaffolding.Test.Fixture.NmidGenerator
end
