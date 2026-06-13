# -------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2025 Noizu Labs Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.FieldProtocolTest do
  use ExUnit.Case,
    async: true

  require Noizu.Support.Entities.DerivedFields.DerivedFieldEntity
  require Noizu.Entity.Macros
  require Noizu.Entity.Meta.Identifier
  require Noizu.Entity.Meta.Field
  require Noizu.Entity.Meta.Json
  require Noizu.Entity.Meta.ACL
  alias Noizu.Support.Entities.DerivedFields
  alias Noizu.Support.Entities.DerivedFields.DerivedFieldEntity

  alias Noizu.Support.Entities.NestedFields.NestedField

  @context Noizu.Context.system()

  @tag :wip
  test "smoke test" do
    {:ok, nested_a} =
      %NestedField{title: "henry"}
      |> NoizuTest.EntityRepo.create(@context)

    {:ok, nested_b} =
      %NestedField{title: "jane"}
      |> NoizuTest.EntityRepo.create(@context)

    {:ok, nested_c} =
      %NestedField{title: "bowie"}
      |> NoizuTest.EntityRepo.create(@context)

    {:ok, e} =
      %DerivedFieldEntity{
        base_field_a: "anna",
        base_field_b: "bob",
        nested_field: nested_a,
        unpacked_nested_field: nested_b,
        unpacked_nested_field_by_ref: nested_c
      }
      |> NoizuTest.EntityRepo.create(@context)

    amnesia_record = NoizuEntityTestDb.DerivedFields.DerivedFieldsTable.read!(e.id)

    {:ok, entity_from_repo} = DerivedFields.get(e.id, @context, [])

    {:ok, nested_a_ref} = Noizu.EntityReference.Protocol.ref(nested_a)
    {:ok, nested_b_ref} = Noizu.EntityReference.Protocol.ref(nested_b)
    {:ok, nested_c_ref} = Noizu.EntityReference.Protocol.ref(nested_c)
    assert entity_from_repo.nested_field == nested_a_ref
    assert entity_from_repo.unpacked_nested_field.id == nested_b.id
    assert entity_from_repo.unpacked_nested_field_by_ref.id == nested_c.id
    assert amnesia_record.entity.nested_field == nested_a_ref
    assert amnesia_record.entity.unpacked_nested_field == nested_b_ref
    assert amnesia_record.entity.unpacked_nested_field_by_ref == nested_c_ref
  end
end
