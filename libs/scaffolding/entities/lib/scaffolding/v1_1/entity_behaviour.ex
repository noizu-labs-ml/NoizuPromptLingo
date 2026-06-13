#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.Scaffolding.V1_1.EntityBehaviour do
  @moduledoc """
  This Behaviour provides some callbacks needed for the Noizu.ERP (EntityReferenceProtocol) to work smoothly.

  Note the following naming conventions  (where Path.To.Entity is the same path in each following case)
  - Entities  MyApp.(Path.To.Entity).MyFooEntity
  - Tables    MyApp.MyDatabase.(Path.To.Entity).MyFooTable
  - Repos     MyApp.(Path.To.Entity).MyFooRepo

  If the above conventions are not used a framework user must provide the appropriate `mnesia_table`, and `repo_module` `use` options.
  """
  alias Noizu.ElixirCore.CallingContext
  #-----------------------------------------------------------------------------
  # aliases, imports, uses,
  #-----------------------------------------------------------------------------
  require Logger

  #-----------------------------------------------------------------------------
  # Behaviour definition and types.
  #-----------------------------------------------------------------------------
  @type nmid :: integer | atom | String.t | tuple
  @type entity_obj :: any
  @type entity_record :: any
  @type entity_tuple_reference :: {:ref, module, nmid}
  @type entity_string_reference :: String.t
  @type entity_reference :: entity_obj | entity_record | entity_tuple_reference | entity_string_reference
  @type details :: any
  @type error :: {:error, details}
  @type options :: Map.t | nil

  @doc """
    Return identifier of ref, sref, entity or record
  """
  @callback id(entity_reference) :: any | error

  @doc """
    Returns appropriate {:ref|:ext_ref, module, identifier} reference tuple
  """
  @callback ref(entity_reference) :: entity_tuple_reference | error

  @doc """
    Returns appropriate string encoded ref. E.g. ref.user.1234
  """
  @callback sref(entity_reference) :: entity_string_reference | error

  @doc """
    Returns entity, given an identifier, ref tuple, ref string or other known identifier type.
    Where an entity is a EntityBehaviour implementing struct.
  """
  @callback entity(entity_reference, options) :: entity_obj | error

  @doc """
    Returns entity, given an identifier, ref tuple, ref string or other known identifier type. Wrapping call in transaction if required.
    Where an entity is a EntityBehaviour implementing struct.
  """
  @callback entity!(entity_reference, options) :: entity_obj | error

  @doc """
    Returns record, given an identifier, ref tuple, ref string or other known identifier type.
    Where a record is the raw mnesia table entry, as opposed to a EntityBehaviour based struct object.
  """
  @callback record(entity_reference, options) :: entity_record | error

  @doc """
    Returns record, given an identifier, ref tuple, ref string or other known identifier type. Wrapping call in transaction if required.
    Where a record is the raw mnesia table entry, as opposed to a EntityBehaviour based struct object.
  """
  @callback record!(entity_reference, options) :: entity_record | error

  @callback has_permission(entity_reference, any, any, options) :: boolean | error
  @callback has_permission!(entity_reference, any, any, options) :: boolean | error

  @doc """
    Converts entity into record format. Aka extracts any fields used for indexing with the expected database table looking something like
    ```
      %Table{
        identifier: entity.identifier,
        ...
        any_indexable_fields: entity.indexable_field,
        ...
        entity: entity
      }
    ```
    The default implementation assumes table structure if simply `%Table{identifier: entity.identifier, entity: entity}` therefore you will need to
    overide this implementation if you have any indexable fields. Future versions of the entity behaviour will accept an indexable field option
    that will insert expected fields and (if indicated) do simple type casting such as transforming DateTime.t fields into utc time stamps or
    `{time_zone, year, month, day, hour, minute, second}` tuples for efficient range querying.
  """
  @callback as_record(entity_obj, options :: Map.t) :: entity_record | error

  @doc """
    Returns the string used for preparing sref format strings. E.g. a `User` struct might use the string ``"user"`` as it's sref_module resulting in
    sref strings like `ref.user.1234`.
  """
  @callback sref_module() :: String.t

  @doc """
  Cast from json to struct.
  """
  @callback from_json(Map.t, CallingContext.t) :: any

  @doc """
  get entitie's repo module
  """
  @callback repo() :: atom


  @doc """
  Compress entity, default options
  """
  @callback compress(entity :: any) :: any

  @doc """
  Compress entity
  """
  @callback compress(entity :: any, options :: Map.t) :: any

  @doc """
  Expand entity, default options
  """
  @callback expand(entity :: any) :: any

  @doc """
  Expand entity
  """
  @callback expand(entity :: any, options :: Map.t) :: any

  #-----------------------------------------------------------------------------
  # Defines
  #-----------------------------------------------------------------------------
  #@methods [:id, :ref, :sref, :entity, :entity!, :record, :record!, :erp_imp, :as_record, :sref_module, :as_record, :from_json, :repo, :shallow, :miss_cb, :compress, :expand, :has_permission, :has_permission!, :poly_base]

  #-----------------------------------------------------------------------------
  # Using Implementation
  #-----------------------------------------------------------------------------
  defmacro __using__(options) do
    # Only include implementation for these methods.
    #option_arg = Keyword.get(options, :only, @methods)
    #only = List.foldl(@methods, %{}, fn(method, acc) -> Map.put(acc, method, Enum.member?(option_arg, method)) end)

    nmid_index = options[:nmid] || 0

    # Don't include implementation for these methods.
    #option_arg = Keyword.get(options, :override, [])
    #override = List.foldl(@methods, %{}, fn(method, acc) -> Map.put(acc, method, Enum.member?(option_arg, method)) end)

    #required? = List.foldl(@methods, %{}, fn(method, acc) -> Map.put(acc, method, only[method] && !override[method]) end)

    # Repo module (entity/record implementation), Module name with "Repo" appeneded if :auto
    repo_module = Keyword.get(options, :repo_module, :auto)
    mnesia_table = Keyword.get(options, :mnesia_table, :auto)


    as_record_options = Keyword.get(options, :as_record_options, Macro.escape(%{}))

    # Default Implementation Provider
    default_implementation = Keyword.get(options, :default_implementation, Noizu.Scaffolding.V1_1.EntityBehaviourDefault)

    sm = Keyword.get(options, :sref_module, "unsupported")
    sref_prefix = "ref." <> sm <> "."

    quote do
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      import unquote(__MODULE__)
      @behaviour Noizu.Scaffolding.EntityBehaviour
      @nmid_index unquote(nmid_index)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      @expanded_repo unquote(default_implementation).expand_repo(__MODULE__, unquote(repo_module))

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def sref_module(), do: unquote(sm)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def poly_base(), do: __MODULE__

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def repo(), do: @expanded_repo

      #-------------------------------------------------------------------------
      # Default Implementation from default_implementation behaviour
      #-------------------------------------------------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def from_json(json, context) do
         @expanded_repo.from_json(json, context)
       end

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def shallow(identifier) do
        %__MODULE__{identifier: identifier}
      end

      #unquote(Macro.expand(default_implementation, __CALLER__).prepare(mnesia_table, repo_module, sref_prefix))

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def compress(entity), do: compress(entity, %{})
      def compress(entity, options), do: entity

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def expand(entity), do: expand(entity, %{})
      def expand(entity, options), do: entity

      @__noizu_v1_1__mnesia_table unquote(mnesia_table)
      @__noizu_v1_1__sref_prefix unquote(sref_prefix)
      @__noizu_v1_1__repo_module unquote(repo_module)
      @__noizu_v1_1__as_record_options unquote(as_record_options)
      use unquote(default_implementation)

      #----------------------------------
      # Forward Compatibility with Advanced Scaffolding
      #----------------------------------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def __noizu_info__(), do: [
        type: __noizu_info__(:type),
        entity: __noizu_info__(:entity),
        sref_module: __noizu_info__(:sref_module),
      ]

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def __noizu_info__(:type), do: :entity_v1

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def __noizu_info__(:entity), do: __MODULE__

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def __noizu_info__(:sref_module), do: sref_module()

      def __nmid__(), do: [
        bare: __nmid__(:bare),
        index: __nmid__(:index)
      ]
      def __nmid__(:bare), do: false
      def __nmid__(:index), do: @nmid_index
      def __erp__(), do: __MODULE__

      defoverridable [
        sref_module: 0,
        poly_base: 0,
        repo: 0,
        from_json: 2,
        shallow: 1,
        compress: 1,
        compress: 2,
        expand: 1,
        expand: 2,
#
#        id: 1,
#        ref: 1,
#        sref: 1,
#        miss_cb: 1,
#        miss_cb: 2,
#        entity: 1,
#        entity: 2,
#        entity!: 1,
#        entity!: 2,
#        record: 1,
#        record: 2,
#        record!: 1,
#        record!: 2,
#        has_permission: 4,
#        has_permission!: 4,
#        as_record: 1,
#        as_record: 2,

        # Advanced Scaffolding Forward Compatibility
        __noizu_info__: 0,
        __noizu_info__: 1,
        __nmid__: 0,
        __nmid__: 1,
        __erp__: 0,
      ]

      #@before_compile unquote(__MODULE__)
    end # end quote
  end #end defmacro __using__(options)

  #defmacro __before_compile__(_env) do
  # quote do
  #   def has_permission(_ref, _permission, _context, _options), do: false
  #   def has_permission!(_ref, _permission, _context, _options), do: false
  # end # end quote
  #end # end defmacro __before_compile__(_env)

end #end defmodule
