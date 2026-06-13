# -------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
# -------------------------------------------------------------------------------

defprotocol Noizu.ElixirCore.OSP do
  @doc """
  Extract an option from user provided values
  """
  def extract(this, acc)
end

# end defprotocol Noizu.ERP

defprotocol Noizu.ElixirCore.SlimOptions do
  @fallback_to_any true
  def slim(entity)
end

defimpl Noizu.ElixirCore.SlimOptions, for: Map do
  def slim(entity) do
    Enum.map(entity, fn {k, v} -> {k, Noizu.ElixirCore.SlimOptions.slim(v)} end)
  end
end

defimpl Noizu.ElixirCore.SlimOptions, for: Any do
  def slim(entity) do
    entity
  end
end

defimpl Noizu.ElixirCore.SlimOptions,
  for: [
    Noizu.ElixirCore.OptionSettings,
    Noizu.ElixirCore.OptionValue,
    Noizu.ElixirCore.OptionList
  ] do
  def slim(entity) do
    Noizu.ElixirCore.SlimOptions.slim(Map.from_struct(entity))
  end
end
