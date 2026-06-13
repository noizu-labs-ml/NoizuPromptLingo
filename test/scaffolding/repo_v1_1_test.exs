#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.Scaffolding.RepoV1_1Test do
  use ExUnit.Case
  use Amnesia
  use  Noizu.Database.Scaffolding.Test.Fixture.FooV1_1Table


  alias Noizu.Scaffolding.Test.Fixture.FooV1_1Repo
  alias Noizu.Scaffolding.Test.Fixture.FooV1_1Entity
  alias Noizu.Database.Scaffolding.Test.Fixture.FooV1_1Table
  alias Noizu.ElixirCore.CallingContext

  setup do
    FooV1_1Table.clear
  end

  @tag :"v1.1"
  test "Repo Options and Entity Type" do
    assert FooV1_1Repo.entity() == FooV1_1Entity
    options = FooV1_1Repo.options()
    assert options.audit_level == :silent
    assert options.sequencer == FooV1_1Entity
  end

  @tag :"v1.1"
  test "Create Entity" do
    context = CallingContext.system()
    entity = %FooV1_1Entity{content: :hello} |> FooV1_1Repo.create!(context)
    assert entity.identifier != nil
  end

  @tag :"v1.1"
  test "Create, and Update" do
    context = CallingContext.system()
    entity = %FooV1_1Entity{content: :hello} |> FooV1_1Repo.create!(context)
    entity = %FooV1_1Entity{entity| content: :goodbye}  |> FooV1_1Repo.update!(context)
    assert entity.content == :goodbye
  end

  @tag :"v1.1"
  test "Create, Update, Get" do
    context = CallingContext.system()
    original_entity = %FooV1_1Entity{content: :hello} |> FooV1_1Repo.create!(context)
    updated_entity = %FooV1_1Entity{original_entity| content: :goodbye}  |> FooV1_1Repo.update!(context)
    fetched_entity = FooV1_1Repo.get!(updated_entity.identifier, context)
    assert fetched_entity.content == :goodbye
    assert fetched_entity.identifier == original_entity.identifier
  end

  @tag :"v1.1"
  test "Create, Update, Get, Delete, Get" do
    context = CallingContext.system()
    original_entity = %FooV1_1Entity{content: :hello} |> FooV1_1Repo.create!(context)
    updated_entity = %FooV1_1Entity{original_entity| content: :goodbye}  |> FooV1_1Repo.update!(context)
    fetched_entity = FooV1_1Repo.get!(updated_entity.identifier, context)
    FooV1_1Repo.delete!(fetched_entity, context)
    no_entity = FooV1_1Repo.get!(fetched_entity.identifier, context)
    assert no_entity == nil
  end

  @tag :"v1.1"
  test "Noizu.ERP.ref(entity)" do
    context = CallingContext.system()
    entity = %FooV1_1Entity{content: :hello} |> FooV1_1Repo.create!(context)
    ref = Noizu.ERP.ref(entity)
    assert ref == {:ref, FooV1_1Entity, entity.identifier}
  end

  @tag :"v1.1"
  test "Noizu.ERP.ref(record)" do
    context = CallingContext.system()
    entity = %FooV1_1Entity{content: :hello} |> FooV1_1Repo.create!(context)
    record = FooV1_1Entity.as_record(entity)
    ref = Noizu.ERP.ref(record)
    assert ref == {:ref, FooV1_1Entity, entity.identifier}
  end

  @tag :"v1.1"
  test "FooV1_1Entity.ref(sref)" do
    # note we can't test Noizu.ERP.ref(sref) directly as implementor must provide.
    context = CallingContext.system()
    entity = %FooV1_1Entity{content: :hello} |> FooV1_1Repo.create!(context)
    sref = "ref.foo-v1p1-test.#{entity.identifier}"
    ref = FooV1_1Entity.ref(sref)
    assert ref == {:ref, FooV1_1Entity, entity.identifier}
  end

  @tag :"v1.1"
  test "Noizu.ERP.entity!(ref)" do
    context = CallingContext.system()
    entity = %FooV1_1Entity{content: :hello} |> FooV1_1Repo.create!(context)
    ref = FooV1_1Entity.ref(entity.identifier)
    unboxed_entity = Noizu.ERP.entity!(ref)
    assert unboxed_entity == entity
  end

  @tag :"v1.1"
  test "Noizu.ERP.entity!(record)" do
    context = CallingContext.system()
    entity = %FooV1_1Entity{content: :hello} |> FooV1_1Repo.create!(context)
    record = FooV1_1Entity.as_record(entity)
    unboxed_entity = Noizu.ERP.entity!(record)
    assert unboxed_entity == entity
  end

  @tag :"v1.1"
  test "FooV1_1Entity.entity!(entity)" do
    # note we can't test Noizu.ERP.ref(sref) directly as implementor must provide.
    context = CallingContext.system()
    entity = %FooV1_1Entity{content: :hello} |> FooV1_1Repo.create!(context)
    unboxed_entity = Noizu.ERP.entity!(entity)
    assert unboxed_entity == entity
  end

  @tag :"v1.1"
  test "Noizu.ERP.record!(ref)" do
    context = CallingContext.system()
    entity = %FooV1_1Entity{content: :hello} |> FooV1_1Repo.create!(context)
    record = FooV1_1Entity.record(entity)
    ref = FooV1_1Entity.ref(entity.identifier)
    unboxed_record = Noizu.ERP.record!(ref)
    assert unboxed_record == record
  end

  @tag :"v1.1"
  test "Noizu.ERP.record!(record)" do
    context = CallingContext.system()
    entity = %FooV1_1Entity{content: :hello} |> FooV1_1Repo.create!(context)
    record = FooV1_1Entity.as_record(entity)
    unboxed_record = Noizu.ERP.record!(record)
    assert unboxed_record == record
  end

  @tag :"v1.1"
  test "FooV1_1Entity.record!(entity)" do
    # note we can't test Noizu.ERP.ref(sref) directly as implementor must provide.
    context = CallingContext.system()
    entity = %FooV1_1Entity{content: :hello} |> FooV1_1Repo.create!(context)
    record = FooV1_1Entity.record(entity)
    unboxed_record = Noizu.ERP.record!(entity)
    assert unboxed_record == record
  end

  @tag :"v1.1"
  test "Noizu.ERP.sref(ref)" do
    context = CallingContext.system()
    entity = %FooV1_1Entity{content: :hello} |> FooV1_1Repo.create!(context)
    ref = FooV1_1Entity.ref(entity.identifier)
    sref = Noizu.ERP.sref(ref)
    expected_sref = "ref.foo-v1p1-test.#{entity.identifier}"
    assert sref == expected_sref
  end



  @tag :"v1.1"
  test "Noizu.ERP.sref_ok(ref)" do
    context = CallingContext.system()
    entity = %FooV1_1Entity{content: :hello} |> FooV1_1Repo.create!(context)
    ref = FooV1_1Entity.ref(entity.identifier)
    {:ok, sref} = Noizu.ERP.sref_ok(ref)
    expected_sref = "ref.foo-v1p1-test.#{entity.identifier}"
    assert sref == expected_sref
  end



  @tag :"v1.1"
  test "Noizu.ERP.sref(entity)" do
    context = CallingContext.system()
    entity = %FooV1_1Entity{content: :hello} |> FooV1_1Repo.create!(context)
    sref = Noizu.ERP.sref(entity)
    expected_sref = "ref.foo-v1p1-test.#{entity.identifier}"
    assert sref == expected_sref
  end

  @tag :"v1.1"
  test "Noizu.ERP.sref(record)" do
    context = CallingContext.system()
    entity = %FooV1_1Entity{content: :hello} |> FooV1_1Repo.create!(context)
    record = FooV1_1Entity.as_record(entity)
    sref = Noizu.ERP.sref(record)
    expected_sref = "ref.foo-v1p1-test.#{entity.identifier}"
    assert sref == expected_sref
  end

  @tag :"v1.1"
  test "Noizu.ERP.ref([tuple])" do
    context = CallingContext.system()
    entity = %FooV1_1Entity{content: :hello} |> FooV1_1Repo.create!(context)
    entity_two = %FooV1_1Entity{entity| identifier: entity.identifier + 1} |> FooV1_1Repo.create!(context)
    entity_three = %FooV1_1Entity{entity| identifier: entity.identifier + 2} |> FooV1_1Repo.create!(context)

    refs = Noizu.ERP.ref([FooV1_1Entity.ref(entity), FooV1_1Entity.record(entity_two), entity_three])
    assert refs == [FooV1_1Entity.ref(entity), FooV1_1Entity.ref(entity_two), FooV1_1Entity.ref(entity_three)]
  end

  @tag :"v1.1"
  test "Noizu.ERP.entity([tuple])" do
    context = CallingContext.system()
    entity = %FooV1_1Entity{content: :hello} |> FooV1_1Repo.create!(context)
    entity_two = %FooV1_1Entity{entity| identifier: entity.identifier + 1} |> FooV1_1Repo.create!(context)
    entity_three = %FooV1_1Entity{entity| identifier: entity.identifier + 2} |> FooV1_1Repo.create!(context)

    refs = Noizu.ERP.ref([FooV1_1Entity.ref(entity), FooV1_1Entity.record(entity_two), entity_three])
    entities = Noizu.ERP.entity!(refs)
    assert entities == [entity, entity_two, entity_three]
  end


  @tag :"v1.1"
  test "FooV1_1Repo.list!" do
    context = CallingContext.system()
    entity = %FooV1_1Entity{content: :hello} |> FooV1_1Repo.create!(context)
    entity_two = %FooV1_1Entity{entity| identifier: entity.identifier + 1} |> FooV1_1Repo.create!(context)
    entity_three = %FooV1_1Entity{entity| identifier: entity.identifier + 2} |> FooV1_1Repo.create!(context)

    _r = Amnesia.Fragment.transaction do
      Noizu.Database.Scaffolding.Test.Fixture.FooV1_1Table.where true == true
    end

    entities = FooV1_1Repo.list!(context) |> Enum.sort(&(&1.identifier <= &2.identifier))
    assert entities == [entity, entity_two, entity_three]
  end

end
