#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.Scaffolding.Query.EntityRefFilteringBehaviour do

  defmacro __using__(options) do
    r = Keyword.get(options, :only, [:match, :list, :create, :get, :update, :delete])
    only = %{
      match: Enum.member?(r, :match),
      list: Enum.member?(r, :list),
      get: Enum.member?(r, :get),
      update: Enum.member?(r, :update),
      delete: Enum.member?(r, :delete),
      create: Enum.member?(r, :create),
    }

    r = Keyword.get(options, :override, [])
    override = %{
      match: Enum.member?(r, :match),
      list: Enum.member?(r, :list),
      get: Enum.member?(r, :get),
      update: Enum.member?(r, :update),
      delete: Enum.member?(r, :delete),
      create: Enum.member?(r, :create),
    }
    mnesia_table = Keyword.get(options, :mnesia_table)

    constraint_field = Keyword.get(options, :constraint_field, :entity_ref)

    if mnesia_table == nil do
       throw "mnesia_table must be passed when calling RepoBehaviour"
    end

    quote do
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      import unquote(__MODULE__)
      @behaviour Noizu.Scaffolding.QueryBehaviour

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      if (unquote(only.match) && !unquote(override.match)) do
        def match(_match_sel, _mnesia_table, %Noizu.ElixirCore.CallingContext{} = _context, _options) do
          throw "Match NYI"
        end
      end

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      if (unquote(only.list) && !unquote(override.list)) do
        def list(mnesia_table, %Noizu.ElixirCore.CallingContext{} = context, options) do
          if (options[:filter_caller]) do
            ref = context.caller
            mnesia_table.where unquote(constraint_field) == ref
          else
            if (options[:filter_entity]) do
              ref = options[:filter_entity]
              mnesia_table.where unquote(constraint_field) == ref
            else
              mnesia_table.where 1 == 1
            end
          end
        end
      end # end conditional include

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      if (unquote(only.get) && !unquote(override.get)) do
        def get(identifier, mnesia_table, %Noizu.ElixirCore.CallingContext{} = context, options) do
          record = if options[:dirty] == true do
            mnesia_table.read!(identifier)
          else
            mnesia_table.read(identifier)
          end

          if (options[:filter_caller]) do
            ref = context.caller
            if (record.unquote(constraint_field) == ref), do: record, else: throw "Not linked to caller"
          else
            if (options[:filter_entity]) do
              ref = options[:filter_entity]
              if (record.unquote(constraint_field) == ref), do: record, else: throw "Not linked to filter_entity"
            else
              record
            end
          end
        end
      end # end conditional include

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      if (unquote(only.create) && !unquote(override.create)) do
        def create(record, mnesia_table, %Noizu.ElixirCore.CallingContext{} = context, options) do
          if (options[:filter_caller]) do
            ref = context.caller
            if (record.unquote(constraint_field) == ref) do
               if options[:dirty] == true do
                 mnesia_table.write!(record)
               else
                 mnesia_table.write(record)
               end
            else
                throw "Not linked to caller"
            end
          else
            if (options[:filter_entity]) do
              ref = options[:filter_entity]
              if (record.unquote(constraint_field) == ref) do
                 if options[:dirty] == true  do
                   mnesia_table.write!(record)
                 else
                   mnesia_table.write(record)
                 end
              else
                 throw "Not linked to filter_entity"
              end
            else
              if options[:dirty] == true  do
                mnesia_table.write!(record)
              else
                mnesia_table.write(record)
              end
            end
          end
        end
      end # end conditional include

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      if (unquote(only.update) && !unquote(override.update)) do
        def update(record, mnesia_table, %Noizu.ElixirCore.CallingContext{} = context, options) do
          if (options[:filter_caller]) do
            ref = context.caller
            record2 = if options[:dirty] == true  do
              mnesia_table.read!(record.identifier)
            else
              mnesia_table.read(record.identifier)
            end

            if (record2.unquote(constraint_field) == ref) do
               if options[:dirty] == true  do
                 mnesia_table.write!(record)
               else
                 mnesia_table.write(record)
               end
            else
              throw "Not linked to caller"
            end
          else
            if (options[:filter_entity]) do
              ref = options[:filter_entity]
              record2 = mnesia_table.read(record.identifier)
              if (record2.unquote(constraint_field) == ref) do
                 if options[:dirty] == true  do
                   mnesia_table.write!(record)
                 else
                   mnesia_table.write(record)
                 end
              else
                 throw "Not linked to filter_entity"
              end
            else
              if options[:dirty] == true  do
                mnesia_table.write!(record)
              else
                mnesia_table.write(record)
              end
            end
          end
        end
      end # end conditional include

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      if (unquote(only.delete) && !unquote(override.delete)) do
        def delete(identifier, %Noizu.ElixirCore.CallingContext{} = context, options) do
          if (options[:filter_caller]) do
            ref = context.caller
            record = if options[:dirty] == true  do
              mnesia_table.read!(identifier)
            else
              mnesia_table.read(identifier)
            end
            if (record.unquote(constraint_field) == ref) do
              if options[:dirty] == true  do
                mnesia_table.delete!(identifier)
              else
                mnesia_table.delete(identifier)
              end
            else
               throw "Not linked to caller"
            end
          else
            if (options[:filter_entity]) do
              ref = options[:filter_entity]
              record = if options[:dirty] == true  do
                mnesia_table.read!(identifier)
              else
                mnesia_table.read(identifier)
              end
              if (record.unquote(constraint_field) == ref) do
                if options[:dirty] == true  do
                  mnesia_table.delete!(identifier)
                else
                  mnesia_table.delete(identifier)
                end
              else
                 throw "Not linked to filter_entity"
               end
            else
              if options[:dirty] == true  do
                mnesia_table.delete!(identifier)
              else
                mnesia_table.delete(identifier)
              end
            end
          end
        end
      end # end conditional include
    end # end quote
  end # end using macro
end # end module
