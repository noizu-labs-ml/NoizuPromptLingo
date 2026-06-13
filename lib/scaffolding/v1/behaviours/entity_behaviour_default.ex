#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.Scaffolding.EntityBehaviourDefault do
    @callback ref_implementation(table :: Module, sref_prefix :: String.t) :: Macro.t
    @callback miss_cb_implementation() :: Macro.t
    @callback sref_implementation(table :: Module, sref_prefix :: String.t) :: Macro.t
    @callback entity_implementation(table :: Module, repo :: Module) :: Macro.t
    @callback entity_txn_implementation(table :: Module, repo :: Module) :: Macro.t
    @callback record_implementation(table :: Module, repo :: Module) :: Macro.t
    @callback record_txn_implementation(table :: Module, repo :: Module) :: Macro.t
    @callback as_record_implementation(Module, options :: nil | Map.t) :: any
    @callback expand_table(Module, Module) :: Module
    @callback expand_repo(Module, Module) :: Module

    @doc """
      Noizu.ERP Implementation
    """
    @callback erp_imp(table :: Module) :: Macro.t

    def id_implementation(table, sref_prefix) do
      quote do
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        @table unquote(__MODULE__).expand_table(__MODULE__, unquote(table))
        def id(nil), do: nil
        def id({:ref, __MODULE__, identifier} = _ref), do: identifier
        def id(%__MODULE__{} = entity), do: entity.identifier
        def id(unquote(sref_prefix) <> identifier), do: ref(identifier) |> id()
        def id(%{__struct__: @table} = record), do: record.identifier
      end # end quote
    end

    def ref_implementation(table, sref_prefix) do
      quote do
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        @table unquote(__MODULE__).expand_table(__MODULE__, unquote(table))
        def ref(nil), do: nil
        def ref({:ref, __MODULE__, _identifier} = ref), do: ref
        def ref(identifier) when is_integer(identifier), do: {:ref, __MODULE__, identifier}
        def ref(unquote(sref_prefix) <> identifier = _sref), do: ref(identifier)
        def ref(identifier) when is_bitstring(identifier), do: {:ref, __MODULE__, String.to_integer(identifier)}
        def ref(identifier) when is_atom(identifier), do: {:ref, __MODULE__, identifier}
        def ref(%__MODULE__{} = entity), do: {:ref, __MODULE__, entity.identifier}
        def ref(%{__struct__: @table} = record), do: {:ref, __MODULE__, record.identifier}
        def ref(any), do: throw "#{__MODULE__}.ref Unsupported item #{inspect any}"
      end # end quote
    end # end ref_implementation

    def sref_implementation(table, sref_prefix) do
      quote do
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        @table unquote(__MODULE__).expand_table(__MODULE__, unquote(table))
        def sref(nil), do: nil
        def sref(identifier) when is_integer(identifier), do: "#{unquote(sref_prefix)}#{identifier}"
        def sref(unquote(sref_prefix) <> identifier = sref), do: sref
        def sref(identifier) when is_bitstring(identifier), do: ref(identifier) |> sref()
        def sref(identifier) when is_atom(identifier), do: "#{unquote(sref_prefix)}#{identifier}"
        def sref(%__MODULE__{} = this), do: "#{unquote(sref_prefix)}#{this.identifier}"
        def sref(%{__struct__: @table} = record), do: "#{unquote(sref_prefix)}#{record.identifier}"
        def sref(any), do: throw "#{__MODULE__}.sref Unsupported item #{inspect any}"
      end # end quote
    end # end sref_implementation


    def miss_cb_implementation() do
      quote do
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        def miss_cb(id, options \\ nil)
        def miss_cb(id, _options), do: nil
      end # end quote
    end # end entity_implementation

    def entity_implementation(table, repo) do
      quote do
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        @table unquote(__MODULE__).expand_table(__MODULE__, unquote(table))
        @repo unquote(__MODULE__).expand_repo(__MODULE__, unquote(repo))
        def entity(item, options \\ nil)
        def entity(nil, _options), do: nil
        def entity(%__MODULE__{} = this, options), do: this
        def entity(%{__struct__: @table} = record, options), do: expand(record.entity, options[:compression] || %{})
        def entity(identifier, options) do
          @repo.get(id(identifier), Noizu.ElixirCore.CallingContext.internal(), options) || miss_cb(identifier, options)
        end
      end # end quote
    end # end entity_implementation

    def entity_txn_implementation(table, repo) do
      quote do
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        @table unquote(__MODULE__).expand_table(__MODULE__, unquote(table))
        @repo unquote(__MODULE__).expand_repo(__MODULE__, unquote(repo))
        def entity!(item, options \\ nil)
        def entity!(nil, _options), do: nil
        def entity!(%__MODULE__{} = this, options), do: this
        def entity!(%{__struct__: @table} = record, options), do: expand(record.entity, options[:compression] || %{})
        def entity!(identifier, options), do: @repo.get!(ref(identifier) |> id(), Noizu.ElixirCore.CallingContext.internal(), options) || miss_cb(identifier, options)
      end # end quote
    end # end entity_txn_implementation

    def record_implementation(table, repo) do
      quote do
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        @table unquote(__MODULE__).expand_table(__MODULE__, unquote(table))
        @repo unquote(__MODULE__).expand_repo(__MODULE__, unquote(repo))
        def record(item, options \\ nil)
        def record(nil, _options), do: nil
        def record(%__MODULE__{} = this, options), do: as_record(this, options)
        def record(%{__struct__: @table} = record, options), do: record
        def record(identifier, options), do:  @repo.get(ref(identifier) |> id(), Noizu.ElixirCore.CallingContext.internal(), options) |> as_record(options)
      end # end quote
    end # end record_implementation

    def record_txn_implementation(table, repo) do
      quote do
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        @table unquote(__MODULE__).expand_table(__MODULE__, unquote(table))
        @repo unquote(__MODULE__).expand_repo(__MODULE__, unquote(repo))
        def record!(item, options \\ nil)
        def record!(nil, _options), do: nil
        def record!(%__MODULE__{} = this, options), do: as_record(this, options)
        def record!(%{__struct__: @table} = record, options), do: record
        def record!(identifier, options), do: @repo.get!(ref(identifier) |> id(), Noizu.ElixirCore.CallingContext.internal(), options) |> as_record(options)
      end # end quote
    end # end record_txn_implementation

    def has_permission_implementation() do
      quote do
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        def has_permission(ref, permission, %Noizu.ElixirCore.CallingContext{} = context, options) do
          context.auth[:permissions][:admin] || context.auth[:permissions][:system] || false
        end
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        def has_permission(ref, permission, %{auth: _auth} = context, options) do
          context.auth[:permissions][:admin] || context.auth[:permissions][:system] || false
        end
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        def has_permission(ref, permission, context, options) do
          false
        end
      end # end quote
    end # end record_implementation

    def has_permission_txn_implementation() do
      quote do
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        def has_permission!(ref, permission, context, options) do
          has_permission(ref, permission, context, options)
        end
      end # end quote
    end # end record_txn_implementation

    def erp_imp(table) do
      quote do
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        parent_module = __MODULE__
        mnesia_table = unquote(__MODULE__).expand_table(parent_module, unquote(table))
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        defimpl Noizu.ERP, for: [__MODULE__, mnesia_table] do
          @parent_module parent_module
          def id(o), do: @parent_module.id(o)
          def ref(o), do: @parent_module.ref(o)
          def sref(o), do: @parent_module.sref(o)
          def entity(o, options \\ nil), do: @parent_module.entity(o, options)
          def entity!(o, options \\ nil), do: @parent_module.entity!(o, options)
          def record(o, options \\ nil), do: @parent_module.record(o, options)
          def record!(o, options \\ nil), do: @parent_module.record!(o, options)



          def id_ok(o) do
            r = id(o)
            r && {:ok, r} || {:error, o}
          end
          def ref_ok(o) do
            r = ref(o)
            r && {:ok, r} || {:error, o}
          end
          def sref_ok(o) do
            r = sref(o)
            r && {:ok, r} || {:error, o}
          end
          def entity_ok(o, options \\ %{}) do
            r = entity(o, options)
            r && {:ok, r} || {:error, o}
          end
          def entity_ok!(o, options \\ %{}) do
            r = entity!(o, options)
            r && {:ok, r} || {:error, o}
          end


        end
      end # end quote
    end # end erp_imp

    def as_record_implementation(table, opts) do
      quote do
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        @mnesia_table unquote(__MODULE__).expand_table(__MODULE__, unquote(table))
        @options unquote(opts)

        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        def as_record(entity, options \\ %{})

        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        def as_record(nil, _options), do: nil

        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        if @options != nil do
          if Map.has_key?(@options, :additional_fields) do
            def as_record(this, options) do
              base = @mnesia_table.__struct__([identifier: this.identifier, entity: compress(this, options[:compression] || %{})])
              List.foldl(@options[:additional_fields], base,
                fn(field, acc) ->
                  case Map.get(this, field, :erp_imp_field_not_found) do
                    :erp_imp_field_not_found -> acc
                    %DateTime{} = v -> Map.put(acc, field, DateTime.to_unix(v))
                    v -> Map.put(acc, field, v)
                  end
                end
              )
            end
          else
            def as_record(this, options) do
              %{__struct__: @mnesia_table, identifier: this.identifier, entity:  compress(this, options[:compression] || %{})}
            end
          end
        else
          def as_record(this, options) do
            %{__struct__: @mnesia_table, identifier: this.identifier, entity: compress(this, options[:compression] || %{})}
          end
        end
      end # end quote
    end # end as_record_implementation

    def expand_table(module, table) do
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

    def expand_repo(module, repo) do
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