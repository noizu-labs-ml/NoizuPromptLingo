#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.Scaffolding.QueryBehaviour do
  @type ref :: tuple
  @type opts :: Map.t
  @type mnesia_table :: atom
  @callback match(any, mnesia_table, Noizu.Scaffolding.CallingContext.t, opts) :: list | {:error, any}
  @callback list(mnesia_table, Noizu.Scaffolding.CallingContext.t, opts) :: list | {:error, any}
  @callback get(any, mnesia_table, Noizu.Scaffolding.CallingContext.t, opts) :: any | {:error, any}
  @callback delete(any, mnesia_table, Noizu.Scaffolding.CallingContext.t, opts) :: :ok | {:error, any}
  @callback update(any, mnesia_table, Noizu.Scaffolding.CallingContext.t, opts) :: any | {:error, any}
  @callback delete(any, mnesia_table, Noizu.Scaffolding.CallingContext.t, opts) :: any | {:error, any}
end
