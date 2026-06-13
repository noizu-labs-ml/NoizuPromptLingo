defmodule Noizu.Entity.ReferenceBehaviour.TypeHelper do
  @moduledoc false
  require Noizu.Entity.Meta.Persistence
  require Noizu.Entity.Meta.Field

  require Noizu.EntityReference.Records
  #alias Noizu.EntityReference.Records, as: R

  def do_field_as_record(
        m,
        %{reference: ref},
        Noizu.Entity.Meta.Field.field_settings(name: name, store: field_store),
        Noizu.Entity.Meta.Persistence.persistence_settings(
          store: store,
          table: table,
          type: type
        ),
        _,
        _
      ) do
    as_name = field_store[table][:name] || field_store[store][:name] || name
    # We need to do a universal ecto conversion
    method =
      case type do
        Noizu.Entity.Store.Amnesia -> :ref
        _ -> :id
      end

    with {:ok, id} <- apply(m, method, [ref]) do
      {:ok, {as_name, id}}
    end
  end

  def do_field_from_record(
        m,
        _,
        %{entity: entity},
        Noizu.Entity.Meta.Field.field_settings(
          options: field_options,
          name: name,
          store: field_store
        ),
        Noizu.Entity.Meta.Persistence.persistence_settings(store: store, table: table),
        context,
        _
      ) do
    as_name = field_store[table][:name] || field_store[store][:name] || name

    case Map.get(entity, as_name) do
      v when is_struct(v) ->
        {:ok, v}

      ref ->
        if field_options[:auto] do
          apply(m, :entity, [ref, context])
        else
          apply(m, :ref, [ref])
        end
    end
    |> case do
      nil -> {:ok, {name, nil}}
      {:ok, entity} -> {:ok, {name, entity}}
      v -> v
    end
  end
  
  def do_field_from_record(
        m,
        _,
        entity = %{__meta__: _},
        Noizu.Entity.Meta.Field.field_settings(
          options: field_options,
          name: name,
          store: field_store
        ),
        Noizu.Entity.Meta.Persistence.persistence_settings(store: store, table: table),
        context,
        _
      ) do
    as_name = field_store[table][:name] || field_store[store][:name] || name
    
    case Map.get(entity, as_name) do
      v when is_struct(v) ->
        {:ok, v}
      
      ref ->
        if field_options[:auto] do
          apply(m, :entity, [ref, context])
        else
          apply(m, :ref, [ref])
        end
    end
    |> case do
         nil -> {:ok, {name, nil}}
         {:ok, entity} -> {:ok, {name, entity}}
         v -> v
       end
  end
end

defmodule Noizu.Entity.Reference.Exception do
  @moduledoc false
  defexception [:message]

  def message(e) do
    "#{inspect(e.message)}"
  end
end

defmodule Noizu.Entity.ReferenceBehaviour do
  @moduledoc """
  Use for declaring a field reference to handle encoding/decoding when writting to storage.
  """

  defmacro __using__(options \\ nil) do
    identifier_type =
      options[:identifier_type] ||
        raise Noizu.Entity.Reference.Exception, "identifier_type is required"

    entity = options[:entity] || raise Noizu.Entity.Reference.Exception, "entity is required"

    quote do
      @erp_type_handlers %{
        uuid: Noizu.Entity.Meta.UUIDIdentifier,
        integer: Noizu.Entity.Meta.IntegerIdentifier,
        atom: Noizu.Entity.Meta.AtomIdentifier,
        ref: Noizu.Entity.Meta.RefIdentifier,
        dual_ref: Noizu.Entity.Meta.DualRefIdentifier
      }

      @type_handler (case unquote(identifier_type) do
                       x when x in [:uuid, :integer, :atom, :ref, :dual_ref] ->
                         @erp_type_handlers[x]

                       x ->
                         x
                     end)
      type_handler = @type_handler

      @derive Noizu.EntityReference.Protocol
      defstruct reference: nil
      use Noizu.Entity.Field.Behaviour

      defdelegate ecto_gen_string(name), to: @type_handler
      def id(%__MODULE__{reference: reference}), do: apply(unquote(entity), :id, [reference])
      def ref(%__MODULE__{reference: reference}), do: apply(unquote(entity), :ref, [reference])
      def sref(%__MODULE__{reference: reference}), do: apply(unquote(entity), :sref, [reference]) 
      def kind(%__MODULE__{reference: reference}), do: apply(unquote(entity), :kind, [reference])

      def entity(%__MODULE__{reference: reference}, context),
        do: apply(unquote(entity), :entity, [reference, context])

      def stub(),
        do: {:ok, %__MODULE__{}}

      # Nest this object (a ref, or struct, etc.) inside reference structure
      def type_as_entity(entity, context, options)
      def type_as_entity(entity, _, _), do: {:ok, %__MODULE__{reference: entity}}

      for store <- [
            Noizu.Entity.Store.Amnesia,
            Noizu.Entity.Store.Dummy,
            Noizu.Entity.Store.Ecto,
            Noizu.Entity.Store.Mnesia,
            Noizu.Entity.Store.Redis
          ] do
        entity_field_protocol = Module.concat(store, Entity.FieldProtocol)

        defimpl entity_field_protocol do
          @type_helper Noizu.Entity.ReferenceBehaviour.TypeHelper

          def field_from_record(
                field,
                record,
                field_settings,
                persistence_settings,
                context,
                options
              ),
              do:
                @type_helper.do_field_from_record(
                  unquote(entity),
                  field,
                  record,
                  field_settings,
                  persistence_settings,
                  context,
                  options
                )

          def field_as_record(field, field_settings, persistence_settings, context, options),
            do:
              @type_helper.do_field_as_record(
                unquote(entity),
                field,
                field_settings,
                persistence_settings,
                context,
                options
              )
        end
      end
    end
  end
end
