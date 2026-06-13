#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.Scaffolding.V2.RepoBehaviour do
  alias Noizu.ElixirCore.CallingContext

  @type ref :: tuple
  @type opts :: Map.t

  @doc """
    Entity repo manages.
  """
  @callback entity() :: any

  @callback audit_engine() :: any
  @callback audit_level() :: any
  @callback entity_module() :: any
  @callback entity_table() :: any

  @callback query_strategy() :: any
  @callback sequencer() :: any
  @callback nmid_generator() :: any
  @callback implementation() :: any

  @doc """
    Compile time options.
  """
  @callback options() :: Module

  @doc """
    Match Records.
  """
  @callback match(any, CallingContext.t, opts) :: list

  @doc """
    Match Records. Transaction Wrapped
  """
  @callback match!(any, CallingContext.t, opts) :: list

  @doc """
    List Records.
  """
  @callback list(CallingContext.t, opts) :: list

  @doc """
    List Records. Transaction Wrapped
  """
  @callback list!(CallingContext.t, opts) :: list

  @doc """
    Fetch record.
  """
  @callback get(integer | atom, CallingContext.t, opts) :: any

  @doc """
    Fetch record. Transaction Wrapped
  """
  @callback get!(integer | atom, CallingContext.t, opts) :: any

  @doc """
    Update record.
  """
  @callback update(any, CallingContext.t, opts) :: any

  @doc """
    Update record. Transaction Wrapped
  """
  @callback update!(any, CallingContext.t, opts) :: any

  @doc """
    Delete record.
  """
  @callback delete(any, CallingContext.t, opts) :: boolean

  @doc """
    Delete record. Transaction Wrapped
  """
  @callback delete!(any, CallingContext.t, opts) :: boolean

  @doc """
    Create new record.
  """
  @callback create(any, CallingContext.t, opts) :: any

  @doc """
    Create new record. Transaction Wrapped
  """
  @callback create!(any, CallingContext.t, opts) :: any

  @doc """
    Hook for any post create steps.
    Provided an entity needs to setup linked objects.
  """
  @callback pre_create_callback(any, CallingContext.t, opts) :: any

  @doc """
    Hook for any post update steps.
  """
  @callback pre_update_callback(any, CallingContext.t, opts) :: any

  @doc """
    Hook for any post delete steps.
  """
  @callback pre_delete_callback(any, CallingContext.t, opts) :: any

  @doc """
    Hook for any post create steps.
    Provided an entity needs to setup linked objects.
  """
  @callback post_create_callback(any, CallingContext.t, opts) :: any


  @doc """
    Hook for any post get steps. (such as versioning)
  """
  @callback post_get_callback(any, CallingContext.t, opts) :: any

  @doc """
    Hook for any post update steps.
  """
  @callback post_update_callback(any, CallingContext.t, opts) :: any

  @doc """
    Hook for any post delete steps.
  """
  @callback post_delete_callback(any, CallingContext.t, opts) :: any

  @doc """
     generate new nmid.
  """
  @callback generate_identifier(any) :: integer | atom

  @doc """
     generate new nmid. Transaction Wrapped
  """
  @callback generate_identifier!(any) :: integer | atom

  @doc """
  Cast from json to struct.
  """
  @callback from_json(Map.t, CallingContext.t, opts) :: any

  @doc """
  Cast from json to struct.
  """
  @callback from_json_version(any, Map.t, CallingContext.t, opts) :: any

  defmacro __using__(options) do
    # Implementation for Persistance layer interactions.
    implementation_provider = Keyword.get(options, :implementation_provider,  Noizu.Scaffolding.V2.RepoBehaviour.AmnesiaProvider)

    options = case Keyword.get(options, :entity_table, :auto) do
      :auto -> Keyword.put(options, :entity_table, Keyword.get(options, :mnesia_table, :auto))
      _ -> options
    end

    quote do
      @behaviour Noizu.Scaffolding.RepoBehaviour
      import unquote(__MODULE__)

      @implementation (unquote(implementation_provider))

      @module __MODULE__
      @options @implementation.expand_options(@module, unquote(options))

      @audit_engine @options[:audit_engine]
      @sequencer @options[:sequencer]
      @audit_level @options[:audit_level]
      @nmid_generator @options[:nmid_generator]
      @entity_table @options[:entity_table]
      @entity_module @options[:entity_module]
      @query_strategy @options[:query_strategy]

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def audit_engine(), do: @audit_engine

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def audit_level(), do: @audit_level

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def entity_module(), do: @entity_module

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def entity_table(), do: @entity_table

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def options(), do: @options

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def query_strategy(), do: @query_strategy

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def sequencer(), do: @sequencer

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def nmid_generator(), do: @nmid_generator

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def implementation(), do: @implementation

      # @deprecated
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def entity(), do: @entity_module

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
          Noizu.FastGlobal.Cluster.get(cache_key,
            fn() ->
              if Amnesia.Table.wait([@entity_table], 500) == :ok do
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

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def update_cache(ref, context, options \\ nil)
      def update_cache(nil, _context, _options), do: nil
      def update_cache(%{__struct__: @entity_module} = entity, _context, options) do
        cache_key = cache_key(entity, options)
        Noizu.FastGlobal.Cluster.put(cache_key, entity, options)
        entity
      end
      def update_cache(ref, context, options) do
        entity = @entity_module.entity!(ref)
        update_cache(entity, context, options)
      end

      #-------------------------------------------------------------------------
      # from_json/2, from_json/3
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def from_json(json, context, options \\ %{}), do: from_json_version(:default, json, context, options)
      def from_json_version(version, json, context, options \\ %{}), do: _imp_from_json_version(@module, version, json, context, options)
     def _imp_from_json_version(m, version, json, context, options), do: @implementation.from_json_version(m, version, json, context, options)

      #-------------------------------------------------------------------------
      # extract_date/3
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def extract_date(d), do: @implementation.extract_date(d)

      #-------------------------------------------------------------------------
      # generate_identifier/1
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def generate_identifier(options \\ nil), do: apply(@nmid_generator, :generate , [sequencer(), options])

      #-------------------------------------------------------------------------
      # generate_identifier!/1
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def generate_identifier!(options \\ nil), do: apply(@nmid_generator, :generate!, [sequencer(), options])

      #==============================
      # @match
      #==============================

      #-------------------------------------------------------------------------
      # match/3
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def match(match_sel, context, options \\ %{}), do: _imp_match(@module, match_sel, context, options)
      def _imp_match(module, match_sel, context, options), do: @implementation.match(module, match_sel, context, options)

      #-------------------------------------------------------------------------
      # match!/3
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def match!(match_sel, context, options \\ %{}), do: _imp_match!(@module, match_sel, context, options)
      def _imp_match!(module, match_sel, context, options), do: @implementation.match!(module, match_sel, context, options)

      #==============================
      # @list
      #==============================

      #-------------------------------------------------------------------------
      # list/2
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def list(context, options \\ %{}), do: _imp_list(@module, context, options)
      def _imp_list(module, context, options), do: @implementation.list(module, context, options)

      #-------------------------------------------------------------------------
      # list!/2
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def list!(context, options \\ %{}), do: _imp_list!(@module, context, options)
     def _imp_list!(module, context, options), do: @implementation.list!(module, context, options)

      #==============================
      # @get
      #==============================

      #-------------------------------------------------------------------------
      # inner_get_callback/3
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def inner_get_callback(identifier, context, options \\ %{}), do: _imp_inner_get_callback(@module, identifier, context, options)
     def _imp_inner_get_callback(module, identifier, context, options), do: @implementation.inner_get_callback(module, identifier, context, options)

      #-------------------------------------------------------------------------
      # post_get_callback/3
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def post_get_callback(entity, context, options \\ %{}), do: @implementation.post_get_callback(entity, context, options)

      #-------------------------------------------------------------------------
      # get/3
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def get(identifier, context, options \\ %{}), do: _imp_get(@module, identifier, context, options)
      def _imp_get(module, identifier, context, options), do: @implementation.get(module, identifier, context, options)

      #-------------------------------------------------------------------------
      # get!/3
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def get!(identifier, context, options \\ %{}), do: _imp_get!(@module, identifier, context, options)
      def _imp_get!(module, identifier, context, options), do: @implementation.get!(module, identifier, context, options)

      #==============================
      # @create
      #==============================

      #-------------------------------------------------------------------------
      # pre_create_callback/3
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
     def pre_create_callback(entity, context, options \\ %{}), do: @implementation.pre_create_callback(entity, context, options)

      #-------------------------------------------------------------------------
      # inner_create_callback/3
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
     def inner_create_callback(entity, context, options \\ %{}), do: @implementation.inner_create_callback(entity, context, options)

      #-------------------------------------------------------------------------
      # post_create_callback/3
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
     def post_create_callback(entity, context, options \\ %{}), do: @implementation.post_create_callback(entity, context, options)

      #-------------------------------------------------------------------------
      # create/3
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
     def create(entity, context, options \\ %{}), do: @implementation.create(entity, context, options)

      #-------------------------------------------------------------------------
      # create!/3
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
     def create!(entity, context, options \\ %{}), do: @implementation.create!(entity, context, options)


      #==============================
      # @update
      #==============================

      #-------------------------------------------------------------------------
      # pre_update_callback/3
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
     def pre_update_callback(entity, context, options \\ %{}), do: @implementation.pre_update_callback(entity, context, options)

      #-------------------------------------------------------------------------
      # inner_update_callback/3
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
     def inner_update_callback(entity, context, options \\ %{}), do: @implementation.inner_update_callback(entity, context, options)

      #-------------------------------------------------------------------------
      # post_update_callback/3
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
     def post_update_callback(entity, context, options \\ %{}), do: @implementation.post_update_callback(entity, context, options)

      #-------------------------------------------------------------------------
      # update/3
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
     def update(entity, context, options \\ %{}), do: @implementation.update(entity, context, options)

      #-------------------------------------------------------------------------
      # update!/3
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
     def update!(entity, context, options \\ %{}), do: @implementation.update!(entity, context, options)

      #==============================
      # @delete
      #==============================

      #-------------------------------------------------------------------------
      # pre_delete_callback/3
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
     def pre_delete_callback(entity, context, options \\ %{}), do: @implementation.pre_delete_callback(entity, context, options)

      #-------------------------------------------------------------------------
      # inner_delete_callback/3
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
     def inner_delete_callback(entity, context, options \\ %{}), do: @implementation.inner_delete_callback(entity, context, options)

      #-------------------------------------------------------------------------
      # post_delete_callback/3
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
     def post_delete_callback(entity, context, options \\ %{}), do: @implementation.post_delete_callback(entity, context, options)

      #-------------------------------------------------------------------------
      # delete/3
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
     def delete(entity, context, options \\ %{}), do: @implementation.delete(entity, context, options)

      #-------------------------------------------------------------------------
      # delete!/3
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
     def delete!(entity, context, options \\ %{}), do: @implementation.delete!(entity, context, options)

      defoverridable [
        audit_engine: 0,
        audit_level: 0,
        entity_module: 0,
        entity_table: 0,
        options: 0,
        query_strategy: 0,
        sequencer: 0,
        nmid_generator: 0,

        entity: 0, # deprecated


        cache_key: 1,
        cache_key: 2,

        delete_cache: 2,
        delete_cache: 3,

        cached: 2,
        cached: 3,


        from_json: 2,
        from_json: 3,

        from_json_version: 3,
        from_json_version: 4,
        _imp_from_json_version: 5,

        extract_date: 1,

        generate_identifier: 0,
        generate_identifier: 1,

        generate_identifier!: 0,
        generate_identifier!: 1,

        match: 2,
        match: 3,
        _imp_match: 4,

        match!: 2,
        match!: 3,
        _imp_match!: 4,

        list: 1,
        list: 2,
        _imp_list: 3,

        list!: 1,
        list!: 2,
        _imp_list!: 3,

        inner_get_callback: 2,
        inner_get_callback: 3,
        _imp_inner_get_callback: 4,

        post_get_callback: 2,
        post_get_callback: 3,

        get: 2,
        get: 3,
        _imp_get: 4,

        get!: 2,
        get!: 3,
        _imp_get!: 4,

        pre_create_callback: 2,
        pre_create_callback: 3,

        inner_create_callback: 2,
        inner_create_callback: 3,

        post_create_callback: 2,
        post_create_callback: 3,

        create: 2,
        create: 3,

        create!: 2,
        create!: 3,

        pre_update_callback: 2,
        pre_update_callback: 3,

        inner_update_callback: 2,
        inner_update_callback: 3,

        post_update_callback: 2,
        post_update_callback: 3,

        update: 2,
        update: 3,

        update!: 2,
        update!: 3,

        pre_delete_callback: 2,
        pre_delete_callback: 3,

        inner_delete_callback: 2,
        inner_delete_callback: 3,

        post_delete_callback: 2,
        post_delete_callback: 3,

        delete: 2,
        delete: 3,

        delete!: 2,
        delete!: 3,
      ]


    end # end quote
  end # end defmacro __using__(options)
end # end defmodule Noizu.Scaffolding.RepoBehaviour
