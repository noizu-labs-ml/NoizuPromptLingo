# -------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2023 Noizu Labs Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.Entity do
  @moduledoc """
  Load def_entity context.
  """

  # entity vsn number
  @callback vsn() :: float

  # entity meta data
  @callback __noizu_meta__() :: map()

  defmacro __using__(_options \\ nil) do
    quote do
      require Noizu.Entity.Macros
      require Noizu.Entity.Meta.Persistence
      import Noizu.Entity.Meta.Persistence

      import Noizu.Entity.Macros,
        only: [
          {:def_entity, 1},
          {:jason_encoder, 0},
          {:jason_encoder, 1}
        ]

      Module.register_attribute(__MODULE__, :persistence, accumulate: true)
    end
  end
end

defprotocol Noizu.Entity.Protocol do
  @moduledoc """
  Unique Identifier for Persistence Layer
  """
  # TODO Determine if this is still needed. Possibly consolidate.
  def layer_id(entity, layer)
end

defimpl Noizu.Entity.Protocol, for: Any do
  def layer_id(_entity, _layer), do: {:error, :not_supported}

  defmacro __deriving__(module, struct, options) do
    deriving(module, struct, options)
  end

  def deriving(module, _struct, _options) do
    # we should be defining a provider rather than requiring these methods be defined for each struct
    quote do
      defimpl Noizu.Entity.Protocol, for: [unquote(module)] do
        def layer_id(subject, layer)
        def layer_id(%{id: x}, _), do: {:ok, x}
      end
    end
  end
end
