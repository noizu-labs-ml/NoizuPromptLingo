#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.Scaffolding.V2.EntityBehaviourPolySupport do
    @callback ref(table :: Module, sref_prefix :: String.t) :: Macro.t
    @callback miss_cb() :: Macro.t
    @callback sref(table :: Module, sref_prefix :: String.t) :: Macro.t
    @callback entity(table :: Module, repo :: Module) :: Macro.t
    @callback entity_txn(table :: Module, repo :: Module) :: Macro.t
    @callback record(table :: Module, repo :: Module) :: Macro.t
    @callback record_txn(table :: Module, repo :: Module) :: Macro.t
    @callback as_record(Module, options :: nil | Map.t) :: any
    @callback expand_table(Module, Module) :: Module
    @callback expand_repo(Module, Module) :: Module



    def compress(_m, entity, _options), do: entity
    def expand(_m, entity, _options), do: entity

    #------------------------------
    # string_to_id
    #------------------------------
    @doc """
      override this if your entity type uses string values, nested refs, etc. for it's identifier.
    """
   def string_to_id(m, id), do: Noizu.Scaffolding.V2.EntityBehaviourDefault.string_to_id(m, id)

    #------------------------------
    # id_to_string
    #------------------------------
    @doc """
      override this if your entity type uses string values, nested refs, etc. for it's identifier.
    """
   def id_to_string(m, id), do: Noizu.Scaffolding.V2.EntityBehaviourDefault.id_to_string(m, id)


    #-----------------
    # id
    #-----------------
    def id(m, ref) do
      b = m.poly_base()
      case ref do
        nil -> nil
        {:ref, ^b, identifier} -> identifier
        %{entity: %{__struct__: ^m, identifier: identifier}} -> identifier
        %{entity: %{__struct__: ^b, identifier: identifier}} -> identifier
        %{entity: %{__struct__: s, identifier: identifier}} -> MapSet.member?(m.poly_support(), s) && identifier
        %{__struct__: ^m, identifier: identifier} -> identifier
        %{__struct__: ^b, identifier: identifier} -> identifier
        %{__struct__: s, identifier: identifier} -> MapSet.member?(m.poly_support(), s) && identifier
        v when is_atom(v) -> v
        v when is_integer(v) -> v
        v when is_bitstring(v) ->
          case m.string_to_id(ref) do
            {:ok, v} -> v
            {:error, _} -> nil
            v -> v
          end
        _ -> nil
      end
    end

    #-----------------
    # ref
    #-----------------
    def ref(m, ref) do
      b = m.poly_base()
      case ref do
        nil -> nil
        {:ref, ^b, _identifier} -> ref
        %{entity: %{__struct__: ^m, identifier: identifier}} -> {:ref, b, identifier}
        %{entity: %{__struct__: ^b, identifier: identifier}} -> {:ref, b, identifier}
        %{entity: %{__struct__: s, identifier: identifier}} -> MapSet.member?(m.poly_support(), s) && {:ref, b, identifier}
        %{__struct__: ^m, identifier: identifier} -> {:ref, b, identifier}
        %{__struct__: ^b, identifier: identifier} -> {:ref, b, identifier}
        %{__struct__: s, identifier: identifier} -> MapSet.member?(m.poly_support(), s) && {:ref, b, identifier}
        v -> (v = m.id(v)) && {:ref, b, v}
      end
    end

    #-----------------
    # sref
    #-----------------
    def sref(m, ref) do
      case m.ref(ref) do
        {:ref, _, identifier} ->
          case m.id_to_string(identifier) do
            {:ok, v} -> "#{m.sref_prefix}#{v}"
            {:error, _} -> nil
            v when is_bitstring(v) -> "#{m.sref_prefix}#{v}"
            _ -> nil
          end
        nil -> nil
        _ -> nil
      end
    end

    #-----------------
    # miss_cb
    #-------------------
    def miss_cb(_m, _ref, _options \\ nil), do: nil
    def miss_cb!(_m, _ref, _options \\ nil), do: nil

    #-----------------
    # entity
    #-----------------
    def entity(m, ref, options) do
      b = m.poly_base()
      case ref do
        nil -> nil
        {:ref, ^b, identifier} ->
          context = Noizu.ElixirCore.CallingContext.system(options[:context])
          m.repo().get(identifier, context, options) || m.miss_cb(identifier, put_in(options, [:context], context))
        %{entity: %{__struct__: ^m}} -> ref.entity
        %{entity: %{__struct__: ^b}} -> ref.entity # type error
        %{entity: %{__struct__: s}} -> MapSet.member?(m.poly_support(), s) && ref.entity # type error
        %{__struct__: ^m} -> ref
        %{__struct__: ^b} -> ref # type error
        %{__struct__: s} -> MapSet.member?(m.poly_support(), s) && ref # type error
        v ->
          v = m.id(v)
          if v do
            context = Noizu.ElixirCore.CallingContext.system(options[:context])
            m.repo().get(v, context, options) || m.miss_cb(v, put_in(options, [:context], context))
          end
      end
    end

    #-----------------
    # entity!
    #-------------------
    def entity!(m, ref, options) do
      b = m.poly_base()
      case ref do
        nil -> nil
        {:ref, ^b, identifier} ->
          context = Noizu.ElixirCore.CallingContext.system(options[:context])
          m.repo().get!(identifier, context, options) || m.miss_cb!(identifier, put_in(options, [:context], context))
        %{entity: %{__struct__: ^m}} -> ref.entity
        %{entity: %{__struct__: ^b}} -> ref.entity # type error
        %{entity: %{__struct__: s}} -> MapSet.member?(m.poly_support(), s) && ref.entity # type error
        %{__struct__: ^m} -> ref
        %{__struct__: ^b} -> ref # type error
        %{__struct__: s} -> MapSet.member?(m.poly_support(), s) && ref # type error
        v ->
          v = m.id(v)
          if v do
            context = Noizu.ElixirCore.CallingContext.system(options[:context])
            m.repo().get!(v, context, options) || m.miss_cb!(v, put_in(options, [:context], context))
          end
      end
    end

    #-----------------
    # record
    #-----------------
    def record(m, ref, options) do
      b = m.poly_base()

      case ref do
        nil -> nil
        {:ref, ^b, identifier} ->
          context = Noizu.ElixirCore.CallingContext.system(options[:context])
          entity = m.repo().get(identifier, context, options) || m.miss_cb(identifier, put_in(options, [:context], context))
          entity && entity.__struct__.as_record(entity)
        %{__struct__: s, entity: %{}} -> (s == m.table()) && ref
        %{__struct__: ^m} -> m.as_record(ref)
        %{__struct__: ^b} -> m.as_record(ref)
        %{__struct__: s} -> MapSet.member?(m.poly_support(), s) && s.as_record(ref)
        v ->
          v = m.id(v)
          if v do
            context = Noizu.ElixirCore.CallingContext.system(options[:context])
            b_options = put_in(options || %{}, [:context], context)
            entity = m.repo().get(v, context, options) || m.miss_cb(v, b_options)
            entity && entity.__struct__.as_record(entity, b_options)
          end
      end
    end

    #-----------------
    # record!
    #-------------------
    def record!(m, ref, options) do
      b = m.poly_base()

      case ref do
        nil -> nil
        {:ref, ^b, identifier} ->
          context = Noizu.ElixirCore.CallingContext.system(options[:context])
          entity = m.repo().get!(identifier, context, options) || m.miss_cb!(identifier, put_in(options, [:context], context))
          entity && entity.__struct__.as_record!(entity)
        %{__struct__: s, entity: %{}} -> (s == m.table()) && ref
        %{__struct__: ^m} -> m.as_record!(ref)
        %{__struct__: ^b} -> m.as_record!(ref)
        %{__struct__: s} -> MapSet.member?(m.poly_support(), s) && s.as_record!(ref)
        v ->
          v = m.id(v)
          if v do
            context = Noizu.ElixirCore.CallingContext.system(options[:context])
            b_options = put_in(options || %{}, [:context], context)
            entity = m.repo().get!(v, context, options) || m.miss_cb!(v, b_options)
            entity && entity.__struct__.as_record!(entity, b_options)
          end
      end
    end

    #-----------------
    # has_permission
    #-----------------
   def has_permission(m, ref, permission, context, options), do: Noizu.Scaffolding.V2.EntityBehaviourDefault.has_permission(m, ref, permission, context, options)

    #-----------------
    # has_permission!
    #-------------------
   def has_permission!(m, ref, permission, context, options), do: Noizu.Scaffolding.V2.EntityBehaviourDefault.has_permission!(m, ref, permission, context, options)

    #-----------------
    # as_record
    #-------------------
   def as_record(m, entity, options), do: Noizu.Scaffolding.V2.EntityBehaviourDefault.as_record(m, entity, options)

    #-----------------
    # as_record!
    #-------------------
   def as_record!(m, entity, options), do: Noizu.Scaffolding.V2.EntityBehaviourDefault.as_record!(m, entity, options)

    #-----------------
    # expand_table
    #-------------------
    def expand_table(is_base, module, table) do
      if is_base do
        # Apply Schema Naming Convention if not specified
        if (table == :auto) do
          path = Module.split(module)
          default_database = Module.concat([List.first(path), "Database"])
          root_table =
            Application.get_env(:noizu_scaffolding, :default_database, default_database)
            |> Module.split()
          entity_name = path |> List.last()
          table_name = String.slice(entity_name, 0..-7) <> "Table"
          inner_path = Enum.slice(path, 1..-2)
          Module.concat(root_table ++ inner_path ++ [table_name])
        else
          table
        end
      else
        if (table == :auto) do
          module.table()
        else
          table
        end
      end
    end #end expand_table

    #-----------------
    # expand_repo
    #-------------------
    def expand_repo(is_base, module, repo) do
      if is_base do
        if (repo == :auto) do
          rm = Module.split(module) |> Enum.slice(0..-2) |> Module.concat
          m = (Module.split(module) |> List.last())
          t = String.slice(m, 0..-7) <> "Repo"
          Module.concat([rm, t])
        else
          repo
        end
      else
        if (repo == :auto) do
          module.repo()
        else
          repo
        end
      end
    end # end expand_repo

  end # end defmodule