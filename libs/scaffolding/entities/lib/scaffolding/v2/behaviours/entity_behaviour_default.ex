#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.Scaffolding.V2.EntityBehaviourDefault do
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
    def string_to_id(_m, nil), do: nil
    def string_to_id(_m, identifier) when is_bitstring(identifier) do
      case identifier do
        "ref." <> _ -> {:error, {:unsupported, identifier}}
        _ ->
          case Integer.parse(identifier) do
            {id, ""} -> {:ok, id}
            v -> {:error, {:parse, v}}
          end
      end
    end
    def string_to_id(_m, i), do: {:error, {:unsupported, i}}

    #------------------------------
    # id_to_string
    #------------------------------
    @doc """
      override this if your entity type uses string values, nested refs, etc. for it's identifier.
    """
    def id_to_string(_m, identifier), do: {:ok, "#{identifier}"}

    #-----------------
    # id
    #-------------------
    def id(_m, nil), do: nil
    def id(m, {:ref, m, identifier} = _ref), do: identifier
    def id(m, %{__struct__: m, identifier: identifier}), do: identifier
    def id(m, %{entity: %{__struct__: m, identifier: identifier}}), do: identifier
    def id(_m, ref) when is_atom(ref), do: ref
    def id(_m, ref) when is_integer(ref), do: ref
    def id(m, ref) when is_bitstring(ref) do
      case m.string_to_id(ref) do
        {:ok, v} -> v
        {:error, _} -> nil
        v -> v
      end
    end
    def id(_m, _ref), do: nil

    #-----------------
    # ref
    #-------------------
    def ref(m, {:ref, m, identifier} = _ref), do: {:ref, m, identifier}
    def ref(m, %{__struct__: m, identifier: identifier}), do: {:ref, m, identifier}
    def ref(m, %{entity: %{__struct__: m, identifier: identifier}}), do: {:ref, m, identifier}
    def ref(m, ref), do: (id = m.id(ref)) && {:ref, m, id}

    #-----------------
    # sref
    #-------------------
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
    #-------------------
    def entity(m, {:ref, m, identifier} = _ref, options) do
      context = Noizu.ElixirCore.CallingContext.system(options[:context])
      m.repo().get(identifier, context, options) || m.miss_cb(identifier, put_in(options, [:context], context))
    end
    def entity(m, %{__struct__: m} = entity, _options), do: entity
    def entity(m, %{entity: %{__struct__: m}} = record, _options), do: record.entity
    def entity(m, ref, options) do
      identifier = m.id(ref)
      if identifier do
        context = Noizu.ElixirCore.CallingContext.system(options[:context])
        m.repo().get(identifier, context, options) || m.miss_cb(identifier, put_in(options, [:context], context))
      end
    end

    #-----------------
    # entity!
    #-------------------
    def entity!(m, {:ref, m, identifier} = _ref, options) do
      context = Noizu.ElixirCore.CallingContext.system(options[:context])
      m.repo().get!(identifier, context, options) || m.miss_cb!(identifier, put_in(options, [:context], context))
    end
    def entity!(m, %{__struct__: m} = entity, _options), do: entity
    def entity!(m, %{entity: %{__struct__: m}} = record, _options), do: record.entity
    def entity!(m, ref, options) do
      identifier = m.id(ref)
      if identifier do
        context = Noizu.ElixirCore.CallingContext.system(options[:context])
        m.repo().get!(identifier, context, options) || m.miss_cb!(identifier, put_in(options, [:context], context))
      end
    end

    #-----------------
    # record
    #-------------------
    def record(m, %{__struct__: m} = entity, options), do: m.as_record(entity, options)
    def record(m, %{__struct__: struct, entity: %{__struct__: m}} = record, _options), do: struct == m.table() && record
    def record(m, ref, options) do
      entity = m.entity(ref, options)
      entity && m.as_record(entity, options)
    end

    #-----------------
    # record!
    #-------------------
    def record!(m, %{__struct__: m} = entity, options), do: m.as_record!(entity, options)
    def record!(m, %{__struct__: struct, entity: %{__struct__: m}} = record, _options), do: struct == m.table() && record
    def record!(m, ref, options) do
      entity = m.entity!(ref, options)
      entity && m.as_record!(entity, options)
    end

    #-----------------
    # has_permission
    #-------------------
    def has_permission(_m, _ref, _permission, %{auth: auth}, _options) do
      auth[:permissions][:admin] || auth[:permissions][:system] || false
    end
    def has_permission(_m, _ref, _permission, _context, _options), do: false

    #-----------------
    # has_permission!
    #-------------------
    def has_permission!(_m, _ref, _permission, %{auth: auth}, _options) do
      auth[:permissions][:admin] || auth[:permissions][:system] || false
    end
    def has_permission!(_m, _ref, _permission, _context, _options), do: false

    #-----------------
    # as_record
    #-------------------
    def as_record(m, %{__struct__: m, identifier: identifier} = entity, options) do
      base = m._int_empty_record()
             |> put_in([Access.key(:identifier)], identifier)
             |> put_in([Access.key(:entity)], m.compress(entity, options[:compression] || %{}))

      case m._int_as_record_options() do
        %{additional_fields: af} when is_list(af) ->
          Enum.reduce(af, base,
            fn(field, acc) ->
              case Map.get(entity, field, :erp_imp_field_not_found) do
                :erp_imp_field_not_found -> acc
                %DateTime{} = v -> put_in(acc, [Access.key(field)], DateTime.to_unix(v))
                %{__struct__: s} = v ->
                  try do
                    if s._int_entity?() do
                      put_in(acc, [Access.key(field)], s.ref(v))
                    else
                      put_in(acc, [Access.key(field)], v)
                    end
                  rescue _ -> put_in(acc, [Access.key(field)], v)
                  catch _ -> put_in(acc, [Access.key(field)], v)
                  end
                v -> put_in(acc, [Access.key(field)], v)
              end
            end)
        _ -> base
      end
    end
    def as_record(_m, _ref, _options), do: nil

    #-----------------
    # as_record!
    #-------------------
    def as_record!(m, %{__struct__: m, identifier: identifier} = entity, options) do
      base = m._int_empty_record()
             |> put_in([Access.key(:identifier)], identifier)
             |> put_in([Access.key(:entity)], m.compress(entity, options[:compression] || %{}))

      case m._int_as_record_options() do
        %{additional_fields: af} when is_list(af) ->
          Enum.reduce(af, base,
            fn(field, acc) ->
              case Map.get(entity, field, :erp_imp_field_not_found) do
                :erp_imp_field_not_found -> acc
                %DateTime{} = v -> put_in(acc, [Access.key(field)], DateTime.to_unix(v))
                %{__struct__: s} = v ->
                  try do
                    if s._int_entity?() do
                      put_in(acc, [Access.key(field)], s.ref(v))
                    else
                      put_in(acc, [Access.key(field)], v)
                    end
                  rescue _ -> put_in(acc, [Access.key(field)], v)
                  catch _ -> put_in(acc, [Access.key(field)], v)
                  end
                v -> put_in(acc, [Access.key(field)], v)
              end
            end)
        _ -> base
      end
    end
    def as_record!(_m, _ref, _options), do: nil

    #-----------------
    # expand_table
    #-------------------
    def expand_table(_, module, table) do
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
    end #end expand_table

    #-----------------
    # expand_repo
    #-------------------
    def expand_repo(_, module, repo) do
      if (repo == :auto) do
        rm = Module.split(module) |> Enum.slice(0..-2) |> Module.concat
        m = (Module.split(module) |> List.last())
        t = String.slice(m, 0..-7) <> "Repo"
        Module.concat([rm, t])
      else
        repo
      end
    end # end expand_repo
  end # end defmodule