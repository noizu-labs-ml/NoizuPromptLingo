# -------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.ElixirCore.ErpTest do
  use ExUnit.Case, async: false

  require Logger

  @tag :lib
  @tag :erp
  test "tuple_to_entity" do
    assert Noizu.ERP.entity({:ref, Noizu.ElixirCore.CallerEntity, :system}) ==
             %Noizu.ElixirCore.CallerEntity{identifier: :system}
  end

  @tag :lib
  @tag :erp
  test "tuple_to_entity_ok" do
    assert Noizu.ERP.entity_ok({:ref, Noizu.ElixirCore.CallerEntity, :system}) ==
             {:ok, %Noizu.ElixirCore.CallerEntity{identifier: :system}}
  end
end
