# -------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.FastGlobal.Record do
  @vsn 1.0
  # -----------------------------------------------------------------------------
  # Struct & Types
  # -----------------------------------------------------------------------------
  @type t :: %__MODULE__{
          identifier: tuple,
          value: any,
          origin: any,
          pool: list,
          revision: integer,
          ts: integer,
          vsn: any
        }

  defstruct identifier: nil,
            value: nil,
            origin: nil,
            pool: [],
            revision: 1,
            ts: 0,
            vsn: 1.0
end
