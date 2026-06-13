# -------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2023 Noizu Labs Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.Repo do
  @moduledoc """
  Load def_repo context.
  """

  @callback __noizu_meta__() :: map()

  defmacro __using__(_options \\ nil) do
    quote do
      require Noizu.Repo.Macros

      import Noizu.Repo.Macros,
        only: [
          {:def_repo, 0},
          {:def_repo, 1},
          {:jason_repo_encoder, 0},
          {:jason_repo_encoder, 1}
        ]

      import Noizu.Core.Helpers
      import NoizuLabs.Entities.Helpers
    end
  end
end
