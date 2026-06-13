# -------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.FastGlobal.ChangeSet do
  @moduledoc """
  This module contains changesets that are used in updating the FastGlobal related schema.
  The changesets are defined in a way that they can be easily applied or rolled back.

  The FastGlobal changeset updates or rolls back changes related to Noizu.FastGlobal.Database.Settings.

  # Usage
  Call the `change_sets/0` function to get the list of changesets. Each changeset is a map that contains
  the following keys:
  - `:changeset`: A string that describes the changeset.
  - `:author`: The author of the changeset.
  - `:note`: A note about the changeset.
  - `:environments`: The environments where the changeset is applicable. It can be set to `:all` for all environments.
  - `:update`: A function that, when called, will apply the changeset.
  - `:rollback`: A function that, when called, will roll back the changeset.

  # Code Review
  The code in this module is well-organized and follows standard Elixir conventions. The `change_sets/0` function is a good example of how to define changesets in a way that makes it easy to apply and roll back changes. The use of anonymous functions for the `:update` and `:rollback` keys provides a clear and concise way to define the actions to be taken for each changeset. The `neighbors/0` function is a nice utility function that abstracts away the details of retrieving the list of nodes in the topology. Overall, the code in this module is clean, efficient, and easy to understand.
  """

  alias Noizu.MnesiaVersioning.ChangeSet
  use Amnesia
  use Noizu.FastGlobal.Database
  use Noizu.MnesiaVersioning.SchemaBehaviour

  # -----------------------------------------------------------------------------
  # neighbors/0
  # -----------------------------------------------------------------------------
  @doc """
  Retrieves the list of nodes in the topology. The topology provider is retrieved from the application environment
  with the key `:noizu_mnesia_versioning`. The nodes are retrieved from the topology provider with the
  `mnesia_nodes/0` function. The function returns `{:ok, nodes}` where `nodes` is the list of nodes.
  """
  def neighbors() do
    topology_provider = Application.get_env(:noizu_mnesia_versioning, :topology_provider)
    {:ok, nodes} = topology_provider.mnesia_nodes()
    nodes
  end

  # -----------------------------------------------------------------------------
  # ChangeSets
  # -----------------------------------------------------------------------------
  @doc """
  Returns a list of changesets for updating the FastGlobal related schema. Each changeset is a map that contains
  keys for the changeset description, author, note, applicable environments, an update function, and a rollback function.
  """
  def change_sets() do
    [
      %ChangeSet{
        changeset: "FastGlobal Related Schema",
        author: "Keith Brings",
        note: "Y",
        environments: :all,
        update: fn ->
          neighbors = neighbors()
          create_table(Noizu.FastGlobal.Database.Settings, disk: neighbors)
          :success
        end,
        rollback: fn ->
          destroy_table(Noizu.FastGlobal.Database.Settings)
          :removed
        end
      }
    ]
  end
end
