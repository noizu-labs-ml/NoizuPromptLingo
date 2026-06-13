# -------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2025 Noizu Labs Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.Entity.Meta.Persistence do
  @moduledoc """
  Persistence Settings Metadata Record.
  """

  require Record
  Record.defrecord(:persistence_settings, table: :auto, kind: nil, store: nil, type: nil)

  @typedoc """
  Persistence Table
  """
  @type persistence_table :: term

  @typedoc """
  Persistence Kind: not currently used.
  """
  @type persistence_kind :: term

  @typedoc """
  Persistence Store: e.g. amnesia database/ecto repo/redis connection
  """
  @type persistence_store :: term

  @typedoc """
  Persistence Type: e.g. Noizu.Entity.Store.Ecto
  """
  @type persistence_type :: term

  @typedoc """
  Persistence Metadata entry
  """
  @type persistence_settings ::
          record(
            :persistence_settings,
            table: persistence_table,
            kind: persistence_kind,
            store: persistence_store,
            type: persistence_type
          )

  # ===========================================================================
  # by_*
  # ===========================================================================
  @doc """
  Returns entity persistence metadata for table
  """
  def by_table(module, table) do
    Enum.find_value(
      Noizu.Entity.Meta.persistence(module),
      fn
        settings = persistence_settings(table: ^table) -> {:ok, settings}
        _ -> nil
      end
    ) || {:error, :not_found}
  end

  @doc """
  Returns entity persistence metadata by type (e.g. Noizu.Entity.Store.Ecto)
  """
  def by_type(module, type) do
    Enum.find_value(
      Noizu.Entity.Meta.persistence(module),
      fn
        settings = persistence_settings(type: ^type) -> {:ok, settings}
        _ -> nil
      end
    ) || {:error, :not_found}
  end

  @doc """
  Returns entity persistence metadata matching storage type (E.g. Mnesua Databse, Repo, etc.)
  """
  def by_store(module, store) do
    Enum.find_value(
      Noizu.Entity.Meta.persistence(module),
      fn
        settings = persistence_settings(store: ^store) -> {:ok, settings}
        _ -> nil
      end
    ) || {:error, :not_found}
  end

  # ===========================================================================
  # ecto_store
  # ===========================================================================

  @doc """
  Short hand for Ecto persistence layer.
  """
  def ecto_store(table, store) do
    persistence_settings(table: table, store: store, type: Noizu.Entity.Store.Ecto)
  end

  @doc """
  Short hand for mnesia persistence layer.
  """
  def mnesia_store(table, store) do
    persistence_settings(table: table, store: store, type: Noizu.Entity.Store.Mnesia)
  end

  @doc """
  Short hand for amnesia persistence layer.
  """
  def amnesia_store(table, store) do
    persistence_settings(table: table, store: store, type: Noizu.Entity.Store.Amnesia)
  end

  @doc """
  Short hand for redis persistence layer.
  """
  def redis_store(table, store) do
    persistence_settings(table: table, store: store, type: Noizu.Entity.Store.Redis)
  end

  @doc """
  Short hand for dummy persistence layer.
  """
  def dummy_store(table, store) do
    persistence_settings(table: table, store: store, type: Noizu.Entity.Store.Dummy)
  end
end
