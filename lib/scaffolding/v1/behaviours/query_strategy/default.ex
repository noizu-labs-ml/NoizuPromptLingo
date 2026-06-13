#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.Scaffolding.QueryStrategy.Default do
  @behaviour Noizu.Scaffolding.QueryBehaviour
  alias Noizu.ElixirCore.CallingContext
  alias Amnesia.Table, as: T
  #alias Amnesia.Table.Selection, as: S
  require Exquisite
  require Logger


  def match(match_sel, mnesia_table, %CallingContext{} = _context, options) do
    if options[:match][:lock] do
      T.match(mnesia_table, options[:match][:lock], match_sel)
    else
      T.match(mnesia_table, match_sel)
    end
  end

  def list(mnesia_table, %CallingContext{} = _context, options) do
    pg = options[:pg] || 1
    rpp = options[:rpp] || 5000

    qspec = cond do
      filters = options[:filters] ->
        Enum.map(filters, fn(filter) ->
          index = Enum.find_index(Keyword.keys(mnesia_table.attributes()), &( &1 == filter[:field]))
          f = cond do
            index != nil -> :"$#{index + 1}"
            true ->
              Logger.warn("Attempting to filter query by nonexistent field #{filter[:field]}")
              nil
          end
          v = is_tuple(filter[:value]) && {filter[:value]} || filter[:value]
          {filter[:comparison] || :==, f, v}
        end)

      filter = options[:filter] ->
        index = Enum.find_index(Keyword.keys(mnesia_table.attributes()), &( &1 == filter[:field]))
        f = cond do
          index != nil -> :"$#{index + 1}"
          true ->
            Logger.warn("Attempting to filter query by nonexistent field #{filter[:field]}")
            nil
        end
        v = is_tuple(filter[:value]) && {filter[:value]} || filter[:value]
        [{filter[:comparison] || :==, f, v}]
      true -> [{:==, true, true}]
    end

    a = for index <- 1..Enum.count(mnesia_table.attributes()) do
      String.to_atom("$#{index}")
    end

    t = List.to_tuple([mnesia_table] ++ a)
    spec = [{t, qspec, [:"$_"]}]

    raw = T.select(mnesia_table, rpp, spec)
    case raw do
      nil -> nil
      :badarg -> :badarg
      raw ->
        raw = if pg > 1, do: Enum.reduce(2..pg, raw, fn(_i, a) -> Amnesia.Selection.next(a) end), else: raw
        if raw == nil, do: nil, else: %Amnesia.Table.Select{raw| coerce: mnesia_table}
    end
  end

  def get(identifier, mnesia_table,  %CallingContext{} = _context, options) do
    if options[:dirty] == true do
      mnesia_table.read!(identifier)
    else
      mnesia_table.read(identifier)
    end
  end

  def update(entity, mnesia_table,  %CallingContext{} = _context, options) do
    if options[:dirty] == true do
      mnesia_table.write!(entity)
    else
      mnesia_table.write(entity)
    end
  end

  def create(entity, mnesia_table,  %CallingContext{} = _context, options) do
    if options[:dirty] == true do
      mnesia_table.write!(entity)
    else
      mnesia_table.write(entity)
    end
  end

  def delete(identifier, mnesia_table,  %CallingContext{} = _context, options) do
    if options[:dirty] == true do
      mnesia_table.delete!(identifier)
    else
      mnesia_table.delete(identifier)
    end
  end

end
