# -------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2025 Noizu Labs Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.Entities do
  @moduledoc """
  Noizu Entities are Structs with meta data for permissions, json encoding, persistence channels, cache and more.

  To use define your  entity and repo module:

  ```elixir
  defmodule MyApp.Versioned.Descriptions.Description do
    use Noizu.Entities
    
    @vsn 1.0
    @repo MyApp.Versioned.Descriptions
    @sref "versioned-description"
    @persistence ecto_store(MyApp.Schema.Versions.Descriptions.Description, MyApp.Repo)
    def_entity do
      id :uuid
      field :title, nil, :string
      field :body, nil, :string
      field :time_stamp, nil, Noizu.Entity.TimeStamp
    end
  end

  defmodule MyApp.Versioned.Descriptions do
      use Noizu.Entities
      def_repo()
  end
  ```


  """

  defmacro __using__(options \\ nil) do
    quote do
      require Logger
      require Record
      require Noizu.EntityReference.Records

      alias Noizu.Service.Types, as: M
      alias Noizu.Service.Types.Handle, as: MessageHandler
      alias Noizu.EntityReference.Records, as: R
      alias Noizu.EntityReference.Protocol, as: ERP

      use Noizu.Entity.Meta, unquote(options)

      # Register Module Attributes
      Module.register_attribute(__MODULE__, :persistence, accumulate: true)
      Module.register_attribute(__MODULE__, :cache, accumulate: true)
      Module.register_attribute(__MODULE__, :vsn, accumulate: false)
      Module.register_attribute(__MODULE__, :sref, accumulate: false)

      # Load Entity and Repo Behaviors
      use Noizu.Entity
      use Noizu.Repo
    end
  end
end
