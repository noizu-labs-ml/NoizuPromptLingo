#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.Scaffolding.RepoBehaviour do
  alias Noizu.ElixirCore.CallingContext

  @type ref :: tuple
  @type opts :: Map.t

  @doc """
    Entity repo manages.
  """
  @callback entity() :: Map.t

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
  @callback from_json(Map.t, CallingContext.t) :: any

  @methods ([
    :entity, :options, :generate_identifier!, :generate_identifier,
    :update, :update!, :delete, :delete!, :create, :create!, :get, :get!,
    :match, :match!, :list, :list!, :post_get_callback, :pre_create_callback, :pre_update_callback, :pre_delete_callback,
    :post_create_callback, :post_get_callback, :post_update_callback, :post_delete_callback,
    :from_json, :extract_date])

  defmacro __using__(options) do
    # Only include implementation for these methods.
    option_arg = Keyword.get(options, :only, @methods)
    only = List.foldl(@methods, %{}, fn(method, acc) -> Map.put(acc, method, Enum.member?(option_arg, method)) end)

    # Don't include implementation for these methods.
    option_arg = Keyword.get(options, :override, [])
    override = List.foldl(@methods, %{}, fn(method, acc) -> Map.put(acc, method, Enum.member?(option_arg, method)) end)

    # Final set of methods to provide implementations for.
    required? = List.foldl(@methods, %{}, fn(method, acc) -> Map.put(acc, method, only[method] && !override[method]) end)

    # Implementation for Persistance layer interactions.
    implementation_provider = Keyword.get(options, :implementation_provider,  Noizu.Scaffolding.RepoBehaviour.AmnesiaProvider)

    # Auditing details
    audit_engine = Keyword.get(options, :audit_engine, Application.get_env(:noizu_scaffolding, :default_audit_engine, Noizu.Scaffolding.AuditEngine.Default))

    quote do
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      @behaviour Noizu.Scaffolding.RepoBehaviour
      @implementation (unquote(implementation_provider))



      @__default_telemetry [enabled: false, sample_rate: 0, events: [get: false, get!: false, cache: false, list: false, list!: false, match: false, match!: false]]
      @__default_enabled_telemetry [enabled: true, sample_rate: 100, events: [get: 10, get!: 10, cache: 5, list: 10, list!: 10, match: 10, match!: 10]]
      @__default_light_telemetry [enabled: true, sample_rate: 50, events: [get: false, get!: false, cache: false, list: false, list!: false, match: false, match!: false]]
      @__default_heavy_telemetry [enabled: false, sample_rate: 250, events: [get: 25, get!: 25, cache: 5, list: 25, list!: 25, match: 25, match!: 25]]
      @__default_diagnostic_telemetry [enabled: true, sample_rate: 1000, events: [get: true, get!: true, cache: true, list: true, list!: true, match: true, match!: true]]
      @__default_disabled_telemetry [enabled: false, sample_rate: 0, events: [get: false, get!: false, cache: false, list: false, list!: false, match: false, match!: false]]
      a__nzdo__telemetry = cond do
                             Module.has_attribute?(__MODULE__, :telemetry) -> {:ok, Module.get_attribute(__MODULE__, :telemetry)}
                             unquote(Enum.member?(options,:telemetry)) -> {:ok, unquote(get_in(options, [:telemetry]))}
                             :else -> nil
                           end
                           |> case do
                                nil -> Application.get_env(:noizu_scaffolding, :telemetry)[:default] || @__default_telemetry
                                {:ok, v} when v in [true, :enabled] -> Application.get_env(:noizu_scaffolding, :telemetry)[:enabled] || @__default_enabled_telemetry
                                {:ok, :light} -> Application.get_env(:noizu_scaffolding, :telemetry)[:light] || @__default_light_telemetry
                                {:ok, :heavy} -> Application.get_env(:noizu_scaffolding, :telemetry)[:heavy] || @__default_heavy_telemetry
                                {:ok, :diagnostic} -> Application.get_env(:noizu_scaffolding, :telemetry)[:diagnostic] || @__default_diagnostic_telemetry
                                {:ok, false} -> Application.get_env(:noizu_scaffolding, :telemetry)[:disabled] || @__default_disabled_telemetry
                                {:ok, :disabled} -> Application.get_env(:noizu_scaffolding, :telemetry)[:disabled] || @__default_disabled_telemetry
                                {:ok, v} when is_list(v)->
                                  defaults = Application.get_env(:noizu_scaffolding, :telemetry)[:enabled] || @__default_enabled_telemetry
                                  events = Keyword.merge(defaults[:events] || [], v[:events] || [])
                                  sample_rate = v[:sample_rate] || defaults[:sample_rate] || @__default_enabled_telemetry[:sample_rate]
                                  enabled = if Enum.member?(v, :enabled), do: v[:enabled], else: defaults[:enabled] || false
                                  [enabled: enabled, sample_rate: sample_rate, events: events]
                              end
      @__nzdo__telemetry a__nzdo__telemetry


      def __persistence__(:telemetry), do: @__nzdo__telemetry

      #=====================================================================
      # Telemetry
      #=====================================================================
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def emit_telemetry?(type, _, context, options) do
        cond do
          get_in(options || [], [:emit_telemtry?]) != nil -> options[:emit_telemtry?]
          get_in(context && context.options || [], [:emit_telemtry?]) != nil -> options[:emit_telemtry?]
          :else ->
            c = __persistence__(:telemetry)
            cond do
              c[:enabled] in [true, :enabled] ->
                case c[:events][type] do
                  false -> false
                  true -> c[:sample_rate]
                  v when is_integer(v) -> v
                  _ -> c[:sample_rate]
                end
              :else -> false
            end
        end |> case do
                 false -> false
                 :disabled -> false
                 true -> 1
                 :enabled -> 1
                 v when is_integer(v) ->
                   cond do
                     v >= 1000 -> 1
                     :rand.uniform(1000) <= v ->
                       r = rem(1000, v)
                       a = cond do
                             r == 0 -> 0
                             :rand.uniform(100) <= ((1000*r)/v) -> 1
                             :else -> 0
                           end
                       div(1000, v) + a
                     :else -> false
                   end
               end
      end

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def telemetry_event(type, _, _, _) do
        m = %{
          get!: :get,
          list!: :list,
          match!: :match,
          update!: :update,
          create!: :create,
        }
        type = m[type] || type
        [:persistence, :event, type]
      end
      
      use unquote(implementation_provider), unquote(options)

      
      
      
      
      
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def audit_engine, do: unquote(audit_engine)
      #-------------------------------------------------------------------------
      # from_json
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      if unquote(required?.from_json) do
        def from_json(_json, _context) do
          throw "From Json Not Implemented For #{__MODULE__}.  use override: from_json and provide your implementation."
        end # end from_json/2
      end

      defoverridable [
        telemetry_event: 4,
        emit_telemetry?: 4
      ]
      
    end # end quote
  end # end defmacro __using__(options)
end # end defmodule Noizu.Scaffolding.RepoBehaviour
