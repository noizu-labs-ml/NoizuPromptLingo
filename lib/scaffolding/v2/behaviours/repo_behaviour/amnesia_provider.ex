#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.Scaffolding.V2.RepoBehaviour.AmnesiaProvider do
  use Amnesia
  require Logger

  #--------------
  #
  #--------------
  def expand_options(m, o) do
    dirty_default = Keyword.get(o, :dirty_default, true)
    sync_default = Keyword.get(o, :sync_default, :async)
    frag_default = Keyword.get(o, :frag_default, false)

    entity_table = case Keyword.get(o, :entity_table, :auto) do
      :auto -> Keyword.get(o, :mnesia_table, :auto)
      v -> v
    end
    entity_table = expand_table(m, entity_table)

    entity_module = expand_entity(m, Keyword.get(o, :entity_module, :auto))
    sequencer = case Keyword.get(o, :sequencer, :auto) do
      :auto -> entity_module
      v -> v
    end
    nmid_generator = Keyword.get(o, :nmid_generator, Application.get_env(:noizu_scaffolding, :default_nmid_generator))
    query_strategy = Keyword.get(o, :query_strategy, Noizu.Scaffolding.QueryStrategy.Default)
    audit_engine = Keyword.get(o, :audit_engine, Application.get_env(:noizu_scaffolding, :default_audit_engine, Noizu.Scaffolding.AuditEngine.Default))
    audit_level = Keyword.get(o, :audit_level, Application.get_env(:noizu_scaffolding, :default_audit_level, :silent))

    %{
      input: o,
      dirty: dirty_default,
      sync: sync_default,
      frag: frag_default,
      entity_table: entity_table,
      entity_module: entity_module,
      nmid_generator: nmid_generator,
      sequencer: sequencer,
      query_strategy: query_strategy,
      audit_engine: audit_engine,
      audit_level: audit_level
    }
  end

  #--------------
  # expand_entity
  #--------------
  def expand_entity(module, :auto) do
    rm = Module.split(module) |> Enum.slice(0..-2) |> Module.concat
    m = (Module.split(module) |> List.last())
    t = String.slice(m, 0..-5) <> "Entity"
    Module.concat([rm, t])
  end
  def expand_entity(_module, e), do: e

  #--------------
  # expand_table
  #--------------
  def expand_table(module, :auto) do
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
  def expand_table(_module, t), do: t

  #--------------
  #
  #--------------
  def extract_data(nil), do: nil
  def extract_date(%DateTime{} = date), do: date
  def extract_date(date) when is_integer(date), do: DateTime.from_unix(date)
  def extract_date(date) when is_bitstring(date) do
    case DateTime.from_iso8601(date) do
      {:ok, dt, _o} -> dt
      _ -> nil
    end
  end

  #-----------------
  # from_json_version
  #-------------------
  def from_json_version(m, _version, _json, _context, _options), do: throw "#{m} must override from_json/2 or from_json/3"

  #--------------
  # match
  #--------------
  def match(module, match_sel, context, options) do
    strategy = options[:query_strategy] || module.query_strategy()
    if options[:audit] || Enum.member?([:verbose], module.audit_level()) do
      audit_engine = options[:audit_engine] || module.audit_engine()
      audit_engine.audit(:match, :scaffolding, module.entity_module(), context, options)
    end

    case strategy.match(match_sel, module.table(), context, options) do
      nil ->
        []
      :badarg ->
        Logger.warn("#{module.entity_module()}.match -> :badarg")
        []
      m ->
        e = module.entity_module()
        m
        |> Amnesia.Selection.values
        |> Enum.map(fn(x) -> e.entity(x, options) end)
    end
  end

  #--------------
  # match!
  #--------------
  def match!(module, match_sel, context, options) do
    m_opt = module.options()
    options = options || %{}
    dirty = Map.get(options, :dirty, m_opt[:dirty])
    frag = Map.get(options, :frag, m_opt[:frag])
    sync = Map.get(options, :sync, m_opt[:sync])
    options_b = options
                |> Map.delete(:frag)
                |> Map.delete(:dirty)
    cond do
      frag ->
        cond do
          dirty ->
            cond do
              sync == :sync -> Amnesia.Fragment.sync(fn -> module.match(match_sel, context, options) end)
              :else -> Amnesia.Fragment.async(fn -> module.match(match_sel, context, options) end)
            end
          :else ->
            Amnesia.Fragment.transaction do
              module.match(match_sel, context, options_b)
            end
        end
      :else ->
        cond do
          dirty ->
            cond do
              sync == :sync -> Amnesia.sync(fn -> module.match(match_sel, context, options) end)
              :else -> Amnesia.async(fn -> module.match(match_sel, context, options) end)
            end
          :else ->
            Amnesia.transaction do
              module.match(match_sel, context, options_b)
            end
        end
    end
  end

  #--------------
  # list
  #--------------
  def list(module, context, options)  do
    strategy = options[:query_strategy] || module.query_strategy()
    if options[:audit] || Enum.member?([:verbose], module.audit_level()) do
      audit_engine = options[:audit_engine] || module.audit_engine()
      audit_engine.audit(:list, :scaffolding, module.entity_module(), context, options)
    end

    case strategy.list(module.entity_table(), context, options) do
      nil ->
        []
      :badarg ->
        Logger.warn("#{module.entity_module()}.list -> :badarg")
        []
      m ->
        e = module.entity_module()
        m
        |> Amnesia.Selection.values
        |> Enum.map(fn(x) -> e.entity(x, options) end)
    end
  end # end list/3

  #--------------
  # list!
  #--------------
  def list!(module, context, options) do
    m_opt = module.options()
    options = options || %{}
    dirty = Map.get(options, :dirty, m_opt[:dirty])
    frag = Map.get(options, :frag, m_opt[:frag])
    sync = Map.get(options, :sync, m_opt[:sync])
    options_b = options
                |> Map.delete(:frag)
                |> Map.delete(:dirty)
    cond do
      frag ->
        cond do
          dirty ->
            cond do
              sync == :sync -> Amnesia.Fragment.sync(fn -> module.list(context, options) end)
              :else -> Amnesia.Fragment.async(fn -> module.list(context, options) end)
            end
          :else ->
            Amnesia.Fragment.transaction do
              module.list(context, options_b)
            end
        end
      :else ->
        cond do
          dirty ->
            cond do
              sync == :sync -> Amnesia.sync(fn -> module.list(context, options) end)
              :else -> Amnesia.async(fn -> module.list(context, options) end)
            end
          :else ->
            Amnesia.transaction do
              module.list(context, options_b)
            end
        end
    end
  end

  #--------------
  # post_get_callback
  #--------------
  def post_get_callback(entity, _context, _options), do: entity

  #--------------
  # inner_get_callback
  #--------------
  def inner_get_callback(module, identifier, context, options) do
    strategy = options[:query_strategy] || module.query_strategy()
    strategy.get(identifier, module.entity_table(), context, options)
    |> module.entity_module().entity(options)
  end

  #--------------
  # get
  #--------------
  def get(module, identifier, context, options) do
    module.inner_get_callback(identifier, context, options)
    |> module.post_get_callback(context, options)
  end # end get/3

  #--------------
  # get!
  #--------------
  def get!(module, identifier, context, options) do
    m_opt = module.options()
    options = options || %{}
    dirty = Map.get(options, :dirty, m_opt[:dirty])
    frag = Map.get(options, :frag, m_opt[:frag])
    sync = Map.get(options, :sync, m_opt[:sync])
    options_b = options
                |> Map.delete(:frag)
                |> Map.delete(:dirty)
    cond do
      frag ->
        cond do
          dirty ->
            cond do
              sync == :sync -> Amnesia.Fragment.sync(fn -> module.get(identifier, context, options) end)
              :else -> Amnesia.Fragment.async(fn -> module.get(identifier, context, options) end)
            end
          :else ->
            Amnesia.Fragment.transaction do
              module.get(identifier, context, options_b)
            end
        end
      :else ->
        cond do
          dirty ->
            cond do
              sync == :sync -> Amnesia.sync(fn -> module.get(identifier, context, options) end)
              :else -> Amnesia.async(fn -> module.get(identifier, context, options) end)
            end
          :else ->
            Amnesia.transaction do
              module.get(identifier, context, options_b)
            end
        end
    end
  end

  #--------------
  # pre_create_callback
  #--------------
  def pre_create_callback(%{identifier: nil} = entity, _context, _options), do: %{entity| identifier: entity.__struct__.repo().generate_identifier()}
  def pre_create_callback(entity, _context, _options), do: entity

  #--------------
  # inner_create_callback
  #--------------
  def inner_create_callback(entity, context, options) do
    module = entity.__struct__.repo()
    strategy = options[:query_strategy] || module.query_strategy()

    if (entity.identifier == nil) do
      throw "Cannot Create #{inspect module.entity_module()} with out identifier field set."
    end
    em = module.entity_module()

    ref = entity
          |> em.record(options)
          |> strategy.create(module.entity_table(), context, options)
          |> em.ref()

    cond do
      options[:audit] == false -> :skip
      !Enum.member?([:very_verbose, :verbose, :core], module.audit_level()) -> :skip
      true ->
        audit_engine = options[:audit_engine] || module.audit_engine()
        audit_engine.audit(:create!, :scaffolding, ref, context, options)
    end

    entity
  end

  #--------------
  # post_create_callback
  #--------------
  def post_create_callback(entity, _context, _options), do: entity

  #--------------
  # create
  #--------------
  def create(entity, context, options) do
    module = entity.__struct__.repo()
    entity
    |> module.pre_create_callback(context, options)
    |> module.inner_create_callback(context, options)
    |> module.post_create_callback(context, options)
  end # end create/3

  #--------------
  # create!
  #--------------
  def create!(entity, context, options) do
    module = entity.__struct__.repo()
    m_opt = module.options()
    options = options || %{}
    dirty = Map.get(options, :dirty, m_opt[:dirty])
    frag = Map.get(options, :frag, m_opt[:frag])
    sync = Map.get(options, :sync, m_opt[:sync])
    options_b = options
                |> Map.delete(:frag)
                |> Map.delete(:dirty)
    cond do
      frag ->
        cond do
          dirty ->
            cond do
              sync == :sync -> Amnesia.Fragment.sync(fn -> module.create(entity, context, options) end)
              :else -> Amnesia.Fragment.async(fn -> module.create(entity, context, options) end)
            end
          :else ->
            Amnesia.Fragment.transaction do
              module.create(entity, context, options_b)
            end
        end
      :else ->
        cond do
          dirty ->
            cond do
              sync == :sync -> Amnesia.sync(fn -> module.create(entity, context, options) end)
              :else -> Amnesia.async(fn -> module.create(entity, context, options) end)
            end
          :else ->
            Amnesia.transaction do
              module.create(entity, context, options_b)
            end
        end
    end
  end


  #--------------
  # pre_update_callback
  #--------------
  def pre_update_callback(entity, _context, _options) do
    if entity.identifier == nil, do: throw "Cannot Update #{inspect entity.__struct__} with out identifier field set."
    entity
  end

  #--------------
  # inner_update_callback
  #--------------
  def inner_update_callback(entity, context, options) do
    module = entity.__struct__.repo()
    strategy = options[:query_strategy] || module.query_strategy()

    em = module.entity_module()
    ref = entity
          |> em.record(options)
          |> strategy.update(module.entity_table(), context, options)
          |> em.ref()

    cond do
      options[:audit] == false -> :skip
      !Enum.member?([:very_verbose, :verbose, :core], module.audit_level()) -> :skip
      true ->
        audit_engine = options[:audit_engine] || module.audit_engine()
        audit_engine.audit(:update!, :scaffolding, ref, context, options)
    end

    entity
  end
  #--------------
  # post_update_callback
  #--------------
  def post_update_callback(entity, _context, _options), do: entity

  #--------------
  # update
  #--------------
  def update(entity, context, options) do
    module = entity.__struct__.repo()
    entity
    |>  module.pre_update_callback(context, options)
    |>  module.inner_update_callback(context, options)
    |>  module.post_update_callback(context, options)
  end # end update/3

  #--------------
  # update!
  #--------------
  def update!(entity, context, options) do
    module = entity.__struct__.repo()
    m_opt = module.options()
    options = options || %{}
    dirty = Map.get(options, :dirty, m_opt[:dirty])
    frag = Map.get(options, :frag, m_opt[:frag])
    sync = Map.get(options, :sync, m_opt[:sync])
    options_b = options
                |> Map.delete(:frag)
                |> Map.delete(:dirty)
    cond do
      frag ->
        cond do
          dirty ->
            cond do
              sync == :sync -> Amnesia.Fragment.sync(fn -> module.update(entity, context, options) end)
              :else -> Amnesia.Fragment.async(fn -> module.update(entity, context, options) end)
            end
          :else ->
            Amnesia.Fragment.transaction do
              module.update(entity, context, options_b)
            end
        end
      :else ->
        cond do
          dirty ->
            cond do
              sync == :sync -> Amnesia.sync(fn -> module.update(entity, context, options) end)
              :else -> Amnesia.async(fn -> module.update(entity, context, options) end)
            end
          :else ->
            Amnesia.transaction do
              module.update(entity, context, options_b)
            end
        end
    end
  end

  #--------------
  # pre_delete_callback
  #--------------
  def pre_delete_callback(entity, _context, _options) do
    if entity.identifier == nil do
      throw "Cannot Delete #{inspect entity.__struct__} with out identifier field set."
    end
    entity
  end

  #--------------
  # inner_delete_callback
  #--------------
  def inner_delete_callback(entity, context, options) do
    module = entity.__struct__.repo()
    strategy = options[:query_strategy] || module.query_strategy()
    strategy.delete(entity.identifier, module.entity_table(), context, options)
    entity
  end

  #--------------
  # post_delete_callback
  #--------------
  def post_delete_callback(entity, context, options) do
    module = entity.__struct__.repo()
    ref = entity
          |> module.entity_module().ref()

    cond do
      options[:audit] == false -> :skip
      !Enum.member?([:very_verbose, :verbose, :core], module.audit_level()) -> :skip
      true ->
        audit_engine = options[:audit_engine] || module.audit_engine()
        audit_engine.audit(:delete!, :scaffolding, ref, context, options)
    end
    entity
  end

  #--------------
  # delete
  #--------------
  def delete(entity, context, options) do
    module = entity.__struct__.repo()
    entity
    |>  module.pre_delete_callback(context, options)
    |>  module.inner_delete_callback(context, options)
    |>  module.post_delete_callback(context, options)
    true
  end # end delete/3

  #--------------
  # delete!
  #--------------
  def delete!(entity, context, options) do
    module = entity.__struct__.repo()
    m_opt = module.options()
    options = options || %{}
    dirty = Map.get(options, :dirty, m_opt[:dirty])
    frag = Map.get(options, :frag, m_opt[:frag])
    sync = Map.get(options, :sync, m_opt[:sync])
    options_b = options
                |> Map.delete(:frag)
                |> Map.delete(:dirty)
    cond do
      frag ->
        cond do
          dirty ->
            cond do
              sync == :sync -> Amnesia.Fragment.sync(fn -> module.delete(entity, context, options) end)
              :else -> Amnesia.Fragment.async(fn -> module.delete(entity, context, options) end)
            end
          :else ->
            Amnesia.Fragment.transaction do
              module.delete(entity, context, options_b)
            end
        end
      :else ->
        cond do
          dirty ->
            cond do
              sync == :sync -> Amnesia.sync(fn -> module.delete(entity, context, options) end)
              :else -> Amnesia.async(fn -> module.delete(entity, context, options) end)
            end
          :else ->
            Amnesia.transaction do
              module.delete(entity, context, options_b)
            end
        end
    end
  end
end
