# -------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2025 Noizu Labs Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.Entity.Meta.Json do
  @moduledoc """
  Logic for entity json details.
  """
  require Record

  Record.defrecord(:json_settings,
    template: nil,
    field: nil,
    as: {:nz, :inherit},
    omit: {:nz, :inherit},
    error: {:nz, :inherit}
  )

  @typedoc """
  Json Template rule applies to.
  """
  @type json_template :: term

  @typedoc """
  Field json entry is for
  """
  @type json_field :: term

  @typedoc """
  Rename json field as
  """
  @type json_as :: term

  @typedoc """
  Omit field form json output
  """
  @type json_omit :: term

  @typedoc """
  Encoding error.
  """
  @type json_error :: term

  @typedoc """
  Persistence Metadata entry
  """
  @type json_settings ::
          record(
            :json_settings,
            template: json_template,
            field: json_field,
            as: json_as,
            omit: json_omit,
            error: json_error
          )
end
