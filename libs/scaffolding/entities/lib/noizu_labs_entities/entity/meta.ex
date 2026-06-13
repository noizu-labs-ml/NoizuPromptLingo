# -------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2023 Noizu Labs Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.Entity.Meta do
  @moduledoc """
  Module for checking and encoding entity metadata.
  """

  require Noizu.EntityReference.Records
  alias Noizu.EntityReference.Records, as: R

  @callback meta() :: []
  @callback fields() :: []
  @callback id() :: []
  @callback persistence() :: []
  @callback json() :: []
  @callback json(template :: atom) :: []

  # ---------------
  # meta/1
  # ---------------
  def meta(%{__struct__: m}), do: meta(m)
  def meta(R.ref(module: m)), do: meta(m)

  def meta(m) when is_atom(m) do
    apply(m, :__noizu_meta__, [])
  rescue
    _ -> nil
  end

  def meta(m),
    do:
      raise(Noizu.EntityReference.ProtocolException,
        ref: m,
        message: "Invalid Entity",
        error: :invalid
      )

  # ---------------
  # sref/1
  # ---------------
  @doc """
  Entity Sref meta data.
  """
  def sref(m), do: meta(m)[:sref]

  # ---------------
  # persistence/1
  # ---------------
  @doc """
  Entity Persistence meta data.
  """
  def persistence(m), do: meta(m)[:persistence]

  # ---------------
  # repo/1
  # ---------------
  @doc """
  Entity Repo meta data.
  """
  def repo(m), do: meta(m)[:repo]

  # ---------------
  # id/1
  # ---------------
  @doc """
  Entity id meta data.
  """
  def id(m), do: meta(m)[:id]

  # ---------------
  # field/1
  # ---------------
  @doc """
  Entity field meta data.
  """
  def fields(m), do: meta(m)[:fields]

  # ---------------
  # json/1
  # ---------------
  @doc """
  Entity json meta data.
  """
  def json(m), do: meta(m)[:json]

  # ---------------
  # json/2
  # ---------------
  @doc """
  Entity json for json_format type meta data.
  """
  def json(m, s) do
    meta = meta(m)
    json = meta[:json]
    json[s] || json[:default]
  end

  # ---------------
  # acl/1
  # ---------------
  @doc """
  Entity ACL meta data.
  """
  def acl(m), do: meta(m)[:acl]

  # ---------------
  # __using__/1
  # ---------------
  defmacro __using__(_options \\ nil) do
    quote do
      require Noizu.Entity.Meta.Identifier
      require Noizu.Entity.Meta.Field
      require Noizu.Entity.Meta.Json
      alias Noizu.Entity.Meta
    end
  end
end
