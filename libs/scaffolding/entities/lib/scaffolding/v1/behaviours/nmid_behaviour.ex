#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.Scaffolding.NmidBehaviour do
  @moduledoc ("""
  This Behaviour provides a generic way for generating unique numeric or other identifiers scoped by instance and entity type.
  """)
  @type seq :: tuple
  @type opts :: Map.t
  @type detail :: any
  @type nmid :: integer | atom | String.t

  @doc ("Update internal sequence and generate new identifier (with out transaction wrapper)")
  @callback generate(seq, opts) :: nmid | {:error, detail}

  @doc ("Update internal sequence and generate new identifier (with transaction wrapper)")
  @callback generate!(seq, opts) :: nmid | {:error, detail}
end
