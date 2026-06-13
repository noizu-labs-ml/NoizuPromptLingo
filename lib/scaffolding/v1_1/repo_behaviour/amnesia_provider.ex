#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.Scaffolding.V1_1.RepoBehaviour.AmnesiaProvider do
  use Amnesia
  require Logger
  alias Noizu.ElixirCore.CallingContext
  alias Noizu.ERP, as: EntityReferenceProtocol
#  @methods ([
#              :entity, :options, :generate_identifier!, :generate_identifier,
#              :update, :update!, :delete, :delete!, :create, :create!, :get, :get!,
#              :match, :match!, :list, :list!, :pre_create_callback, :pre_update_callback, :pre_delete_callback,
#              :post_create_callback, :post_get_callback, :post_update_callback, :post_delete_callback,
#              :extract_date, :cache_key, :delete_cache, :cached
#            ])

  defmacro __using__(options) do
    # Only include implementation for these methods.
    #option_arg = Keyword.get(options, :only, @methods)
    #only = List.foldl(@methods, %{}, fn(method, acc) -> Map.put(acc, method, Enum.member?(option_arg, method)) end)

    # Don't include implementation for these methods.
    #option_arg = Keyword.get(options, :override, [])
    #override = List.foldl(@methods, %{}, fn(method, acc) -> Map.put(acc, method, Enum.member?(option_arg, method)) end)

    # Final set of methods to provide implementations for.
    #required? = List.foldl(@methods, %{}, fn(method, acc) -> Map.put(acc, method, only[method] && !override[method]) end)

    # associated mnesia table and entity
    mnesia_table = Keyword.get(options, :mnesia_table, :auto)
    entity_module = Keyword.get(options, :entity_module, :auto)

    query_strategy = Keyword.get(options, :query_strategy, Noizu.Scaffolding.QueryStrategy.Default)

    audit_engine = Keyword.get(options, :audit_engine, Application.get_env(:noizu_scaffolding, :default_audit_engine, Noizu.Scaffolding.AuditEngine.Default))

    nmid_generator = Keyword.get(options, :nmid_generator, Application.get_env(:noizu_scaffolding, :default_nmid_generator))
    sequencer = Keyword.get(options, :sequencer, :auto)

    dirty_default = Keyword.get(options, :dirty_default, true)
    frag_default = Keyword.get(options, :frag_default, :async)

    audit_level = Keyword.get(options, :audit_level, Application.get_env(:noizu_scaffolding, :default_audit_level, :silent))

    quote do
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      use Amnesia
      require Logger
      alias Noizu.ElixirCore.CallingContext
      alias Noizu.ERP, as: EntityReferenceProtocol
      import unquote(__MODULE__)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      @dirty_default (unquote(dirty_default))
      @frag_default (unquote(frag_default))

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      mnesia_table = if unquote(mnesia_table) == :auto, do: Noizu.Scaffolding.RepoBehaviour.AmnesiaProviderDefault.expand_table(__MODULE__), else: unquote(mnesia_table)
      @mnesia_table (mnesia_table)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      entity_module = if unquote(entity_module) == :auto, do: Noizu.Scaffolding.RepoBehaviour.AmnesiaProviderDefault.expand_entity(__MODULE__), else: unquote(entity_module)
      @entity_module entity_module

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      sequencer = case unquote(sequencer) do
                    :auto -> @entity_module
                    v -> v
                  end
      @sequencer sequencer

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      query_strategy = unquote(query_strategy)
      @query_strategy (query_strategy)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      audit_engine = unquote(audit_engine)
      @audit_engine (audit_engine)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      @audit_level unquote(audit_level)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      @nmid_generator unquote(nmid_generator)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      @param_pass_thru ({__MODULE__, @entity_module, @mnesia_table, @query_strategy, @audit_engine, @dirty_default, @frag_default, @audit_level})


      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def entity() do
        @entity_module
      end # end

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def options() do
        input = unquote(options)
        %{
          input: input,
          mnesia_table: @mnesia_table,
          entity_module: @entity_module,
          sequencer: @sequencer,
          query_strategy: @query_strategy,
          audit_engine: @audit_engine,
          audit_level: @audit_level
        }
      end # end

      #-------------------------------------------------------------------------
      # generate_identifier/1, generate_identifier!/1
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def generate_identifier(options \\ nil) do
        @nmid_generator.generate(@sequencer, options)
      end # end generate_identifier/1

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def generate_identifier!(options \\ nil) do
        @nmid_generator.generate!(@sequencer, options)
      end # end generate_identifier/1

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def cache_key(ref, options \\ nil) do
        sref = @entity_module.sref(ref)
        sref && :"e_c:#{sref}"
      end

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def delete_cache(ref, context, options \\ nil) do
        # @todo use noizu cluster and meta to track applicable servers.
        key = cache_key(ref, options)
        if key do
          FastGlobal.delete(key)
          spawn fn ->
            (options[:nodes] || Node.list())
            |> Task.async_stream(fn(n) -> :rpc.cast(n, FastGlobal, :delete, [key]) end)
            |> Enum.map(&(&1))
          end
          # return
          :ok
        else
          {:error, :ref}
        end
      end


      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def cached(ref, context, options \\ nil)
      def cached(nil, _context, _options), do: nil
      def cached(%{__struct__: @entity_module} = entity, _context, _options), do: entity
      def cached(ref, context, options) do
        cache_key = cache_key(ref, options)
        if cache_key do
          ts = :os.system_time(:second)
          identifier = @entity_module.id(ref)
          # @todo setup invalidation scheme

          emit = emit_telemetry?(:cache, ref, context, options)
          emit && :telemetry.execute(telemetry_event(:cache, ref, context, options), %{count: emit}, %{mod: __MODULE__})

          Noizu.FastGlobal.Cluster.get(cache_key,
            fn() ->
              emit && :telemetry.execute(telemetry_event(:cache_miss, ref, context, options), %{count: emit}, %{mod: __MODULE__})
              
              if Amnesia.Table.wait([@mnesia_table], 500) == :ok do
                case get!(identifier, context, options) do
                  entity = %{} -> entity
                  nil -> nil
                  _ -> {:fast_global, :no_cache, nil}
                end
              else
                {:fast_global, :no_cache, nil}
              end
            end
            
          )
        end
      end

      #-------------------------------------------------------------------------
      # @match
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def match(match_sel, context, options \\ %{})
      def match(match_sel, %CallingContext{} = context, options), do: Noizu.Scaffolding.RepoBehaviour.AmnesiaProviderDefault.match(@param_pass_thru, match_sel, context, options)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def match!(match_sel, context, options \\ %{})
      def match!(match_sel, %CallingContext{} = context, options), do: Noizu.Scaffolding.RepoBehaviour.AmnesiaProviderDefault.match!(@param_pass_thru, match_sel, context, options)

      #-------------------------------------------------------------------------
      # @list
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def list(context, options \\ %{})
      def list(%CallingContext{} = context, options), do: Noizu.Scaffolding.RepoBehaviour.AmnesiaProviderDefault.list(@param_pass_thru, context, options)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def list!(context, options \\ %{})
      def list!(%CallingContext{} = context, options), do: Noizu.Scaffolding.RepoBehaviour.AmnesiaProviderDefault.list!(@param_pass_thru, context, options)

      #-------------------------------------------------------------------------
      # @get
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def get(identifier, context, options \\ %{})
      def get(identifier, %CallingContext{} = context, options), do: Noizu.Scaffolding.RepoBehaviour.AmnesiaProviderDefault.get(@param_pass_thru, identifier, context, options)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def post_get_callback(entity, context, options), do: Noizu.Scaffolding.RepoBehaviour.AmnesiaProviderDefault.post_get_callback(@param_pass_thru, entity, context, options)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def get!(identifier, context, options \\ %{})
      def get!(identifier, %CallingContext{} = context, options), do: Noizu.Scaffolding.RepoBehaviour.AmnesiaProviderDefault.get!(@param_pass_thru, identifier, context, options)

      #-------------------------------------------------------------------------
      # @update
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def pre_update_callback(entity, context, options), do: Noizu.Scaffolding.RepoBehaviour.AmnesiaProviderDefault.pre_update_callback(@param_pass_thru, entity, context, options)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def post_update_callback(entity, context, options), do: Noizu.Scaffolding.RepoBehaviour.AmnesiaProviderDefault.post_update_callback(@param_pass_thru, entity, context, options)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def update(entity, context, options \\ %{})
      def update(entity, %CallingContext{} = context, options), do: Noizu.Scaffolding.RepoBehaviour.AmnesiaProviderDefault.update(@param_pass_thru, entity, context, options)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def update!(entity, context, options \\ %{})
      def update!(entity, %CallingContext{} = context, options), do: Noizu.Scaffolding.RepoBehaviour.AmnesiaProviderDefault.update!(@param_pass_thru, entity, context, options)

      #-------------------------------------------------------------------------
      # @delete
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def pre_delete_callback(entity, context, options), do: Noizu.Scaffolding.RepoBehaviour.AmnesiaProviderDefault.pre_delete_callback(@param_pass_thru, entity, context, options)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def post_delete_callback(entity, context, options), do: Noizu.Scaffolding.RepoBehaviour.AmnesiaProviderDefault.post_delete_callback(@param_pass_thru, entity, context, options)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def delete(entity, context, options \\ %{})
      def delete(entity, %CallingContext{} = context, options), do: Noizu.Scaffolding.RepoBehaviour.AmnesiaProviderDefault.delete(@param_pass_thru, entity, context, options)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def delete!(entity, context, options \\ %{})
      def delete!(entity, %CallingContext{} = context, options), do: Noizu.Scaffolding.RepoBehaviour.AmnesiaProviderDefault.delete!(@param_pass_thru, entity, context, options)

      #-------------------------------------------------------------------------
      # @create
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def pre_create_callback(entity, context, options) do
        Noizu.Scaffolding.RepoBehaviour.AmnesiaProviderDefault.pre_create_callback(@param_pass_thru, entity, context, options)
      end

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def post_create_callback(entity, context, options), do: Noizu.Scaffolding.RepoBehaviour.AmnesiaProviderDefault.post_create_callback(@param_pass_thru, entity, context, options)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def create(entity, context, options \\ %{})
      def create(entity, context = %CallingContext{}, options), do: Noizu.Scaffolding.RepoBehaviour.AmnesiaProviderDefault.create(@param_pass_thru, entity, context, options)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def create!(entity, context, options \\ %{})
      def create!(entity, context = %CallingContext{}, options), do: Noizu.Scaffolding.RepoBehaviour.AmnesiaProviderDefault.create!(@param_pass_thru, entity, context, options)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def extract_date(any), do: Noizu.Scaffolding.RepoBehaviour.AmnesiaProviderDefault.extract_date(any)

      defoverridable [
        entity: 0,
        options: 0,
        generate_identifier: 0,
        generate_identifier: 1,
        generate_identifier!: 0,
        generate_identifier!: 1,
        cache_key: 1,
        cache_key: 2,
        delete_cache: 2,
        delete_cache: 3,
        cached: 2,
        cached: 3,

        match: 2,
        match: 3,
        match!: 2,
        match!: 3,
        list: 1,
        list: 2,
        list!: 1,
        list!: 2,

        post_get_callback: 3,
        get: 2,
        get: 3,
        get!: 2,
        get!: 3,

        pre_update_callback: 3,
        post_update_callback: 3,
        update: 2,
        update: 3,
        update!: 2,
        update!: 3,

        pre_delete_callback: 3,
        post_delete_callback: 3,
        delete: 2,
        delete: 3,
        delete!: 2,
        delete!: 3,

        pre_create_callback: 3,
        post_create_callback: 3,
        create: 2,
        create: 3,
        create!: 2,
        create!: 3,

        extract_date: 1
      ]




    end # end quote
  end # end __using__
end
