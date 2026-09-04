defmodule NoizuPromptLingua.VersionedContextsTest do
  use NoizuPromptLingua.DataCase

  @moduledoc """
  The three versioned contexts (entities/versioned/{names,strings,descriptions}.ex)
  share the Noizu.Repo CRUD template: create via attrs / entity / changeset,
  update/4, delete/3, change/2 mapping, list/2, and the get_* alias.
  """

  @ctx Noizu.Context.system()

  # The three contexts differ only in module names and change/2 key mapping.
  # Each test drives one template through all clauses.

  test "Versioned.Names: attrs create, change mapping, update, list, delete" do
    alias NoizuPromptLingua.Versioned.Names

    assert {:ok, name} =
             Names.create(
               %{"first" => "Ada", "middle" => ["G"], "last" => "Byron", "ignored" => :x},
               @ctx
             )

    assert name.first == "Ada"
    assert name.last == "Byron"

    assert {:ok, updated} = Names.update(name, %{"first" => "Augusta"}, @ctx, [])
    assert updated.first == "Augusta"

    assert {:ok, _} = Names.get_versioned_name(name.id, @ctx)
    assert Enum.any?(Names.list(@ctx), &(&1.id == name.id))

    cs =
      Names.change(%NoizuPromptLingua.Versioned.Names.Name{}, %{"last" => "Lovelace", "junk" => 1})

    assert cs.changes.last == "Lovelace"
    refute Map.has_key?(cs.changes, :junk)

    assert {:ok, _} = Names.delete(updated, @ctx)
  end

  test "Versioned.Names: entity and changeset create clauses" do
    alias NoizuPromptLingua.Versioned.Names

    entity = %NoizuPromptLingua.Versioned.Names.Name{first: "Grace", last: "Hopper"}
    assert {:ok, via_entity} = Names.create(entity, @ctx)
    assert via_entity.last == "Hopper"

    # explicit id: Noizu entity create does not autogenerate ids the way Ecto
    # schemas do, so the changeset path needs one.
    cs =
      Names.change(%NoizuPromptLingua.Versioned.Names.Name{}, %{
        "id" => Ecto.UUID.generate(),
        "first" => "Edsger"
      })

    assert {:ok, via_cs} = Names.create(cs, @ctx)
    assert via_cs.first == "Edsger"
  end

  test "Versioned.Strings: attrs create, update, get, change, delete" do
    alias NoizuPromptLingua.Versioned.Strings

    assert {:ok, str} = Strings.create(%{"content" => "hello"}, @ctx)
    assert str.content == "hello"

    assert {:ok, updated} = Strings.update(str, %{"content" => "world"}, @ctx, [])
    assert updated.content == "world"

    assert {:ok, _} = Strings.get_versioned_string(updated.id, @ctx)
    assert Enum.any?(Strings.list(@ctx), &(&1.id == updated.id))

    cs = Strings.change(%NoizuPromptLingua.Versioned.Strings.String{}, %{"content" => "again"})
    assert cs.changes.content == "again"

    assert {:ok, _} = Strings.delete(updated, @ctx)
  end

  test "Versioned.Strings: entity and changeset create clauses" do
    alias NoizuPromptLingua.Versioned.Strings

    assert {:ok, via_entity} =
             Strings.create(%NoizuPromptLingua.Versioned.Strings.String{content: "e"}, @ctx)

    assert via_entity.content == "e"

    cs =
      Strings.change(%NoizuPromptLingua.Versioned.Strings.String{}, %{
        "id" => Ecto.UUID.generate(),
        "content" => "c"
      })

    assert {:ok, via_cs} = Strings.create(cs, @ctx)
    assert via_cs.content == "c"
  end

  test "Versioned.Descriptions: attrs create, update, get, change, delete" do
    alias NoizuPromptLingua.Versioned.Descriptions

    assert {:ok, desc} =
             Descriptions.create(%{"title" => "T", "body" => "B"}, @ctx)

    assert desc.title == "T"

    assert {:ok, updated} = Descriptions.update(desc, %{"body" => "B2"}, @ctx, [])
    assert updated.body == "B2"

    assert {:ok, _} = Descriptions.get_versioned_description(updated.id, @ctx)
    assert Enum.any?(Descriptions.list(@ctx), &(&1.id == updated.id))

    cs =
      Descriptions.change(%NoizuPromptLingua.Versioned.Descriptions.Description{}, %{
        "title" => "T2"
      })

    assert cs.changes.title == "T2"

    assert {:ok, _} = Descriptions.delete(updated, @ctx)
  end

  test "Versioned.Descriptions: entity and changeset create clauses" do
    alias NoizuPromptLingua.Versioned.Descriptions

    assert {:ok, via_entity} =
             Descriptions.create(
               %NoizuPromptLingua.Versioned.Descriptions.Description{title: "E", body: "eb"},
               @ctx
             )

    assert via_entity.title == "E"

    cs =
      Descriptions.change(%NoizuPromptLingua.Versioned.Descriptions.Description{}, %{
        "id" => Ecto.UUID.generate(),
        "body" => "cb"
      })

    assert {:ok, via_cs} = Descriptions.create(cs, @ctx)
    assert via_cs.body == "cb"
  end
end
