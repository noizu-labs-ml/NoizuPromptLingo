#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------
defmodule Noizu.FastGlobal.RepoBehaviour.FastGlobalCachedProvider do
  use Amnesia
  require Logger
  alias Noizu.ElixirCore.CallingContext
  alias Noizu.ERP, as: EntityReferenceProtocol
  @methods ([
              :entity, :options, :generate_identifier!, :generate_identifier,
              :update, :update!, :delete, :delete!, :create, :create!, :get, :get!,
              :match, :match!, :list, :list!, :pre_create_callback, :pre_update_callback, :pre_delete_callback,
              :post_create_callback, :post_get_callback, :post_update_callback, :post_delete_callback,
              :extract_date
            ])

  defmacro __using__(options) do
    # Only include implementation for these methods.
    option_arg = Keyword.get(options, :only, @methods)
    only = List.foldl(@methods, %{}, fn(method, acc) -> Map.put(acc, method, Enum.member?(option_arg, method)) end)

    # Don't include implementation for these methods.
    option_arg = Keyword.get(options, :override, [])
    override = List.foldl(@methods, %{}, fn(method, acc) -> Map.put(acc, method, Enum.member?(option_arg, method)) end)

    # Final set of methods to provide implementations for.
    required? = List.foldl(@methods, %{}, fn(method, acc) -> Map.put(acc, method, only[method] && !override[method]) end)

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

    persistence_strategy =  Keyword.get(options, :persistence_strategy, Noizu.Scaffolding.RepoBehaviour.AmnesiaProviderDefault)

    quote do
      use Amnesia
      require Logger
      alias Noizu.ElixirCore.CallingContext
      alias Noizu.ERP, as: EntityReferenceProtocol
      import unquote(__MODULE__)


      @persistence_strategy (unquote(persistence_strategy))

      @dirty_default (unquote(dirty_default))
      @frag_default (unquote(frag_default))

      mnesia_table = if unquote(mnesia_table) == :auto, do: @persistence_strategy.expand_table(__MODULE__), else: unquote(mnesia_table)
      @mnesia_table (mnesia_table)

      entity_module = if unquote(entity_module) == :auto, do: @persistence_strategy.expand_entity(__MODULE__), else: unquote(entity_module)
      @entity_module entity_module

      sequencer = case unquote(sequencer) do
        :auto -> @entity_module
        v -> v
      end
      @sequencer sequencer

      query_strategy = unquote(query_strategy)
      @query_strategy (query_strategy)

      audit_engine = unquote(audit_engine)
      @audit_engine (audit_engine)

      @audit_level unquote(audit_level)

      @nmid_generator unquote(nmid_generator)

      @param_pass_thru ({__MODULE__, @entity_module, @mnesia_table, @query_strategy, @audit_engine, @dirty_default, @frag_default, @audit_level})



      if (unquote(only.entity) && !unquote(override.entity)) do
        def entity() do
          @entity_module
        end # end
      end

      if (unquote(only.options) && !unquote(override.options)) do
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
      end

      #-------------------------------------------------------------------------
      # generate_identifier/1, generate_identifier!/1
      #-------------------------------------------------------------------------
      if (unquote(only.generate_identifier) && !unquote(override.generate_identifier)) do
        def generate_identifier(options \\ nil) do
          @nmid_generator.generate(@sequencer, options)
        end # end generate_identifier/1
      end

      if (unquote(only.generate_identifier!) && !unquote(override.generate_identifier!)) do
        def generate_identifier!(options \\ nil) do
          @nmid_generator.generate!(@sequencer, options)
        end # end generate_identifier/1
      end

      #-------------------------------------------------------------------------
      # @match
      #-------------------------------------------------------------------------
      if unquote(required?.match) do
        def match(match_sel, context, options \\ %{})
        def match(match_sel, %CallingContext{} = context, options), do: @persistence_strategy.match(@param_pass_thru, match_sel, context, options)
      end # end required?.match
      if unquote(required?.match!) do
        def match!(match_sel, context, options \\ %{})
        def match!(match_sel, %CallingContext{} = context, options), do: @persistence_strategy.match!(@param_pass_thru, match_sel, context, options)
      end # end required?.match!

      #-------------------------------------------------------------------------
      # @list
      #-------------------------------------------------------------------------
      if unquote(required?.list) do
        def list(context, options \\ %{})
        def list(%CallingContext{} = context, options), do: @persistence_strategy.list(@param_pass_thru, context, options)
      end # end required?.list
      if unquote(required?.list!) do
        def list!(context, options \\ %{})
        def list!(%CallingContext{} = context, options), do: @persistence_strategy.list!(@param_pass_thru, context, options)
      end # end required?.list!

      #-------------------------------------------------------------------------
      # @get
      #-------------------------------------------------------------------------
      if unquote(required?.get) do
        def get(identifier, context, options \\ %{})
        def get(identifier, %CallingContext{} = context, options) do
          options = Map.merge(%{no_cache: false}, options || %{})
          if options.no_cache do
            @persistence_strategy.get(@param_pass_thru, identifier, context, options)
          else
            sref = @entity_module.sref(identifier)
            sref_atom = :"#{sref}"
            Noizu.FastGlobal.get(sref_atom,
              fn() ->
                try do
                  @persistence_strategy.get(@param_pass_thru, identifier, context, options)
                rescue _e -> {:fast_global, :no_cache, nil}
                catch _e -> {:fast_global, :no_cache, nil}
                end
              end,
              options[:fg_options]
            )
          end
        end
      end # end required?.get

      if unquote(required?.post_get_callback) do
        def post_get_callback(entity, context, options), do: @persistence_strategy.post_get_callback(@param_pass_thru, entity, context, options)
      end # end required?.post_get_callback
      if unquote(required?.get!) do
        def get!(identifier, context, options \\ %{})
        def get!(identifier, %CallingContext{} = context, options) do
          @persistence_strategy.get!(@param_pass_thru, identifier, context, options)
        end
      end # end required?.get!

      #-------------------------------------------------------------------------
      # @update
      #-------------------------------------------------------------------------
      if unquote(required?.pre_update_callback) do
        def pre_update_callback(entity, context, options), do: @persistence_strategy.pre_update_callback(@param_pass_thru, entity, context, options)
      end # end required?.pre_update_callback
      if unquote(required?.post_update_callback) do
        def post_update_callback(entity, context, options), do: @persistence_strategy.post_update_callback(@param_pass_thru, entity, context, options)
      end # end required?.post_update_callback
      if unquote(required?.update) do
        def update(entity, context, options \\ %{})
        def update(entity, %CallingContext{} = context, options) do
          options = Map.merge(%{no_cache: false}, options || %{})
          if options.no_cache do
            @persistence_strategy.update(@param_pass_thru, entity, context, options)
          else
            u = @persistence_strategy.update(@param_pass_thru, entity, context, options)
            if (u != nil || options[:fg_options][:cache_nil]) do
              sref = @entity_module.sref(identifier)
              sref_atom = :"#{sref}"
              Noizu.FastGlobal.put(sref, u, options[:fg_options])
            end
            u
          end
        end
      end # end required?.update
      if unquote(required?.update!) do
        def update!(entity, context, options \\ %{})
        def update!(entity, %CallingContext{} = context, options) do
          @persistence_strategy.update!(@param_pass_thru, entity, context, options)
        end
      end # end required?.update!

      #-------------------------------------------------------------------------
      # @delete
      #-------------------------------------------------------------------------
      if unquote(required?.pre_delete_callback) do
        def pre_delete_callback(entity, context, options), do: @persistence_strategy.pre_delete_callback(@param_pass_thru, entity, context, options)
      end # end required?.pre_delete_callback
      if unquote(required?.post_delete_callback) do
        def post_delete_callback(entity, context, options), do: @persistence_strategy.post_delete_callback(@param_pass_thru, entity, context, options)
      end # end required?.post_delete_callback
      if unquote(required?.delete) do
        def delete(entity, context, options \\ %{})
        def delete(entity, %CallingContext{} = context, options) do
          options = Map.merge(%{no_cache: false}, options || %{})
          if options.no_cache do
            @persistence_strategy.delete(@param_pass_thru, entity, context, options)
          else
            sref = @entity_module.sref(entity)
            sref_atom = :"#{sref}"
            Noizu.FastGlobal.put(sref, nil, options[:fg_options])
            @persistence_strategy.delete(@param_pass_thru, entity, context, options)
          end
        end
      end # end  required?.delete
      if unquote(required?.delete!) do
        def delete!(entity, context, options \\ %{})
        def delete!(entity, %CallingContext{} = context, options), do: @persistence_strategy.delete!(@param_pass_thru, entity, context, options)
      end # end required?.delete!

      #-------------------------------------------------------------------------
      # @create
      #-------------------------------------------------------------------------
      if unquote(required?.pre_create_callback) do
        def pre_create_callback(entity, context, options) do
          @persistence_strategy.pre_create_callback(@param_pass_thru, entity, context, options)
        end
      end # end required?.pre_create_callback
      if unquote(required?.post_create_callback) do
        def post_create_callback(entity, context, options), do: @persistence_strategy.post_create_callback(@param_pass_thru, entity, context, options)
      end # end required?.post_create_callback
      if unquote(required?.create) do
        def create(entity, context, options \\ %{})
        def create(entity, context = %CallingContext{}, options) do
          options = Map.merge(%{no_cache: false}, options || %{})
          if options.no_cache do
            @persistence_strategy.create(@param_pass_thru, entity, context, options)
          else
            u = @persistence_strategy.create(@param_pass_thru, entity, context, options)
            if u do
              sref = @entity_module.sref(u)
              sref_atom = :"#{sref}"
              Noizu.FastGlobal.put(sref, u, options[:fg_options])
            end
            u
          end
        end
      end # end required?.create
      if unquote(required?.create!) do
        def create!(entity, context, options \\ %{})
        def create!(entity, context = %CallingContext{}, options), do: @persistence_strategy.create!(@param_pass_thru, entity, context, options)
      end # end required?.create

      if unquote(required?.extract_date) do
        def extract_date(any), do: @persistence_strategy.extract_date(any)
      end
    end # end quote
  end # end __using__
end
