# -------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2025 Noizu Labs Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.Entity.Meta.Field do
  @moduledoc """
  Meta Data Record for Field Settings.
  """

  require Record

  Record.defrecord(:field_settings,
    name: nil,
    store: [],
    type: nil,
    transient: false,
    pii: false,
    default: nil,
    acl: nil,
    options: nil
  )

  @typedoc """
  Field Name
  """
  @type field_name :: term

  @typedoc """
  Field Persistence Store Settings
  """
  @type field_store :: [term]

  @typedoc """
  Field Type, used to populate changesets and perform embedded/nestd object management.

  ```elixir
  def_entity do
      id :uuid
      field :title, nil, :string # A Ecto String - so changesets specify a string field.
      field :body, nil, :string
      field :time_stamp, nil, Noizu.Entity.TimeStamp # A embedded object, changeset converts back and forth to inserted_at, updated_at, and deleted_at date time fields.
  end
  ```
  """
  @type field_type :: term

  @typedoc """
  Is field ephermal (not persisted)?
  """
  @type field_transient :: boolean

  @typedoc """
  Field PII level (Personally Identifiable Information).
  """
  @type field_pii :: boolean | term

  @typedoc """
  Field Default Value
  """
  @type field_default :: term

  @typedoc """
  Field ACL permissions
  """
  @type field_acl :: term

  @typedoc """
  Field Internal/User Options
  """
  @type field_options :: term

  @typedoc """
  Field Metadata entry
  """
  @type field_settings ::
          record(
            :field_settings,
            name: field_name,
            store: field_store,
            type: field_type,
            transient: field_transient,
            pii: field_pii,
            default: field_default,
            acl: field_acl,
            options: field_options
          )
end
