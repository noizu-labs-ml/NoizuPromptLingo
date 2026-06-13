#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.Scaffolding.V1_1.EntityBehaviourDefault do

  defmacro __using__(_options) do
    quote do
      #      @__noizu_v1_1__mnesia_table unquote(mnesia_table)
      #      @__noizu_v1_1__sref_prefix unquote(sref_prefix)
      #      @__noizu_v1_1__repo_module unquote(repo_module)
      #      @__noizu_v1_1__as_record_options unquote(as_record_options)
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      @table Noizu.Scaffolding.V1_1.EntityBehaviourDefault.expand_table(__MODULE__, @__noizu_v1_1__mnesia_table)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      @repo Noizu.Scaffolding.V1_1.EntityBehaviourDefault.expand_repo(__MODULE__, @__noizu_v1_1__repo_module)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def id(nil), do: nil
      def id({:ref, __MODULE__, identifier} = _ref), do: identifier
      def id(%__MODULE__{} = entity), do: entity.identifier
      def id(@__noizu_v1_1__sref_prefix <> identifier), do: ref(identifier) |> id()
      def id(%{__struct__: @table} = record), do: record.identifier
      def id(_), do: nil

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def ref(nil), do: nil
      def ref({:ref, __MODULE__, _identifier} = ref), do: ref
      def ref(identifier) when is_integer(identifier), do: {:ref, __MODULE__, identifier}
      def ref(@__noizu_v1_1__sref_prefix <> identifier = _sref), do: ref(identifier)
      def ref(identifier) when is_bitstring(identifier), do: {:ref, __MODULE__, String.to_integer(identifier)}
      def ref(identifier) when is_atom(identifier), do: {:ref, __MODULE__, identifier}
      def ref(%__MODULE__{} = entity), do: {:ref, __MODULE__, entity.identifier}
      def ref(%{__struct__: @table} = record), do: {:ref, __MODULE__, record.identifier}
      def ref(_), do: nil

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def sref(nil), do: nil
      def sref(identifier) when is_integer(identifier), do: "#{@__noizu_v1_1__sref_prefix}#{identifier}"
      def sref(@__noizu_v1_1__sref_prefix <> identifier = sref), do: sref
      def sref(identifier) when is_bitstring(identifier), do: ref(identifier) |> sref()
      def sref(identifier) when is_atom(identifier), do: "#{@__noizu_v1_1__sref_prefix}#{identifier}"
      def sref(%__MODULE__{} = this), do: "#{@__noizu_v1_1__sref_prefix}#{this.identifier}"
      def sref(%{__struct__: @table} = record), do: "#{@__noizu_v1_1__sref_prefix}#{record.identifier}"
      def sref(_), do: nil

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def miss_cb(id, options \\ nil)
      def miss_cb(id, _options), do: nil

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def entity(item, options \\ nil)
      def entity(nil, _options), do: nil
      def entity(%__MODULE__{} = this, options), do: this
      def entity(%{__struct__: @table} = record, options), do: expand(record.entity, options[:compression] || %{})
      def entity(identifier, options) do
        @repo.get(id(identifier), Noizu.ElixirCore.CallingContext.internal(), options) || miss_cb(identifier, options)
      end

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def entity!(item, options \\ nil)
      def entity!(nil, _options), do: nil
      def entity!(%__MODULE__{} = this, options), do: this
      def entity!(%{__struct__: @table} = record, options), do: expand(record.entity, options[:compression] || %{})
      def entity!(identifier, options), do: @repo.get!(ref(identifier) |> id(), Noizu.ElixirCore.CallingContext.internal(), options) || miss_cb(identifier, options)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def record(item, options \\ nil)
      def record(nil, _options), do: nil
      def record(%__MODULE__{} = this, options), do: as_record(this, options)
      def record(%{__struct__: @table} = record, options), do: record
      def record(identifier, options), do: @repo.get(ref(identifier) |> id(), Noizu.ElixirCore.CallingContext.internal(), options) |> as_record(options)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def record!(item, options \\ nil)
      def record!(nil, _options), do: nil
      def record!(%__MODULE__{} = this, options), do: as_record(this, options)
      def record!(%{__struct__: @table} = record, options), do: record
      def record!(identifier, options), do: @repo.get!(ref(identifier) |> id(), Noizu.ElixirCore.CallingContext.internal(), options) |> as_record(options)


      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def has_permission(_ref, _permission, %Noizu.ElixirCore.CallingContext{} = context, _options), do: context.auth[:permissions][:admin] || context.auth[:permissions][:system] || false
      def has_permission(_ref, _permission, _context, _options), do: false

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def has_permission!(_ref, _permission, %Noizu.ElixirCore.CallingContext{} = context, _options), do: context.auth[:permissions][:admin] || context.auth[:permissions][:system] || false
      def has_permission!(_ref, _permission, _context, _options), do: false


      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def as_record(entity, options \\ %{})
      def as_record(nil, _options), do: nil
      def as_record(this, options) do
        base = @table.__struct__([identifier: this.identifier, entity: compress(this, options[:compression] || %{})])
        List.foldl(@__noizu_v1_1__as_record_options[:additional_fields] || [], base,
          fn(field, acc) ->
            case Map.get(this, field, :erp_imp_field_not_found) do
              :erp_imp_field_not_found -> acc
              %DateTime{} = v -> Map.put(acc, field, DateTime.to_unix(v))
              v -> Map.put(acc, field, v)
            end
          end
        )
      end



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


      defoverridable [
        id: 1,
        ref: 1,
        sref: 1,
        miss_cb: 1,
        miss_cb: 2,
        entity: 1,
        entity: 2,
        entity!: 1,
        entity!: 2,
        record: 1,
        record: 2,
        record!: 1,
        record!: 2,
        has_permission: 4,
        has_permission!: 4,
        as_record: 1,
        as_record: 2,

        id_ok: 1,
        ref_ok: 1,
        sref_ok: 1,
        entity_ok: 1,
        entity_ok: 2,
        entity_ok!: 1,
        entity_ok!: 2,

      ]
    end
  end

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