#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.Scaffolding.RepoBehaviour.AmnesiaProviderDefault do
  use Amnesia
  require Logger
  alias Noizu.ElixirCore.CallingContext
  alias Noizu.ERP, as: EntityReferenceProtocol

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

  #-----------------------------------------------------------------------------
  # Behaviour methods
  #-----------------------------------------------------------------------------
  def match({mod, entity_module, mnesia_table, query_strategy, audit_engine, _dirty, _frag, audit_level} = _indicator, match_sel, %CallingContext{} = context, options) do
    emit = mod.emit_telemetry?(:match, nil, context, options)
    emit && :telemetry.execute(mod.telemetry_event(:match, nil, context, options), %{count: emit}, %{mod: mod})
  
    strategy = options[:query_strategy] || query_strategy
    if options[:audit] || Enum.member?([:verbose], audit_level) || (context.options[:audit] == :verbose) do
      audit_engine = context.options[:audit_engine] || options[:audit_engine] || audit_engine
      audit_engine.audit(:match, :scaffolding, entity_module, context, options)
    end

    case strategy.match(match_sel, mnesia_table, context, options) do
      nil ->
         []
      :badarg ->
        Logger.warn("#{entity_module}.match -> :badarg")
        []
      m ->
        m
        |> Amnesia.Selection.values
        |> Enum.map(fn(x) -> entity_module.entity(x, options) end)
    end
  end # end list/3

  def match!({mod, _entity_module, _mnesia_table, _query_strategy, _audit_engine, dirty, frag, _audit_level} = _indicator, match_sel, %CallingContext{} = context, options) do
    options = options || %{}
    dirty = Map.get(options, :dirty, dirty)
    frag = Map.get(options, :frag, frag)
    options = options |> Map.delete(:frag) |> Map.delete(:dirty)
    cond do
      dirty && frag == :sync -> Amnesia.Fragment.sync(fn ->  mod.match(match_sel, context, options) end)
      dirty -> Amnesia.Fragment.async(fn ->  mod.match(match_sel, context, options) end)
      true ->
        Amnesia.Fragment.transaction do
           mod.match(match_sel, context, options)
        end
    end # end cond do
  end

  def list({mod, entity_module, mnesia_table, query_strategy, audit_engine, _dirty, _frag, audit_level} = _indicator, %CallingContext{} = context, options) do
    emit = mod.emit_telemetry?(:list, nil, context, options)
    emit && :telemetry.execute(mod.telemetry_event(:list, nil, context, options), %{count: emit}, %{mod: mod})
  
    strategy = options[:query_strategy] || query_strategy
    if options[:audit] || Enum.member?([:verbose], audit_level) || (context.options[:audit] == :verbose) do
      audit_engine = context.options[:audit_engine] || options[:audit_engine] || audit_engine
      audit_engine.audit(:list, :scaffolding, entity_module, context, options)
    end

    case strategy.list(mnesia_table, context, options) do
      nil ->
         []
      :badarg ->
        Logger.warn("#{entity_module}.list -> :badarg")
        []
      m ->
        m
        |> Amnesia.Selection.values
        |> Enum.map(fn(x) -> entity_module.entity(x, options) end)
    end
  end # end list/3

  def list!({mod, _entity_module, _mnesia_table, _query_strategy, _audit_engine, dirty, frag, _audit_level} = _indicator, %CallingContext{} = context, options) do
    dirty = Map.get(options, :dirty, dirty)
    frag = Map.get(options, :frag, frag)
    options = options |> Map.delete(:frag) |> Map.delete(:dirty)

    cond do
      dirty && frag == :sync -> Amnesia.Fragment.sync(fn -> mod.list(context, options) end)
      dirty -> Amnesia.Fragment.async(fn -> mod.list(context, options) end)
      true ->
        Amnesia.Fragment.transaction do
          mod.list(context, options)
        end
    end # end cond do
  end
  
  def get({mod, entity_module, mnesia_table, query_strategy, audit_engine, _dirty, _frag, audit_level} = _indicator, identifier, %CallingContext{} = context, options) do
    strategy = options[:query_strategy] || query_strategy
    record = strategy.get(identifier, mnesia_table, context, options)

    if options[:audit] || Enum.member?([:very_verbose], audit_level) || (context.options[:audit] == :verbose) do
      ref = case record do
        nil -> nil
        _ -> EntityReferenceProtocol.ref(record)
      end
      audit_engine = context.options[:audit_engine] || options[:audit_engine] || audit_engine
      audit_engine.audit(:get, :scaffolding, ref, context, options)
    end

    emit = mod.emit_telemetry?(:get, identifier, context, options)
    emit && :telemetry.execute(mod.telemetry_event(:get, identifier, context, options), %{count: emit}, %{mod: mod, miss: !record || true})
    
    entity_module.entity(record, options)
    |> mod.post_get_callback(context, options)
  end # end get/3
  def post_get_callback(_indicator, entity, _context, _options), do: entity

  def get!({mod, _entity_module, _mnesia_table, _query_strategy, _audit_engine, dirty, frag, _audit_level} = _indicator, identifier, %CallingContext{} = context, options) do
    options = options || %{}
    dirty = Map.get(options, :dirty, dirty)
    frag = Map.get(options, :frag, frag)
    options = options |> Map.delete(:frag) |> Map.delete(:dirty)
    cond do
      dirty && frag == :sync -> Amnesia.Fragment.sync(fn -> mod.get(identifier, context, options) end)
      dirty -> Amnesia.Fragment.async(fn -> mod.get(identifier, context, options) end)
      true ->
        Amnesia.Fragment.transaction do
          mod.get(identifier, context, options)
        end
    end # end cond do
  end



  def pre_update_callback(_indicator, entity, _context, _options), do: entity
  def post_update_callback(_indicator, entity, _context, _options), do: entity
  def update({mod, entity_module, mnesia_table, query_strategy, audit_engine, _dirty, _frag, audit_level} = _indicator, entity, %CallingContext{} = context, options) do
    emit = mod.emit_telemetry?(:update, entity, context, options)
    emit && :telemetry.execute(mod.telemetry_event(:update, entity, context, options), %{count: emit}, %{mod: mod})
    
    strategy = options[:query_strategy] || query_strategy
    if entity.identifier == nil, do: throw "Cannot Update #{inspect entity_module} with out identifier field set."
    entity = mod.pre_update_callback(entity, context, options)
    ref = entity
      |> entity_module.record(options)
      |> strategy.update(mnesia_table, context, options)
      |> entity_module.ref()
    cond do
      context.options[:audit] ->
        audit_engine = context.options[:audit_engine] || options[:audit_engine] || audit_engine
        audit_engine.audit(:update!, :scaffolding, ref, context, options)
      options[:audit] == false -> :skip
      !Enum.member?([:very_verbose, :verbose, :core], audit_level) -> :skip
      true ->
        audit_engine = context.options[:audit_engine] || options[:audit_engine] || audit_engine
        audit_engine.audit(:update!, :scaffolding, ref, context, options)
    end

    entity
    |> mod.post_update_callback(context, options)
  end # end update/3

  def update!({mod, _entity_module, _mnesia_table, _query_strategy, _audit_engine, dirty, frag, _audit_level} = _indicator, entity, %CallingContext{} = context, options) do
    options = options || %{}
    dirty = Map.get(options, :dirty, dirty)
    frag = Map.get(options, :frag, frag)
    options = options
              |> Map.delete(:frag)
              |> Map.delete(:dirty)
    # Todo honor the frag param here.
    cond do
      dirty && frag == :sync -> Amnesia.Fragment.sync(fn -> mod.update(entity, context, options) end)
      dirty -> Amnesia.Fragment.async(fn -> mod.update(entity, context, options) end)
      true ->
        Amnesia.Fragment.transaction do
          mod.update(entity, context, options)
        end
    end # end cond do
  end

  def pre_delete_callback(_indicator, entity, _context, _options), do: entity
  def post_delete_callback(_indicator, entity, _context, _options), do: entity
  def delete({mod, entity_module, mnesia_table, query_strategy, audit_engine, _dirty, _frag, audit_level} = _indicator, entity, %CallingContext{} = context, options) do
    emit = mod.emit_telemetry?(:delete, entity, context, options)
    emit && :telemetry.execute(mod.telemetry_event(:delete, entity, context, options), %{count: emit}, %{mod: mod})
    
    strategy = options[:query_strategy] || query_strategy
    if entity.identifier == nil do
      throw "Cannot Delete #{inspect entity_module} with out identifier field set."
    end
    
    entity = mod.pre_delete_callback(entity, context, options)

    strategy.delete(entity.identifier, mnesia_table, context, options)
    ref = entity
      |> mod.post_delete_callback(context, options)
      |> entity_module.ref()

    cond do
      context.options[:audit] ->
        audit_engine = context.options[:audit_engine] || options[:audit_engine] || audit_engine
        audit_engine.audit(:update!, :scaffolding, ref, context, options)
      options[:audit] == false -> :skip
      !Enum.member?([:very_verbose, :verbose, :core], audit_level) -> :skip
      true ->
        audit_engine = options[:audit_engine] || audit_engine
        audit_engine.audit(:delete!, :scaffolding, ref, context, options)
    end

    true
  end # end delete/3

  def delete!({mod, _entity_module, _mnesia_table, _query_strategy, _audit_engine, dirty, frag, _audit_level} = _indicator, entity, %CallingContext{} = context, options) do
    options = options || %{}
    dirty = Map.get(options, :dirty, dirty)
    frag = Map.get(options, :frag, frag)
    options = options |> Map.delete(:frag) |> Map.delete(:dirty)
    
    # @todo honor the dirty directive don't drop.
    cond do
      dirty && frag == :sync -> Amnesia.Fragment.sync(fn -> mod.delete(entity, context, options) end)
      dirty -> Amnesia.Fragment.async(fn -> mod.delete(entity, context, options) end)
      true ->
        Amnesia.Fragment.transaction do
          mod.delete(entity, context, options)
        end
    end # end cond do
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
  def create({mod, entity_module, mnesia_table, query_strategy, audit_engine, _dirty, _frag, audit_level} = _indicator, entity, context = %CallingContext{}, options) do
    strategy = options[:query_strategy] || query_strategy

    emit = mod.emit_telemetry?(:create, entity, context, options)
    emit && :telemetry.execute(mod.telemetry_event(:create, entity, context, options), %{count: emit}, %{mod: mod})
    
    entity = mod.pre_create_callback(entity, context, options)
    if (entity.identifier == nil) do
      throw "Cannot Create #{inspect entity_module} with out identifier field set."
    end
    ref = entity
      |> entity_module.record(options)
      |> strategy.create(mnesia_table, context, options)
      |> entity_module.ref()

    cond do
      context.options[:audit] ->
        audit_engine = context.options[:audit_engine] || options[:audit_engine] || audit_engine
        audit_engine.audit(:update!, :scaffolding, ref, context, options)
      options[:audit] == false -> :skip
      !Enum.member?([:very_verbose, :verbose, :core], audit_level) -> :skip
      true ->
        audit_engine = context.options[:audit_engine] || options[:audit_engine] || audit_engine
        audit_engine.audit(:create!, :scaffolding, ref, context, options)
    end

    # No need to return actual record as to_mnesia should not be modifying it in a way that would impact the final structure.
    entity
      |> mod.post_create_callback(context, options)
  end # end create/3

  def create!({mod, _entity_module, _mnesia_table, _query_strategy, _audit_engine, dirty, frag, _audit_level} = _indicator, entity, %CallingContext{} = context, options) do
    options = options || %{}
    dirty = Map.get(options, :dirty, dirty)
    frag = Map.get(options, :frag, frag)
    options = options |> Map.delete(:frag) |> Map.delete(:dirty)
    cond do
      dirty && frag == :sync -> Amnesia.Fragment.sync(fn -> mod.create(entity, context, options) end)
      dirty -> Amnesia.Fragment.async(fn -> mod.create(entity, context, options) end)
      true ->
        Amnesia.Fragment.transaction do
          mod.create(entity, context, options)
        end
    end # end cond do
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
