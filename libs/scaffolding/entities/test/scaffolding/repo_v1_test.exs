#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.Scaffolding.RepoV1Test do
  use ExUnit.Case
  use Amnesia
  use  Noizu.Database.Scaffolding.Test.Fixture.FooTable


  alias Noizu.Scaffolding.Test.Fixture.FooRepo
  alias Noizu.Scaffolding.Test.Fixture.FooEntity
  alias Noizu.Database.Scaffolding.Test.Fixture.FooTable
  alias Noizu.ElixirCore.CallingContext

  setup do
    FooTable.clear
  end

  test "Repo Options and Entity Type" do
    assert FooRepo.entity() == FooEntity
    options = FooRepo.options()
    assert options.audit_level == :silent
    assert options.sequencer == FooEntity
  end

  test "Create Entity" do
    context = CallingContext.system()
    entity = %FooEntity{content: :hello} |> FooRepo.create!(context)
    assert entity.identifier != nil
  end

  test "Create, and Update" do
    context = CallingContext.system()
    entity = %FooEntity{content: :hello} |> FooRepo.create!(context)
    entity = %FooEntity{entity| content: :goodbye}  |> FooRepo.update!(context)
    assert entity.content == :goodbye
  end

  test "Create, Update, Get" do
    context = CallingContext.system()
    original_entity = %FooEntity{content: :hello} |> FooRepo.create!(context)
    updated_entity = %FooEntity{original_entity| content: :goodbye}  |> FooRepo.update!(context)
    fetched_entity = FooRepo.get!(updated_entity.identifier, context)
    assert fetched_entity.content == :goodbye
    assert fetched_entity.identifier == original_entity.identifier
  end

  test "Create, Update, Get, Delete, Get" do
    context = CallingContext.system()
    original_entity = %FooEntity{content: :hello} |> FooRepo.create!(context)
    updated_entity = %FooEntity{original_entity| content: :goodbye}  |> FooRepo.update!(context)
    fetched_entity = FooRepo.get!(updated_entity.identifier, context)
    FooRepo.delete!(fetched_entity, context)
    no_entity = FooRepo.get!(fetched_entity.identifier, context)
    assert no_entity == nil
  end

  test "Noizu.ERP.ref(entity)" do
    context = CallingContext.system()
    entity = %FooEntity{content: :hello} |> FooRepo.create!(context)
    ref = Noizu.ERP.ref(entity)
    assert ref == {:ref, FooEntity, entity.identifier}
  end

  test "Noizu.ERP.ref(record)" do
    context = CallingContext.system()
    entity = %FooEntity{content: :hello} |> FooRepo.create!(context)
    record = FooEntity.as_record(entity)
    ref = Noizu.ERP.ref(record)
    assert ref == {:ref, FooEntity, entity.identifier}
  end

  test "FooEntity.ref(sref)" do
    # note we can't test Noizu.ERP.ref(sref) directly as implementor must provide.
    context = CallingContext.system()
    entity = %FooEntity{content: :hello} |> FooRepo.create!(context)
    sref = "ref.foo-test.#{entity.identifier}"
    ref = FooEntity.ref(sref)
    assert ref == {:ref, FooEntity, entity.identifier}
  end

  test "Noizu.ERP.entity!(ref)" do
    context = CallingContext.system()
    entity = %FooEntity{content: :hello} |> FooRepo.create!(context)
    ref = FooEntity.ref(entity.identifier)
    unboxed_entity = Noizu.ERP.entity!(ref)
    assert unboxed_entity == entity
  end

  test "Noizu.ERP.entity!(record)" do
    context = CallingContext.system()
    entity = %FooEntity{content: :hello} |> FooRepo.create!(context)
    record = FooEntity.as_record(entity)
    unboxed_entity = Noizu.ERP.entity!(record)
    assert unboxed_entity == entity
  end

  test "FooEntity.entity!(entity)" do
    # note we can't test Noizu.ERP.ref(sref) directly as implementor must provide.
    context = CallingContext.system()
    entity = %FooEntity{content: :hello} |> FooRepo.create!(context)
    unboxed_entity = Noizu.ERP.entity!(entity)
    assert unboxed_entity == entity
  end


  test "FooEntity.entity_ok!(entity)" do
    # note we can't test Noizu.ERP.ref(sref) directly as implementor must provide.
    context = CallingContext.system()
    entity = %FooEntity{content: :hello} |> FooRepo.create!(context)
    {:ok, unboxed_entity} = Noizu.ERP.entity_ok!(entity)
    assert unboxed_entity == entity
  end

  test "Noizu.ERP.record!(ref)" do
    context = CallingContext.system()
    entity = %FooEntity{content: :hello} |> FooRepo.create!(context)
    record = FooEntity.record(entity)
    ref = FooEntity.ref(entity.identifier)
    unboxed_record = Noizu.ERP.record!(ref)
    assert unboxed_record == record
  end

  test "Noizu.ERP.record!(record)" do
    context = CallingContext.system()
    entity = %FooEntity{content: :hello} |> FooRepo.create!(context)
    record = FooEntity.as_record(entity)
    unboxed_record = Noizu.ERP.record!(record)
    assert unboxed_record == record
  end

  test "FooEntity.record!(entity)" do
    # note we can't test Noizu.ERP.ref(sref) directly as implementor must provide.
    context = CallingContext.system()
    entity = %FooEntity{content: :hello} |> FooRepo.create!(context)
    record = FooEntity.record(entity)
    unboxed_record = Noizu.ERP.record!(entity)
    assert unboxed_record == record
  end

  test "Noizu.ERP.sref(ref)" do
    context = CallingContext.system()
    entity = %FooEntity{content: :hello} |> FooRepo.create!(context)
    ref = FooEntity.ref(entity.identifier)
    sref = Noizu.ERP.sref(ref)
    expected_sref = "ref.foo-test.#{entity.identifier}"
    assert sref == expected_sref
  end

  test "Noizu.ERP.sref(entity)" do
    context = CallingContext.system()
    entity = %FooEntity{content: :hello} |> FooRepo.create!(context)
    sref = Noizu.ERP.sref(entity)
    expected_sref = "ref.foo-test.#{entity.identifier}"
    assert sref == expected_sref
  end

  test "Noizu.ERP.sref(record)" do
    context = CallingContext.system()
    entity = %FooEntity{content: :hello} |> FooRepo.create!(context)
    record = FooEntity.as_record(entity)
    sref = Noizu.ERP.sref(record)
    expected_sref = "ref.foo-test.#{entity.identifier}"
    assert sref == expected_sref
  end

  test "Noizu.ERP.ref([tuple])" do
    context = CallingContext.system()
    entity = %FooEntity{content: :hello} |> FooRepo.create!(context)
    entity_two = %FooEntity{entity| identifier: entity.identifier + 1} |> FooRepo.create!(context)
    entity_three = %FooEntity{entity| identifier: entity.identifier + 2} |> FooRepo.create!(context)

    refs = Noizu.ERP.ref([FooEntity.ref(entity), FooEntity.record(entity_two), entity_three])
    assert refs == [FooEntity.ref(entity), FooEntity.ref(entity_two), FooEntity.ref(entity_three)]
  end

  test "Noizu.ERP.entity([tuple])" do
    context = CallingContext.system()
    entity = %FooEntity{content: :hello} |> FooRepo.create!(context)
    entity_two = %FooEntity{entity| identifier: entity.identifier + 1} |> FooRepo.create!(context)
    entity_three = %FooEntity{entity| identifier: entity.identifier + 2} |> FooRepo.create!(context)

    refs = Noizu.ERP.ref([FooEntity.ref(entity), FooEntity.record(entity_two), entity_three])
    entities = Noizu.ERP.entity!(refs)
    assert entities == [entity, entity_two, entity_three]
  end


  test "FooRepo.list!" do
    context = CallingContext.system()
    entity = %FooEntity{content: :hello} |> FooRepo.create!(context)
    entity_two = %FooEntity{entity| identifier: entity.identifier + 1} |> FooRepo.create!(context)
    entity_three = %FooEntity{entity| identifier: entity.identifier + 2} |> FooRepo.create!(context)

    _r = Amnesia.Fragment.transaction do
      Noizu.Database.Scaffolding.Test.Fixture.FooTable.where true == true
    end

    entities = FooRepo.list!(context) |> Enum.sort(&(&1.identifier <= &2.identifier))
    assert entities == [entity, entity_two, entity_three]
  end

end
