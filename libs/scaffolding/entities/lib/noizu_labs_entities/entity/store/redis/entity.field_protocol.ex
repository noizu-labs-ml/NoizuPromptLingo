# -------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2023 Noizu Labs Inc. All rights reserved.
# -------------------------------------------------------------------------------

defprotocol Noizu.Entity.Store.Redis.Entity.FieldProtocol do
  @fallback_to_any true
  def field_as_record(field, field_settings, persistence_settings, context, options)
  def field_from_record(field, record, field_settings, persistence_settings, context, options)
end

defimpl Noizu.Entity.Store.Redis.Entity.FieldProtocol, for: [Any] do
  require Noizu.Entity.Meta.Persistence
  require Noizu.Entity.Meta.Field
  # ---------------------------
  #
  # ---------------------------
  def field_as_record(
        field,
        Noizu.Entity.Meta.Field.field_settings(name: name, store: _field_store),
        Noizu.Entity.Meta.Persistence.persistence_settings(store: _store, table: _table),
        _context,
        _options
      ) do
    {:ok, {name, field}}
  end

  # ---------------------------
  #
  # ---------------------------
  def field_from_record(
        _field_stub,
        record,
        Noizu.Entity.Meta.Field.field_settings(name: name, store: _field_store),
        Noizu.Entity.Meta.Persistence.persistence_settings(store: _store, table: _table),
        _context,
        _options
      ) do
    {:ok, {name, get_in(record, [Access.key(name)])}}
  end
end
