# -------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2023 Noizu Labs Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.AmnesiaEntitiesTest do
  use ExUnit.Case
  require Noizu.Support.Entities.Foos.Foo
  require Noizu.Entity.Macros
  require Noizu.Entity.Meta.Identifier
  require Noizu.Entity.Meta.Field
  require Noizu.Entity.Meta.Json
  require Noizu.Entity.Meta.ACL

  @context Noizu.Context.system()

  test "smoke test" do
    {:ok, e} =
      %Noizu.Support.Entities.BizBops.BizBop{
        title2: "Apple",
        description: "Bop",
        inserted_at: DateTime.utc_now()
      }
      |> NoizuTest.EntityRepo.create(@context)

    r = NoizuEntityTestDb.BizBops.BizBopTable.read!(e.id)
    assert is_integer(r.inserted_at)
    fields = Noizu.Entity.Meta.fields(e)
    Noizu.Entity.Meta.Field.field_settings(options: o) = fields[:title2]
    assert o == [auto: false]
  end
end
