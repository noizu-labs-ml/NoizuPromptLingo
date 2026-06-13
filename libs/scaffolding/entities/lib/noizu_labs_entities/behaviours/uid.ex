# -------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2023 Noizu Labs Inc. All rights reserved.
# -------------------------------------------------------------------------------
defmodule Noizu.Entity.UID do
  @moduledoc """
  Wrapper around UUID generator: to allow custom uuid generator logic.
  """
  @handler Application.compile_env(:noizu_labs_entities, :uid_provider, Noizu.Entity.UID.Stub)
  @callback generate(any, any) :: any
  @callback ref(any) :: {:ok, any} | {:error, any}
  def generate(r, n), do: apply(@handler, :generate, [r, n])
  def ref(id), do: apply(@handler, :ref, [id])
end

defmodule Noizu.Entity.UID.Stub do
  @moduledoc false
  def generate(_, _), do: {:ok, {:os.system_time(:millisecond) - 1_683_495_051_937, 0}}
  def ref(_), do: {:error, {:unsupported, __MODULE__, :ref}}
end
