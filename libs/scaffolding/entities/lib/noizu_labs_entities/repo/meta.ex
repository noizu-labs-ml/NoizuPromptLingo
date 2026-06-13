# -------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2023 Noizu Labs Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.Repo.Meta do
  @moduledoc """
  Logic for driving entity repos.
  """
  require Noizu.Entity.Meta.Persistence
  require Noizu.Entity.Meta.Field
  require Noizu.Entity.Meta.Identifier
  # import Noizu.Core.Helpers

  @erp_type_handlers %{
    uuid: Noizu.Entity.Meta.UUIDIdentifier,
    integer: Noizu.Entity.Meta.IntegerIdentifier,
    atom: Noizu.Entity.Meta.AtomIdentifier,
    ref: Noizu.Entity.Meta.RefIdentifier,
    dual_ref: Noizu.Entity.Meta.DualRefIdentifier
  }

  # -------------------
  # create/3
  # -------------------
  def create(%Ecto.Changeset{} = changeset, context, options) do
    if changeset.valid? do
      Enum.reduce(changeset.changes, changeset.data, fn {field, value}, acc ->
        put_in(acc, [Access.key(field)], value)
      end)
      |> create(context, options)
    else
      {:error, changeset.errors}
    end
  end

  def create(entity, context, options) do
    with repo <- Noizu.Entity.Meta.repo(entity),
         {:ok, entity} <- apply(repo, :__before_create__, [entity, context, options]),
         {:ok, entity} <- apply(repo, :__do_create__, [entity, context, options]),
         {:ok, entity} <- apply(repo, :__after_create__, [entity, context, options]) do
      {:ok, entity}
    end
  end

  # -------------------
  # update/3
  # -------------------
  def update(%Ecto.Changeset{} = changeset, context, options) do
    if changeset.valid? do
      Enum.reduce(changeset.changes, changeset.data, fn {field, value}, acc ->
        put_in(acc, [Access.key(field)], value)
      end)
      |> update(context, options)
    else
      {:error, changeset.errors}
    end
  end

  def update(entity, context, options) do
    with repo <- Noizu.Entity.Meta.repo(entity),
         {:ok, entity} <- apply(repo, :__before_update__, [entity, context, options]),
         {:ok, entity} <- apply(repo, :__do_update__, [entity, context, options]),
         {:ok, entity} <- apply(repo, :__after_update__, [entity, context, options]) do
      {:ok, entity}
    end
  end

  # -------------------
  # get/3
  # -------------------
  def get(entity, context, options) do
    with repo <- Noizu.Entity.Meta.repo(entity),
         {:ok, entity} <- apply(repo, :__before_get__, [entity, context, options]),
         {:ok, entity} <- apply(repo, :__do_get__, [entity, context, options]),
         {:ok, entity} <- apply(repo, :__after_get__, [entity, context, options]) do
      {:ok, entity}
    end
  end

  # -------------------
  # delete/3
  # -------------------
  def delete(entity, context, options) do
    with repo <- Noizu.Entity.Meta.repo(entity),
         {:ok, entity} <- apply(repo, :__before_delete__, [entity, context, options]),
         {:ok, entity} <- apply(repo, :__do_delete__, [entity, context, options]),
         {:ok, entity} <- apply(repo, :__after_delete__, [entity, context, options]) do
      {:ok, entity}
    end
  end
  
  defp __before_create__generate_id(entity, context, options)
  defp __before_create__generate_id(entity, _, _) do
    cond do
      entity.id ->
        {:ok, entity}

      :else ->
        with {:ok, {id, index}} <-
               Noizu.Entity.UID.generate(Noizu.Entity.Meta.repo(entity), node()),
             {field, Noizu.Entity.Meta.Identifier.id_settings(type: id_type)} <-
               Noizu.Entity.Meta.id(entity),
             handler <- @erp_type_handlers[id_type] || id_type,
             generated_id <- handler.format_id(entity, id, index) do
          {:ok, put_in(entity, [Access.key(field)], generated_id)}
        end
    end
  end

  defp __before_create__type({:ok, entity}, context, options) do
    entity =
      Noizu.Entity.Meta.fields(entity)
      |> Enum.map(fn
        {_, Noizu.Entity.Meta.Field.field_settings(type: nil)} ->
          nil

        {_, Noizu.Entity.Meta.Field.field_settings(type: {:ecto, _})} ->
          nil

        {field, Noizu.Entity.Meta.Field.field_settings(type: type) = field_settings} ->
          with {:ok, update} <-
                 apply(type, :type__before_create, [
                   get_in(entity, [Access.key(field)]),
                   field_settings,
                   context,
                   options
                 ]) do
            {field, update}
          else
            _ -> nil
          end
      end)
      |> Enum.filter(& &1)
      |> Enum.reduce(entity, fn {field, update}, acc -> Map.put(acc, field, update) end)

    {:ok, entity}
  end

  defp __before_create__type(v, _, _), do: v
  # -------------------
  # __before_create__3
  # -------------------
  def __before_create__(entity, context, options) do
    entity
    |> __before_create__generate_id(context, options)
    |> __before_create__type(context, options)
  end

  # -------------------
  #
  # -------------------
  def __do_create__(entity, context, options) do
    Noizu.Entity.Meta.persistence(entity)
    |> Enum.map(fn settings ->
      Noizu.Entity.Meta.Persistence.persistence_settings(type: type) = settings
      protocol = Module.concat([type, EntityProtocol])

      with {:ok, record} <- apply(protocol, :as_record, [entity, settings, context, options]) do
        apply(protocol, :persist, [record, :create, settings, context, options])
      end
    end)

    {:ok, entity}
  end

  # -------------------
  #
  # -------------------
  def __after_create__(entity, _context, _options) do
    {:ok, entity}
  end

  defp __before_update__type({:ok, entity}, context, options) do
    entity =
      Noizu.Entity.Meta.fields(entity)
      |> Enum.map(fn
        {_, Noizu.Entity.Meta.Field.field_settings(type: nil)} ->
          nil

        {_, Noizu.Entity.Meta.Field.field_settings(type: {:ecto, _})} ->
          nil

        {field, Noizu.Entity.Meta.Field.field_settings(type: type) = field_settings} ->
          with {:ok, update} <-
                 apply(type, :type__before_update, [
                   get_in(entity, [Access.key(field)]),
                   field_settings,
                   context,
                   options
                 ]) do
            {field, update}
          else
            _ -> nil
          end
      end)
      |> Enum.filter(& &1)
      |> Enum.reduce(entity, fn {field, update}, acc -> Map.put(acc, field, update) end)

    {:ok, entity}
  end

  defp __before_update__type(v, _, _), do: v
  # -------------------
  #
  # -------------------
  def __before_update__(entity, context, options) do
    cond do
      entity.id ->
        {:ok, entity}

      :else ->
        {:error, :id_required}
    end
    |> __before_update__type(context, options)
  end

  # -------------------
  #
  # -------------------
  def __do_update__(entity, context, options) do
    Noizu.Entity.Meta.persistence(entity)
    |> Enum.map(fn settings ->
      Noizu.Entity.Meta.Persistence.persistence_settings(type: type) = settings
      protocol = Module.concat([type, EntityProtocol])

      with {:ok, record} <- apply(protocol, :as_record, [entity, settings, context, options]) do
        apply(protocol, :persist, [record, :update, settings, context, options])
      end
    end)

    {:ok, entity}
  end

  # -------------------
  #
  # -------------------
  def __after_update__(entity, _context, _options) do
    {:ok, entity}
  end

  # -------------------
  #
  # -------------------
  def __before_get__(entity, _context, _options) do
    {:ok, entity}
  end

  # -------------------
  #
  # -------------------
  def __do_get__(entity, context, options) do
    Noizu.Entity.Meta.persistence(entity)
    |> Enum.reduce_while({:error, :not_found}, fn settings, _ ->
      Noizu.Entity.Meta.Persistence.persistence_settings(type: type) = settings
      protocol = Module.concat([type, EntityProtocol])

      with {:ok, entity} <-
             apply(protocol, :fetch_as_entity, [entity, settings, context, options]) do
        {:halt, {:ok, entity}}
      else
        err -> {:cont, err}
      end
    end)
  end

  # -------------------
  #
  # -------------------
  def __after_get__(entity, _context, _options) do
    {:ok, entity}
  end

  # -------------------
  #
  # -------------------
  def __before_delete__(entity, _context, _options) do
    cond do
      entity.id -> {:ok, entity}
    end
  end

  # -------------------
  #
  # -------------------
  def __do_delete__(entity, context, options) do
    Noizu.Entity.Meta.persistence(entity.__struct__)
    |> Enum.reverse()
    |> Enum.map(fn settings ->
      Noizu.Entity.Meta.Persistence.persistence_settings(type: type) = settings
      protocol = Module.concat([type, EntityProtocol])
      apply(protocol, :delete_record, [entity, settings, context, options])
    end)

    {:ok, entity}
  end

  defp __after_delete__type(entity, context, options) do
    entity =
      Noizu.Entity.Meta.fields(entity)
      |> Enum.map(fn
        {_, Noizu.Entity.Meta.Field.field_settings(type: nil)} ->
          nil

        {_, Noizu.Entity.Meta.Field.field_settings(type: {:ecto, _})} ->
          nil

        {field, Noizu.Entity.Meta.Field.field_settings(type: type) = field_settings} ->
          with {:ok, update} <-
                 apply(type, :type__after_delete, [
                   get_in(entity, [Access.key(field)]),
                   field_settings,
                   context,
                   options
                 ]) do
            {field, update}
          else
            _ -> nil
          end
      end)
      |> Enum.filter(& &1)
      |> Enum.reduce(entity, fn {field, update}, acc -> Map.put(acc, field, update) end)

    {:ok, entity}
  end

  # -------------------
  #
  # -------------------
  def __after_delete__(entity, context, options) do
    __after_delete__type(entity, context, options)
  end
end
