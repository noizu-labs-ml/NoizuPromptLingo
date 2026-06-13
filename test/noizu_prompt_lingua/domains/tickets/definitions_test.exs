defmodule NoizuPromptLingua.Domains.Tickets.DefinitionsTest do
  use NoizuPromptLingua.DataCase, async: true

  alias NoizuPromptLingua.Domains.Tickets.Definitions

  describe "field definitions" do
    test "create_field/1 creates a field definition" do
      assert {:ok, field} = Definitions.create_field(%{
        slug: "test_field",
        label: "Test Field",
        field_type: "text"
      })

      assert field.slug == "test_field"
      assert field.label == "Test Field"
      assert field.field_type == "text"
    end

    test "create_field/1 validates field_type" do
      assert {:error, changeset} = Definitions.create_field(%{
        slug: "bad", label: "Bad", field_type: "invalid"
      })

      assert %{field_type: _} = errors_on(changeset)
    end

    test "create_field/1 enforces unique slug" do
      attrs = %{slug: "dupe", label: "Dupe", field_type: "text"}
      assert {:ok, _} = Definitions.create_field(attrs)
      assert {:error, changeset} = Definitions.create_field(attrs)
      assert %{slug: _} = errors_on(changeset)
    end

    test "get_field/1 returns a field by slug" do
      {:ok, _} = Definitions.create_field(%{slug: "findme", label: "Find Me", field_type: "number"})
      assert %{slug: "findme"} = Definitions.get_field("findme")
    end

    test "get_field/1 returns nil for missing slug" do
      assert is_nil(Definitions.get_field("nonexistent"))
    end

    test "update_field/2 updates attributes" do
      {:ok, _} = Definitions.create_field(%{slug: "upd", label: "Old", field_type: "text"})
      assert {:ok, updated} = Definitions.update_field("upd", %{label: "New"})
      assert updated.label == "New"
    end

    test "update_field/2 returns error for missing slug" do
      assert {:error, :not_found} = Definitions.update_field("nope", %{label: "X"})
    end

    test "delete_field/1 removes a field" do
      {:ok, _} = Definitions.create_field(%{slug: "del", label: "Del", field_type: "text"})
      assert {:ok, _} = Definitions.delete_field("del")
      assert is_nil(Definitions.get_field("del"))
    end

    test "list_fields/0 returns all fields sorted by slug" do
      {:ok, _} = Definitions.create_field(%{slug: "z_field", label: "Z", field_type: "text"})
      {:ok, _} = Definitions.create_field(%{slug: "a_field", label: "A", field_type: "text"})
      fields = Definitions.list_fields()
      slugs = Enum.map(fields, & &1.slug)
      assert "a_field" in slugs
      assert "z_field" in slugs
      assert Enum.find_index(slugs, &(&1 == "a_field")) < Enum.find_index(slugs, &(&1 == "z_field"))
    end

    test "upsert_field/1 creates new or updates existing" do
      assert {:ok, f1} = Definitions.upsert_field(%{slug: "ups", label: "V1", field_type: "text"})
      assert f1.label == "V1"

      assert {:ok, f2} = Definitions.upsert_field(%{slug: "ups", label: "V2", field_type: "text"})
      assert f2.label == "V2"
      assert f2.id == f1.id
    end

    test "create_field/1 with select options" do
      assert {:ok, field} = Definitions.create_field(%{
        slug: "color",
        label: "Color",
        field_type: "select",
        options: %{"values" => [%{"value" => "red", "label" => "Red"}, %{"value" => "blue", "label" => "Blue"}]}
      })

      assert field.options["values"] |> length() == 2
    end
  end

  describe "type definitions" do
    test "create_type/1 creates a type definition" do
      assert {:ok, type_def} = Definitions.create_type(%{
        slug: "test_type",
        name: "Test Type",
        description: "A test type",
        status_workflow: %{"statuses" => ["open", "closed"], "transitions" => %{"open" => ["closed"]}}
      })

      assert type_def.slug == "test_type"
      assert type_def.status_workflow["statuses"] == ["open", "closed"]
    end

    test "create_type/1 enforces unique slug" do
      attrs = %{slug: "dupe_type", name: "Dupe"}
      assert {:ok, _} = Definitions.create_type(attrs)
      assert {:error, _} = Definitions.create_type(attrs)
    end

    test "get_type/1 returns type with preloaded fields" do
      {:ok, _} = Definitions.create_type(%{slug: "gt", name: "GT"})
      type_def = Definitions.get_type("gt")
      assert type_def.slug == "gt"
      assert is_list(type_def.type_fields)
    end

    test "get_type/1 excludes soft-deleted types" do
      {:ok, _} = Definitions.create_type(%{slug: "sdel", name: "SoftDel"})
      assert {:ok, _} = Definitions.delete_type("sdel")
      assert is_nil(Definitions.get_type("sdel"))
    end

    test "update_type/2 updates attributes" do
      {:ok, _} = Definitions.create_type(%{slug: "updt", name: "Old Name"})
      assert {:ok, updated} = Definitions.update_type("updt", %{name: "New Name"})
      assert updated.name == "New Name"
    end

    test "delete_type/1 soft-deletes" do
      {:ok, _} = Definitions.create_type(%{slug: "sd2", name: "SD2"})
      assert {:ok, deleted} = Definitions.delete_type("sd2")
      assert not is_nil(deleted.deleted_at)
    end

    test "list_types/0 excludes soft-deleted" do
      {:ok, _} = Definitions.create_type(%{slug: "alive", name: "Alive"})
      {:ok, _} = Definitions.create_type(%{slug: "dead", name: "Dead"})
      Definitions.delete_type("dead")

      types = Definitions.list_types()
      slugs = Enum.map(types, & &1.slug)
      assert "alive" in slugs
      refute "dead" in slugs
    end
  end

  describe "type-field associations" do
    test "add_field_to_type/3 links a field to a type" do
      {:ok, _} = Definitions.create_field(%{slug: "tf_field", label: "TF", field_type: "text"})
      {:ok, _} = Definitions.create_type(%{slug: "tf_type", name: "TF Type"})

      assert {:ok, _} = Definitions.add_field_to_type("tf_type", "tf_field", required: true, position: 0)
    end

    test "get_type_fields/1 returns ordered fields with metadata" do
      {:ok, _} = Definitions.create_field(%{slug: "f1", label: "F1", field_type: "text"})
      {:ok, _} = Definitions.create_field(%{slug: "f2", label: "F2", field_type: "number"})
      {:ok, _} = Definitions.create_type(%{slug: "ft_type", name: "FT"})

      Definitions.add_field_to_type("ft_type", "f2", required: false, position: 1)
      Definitions.add_field_to_type("ft_type", "f1", required: true, position: 0)

      fields = Definitions.get_type_fields("ft_type")
      assert length(fields) == 2
      assert hd(fields).slug == "f1"
      assert hd(fields).required == true
      assert List.last(fields).slug == "f2"
    end

    test "get_type_fields/1 returns empty list for missing type" do
      assert Definitions.get_type_fields("nope") == []
    end
  end

  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
