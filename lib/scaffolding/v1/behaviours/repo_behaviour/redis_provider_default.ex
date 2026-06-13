#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.Scaffolding.RepoBehaviour.RedisProviderDefault do
  alias Noizu.ElixirCore.CallingContext

  #-----------------------------------------------------------------------------
  #  Utils
  #-----------------------------------------------------------------------------
  def expand_table(module) do
    path = Module.split(module)
    default_database = Module.concat([List.first(path), "Database"])
    root_table =
      Application.get_env(:noizu_scaffolding, :default_database, default_database)
      |> Module.split()
    entity_name = path |> List.last()
    table_name = String.slice(entity_name, 0..-5) <> "Table"
    inner_path = Enum.slice(path, 1..-2)
    Module.concat(root_table ++ inner_path ++ [table_name])
  end #end expand_table

  def expand_entity(module) do
    rm = Module.split(module) |> Enum.slice(0..-2) |> Module.concat
    m = (Module.split(module) |> List.last())
    t = String.slice(m, 0..-5) <> "Entity"
    Module.concat([rm, t])
  end # end expand_repo

  #-------------------------------
  # match/4
  #-------------------------------
  def match({_mod, entity_module, _mnesia_table, query_strategy, _audit_engine, _dirty, _frag, _audit_level} = _indicator, match_sel, %CallingContext{} = context, options) do
    strategy = options[:query_strategy] || query_strategy
    #if options[:audit] do
    #  audit_engine = options[:audit_engine] || audit_engine
    #  audit_engine.audit(:match, :scaffolding, entity_module, context, options)
    #end

    case strategy.match(match_sel, entity_module, context, options) do
      nil ->
        []
      {:ok, m} ->
        m
        |> Enum.map(fn(x) -> entity_module.redis_decode(x, options) end)
    end
  end # end list/3

  def match!(indicator, match_sel, %CallingContext{} = context, options) do
    match(indicator, match_sel, context, options)
  end

  def list({_mod, entity_module, _mnesia_table, query_strategy, _audit_engine, _dirty, _frag, _audit_level} = _indicator, %CallingContext{} = context, options) do
    strategy = options[:query_strategy] || query_strategy
    #if options[:audit] do
    #  audit_engine = options[:audit_engine] || audit_engine
    #  audit_engine.audit(:list, :scaffolding, entity_module, context, options)
    #end
    case strategy.list(entity_module, context, options) do
      {:error, _details} -> []
      nil ->
        []
      {:ok, m} ->
        m
        |> Enum.map(fn(x) -> entity_module.redis_decode(x, options) end)
    end
  end # end list/3

  def list!(indicator, %CallingContext{} = context, options) do
    list(indicator, context, options)
  end

  def get({mod, entity_module, _mnesia_table, query_strategy, _audit_engine, _dirty, _frag, _audit_level} = _indicator, identifier, %CallingContext{} = context, options) do
    strategy = options[:query_strategy] || query_strategy
    case strategy.get(identifier, entity_module, context, options) do
      {:ok, encoded} ->
        entity_module.redis_decode(encoded, options)
        |> mod.post_get_callback(context, options)
      error -> error
    end
  end # end get/3
  def post_get_callback(_indicator, entity, _context, _options), do: entity

  def get!(indicator, identifier, %CallingContext{} = context, options) do
    get(indicator, identifier, context, options)
  end

  def pre_update_callback(_indicator, entity, _context, _options), do: entity

  def post_update_callback(_indicator, entity, _context, _options), do: entity

  def update({mod, entity_module, _mnesia_table, query_strategy, _audit_engine, _dirty, _frag, _audit_level} = _indicator, entity, %CallingContext{} = context, options) do
    strategy = options[:query_strategy] || query_strategy
    if entity.identifier == nil, do: throw "Cannot Update #{inspect entity_module} with out identifier field set."
    entity = mod.pre_update_callback(entity, context, options)

    case strategy.update(entity, entity_module, context, options) do
      {:ok, _encoded} ->
        #cond do
        #  options[:audit] == false -> :skip
        #  true ->
        #    audit_engine = options[:audit_engine] || audit_engine
        #    audit_engine.audit(:update!, :scaffolding, ref, context, options)
        #end

        entity
        |> mod.post_update_callback(context, options)
      error -> error
    end
  end # end update/3

  def update!(indicator, entity, %CallingContext{} = context, options) do
    update(indicator, entity, context, options)
  end

  def pre_delete_callback(_indicator, entity, _context, _options), do: entity

  def post_delete_callback(_indicator, entity, _context, _options), do: entity

  def delete({mod, entity_module, _mnesia_table, query_strategy, _audit_engine, _dirty, _frag, _audit_level} = _indicator, entity, %CallingContext{} = context, options) do
    strategy = options[:query_strategy] || query_strategy
    if entity.identifier == nil do
      throw "Cannot Delete #{inspect entity_module} with out identiifer field set."
    end
    entity = mod.pre_delete_callback(entity, context, options)
    case strategy.delete(entity.identifier, entity_module, context, options) do
      {:ok, _details} ->
        entity
        |> mod.post_delete_callback(context, options)

        #ref = entity
        #      |> mod.post_delete_callback(context, options)
        #      |> entity_module.ref()

        #cond do
        #  options[:audit] == false -> :skip
        #  true ->
        #    audit_engine = options[:audit_engine] || audit_engine
        #    audit_engine.audit(:delete!, :scaffolding, ref, context, options)
        #end

        true
      error -> error
    end
  end # end delete/3

  def delete!(indicator, entity, %CallingContext{} = context, options) do
    delete(indicator, entity, context, options)
  end

  def pre_create_callback({mod, _entity_module, _mnesia_table, _query_strategy, _audit_engine, _dirty, _frag, _audit_level} = _indicator, entity, _context, _options) do
    if entity.identifier == nil do
      %{entity| identifier: mod.generate_identifier}
    else
      entity
    end
  end

  def pre_create_callback(_indicator, entity, _context, _options) do
    entity
  end

  def post_create_callback(_indicator, entity, _context, _options), do: entity
  def create({mod, entity_module, _mnesia_table, query_strategy, _audit_engine, _dirty, _frag, _audit_level} = _indicator, entity, context = %CallingContext{}, options) do
    strategy = options[:query_strategy] || query_strategy
    entity = mod.pre_create_callback(entity, context, options)
    if (entity.identifier == nil) do
      throw "Cannot Create #{inspect entity_module} with out identifier field set."
    end

    case strategy.create(entity, entity_module, context, options) do
      {:ok, _encoded} ->

        #ref = entity
        #      |> entity_module.record(options)
        #      |> strategy.create(mnesia_table, context, options)
        #      |> entity_module.ref()

        #cond do
        #  options[:audit] == false -> :skip
        #  true ->
        #    audit_engine = options[:audit_engine] || audit_engine
        #    audit_engine.audit(:create!, :scaffolding, ref, context, options)
        #end

        # No need to return actual record as to_mnesia should not be modifying it in a way that would impact the final structure.
        entity
        |> mod.post_create_callback(context, options)

      error -> error
    end

  end # end create/3

  def create!(indicator, entity, %CallingContext{} = context, options) do
    create(indicator, entity, context, options)
  end

  #-------------------------------
  #
  #-------------------------------
  def extract_data(nil), do: nil
  def extract_date(%DateTime{} = date), do: date
  def extract_date(date) when is_integer(date), do: DateTime.from_unix(date)
  def extract_date(date) when is_bitstring(date) do
    case DateTime.from_iso8601(date) do
      {:ok, dt, _o} -> dt
      _ -> nil
    end
  end

end