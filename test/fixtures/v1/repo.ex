#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.Scaffolding.Test.Fixture.FooRepo do
  use Noizu.Scaffolding.RepoBehaviour,
    nmid_generator: Noizu.Scaffolding.Test.Fixture.NmidGenerator
end
