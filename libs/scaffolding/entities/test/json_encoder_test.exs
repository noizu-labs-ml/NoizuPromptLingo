# -------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2023 Noizu Labs Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.JasonEncoderTest do
  use ExUnit.Case
  require Noizu.Support.Entities.Foos.Foo
  require Noizu.Entity.Macros
  require Noizu.Entity.Meta.Identifier
  require Noizu.Entity.Meta.Field
  require Noizu.Entity.Meta.Json
  require Noizu.Entity.Meta.ACL

  @context Noizu.Context.system()

  test "Happy Path" do
    {:ok, e} =
      %Noizu.Support.Entities.BizBops.BizBop{
        title2: "Apple",
        description: "Bop",
        inserted_at: DateTime.utc_now()
      }
      |> NoizuTest.EntityRepo.create(@context)

    {:ok, json} = Jason.encode(e, user: [context: @context, options: []])

    cond do
      json ==
          "{\"id\":\"ref.biz-bop.#{ShortUUID.encode!(e.id)}\",\"inserted_at\":\"#{e.inserted_at |> DateTime.to_iso8601()}\",\"vsn\":1.0}" ->
        :ok

        assert json ==
          "{\"id\":\"ref.biz-bop.#{ShortUUID.encode!(e.id)}\",\"vsn\":1.0,\"inserted_at\":\"#{e.inserted_at |> DateTime.to_iso8601()}\"}"

      :else ->
        assert json ==
                 "{\"id\":\"ref.biz-bop.#{ShortUUID.encode!(e.id)}\",\"vsn\":1.0,\"inserted_at\":\"#{e.inserted_at |> DateTime.to_iso8601()}\"}"
    end
  end
end
