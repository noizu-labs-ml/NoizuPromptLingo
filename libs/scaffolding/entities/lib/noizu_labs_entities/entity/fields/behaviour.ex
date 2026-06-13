defmodule Noizu.Entity.Field.Behaviour do
  @moduledoc """
  Defines Entity.Field behavior used for marshalling from/to peristence layers and managing complex/compound types that compose/break fields up into layer specific fields.
  """

  @typedoc """
  Field Entry Name
  """
  @type field_name :: atom

  @typedoc """
  Field settings
  """
  @type field_settings :: Noizu.Entity.Meta.Field.field_settings()

  @doc """
  Generate ecto generator field entries for given field.
  Used by Mix.Tasks.Nz.Gen.Entity
  """
  @callback ecto_gen_string(name :: field_name) :: {:ok, any} | {:error, any}
  #
  #  @doc """
  #  Convert entity.field to a record for persistence.
  #  """
  #  @callback as_record(entity :: any, settings :: any, context :: any, options :: any) ::
  #              {:ok, any} | {:error, any}
  #
  #  @doc """
  #  Convert records.field(s) to entity field. Usual 1-2-1 mapping although composite fields liek TimeStamp, Path, etc. combine multiple fields into a single entity field.
  #  """
  #  @callback as_entity(entity :: any, settings :: any, context :: any, options :: any) ::
  #              {:ok, any} | {:error, any}
  #
  #  @doc """
  #  Delete Record
  #  """
  #  @callback delete_record(entity :: any, settings :: any, context :: any, options :: any) ::
  #              {:ok, any} | {:error, any}
  #
  #
  #  @doc """
  #  Convert record field(s) to entity field(s)
  #  """
  #  @callback from_record(entity :: any, settings :: any, context :: any, options :: any) ::
  #              {:ok, any} | {:error, any}
  #
  #  @doc """
  #  Persist entity.
  #  """
  #  @callback persist(
  #              entity :: any,
  #              action_type :: atom,
  #              settings :: any,
  #              context :: any,
  #              options :: any
  #            ) :: any

  @doc """
  Before Create Hook for Entity Field Type.
  Runs at entity (not layer level).
  - Populate entity if stub entry added(e.g. string to versioned string)
  - Persist dependent entities.
  """
  @callback type__before_create(entity :: any, settings :: any, context :: any, options :: any) ::
              {:ok, any} | {:error, any}

  @doc """
  Before Update Hook for Entity Field Types.
  Runs at entity (not persistence layer) level.
  Update dependent entries/tables. (may span multiple storage types).
  """
  @callback type__before_update(entity :: any, settings :: any, context :: any, options :: any) ::
              {:ok, any} | {:error, any}

  @doc """
  After Delete Hook for Entity Field Types.
  Runs at entity (not persistence layer) level.
  Update dependent entries/tables. (may span multiple storage types).
  """
  @callback type__after_delete(entity :: any, settings :: any, context :: any, options :: any) ::
              {:ok, any} | {:error, any}

  @doc """
  Convert Type to Entity - Struct stored in entity may be incomplete, for example if real time data is bound.
  Runs at entity level, fully populates and possibly casts field to type used for persistence.
  """
  @callback type_as_entity(entity :: any, context :: any, options :: any) ::
              {:ok, any} | {:error, any}

  @doc """
  Return empty entity stub.
  """
  @callback stub() :: {:ok, any} | {:error, any}
  #
  #  @doc """
  #  Field as record (unpack entity field to record field(s)
  #  """
  #  @callback field_as_record(field :: any, settings :: any, context :: any, options :: any) ::
  #              {:ok, any} | {:error, any}
  #
  #  @doc """
  #  Field from record fields (combine record field(s) to entity.field(s).
  #  """
  #  @callback field_from_record(field :: any, settings :: any, context :: any, options :: any) ::
  #              {:ok, any} | {:error, any}

  defmacro __using__(_options \\ nil) do
    quote do
      @behaviour Noizu.Entity.Field.Behaviour
      def ecto_gen_string(prefix), do: {:error, {:ecto_gen_string, :unsupported}}

      #      def as_record(_, _, _, _), do: {:error, {:as_record, :unsupported}}
      #      def as_entity(_, _, _, _), do: {:error, {:as_entity, :unsupported}}
      #      def delete_record(_, _, _, _), do: {:error, {:delete_record, :unsupported}}
      #      def from_record(_, _, _, _), do: {:error, {:from_record, :unsupported}}
      #      def persist(_, _, _, _, _), do: {:error, {:persist, :unsupported}}

      def type__before_create(field_type, settings, context, options)

      def type__before_create(_, _, _, _),
        do: {:error, {:unsupported, __MODULE__, :type__before_create}}

      def type__before_update(field_type, settings, context, options)

      def type__before_update(_, _, _, _),
        do: {:error, {:unsupported, __MODULE__, :type__before_update}}

      def type__after_delete(field_type, settings, context, options)

      def type__after_delete(_, _, _, _),
        do: {:error, {:unsupported, __MODULE__, :type__after_delete}}

      def type_as_entity(nil, _, _), do: stub()
      def type_as_entity(this, _, _), do: {:ok, this}
      def stub(), do: {:ok, %__MODULE__{}}
      #
      #      def field_as_record(_, _, _, _), do: {:error, :field_as_record}
      #      def field_from_record(_, _, _, _), do: {:error, :field_from_record}

      defoverridable ecto_gen_string: 1,
                     #                     as_record: 4,
                     #                     as_entity: 4,
                     #                     delete_record: 4,
                     #                     from_record: 4,
                     #                     persist: 5,
                     type__before_create: 4,
                     type__before_update: 4,
                     type__after_delete: 4,
                     type_as_entity: 3,
                     stub: 0

      #                     field_as_record: 4,
      #                     field_from_record: 4
    end
  end
end
