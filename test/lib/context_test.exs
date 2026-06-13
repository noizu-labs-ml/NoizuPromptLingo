# -------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.ElixirCore.ContextTest do
  use ExUnit.Case, async: false

  require Logger

  @tag :lib
  @tag :context
  test "initialization and logger setup" do
    sut = Noizu.ElixirCore.CallingContext.system(%{})

    assert sut.caller == {:ref, Noizu.ElixirCore.CallerEntity, :system}
    Noizu.ElixirCore.CallingContext.meta_update(sut)

    meta = Logger.metadata()
    assert meta[:context_caller] == {:ref, Noizu.ElixirCore.CallerEntity, :system}
  end
end
