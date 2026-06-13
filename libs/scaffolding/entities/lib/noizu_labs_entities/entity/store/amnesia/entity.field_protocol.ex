# -------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2025 Noizu Labs Inc. All rights reserved.
# -------------------------------------------------------------------------------

defprotocol Noizu.Entity.Store.Amnesia.Entity.FieldProtocol do
  @moduledoc """
  This is the protocol used to pack/unpack individual fields (if the fields have a type implementation.) to and from storage.
  """

  @fallback_to_any true

  @typedoc "An Entity That Implements the Entity.FieldProtocol"
  @type field :: any

  @typedoc "Valid field name for storage mechanism"
  @type field_name :: any

  @typedoc "An Amnesia Record"
  @type record :: any

  @typedoc "Entity Settings Record"
  @type field_settings :: Noizu.Entity.Meta.Field.field_settings()

  @typedoc "Persistence Settings"
  @type persistence_settings :: Noizu.Entity.Meta.Persistence.persistence_settings()

  @typedoc "Context Record"
  @type context :: any

  @typedoc "Options Keyword List"
  @type options :: nil | list

  @doc """
  Convert field to record format.
  """
  @spec field_as_record(field, field_settings, persistence_settings, context, options) ::
          {:ok, {field_name, any}} | {:error, any}
  def field_as_record(field, field_settings, persistence_settings, context, options)

  @doc """
  Extract field from record.
  """
  @spec field_from_record(field, record, field_settings, persistence_settings, context, options) ::
          {:ok, any} | {:error, any}
  def field_from_record(field, record, field_settings, persistence_settings, context, options)
end

defimpl Noizu.Entity.Store.Amnesia.Entity.FieldProtocol, for: [Any] do
  require Noizu.Entity.Meta.Persistence
  require Noizu.Entity.Meta.Field

  # ---------------------------
  # field_as_record/4
  # ---------------------------
  def field_as_record(field, field_settings, persistence_settings, context, options)

  def field_as_record(
        _,
        Noizu.Entity.Meta.Field.field_settings(name: name, transient: true),
        _,
        _,
        _
      ) do
    {:ok, {name, nil}}
  end

  def field_as_record(field, Noizu.Entity.Meta.Field.field_settings(name: name), _, _, _) do
    {:ok, {name, field}}
  end

  # ---------------------------
  # field_from_record
  # ---------------------------
  def field_from_record(field, record, field_settings, persistence_settings, context, options)

  def field_from_record(_, _, _, _, _, _),
    # We simply grab Amnesia for default cases. Multi Table scenarios require Overrides
    do: {:error, {:unsupported, Amnesia}}
end
