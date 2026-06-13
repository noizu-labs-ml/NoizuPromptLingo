# -------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2025 Noizu Labs Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.Entity.Meta.Identifier do
  @moduledoc """
  Logic for entity identifier details.
  """
  require Record
  Record.defrecord(:id_settings, name: nil, generate: true, universal: false, type: nil)

  @typedoc """
  Name of identifier field (Default :id)
  """
  @type identifier_name :: term
  @typedoc """
  Auto generate identifier?
  """
  @type identifier_generate :: term

  @typedoc """
  Is this identifier universal? (i.e. identifier encodes information about table source, node tenancy and id)
  """
  @type identifier_universal :: term

  @typedoc """
  Type of identifier field (Default :uuid)
  """
  @type identifier_type :: :uuid | :atom | :integer | :ref | :dual_ref | term

  @typedoc """
  Identifier Field Metadata entry
  """
  @type id_settings ::
          record(
            :id_settings,
            name: identifier_name,
            generate: identifier_generate,
            universal: identifier_universal,
            type: identifier_type
          )
end
