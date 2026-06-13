# -------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2023 Noizu Labs Inc. All rights reserved.
# -------------------------------------------------------------------------------

if Code.ensure_loaded?(Ecto) do
  defmodule Noizu.Entity.Store.Ecto.EntityProtocol.Behaviour do
    @moduledoc """
    Support for Ecto backed Entities.
    """
    require Noizu.Entity.Meta.Persistence
    require Noizu.Entity.Meta.Field

    # ---------------------------
    #
    # ---------------------------
    @callback persist(
                record :: any,
                type :: :create | :update,
                settings :: Tuple,
                context :: any,
                options :: any
              ) :: {:ok, any} | {:error, details :: any}
    def persist(
          %{__struct__: table} = record,
          :create,
          Noizu.Entity.Meta.Persistence.persistence_settings(table: table, store: repo),
          _context,
          _options
        ) do
      # Verify table match
      apply(repo, :insert, [record])
    end

    def persist(
          %{__struct__: table} = record,
          :update,
          Noizu.Entity.Meta.Persistence.persistence_settings(table: table, store: repo),
          _context,
          _options
        ) do
      # 1. Get record
      if current = apply(repo, :get, [table, record.id]) do
        cs = apply(table, :changeset, [current, Map.from_struct(record)])
        apply(repo, :update, [cs])
      end
    end

    def persist(_, _, _, _, _) do
      {:error, :pending}
    end

    # ---------------------------
    #
    # ---------------------------
    @callback as_record(entity :: any, settings :: Tuple, context :: any, options :: any) ::
                {:ok, any} | {:error, details :: any}
    def as_record(
          entity,
          Noizu.Entity.Meta.Persistence.persistence_settings(table: table) = settings,
          context,
          options
        ) do
      # @todo strip transient fields,
      # @todo collapse refs.
      # @todo map fields
      # @todo Inject indexes

      #     Record.defrecord(:field_settings, [name: nil, store: nil, type: nil, transient: false, pii: false, default: nil, acl: nil])
      fields =
        Noizu.Entity.Meta.fields(entity)
        |> Enum.map(fn
          {_, Noizu.Entity.Meta.Field.field_settings(name: name, type: nil) = field_settings} ->
            Noizu.Entity.Store.Ecto.Entity.FieldProtocol.field_as_record(
              get_in(entity, [Access.key(name)]),
              field_settings,
              settings,
              context,
              options
            )

          {_,
           Noizu.Entity.Meta.Field.field_settings(name: name, type: {:ecto, _}) = field_settings} ->
            Noizu.Entity.Store.Ecto.Entity.FieldProtocol.field_as_record(
              get_in(entity, [Access.key(name)]),
              field_settings,
              settings,
              context,
              options
            )

          {_, Noizu.Entity.Meta.Field.field_settings(name: name, type: type) = field_settings} ->
            {:ok, field_entry} =
              apply(type, :type_as_entity, [get_in(entity, [Access.key(name)]), context, options])

            Noizu.Entity.Store.Ecto.Entity.FieldProtocol.field_as_record(
              field_entry,
              field_settings,
              settings,
              context,
              options
            )
        end)
        |> List.flatten()
        |> List.flatten()
        |> Enum.map(fn
          {:ok, v} -> v
          _ -> nil
        end)
        |> Enum.filter(& &1)

      record = struct(table, fields)
      {:ok, record}
    end

    # ---------------------------
    #
    # ---------------------------
    @callback fetch_as_entity(entity :: any, settings :: Tuple, context :: any, options :: any) ::
                {:ok, any} | {:error, details :: any}
    def fetch_as_entity(
          entity,
          Noizu.Entity.Meta.Persistence.persistence_settings(table: table, store: store) =
            settings,
          context,
          options
        ) do
      with {:ok, id} <- Noizu.EntityReference.Protocol.id(entity),
           record = %{} <- apply(store, :get, [table, id]) do
        from_record(record, settings, context, options)
      end
    end

    # ---------------------------
    #
    # ---------------------------
    @callback as_entity(
                entity :: any,
                record :: any,
                settings :: Tuple,
                context :: any,
                options :: any
              ) :: {:ok, any} | {:error, details :: any}
    def as_entity(
          _,
          record,
          Noizu.Entity.Meta.Persistence.persistence_settings() = settings,
          context,
          options
        ) do
      from_record(record, settings, context, options)
    end

    # ---------------------------
    #
    # ---------------------------
    @callback delete_record(entity :: any, settings :: Tuple, context :: any, options :: any) ::
                {:ok, any} | {:error, details :: any}
    def delete_record(
          entity,
          Noizu.Entity.Meta.Persistence.persistence_settings(table: table, store: store),
          _context,
          _options
        ) do
      with {:ok, id} <- Noizu.EntityReference.Protocol.id(entity) do
        apply(store, :delete, [struct(table, id: id)])
      end
    end

    # ---------------------------
    #
    # ---------------------------
    @callback merge_from_record(
                entity :: any,
                record :: any,
                settings :: Tuple,
                context :: any,
                options :: any
              ) :: {:ok, any} | {:error, details :: any}
    def merge_from_record(
          _entity,
          record,
          Noizu.Entity.Meta.Persistence.persistence_settings(kind: _kind) = settings,
          context,
          options
        ) do
      from_record(record, settings, context, options)
    end

    @callback from_record(entity :: any, settings :: Tuple, context :: any, options :: any) ::
                {:ok, any} | {:error, details :: any}
    def from_record(
          record,
          Noizu.Entity.Meta.Persistence.persistence_settings(kind: kind) = settings,
          context,
          options
        ) do
      fields =
        Noizu.Entity.Meta.fields(kind)
        |> Enum.map(fn
          {_, Noizu.Entity.Meta.Field.field_settings(name: _name, type: nil) = field_settings} ->
            Noizu.Entity.Store.Ecto.Entity.FieldProtocol.field_from_record(
              nil,
              record,
              field_settings,
              settings,
              context,
              options
            )

          {_,
           Noizu.Entity.Meta.Field.field_settings(name: _name, type: {:ecto, _}) = field_settings} ->
            Noizu.Entity.Store.Ecto.Entity.FieldProtocol.field_from_record(
              nil,
              record,
              field_settings,
              settings,
              context,
              options
            )

          {_, Noizu.Entity.Meta.Field.field_settings(name: _name, type: type) = field_settings} ->
            {:ok, stub} = apply(type, :stub, [])

            Noizu.Entity.Store.Ecto.Entity.FieldProtocol.field_from_record(
              # used for matching
              stub,
              record,
              field_settings,
              settings,
              context,
              options
            )
        end)
        |> List.flatten()
        |> Enum.map(fn
          {:ok, v} -> v
          _ -> nil
        end)
        |> Enum.filter(& &1)

      entity = struct(kind, fields)
      {:ok, entity}
    end

    defmacro __using__(_) do
      quote do
        @behaviour Noizu.Entity.Store.Ecto.EntityProtocol.Behaviour
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

        defoverridable persist: 5,
                       as_record: 4,
                       fetch_as_entity: 4,
                       as_entity: 5,
                       delete_record: 4,
                       from_record: 4,
                       merge_from_record: 5
      end
    end
  end
end
