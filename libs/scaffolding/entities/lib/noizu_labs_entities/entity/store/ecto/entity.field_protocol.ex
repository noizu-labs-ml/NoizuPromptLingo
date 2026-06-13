# -------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2023 Noizu Labs Inc. All rights reserved.
# -------------------------------------------------------------------------------

defprotocol Noizu.Entity.Store.Ecto.Entity.FieldProtocol do
  @fallback_to_any true
  def field_as_record(field, field_settings, persistence_settings, context, options)
  def field_from_record(field, record, field_settings, persistence_settings, context, options)
end

unless Code.ensure_loaded?(Ecto) do
  defimpl Noizu.Entity.Store.Ecto.Entity.FieldProtocol, for: [Any] do
    def field_as_record(field, field_settings, persistence_settings, context, options),
      do: raise(Noizu.Entity.Store.Ecto.Exception, message: "Ecto Not Available")

    def field_from_record(field, record, field_settings, persistence_settings, context, options),
      do: raise(Noizu.Entity.Store.Ecto.Exception, message: "Ecto Not Available")
  end
else
  defimpl Noizu.Entity.Store.Ecto.Entity.FieldProtocol, for: [Any] do
    require Noizu.Entity.Meta.Persistence
    require Noizu.Entity.Meta.Field

    # ---------------------------
    #
    # ---------------------------
    def field_as_record(
          field,
          Noizu.Entity.Meta.Field.field_settings(name: name, store: field_store),
          Noizu.Entity.Meta.Persistence.persistence_settings(store: store, table: table),
          _context,
          _options
        ) do
      name = field_store[table][:name] || field_store[store][:name] || name
      {:ok, {name, field}}
    end

    # ---------------------------
    #
    # ---------------------------
    def field_from_record(
          _field_stub,
          record,
          Noizu.Entity.Meta.Field.field_settings(name: name, store: field_store),
          Noizu.Entity.Meta.Persistence.persistence_settings(store: store, table: table),
          _context,
          _options
        ) do
      as_name = field_store[table][:name] || field_store[store][:name] || name
      {:ok, {name, get_in(record, [Access.key(as_name)])}}
    end
  end
end
