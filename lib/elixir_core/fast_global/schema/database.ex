# -------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
# -------------------------------------------------------------------------------

use Amnesia

defdatabase Noizu.FastGlobal.Database do
  @moduledoc """
  The `Noizu.FastGlobal.Database` module defines the schema for the FastGlobal Database.

  This module uses the `Amnesia` library, a simple and powerful library for working with Mnesia, the Erlang's built-in distributed real-time database.

  # Tables
  The database consists of the following tables:
  - `Settings`: stores the settings for the FastGlobal database.

  # Code Review
  The code is simple and straightforward, following the conventions of the `Amnesia` library. The schema definition is clear, and the use of the `deftable` macro makes it easy to understand the structure of the database tables. The `Settings` table is well-defined, with clearly named fields. The use of the `type: :set` option indicates that each entry in the table should be unique. However, it should be noted that no indexes are defined for the table, which may impact performance if the table grows large and queries are performed on non-key fields. The `@type` specification for the `Settings` struct is a good practice, as it provides type checking and documentation benefits.
  """

  # -----------------------------------------------------------------------------
  # @Settings
  # -----------------------------------------------------------------------------
  deftable Settings, [:identifier, :value], type: :set, index: [] do
    @moduledoc """
    This module defines the `Settings` table for the `Noizu.FastGlobal.Database`.

    The `Settings` table has the following structure:

    - `identifier`: a field of any type that serves as the identifier for the setting.
    - `value`: a field of any type that holds the value of the setting.

    The table is of type `:set`, which means each entry in the table is unique. There are no indexes defined for this table.
    """
    @type t :: %Settings{
            identifier: any,
            value: any
          }
  end

  # end deftable Email.Templates
end

# end defdatabase Noizu.FastGlobal.Database
