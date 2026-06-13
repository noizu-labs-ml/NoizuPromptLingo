# -------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2023 Noizu Labs Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.EntitiesTest do
  use ExUnit.Case
  require Noizu.Support.Entities.Foos.Foo
  require Noizu.Entity.Macros
  require Noizu.Entity.Meta.Identifier
  require Noizu.Entity.Meta.Field
  require Noizu.Entity.Meta.Json
  require Noizu.Entity.Meta.ACL

  @context Noizu.Context.system()

  #  doctest Noizu.Entities
  def ignore_key(key, keys) do
    ks = Enum.map(keys, fn {k, _} -> k end)

    cond do
      key in ks -> keys[key]
      :else -> :"*ignore"
    end
  end

  #     Record.defrecord(:acl_settings, [target: nil, type: nil, requirement: nil])
  def expected_acl(keys) do
    Noizu.Entity.Meta.ACL.acl_settings(
      target: ignore_key(:target, keys),
      type: ignore_key(:type, keys),
      requirement: ignore_key(:requirement, keys)
    )
  end

  def expected_json(keys) do
    Noizu.Entity.Meta.Json.json_settings(
      template: ignore_key(:template, keys),
      field: ignore_key(:field, keys),
      as: ignore_key(:as, keys),
      omit: ignore_key(:omit, keys),
      error: ignore_key(:error, keys)
    )
  end

  def expected_field(keys) do
    Noizu.Entity.Meta.Field.field_settings(
      name: ignore_key(:name, keys),
      type: ignore_key(:type, keys),
      transient: ignore_key(:transient, keys),
      pii: ignore_key(:pii, keys),
      default: ignore_key(:default, keys),
      acl: ignore_key(:acl, keys),
      options: ignore_key(:options, keys)
    )
  end

  # Record.defrecord(:nz__field, [name: nil, type: nil, transient: false, pii: false, default: nil])
  def assert_record(nil = actual, expected) do
    assert actual == expected
  end

  def assert_record(actual, nil = expected) do
    assert actual == expected
  end

  def assert_record({:nz, :inherit} = actual, expected) do
    assert actual == expected
  end

  def assert_record(actual, {:nz, :inherit} = expected) do
    assert actual == expected
  end

  def assert_record(actual, expected) do
    actual =
      Enum.zip(Tuple.to_list(actual), Tuple.to_list(expected))
      |> Enum.map(fn
        {_, :"*ignore"} -> :"*ignore"
        {x, _} -> x
      end)
      |> List.to_tuple()

    assert actual == expected
  end

  test "field attributes" do
    fields = Noizu.Entity.Meta.fields(Noizu.Support.Entities.Foos.Foo)

    assert_record(
      fields[:id],
      expected_field(name: :id, transient: false, pii: false, default: nil)
    )

    assert_record(
      fields[:name],
      expected_field(name: :name, transient: false, pii: :low, default: nil)
    )

    assert_record(
      fields[:passport_number],
      expected_field(name: :passport_number, transient: false, pii: :sensitive, default: nil)
    )

    assert_record(
      fields[:address],
      expected_field(name: :address, transient: false, pii: :sensitive, default: nil)
    )

    assert_record(
      fields[:ephermal_one],
      expected_field(name: :ephermal_one, transient: true, pii: false, default: nil)
    )

    assert_record(
      fields[:ephermal_two],
      expected_field(name: :ephermal_two, transient: true, pii: false, default: nil)
    )

    assert_record(
      fields[:ephermal_three],
      expected_field(name: :ephermal_three, transient: true, pii: false, default: nil)
    )

    assert_record(
      fields[:title],
      expected_field(name: :title, transient: false, pii: false, default: nil)
    )

    assert_record(
      fields[:description],
      expected_field(name: :description, transient: false, pii: false, default: nil)
    )

    assert_record(
      fields[:vsn],
      expected_field(name: :vsn, transient: false, pii: false, default: 1.0)
    )

    assert_record(
      fields[:meta],
      expected_field(name: :meta, transient: false, pii: false, default: nil)
    )

    assert_record(
      fields[:__transient__],
      expected_field(name: :__transient__, transient: true, pii: false, default: nil)
    )
  end

  describe "Entity Json" do
    test "templates" do
      templates =
        Noizu.Entity.Meta.json(Noizu.Support.Entities.Foos.Foo)
        |> Map.keys()

      assert Enum.sort(templates) ==
               Enum.sort([:admin, :admin2, :api, :bar, :brief, :default, :foo, :special])
    end

    test "not_set template" do
      unsupported = Noizu.Entity.Meta.json(Noizu.Support.Entities.Foos.Foo, :not_supported)
      default = Noizu.Entity.Meta.json(Noizu.Support.Entities.Foos.Foo, :default)
      assert unsupported == default
    end

    test "default template" do
      template = :default
      sut = Noizu.Entity.Meta.json(Noizu.Support.Entities.Foos.Foo, template)

      assert_record(
        sut[:name],
        expected_json(
          field: :name,
          template: template,
          omit: false,
          as: {:nz, :inherit},
          error: {:nz, :inherit}
        )
      )

      assert_record(sut[:passport_number], nil)

      assert_record(
        sut[:address],
        expected_json(
          field: :address,
          template: template,
          omit: false,
          as: {:nz, :inherit},
          error: {:nz, :inherit}
        )
      )

      assert_record(sut[:ephermal_one], nil)
      assert_record(sut[:ephermal_two], nil)
      assert_record(sut[:ephermal_three], nil)

      assert_record(
        sut[:title],
        expected_json(
          field: :title,
          template: template,
          omit: false,
          as: {:nz, :inherit},
          error: {:nz, :inherit}
        )
      )

      assert_record(sut[:title2], nil)
      assert_record(sut[:description], nil)
      assert_record(sut[:json_template_specific], nil)
      assert_record(sut[:json_template_specific2], nil)
    end

    test "admin template" do
      template = :admin
      sut = Noizu.Entity.Meta.json(Noizu.Support.Entities.Foos.Foo, template)

      assert_record(
        sut[:name],
        expected_json(
          field: :name,
          template: template,
          omit: false,
          as: {:nz, :inherit},
          error: {:nz, :inherit}
        )
      )

      assert_record(sut[:passport_number], nil)

      assert_record(
        sut[:address],
        expected_json(
          field: :address,
          template: template,
          omit: false,
          as: {:nz, :inherit},
          error: {:nz, :inherit}
        )
      )

      assert_record(
        sut[:ephermal_one],
        expected_json(
          field: :ephermal_one,
          template: template,
          omit: false,
          as: {:nz, :inherit},
          error: {:nz, :inherit}
        )
      )

      assert_record(sut[:ephermal_two], nil)
      assert_record(sut[:ephermal_three], nil)

      assert_record(
        sut[:title],
        expected_json(
          field: :title,
          template: template,
          omit: false,
          as: {:nz, :inherit},
          error: {:nz, :inherit}
        )
      )

      assert_record(
        sut[:title2],
        expected_json(
          field: :title2,
          template: template,
          omit: false,
          as: :apple,
          error: {:nz, :inherit}
        )
      )

      assert_record(
        sut[:description],
        expected_json(
          field: :description,
          template: template,
          omit: false,
          as: {:nz, :inherit},
          error: {:nz, :inherit}
        )
      )

      assert_record(
        sut[:json_template_specific],
        expected_json(
          field: :json_template_specific,
          template: template,
          omit: false,
          as: {:nz, :inherit},
          error: {:nz, :inherit}
        )
      )

      assert_record(
        sut[:json_template_specific2],
        expected_json(
          field: :json_template_specific2,
          template: template,
          omit: false,
          as: {:nz, :inherit},
          error: {:nz, :inherit}
        )
      )
    end

    test "api template" do
      template = :api
      sut = Noizu.Entity.Meta.json(Noizu.Support.Entities.Foos.Foo, template)

      assert_record(
        sut[:name],
        expected_json(
          field: :name,
          template: template,
          omit: false,
          as: {:nz, :inherit},
          error: {:nz, :inherit}
        )
      )

      assert_record(sut[:passport_number], nil)

      assert_record(
        sut[:address],
        expected_json(
          field: :address,
          template: template,
          omit: false,
          as: {:nz, :inherit},
          error: {:nz, :inherit}
        )
      )

      assert_record(sut[:ephermal_one], nil)
      assert_record(sut[:ephermal_two], nil)
      assert_record(sut[:ephermal_three], nil)

      assert_record(
        sut[:title],
        expected_json(
          field: :title,
          template: template,
          omit: false,
          as: {:nz, :inherit},
          error: {:nz, :inherit}
        )
      )

      assert_record(sut[:title2], nil)
      assert_record(sut[:description], nil)
      assert_record(sut[:json_template_specific], nil)

      assert_record(
        sut[:json_template_specific2],
        expected_json(
          field: :json_template_specific2,
          template: template,
          omit: false,
          as: :bop2,
          error: {:nz, :inherit}
        )
      )
    end

    test "brief template" do
      template = :brief
      sut = Noizu.Entity.Meta.json(Noizu.Support.Entities.Foos.Foo, template)

      assert_record(
        sut[:name],
        expected_json(
          field: :name,
          template: template,
          omit: false,
          as: {:nz, :inherit},
          error: {:nz, :inherit}
        )
      )

      assert_record(sut[:passport_number], nil)

      assert_record(
        sut[:address],
        expected_json(
          field: :address,
          template: template,
          omit: false,
          as: {:nz, :inherit},
          error: {:nz, :inherit}
        )
      )

      assert_record(sut[:ephermal_one], nil)
      assert_record(sut[:ephermal_two], nil)
      assert_record(sut[:ephermal_three], nil)
      assert_record(sut[:title], nil)
      assert_record(sut[:title2], nil)
      assert_record(sut[:description], nil)

      assert_record(
        sut[:json_template_specific],
        expected_json(
          field: :json_template_specific,
          template: template,
          omit: false,
          as: {:nz, :inherit},
          error: {:nz, :inherit}
        )
      )

      assert_record(
        sut[:json_template_specific2],
        expected_json(
          field: :json_template_specific2,
          template: template,
          omit: false,
          as: {:nz, :inherit},
          error: {:nz, :inherit}
        )
      )
    end
  end

  describe "Entity ACL" do
    test "Set Permissions" do
      sut = Noizu.Entity.Meta.acl(Noizu.Support.Entities.Foos.Foo)[:name]
      # |> IO.inspect(label: "FINALLY")
      assert sut == [
               {:acl_settings, :entity, :role, [:role2, :role3, :supper_trooper, :user]},
               {:acl_settings, :field, :role, [:supper_trooper]},
               {:acl_settings, {:parent, 0}, :role, [:user]},
               {:acl_settings, {:path, [{Access, :key, [:a]}, {Access, :key, [:b]}]}, :role,
                [:role_y, :role_x]}
             ]
    end

    test "Default Permissions - public" do
      sut = Noizu.Entity.Meta.acl(Noizu.Support.Entities.Foos.Foo)[:title]
      assert sut == {:acl_settings, :entity, :unrestricted, :unrestricted}
    end

    test "Default Permissions - pii" do
      sut = Noizu.Entity.Meta.acl(Noizu.Support.Entities.Foos.Foo)[:passport_number]
      assert sut == {:acl_settings, :entity, :role, [:user, :admin, :system]}
    end

    test "Default Permissions - transitive" do
      sut = Noizu.Entity.Meta.acl(Noizu.Support.Entities.Foos.Foo)[:ephermal_one]
      assert sut == {:acl_settings, :entity, :role, [:admin, :system]}
    end
  end

  describe "Repo Crude" do
    test "Save and Get Record" do
      id = :os.system_time(:millisecond) * 100 + 1

      entity = %Noizu.Support.Entities.Foos.Foo{
        id: id,
        name: "Henry",
        title: "Bob",
        description: "Sample Entity",
        time_stamp: Noizu.Entity.TimeStamp.now()
      }

      {:ok, entity} = Noizu.Support.Entities.Foos.create(entity, @context, nil)
      {:ok, sut} = Noizu.Support.Entities.Foos.get(id, @context, nil)
      assert sut.__struct__ == entity.__struct__
      assert sut.title == entity.title
      assert sut.time_stamp == entity.time_stamp
    end

    test "Delete Record" do
      id = :os.system_time(:millisecond) * 100 + 2

      entity = %Noizu.Support.Entities.Foos.Foo{
        id: id,
        name: "Henry",
        title: "Bob",
        description: "Sample Entity",
        time_stamp: Noizu.Entity.TimeStamp.now()
      }

      {:ok, entity} = Noizu.Support.Entities.Foos.create(entity, @context, nil)
      Noizu.Support.Entities.Foos.delete(entity, @context, nil)
      {:error, :not_found} = Noizu.Support.Entities.Foos.get(id, @context, nil)
    end
  end

  describe "Extended.UUIDReference field" do
    test "Save and Get Record" do
      id = :os.system_time(:millisecond) * 100 + 1

      foo = %Noizu.Support.Entities.Foos.Foo{
        id: id,
        name: "Henry 1",
        title: "Bob",
        description: "Sample Entity",
        time_stamp: Noizu.Entity.TimeStamp.now()
      }

      {:ok, foo_entity} = Noizu.Support.Entities.Foos.create(foo, @context, nil)
      {:ok, foo_ref} = Noizu.Support.Entities.Foos.Foo.ref(foo_entity)

      id = :os.system_time(:millisecond) * 100 + 3

      entity = %Noizu.Support.Entities.Foos.Foo{
        id: id,
        name: "Henry",
        reference_field: foo_ref
      }

      {:ok, entity} = Noizu.Support.Entities.Foos.create(entity, @context, nil)
      {:ok, sut} = Noizu.Support.Entities.Foos.get(id, @context, nil)
      assert sut.__struct__ == entity.__struct__
      assert sut.title == entity.title
      assert sut.reference_field.name == "Henry 1"
    end
  end

  describe "Repo - Field Hooks" do
    test "Field PreCreate - entity" do
      id = :os.system_time(:millisecond) * 100 + 1

      entity = %Noizu.Support.Entities.Foos.Foo{
        id: id,
        special_field: %Noizu.Support.Entity.TestField{sno: "Appa"},
        name: "Henry",
        title: "Bob",
        description: "Sample Entity",
        time_stamp: Noizu.Entity.TimeStamp.now()
      }

      {:ok, entity} = Noizu.Support.Entities.Foos.create(entity, @context, nil)
      {:ok, sut} = Noizu.Support.Entities.Foos.get(id, @context, nil)
      assert entity.special_field.id == 31_337
      assert entity.special_field.sno == "Appa"
      assert sut.special_field == entity.special_field
    end

    test "Field PreCreate - entity exists" do
      id = :os.system_time(:millisecond) * 100 + 1

      entity = %Noizu.Support.Entities.Foos.Foo{
        id: id,
        special_field: %Noizu.Support.Entity.TestField{id: 5, sno: "Appa"},
        name: "Henry",
        title: "Bob",
        description: "Sample Entity",
        time_stamp: Noizu.Entity.TimeStamp.now()
      }

      {:ok, entity} = Noizu.Support.Entities.Foos.create(entity, @context, nil)
      {:ok, sut} = Noizu.Support.Entities.Foos.get(id, @context, nil)
      assert entity.special_field.id == 5
      assert entity.special_field.sno == "Appa"
      assert sut.special_field == entity.special_field
    end

    test "Field PreCreate - short hand" do
      id = :os.system_time(:millisecond) * 100 + 1

      entity = %Noizu.Support.Entities.Foos.Foo{
        id: id,
        special_field: "Oppa",
        name: "Henry",
        title: "Bob",
        description: "Sample Entity",
        time_stamp: Noizu.Entity.TimeStamp.now()
      }

      {:ok, entity} = Noizu.Support.Entities.Foos.create(entity, @context, nil)
      {:ok, sut} = Noizu.Support.Entities.Foos.get(id, @context, nil)
      assert entity.special_field.id == 0xF00BA7
      assert entity.special_field.sno == "Oppa"
      assert sut.special_field == entity.special_field
    end

    test "Field PreUpdate - entity" do
      id = :os.system_time(:millisecond) * 100 + 1

      entity = %Noizu.Support.Entities.Foos.Foo{
        id: id,
        special_field: %Noizu.Support.Entity.TestField{sno: "Appa"},
        name: "Henry",
        title: "Bob",
        description: "Sample Entity",
        time_stamp: Noizu.Entity.TimeStamp.now()
      }

      {:ok, entity} = Noizu.Support.Entities.Foos.update(entity, @context, nil)
      {:ok, sut} = Noizu.Support.Entities.Foos.get(id, @context, nil)
      assert entity.special_field.id == nil
      assert entity.special_field.sno == "Appa_updated"
      assert sut.special_field == entity.special_field
    end

    test "Field PreUpdate - entity exists" do
      id = :os.system_time(:millisecond) * 100 + 1

      entity = %Noizu.Support.Entities.Foos.Foo{
        id: id,
        special_field: %Noizu.Support.Entity.TestField{id: 5, sno: "Appa"},
        name: "Henry",
        title: "Bob",
        description: "Sample Entity",
        time_stamp: Noizu.Entity.TimeStamp.now()
      }

      {:ok, entity} = Noizu.Support.Entities.Foos.update(entity, @context, nil)
      {:ok, sut} = Noizu.Support.Entities.Foos.get(id, @context, nil)
      assert entity.special_field.id == 5
      assert entity.special_field.sno == "Appa_updated"
      assert sut.special_field == entity.special_field
    end

    test "Field PreUpdate - short hand" do
      id = :os.system_time(:millisecond) * 100 + 1

      entity = %Noizu.Support.Entities.Foos.Foo{
        id: id,
        special_field: "Oppa",
        name: "Henry",
        title: "Bob",
        description: "Sample Entity",
        time_stamp: Noizu.Entity.TimeStamp.now()
      }

      {:ok, entity} = Noizu.Support.Entities.Foos.update(entity, @context, nil)
      {:ok, sut} = Noizu.Support.Entities.Foos.get(id, @context, nil)
      assert entity.special_field.id == 0xF00BA8
      assert entity.special_field.sno == "Oppa"
      assert sut.special_field == entity.special_field
    end
  end

  describe "Ecto.Changeset support" do
    test "validate required" do
      cs =
        Noizu.Support.Entities.BizBops.BizBop.changeset(
          %Noizu.Support.Entities.BizBops.BizBop{},
          %{}
        )

      assert cs.errors[:name] == {"can't be blank", [validation: :required]}
    end

    test "validate type" do
      cs =
        Noizu.Support.Entities.BizBops.BizBop.changeset(
          %Noizu.Support.Entities.BizBops.BizBop{},
          %{ecto_hint: 123, name: "apple"}
        )

      assert cs.errors[:ecto_hint] == {"is invalid", [type: :string, validation: :cast]}
    end

    test "valid changeset" do
      cs =
        Noizu.Support.Entities.BizBops.BizBop.changeset(
          %Noizu.Support.Entities.BizBops.BizBop{},
          %{ecto_hint: "string", name: "apple"}
        )

      assert cs.errors == []
    end

    test "Create from changeset - direct" do
      initial = %Noizu.Support.Entities.BizBops.BizBop{
        title2: "Apple",
        description: "Bop",
        inserted_at: DateTime.utc_now()
      }

      cs =
        Noizu.Support.Entities.BizBops.BizBop.changeset(initial, %{
          ecto_hint: "string",
          name: "apple"
        })

      {:ok, e} = Noizu.Support.Entities.BizBops.create(cs, @context, [])
      r = NoizuEntityTestDb.BizBops.BizBopTable.read!(e.id)
      assert is_integer(r.inserted_at)
      assert r.entity.name == "apple"
    end

    test "Create from changeset" do
      initial = %Noizu.Support.Entities.BizBops.BizBop{
        title2: "Apple",
        description: "Bop",
        inserted_at: DateTime.utc_now()
      }

      cs =
        Noizu.Support.Entities.BizBops.BizBop.changeset(initial, %{
          ecto_hint: "string",
          name: "apple"
        })

      {:ok, e} = NoizuTest.EntityRepo.create(cs, @context)
      r = NoizuEntityTestDb.BizBops.BizBopTable.read!(e.id)
      assert is_integer(r.inserted_at)
      assert r.entity.name == "apple"
    end
  end
end
