#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.Scaffolding.AuditEngineBehaviour do
  @moduledoc """
  This Protocol provides a generic way for our scaffolding system to record audit worthy events.
  Actual implementation is left to the user but notes on a possible implemention are included in this projects README.md file.
  """

  @type note :: nil | String.t
  @type nmid :: integer | atom | String.t
  @type entity :: {:ref, atom, nmid} | any
  @type details :: any
  @type event :: atom | tuple
  @type response :: :ok | {:error, details} | any

  @doc "Save event occurence to persistence layer with out wrapping within a Mnesia transaction."
  @callback audit(event, details, entity, Noizu.ElixirCore.CallingContext.t, note) :: response

  @doc "Save event occurence to persistence layer including mnesia transaction if mnesia backend used."
  @callback audit!(event, details, entity, Noizu.ElixirCore.CallingContext.t, note) :: response
end
