#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.Scaffolding.RepoV2Test do
  use ExUnit.Case
  use Amnesia
  use  Noizu.Database.Scaffolding.Test.Fixture.FooV2Table

  alias Noizu.Scaffolding.Test.Fixture.FooV2Entity
  alias Noizu.Scaffolding.Test.Fixture.FooV2Repo
  alias Noizu.Database.Scaffolding.Test.Fixture.FooV2Table
  alias Noizu.ElixirCore.CallingContext

  setup do
    FooV2Table.clear
  end

  test "Repo Options and Entity Type" do
    assert FooV2Repo.entity() == FooV2Entity
    options = FooV2Repo.options()
    assert options.audit_level == :silent
    assert options.sequencer == FooV2Entity
  end

  test "Create Entity" do
    context = CallingContext.system()
    entity = %FooV2Entity{content: :hello} |> FooV2Repo.create!(context)
    assert entity.identifier != nil
  end

  test "Create, and Update" do
    context = CallingContext.system()
    entity = %FooV2Entity{content: :hello} |> FooV2Repo.create!(context)
    entity = %FooV2Entity{entity| content: :goodbye}  |> FooV2Repo.update!(context)
    assert entity.content == :goodbye
  end

  test "Create, Update, Get" do
    context = CallingContext.system()
    original_entity = %FooV2Entity{content: :hello} |> FooV2Repo.create!(context)
    updated_entity = %FooV2Entity{original_entity| content: :goodbye}  |> FooV2Repo.update!(context)
    fetched_entity = FooV2Repo.get!(updated_entity.identifier, context)
    assert fetched_entity.content == :goodbye
    assert fetched_entity.identifier == original_entity.identifier
  end

  test "Create, Update, Get, Delete, Get" do
    context = CallingContext.system()
    original_entity = %FooV2Entity{content: :hello} |> FooV2Repo.create!(context)
    updated_entity = %FooV2Entity{original_entity| content: :goodbye}  |> FooV2Repo.update!(context)
    fetched_entity = FooV2Repo.get!(updated_entity.identifier, context)
    FooV2Repo.delete!(fetched_entity, context)
    no_entity = FooV2Repo.get!(fetched_entity.identifier, context)
    assert no_entity == nil
  end

  test "Noizu.ERP.ref(entity)" do
    context = CallingContext.system()
    entity = %FooV2Entity{content: :hello} |> FooV2Repo.create!(context)
    ref = Noizu.ERP.ref(entity)
    assert ref == {:ref, FooV2Entity, entity.identifier}
  end


  test "Noizu.ERP.ref_ok(entity)" do
    context = CallingContext.system()
    entity = %FooV2Entity{content: :hello} |> FooV2Repo.create!(context)
    {:ok, ref} = Noizu.ERP.ref_ok(entity)
    assert ref == {:ref, FooV2Entity, entity.identifier}
  end

  test "Noizu.ERP.ref(record)" do
    context = CallingContext.system()
    entity = %FooV2Entity{content: :hello} |> FooV2Repo.create!(context)
    record = FooV2Entity.as_record(entity)
    ref = Noizu.ERP.ref(record)
    assert ref == {:ref, FooV2Entity, entity.identifier}
  end

  test "FooV2Entity.ref(sref)" do
    # note we can't test Noizu.ERP.ref(sref) directly as implementor must provide.
    context = CallingContext.system()
    entity = %FooV2Entity{content: :hello} |> FooV2Repo.create!(context)
    sref = "ref.foo-v2-test.#{entity.identifier}"
    ref = FooV2Entity.ref(sref)
    assert ref == {:ref, FooV2Entity, entity.identifier}
  end

  test "Noizu.ERP.entity!(ref)" do
    context = CallingContext.system()
    entity = %FooV2Entity{content: :hello} |> FooV2Repo.create!(context)
    ref = FooV2Entity.ref(entity.identifier)
    unboxed_entity = Noizu.ERP.entity!(ref)
    assert unboxed_entity == entity
  end

  test "Noizu.ERP.entity!(record)" do
    context = CallingContext.system()
    entity = %FooV2Entity{content: :hello} |> FooV2Repo.create!(context)
    record = FooV2Entity.as_record(entity)
    unboxed_entity = Noizu.ERP.entity!(record)
    assert unboxed_entity == entity
  end

  test "FooV2Entity.entity!(entity)" do
    # note we can't test Noizu.ERP.ref(sref) directly as implementor must provide.
    context = CallingContext.system()
    entity = %FooV2Entity{content: :hello} |> FooV2Repo.create!(context)
    unboxed_entity = Noizu.ERP.entity!(entity)
    assert unboxed_entity == entity
  end

  test "Noizu.ERP.record!(ref)" do
    context = CallingContext.system()
    entity = %FooV2Entity{content: :hello} |> FooV2Repo.create!(context)
    record = FooV2Entity.record(entity)
    ref = FooV2Entity.ref(entity.identifier)
    unboxed_record = Noizu.ERP.record!(ref)
    assert unboxed_record == record
  end

  test "Noizu.ERP.record!(record)" do
    context = CallingContext.system()
    entity = %FooV2Entity{content: :hello} |> FooV2Repo.create!(context)
    record = FooV2Entity.as_record(entity)
    unboxed_record = Noizu.ERP.record!(record)
    assert unboxed_record == record
  end

  test "FooV2Entity.record!(entity)" do
    # note we can't test Noizu.ERP.ref(sref) directly as implementor must provide.
    context = CallingContext.system()
    entity = %FooV2Entity{content: :hello} |> FooV2Repo.create!(context)
    record = FooV2Entity.record(entity)
    unboxed_record = Noizu.ERP.record!(entity)
    assert unboxed_record == record
  end

  test "Noizu.ERP.sref(ref)" do
    context = CallingContext.system()
    entity = %FooV2Entity{content: :hello} |> FooV2Repo.create!(context)
    ref = FooV2Entity.ref(entity.identifier)
    sref = Noizu.ERP.sref(ref)
    expected_sref = "ref.foo-v2-test.#{entity.identifier}"
    assert sref == expected_sref
  end

  test "Noizu.ERP.sref(entity)" do
    context = CallingContext.system()
    entity = %FooV2Entity{content: :hello} |> FooV2Repo.create!(context)
    sref = Noizu.ERP.sref(entity)
    expected_sref = "ref.foo-v2-test.#{entity.identifier}"
    assert sref == expected_sref
  end

  test "Noizu.ERP.sref(record)" do
    context = CallingContext.system()
    entity = %FooV2Entity{content: :hello} |> FooV2Repo.create!(context)
    record = FooV2Entity.as_record(entity)
    sref = Noizu.ERP.sref(record)
    expected_sref = "ref.foo-v2-test.#{entity.identifier}"
    assert sref == expected_sref
  end

  test "Noizu.ERP.ref([tuple])" do
    context = CallingContext.system()
    entity = %FooV2Entity{content: :hello} |> FooV2Repo.create!(context)
    entity_two = %FooV2Entity{entity| identifier: entity.identifier + 1} |> FooV2Repo.create!(context)
    entity_three = %FooV2Entity{entity| identifier: entity.identifier + 2} |> FooV2Repo.create!(context)

    refs = Noizu.ERP.ref([FooV2Entity.ref(entity), FooV2Entity.record(entity_two), entity_three])
    assert refs == [FooV2Entity.ref(entity), FooV2Entity.ref(entity_two), FooV2Entity.ref(entity_three)]
  end

  test "Noizu.ERP.entity([tuple])" do
    context = CallingContext.system()
    entity = %FooV2Entity{content: :hello} |> FooV2Repo.create!(context)
    entity_two = %FooV2Entity{entity| identifier: entity.identifier + 1} |> FooV2Repo.create!(context)
    entity_three = %FooV2Entity{entity| identifier: entity.identifier + 2} |> FooV2Repo.create!(context)

    refs = Noizu.ERP.ref([FooV2Entity.ref(entity), FooV2Entity.record(entity_two), entity_three])
    entities = Noizu.ERP.entity!(refs)
    assert entities == [entity, entity_two, entity_three]
  end


  test "FooV2Repo.list!" do
    context = CallingContext.system()
    entity = %FooV2Entity{content: :hello} |> FooV2Repo.create!(context)
    entity_two = %FooV2Entity{entity| identifier: entity.identifier + 1} |> FooV2Repo.create!(context)
    entity_three = %FooV2Entity{entity| identifier: entity.identifier + 2} |> FooV2Repo.create!(context)

    _r = Amnesia.Fragment.transaction do
      Noizu.Database.Scaffolding.Test.Fixture.FooV2Table.where true == true
    end

    entities = FooV2Repo.list!(context) |> Enum.sort(&(&1.identifier <= &2.identifier))
    assert entities == [entity, entity_two, entity_three]
  end

end
