# -------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2023 Noizu Labs Inc. All rights reserved.
# -------------------------------------------------------------------------------

defprotocol Noizu.Entity.Store.Ecto.EntityProtocol do
  @fallback_to_any true
  require Noizu.Entity.Meta.Field

  def persist(entity, type, settings, context, options)
  def as_record(entity, settings, context, options)
  def fetch_as_entity(entity, settings, context, options)
  def as_entity(entity, record, settings, context, options)
  def delete_record(entity, settings, context, options)
  def from_record(record, settings, context, options)
  def merge_from_record(entity, record, settings, context, options)
end

unless Code.ensure_loaded?(Ecto) do
  defimpl Noizu.Entity.Store.Ecto.EntityProtocol, for: [Any] do
    def persist(entity, type, settings, context, options),
      do: raise(Noizu.Entity.Store.Ecto.Exception, message: "Ecto Not Available")

    def as_record(entity, settings, context, options),
      do: raise(Noizu.Entity.Store.Ecto.Exception, message: "Ecto Not Available")

    def fetch_as_entity(entity, settings, context, options),
      do: raise(Noizu.Entity.Store.Ecto.Exception, message: "Ecto Not Available")

    def as_entity(entity, record, settings, context, options),
      do: raise(Noizu.Entity.Store.Ecto.Exception, message: "Ecto Not Available")

    def delete_record(entity, settings, context, options),
      do: raise(Noizu.Entity.Store.Ecto.Exception, message: "Ecto Not Available")

    def from_record(record, settings, context, options),
      do: raise(Noizu.Entity.Store.Ecto.Exception, message: "Ecto Not Available")

    def merge_from_record(entity, record, settings, context, options),
      do: raise(Noizu.Entity.Store.Ecto.Exception, message: "Ecto Not Available")
  end
else
  defimpl Noizu.Entity.Store.Ecto.EntityProtocol, for: [Any] do
    defmacro __deriving__(module, _struct, _options) do
      quote do
        use Noizu.Entity.Store.Ecto.EntityProtocol.Behaviour

        defimpl Noizu.Entity.Store.Ecto.Entity.FieldProtocol, for: [unquote(module)] do
          def persist(record, action, settings, context, options),
            do: apply(unquote(module), :persist, [record, action, settings, context, options])

          def as_record(record, settings, context, options),
            do: apply(unquote(module), :as_record, [record, settings, context, options])

          def fetch_as_entity(record, settings, context, options),
            do: apply(unquote(module), :fetch_as_entity, [record, settings, context, options])

          def as_entity(entity, record, settings, context, options),
            do: apply(unquote(module), :as_entity, [entity, record, settings, context, options])

          def delete_record(record, settings, context, options),
            do: apply(unquote(module), :delete_record, [record, settings, context, options])

          def from_record(record, settings, context, options),
            do: apply(unquote(module), :from_record, [record, settings, context, options])

          def merge_from_record(entity, record, settings, context, options),
            do:
              apply(unquote(module), :merge_from_record, [
                entity,
                record,
                settings,
                context,
                options
              ])
        end
      end
    end

    defdelegate persist(record, action, settings, context, options),
      to: Noizu.Entity.Store.Ecto.EntityProtocol.Behaviour

    defdelegate as_record(record, settings, context, options),
      to: Noizu.Entity.Store.Ecto.EntityProtocol.Behaviour

    defdelegate fetch_as_entity(record, settings, context, options),
      to: Noizu.Entity.Store.Ecto.EntityProtocol.Behaviour

    defdelegate as_entity(entity, record, settings, context, options),
      to: Noizu.Entity.Store.Ecto.EntityProtocol.Behaviour

    defdelegate delete_record(record, settings, context, options),
      to: Noizu.Entity.Store.Ecto.EntityProtocol.Behaviour

    defdelegate from_record(record, settings, context, options),
      to: Noizu.Entity.Store.Ecto.EntityProtocol.Behaviour

    defdelegate merge_from_record(entity, record, settings, context, options),
      to: Noizu.Entity.Store.Ecto.EntityProtocol.Behaviour
  end
end
