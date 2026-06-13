#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------


defmodule Noizu.Scaffolding.Test.Fixture.FooV1_1Entity do
  @vsn (1.0)

  #-----------------------------------------------------------------------------
  # Struct & Types
  #-----------------------------------------------------------------------------
  @type t :: %__MODULE__{
    identifier: Types.appengine_id,
    second: any,
    content: any,
    vsn: Types.vsn
  }

  defstruct [
      identifier: nil,
      second: :apple,
      content: :test,
      vsn: @vsn
  ]

  use Noizu.Scaffolding.V1_1.EntityBehaviour,
      sref_module: "foo-v1p1-test",
      as_record_options: %{additional_fields: [:second]}

end

