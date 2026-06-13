defmodule NoizuPromptLingua.Domains.Tickets.SeedTest do
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.Tickets.{Seed, Definitions}

  describe "run/0" do
    test "seeds all field definitions" do
      assert :ok = Seed.run()

      expected_fields = ~w(priority severity story_points acceptance_criteria
        steps_to_reproduce expected_behavior actual_behavior environment
        component labels due_date estimate research_question hypothesis
        findings doc_type target_audience prd_link)

      for slug <- expected_fields do
        assert Definitions.get_field(slug), "Expected field '#{slug}' to be seeded"
      end
    end

    test "seeds all type definitions" do
      Seed.run()

      expected_types = ~w(epic user_story prd bug task documentation research subtask)

      for slug <- expected_types do
        type_def = Definitions.get_type(slug)
        assert type_def, "Expected type '#{slug}' to be seeded"
        assert type_def.status_workflow, "Expected status_workflow for '#{slug}'"
      end
    end

    test "seeds type-field associations" do
      Seed.run()

      bug_fields = Definitions.get_type_fields("bug")
      slugs = Enum.map(bug_fields, & &1.slug)

      assert "priority" in slugs
      assert "severity" in slugs
      assert "steps_to_reproduce" in slugs

      priority_field = Enum.find(bug_fields, &(&1.slug == "priority"))
      assert priority_field.required == true
    end

    test "is idempotent" do
      Seed.run()
      field_count_1 = length(Definitions.list_fields())
      type_count_1 = length(Definitions.list_types())

      Seed.run()
      assert length(Definitions.list_fields()) == field_count_1
      assert length(Definitions.list_types()) == type_count_1
    end

    test "each type has a valid status workflow" do
      Seed.run()

      for type_def <- Definitions.list_types() do
        workflow = type_def.status_workflow
        assert is_list(workflow["statuses"]), "#{type_def.slug} should have statuses list"
        assert is_map(workflow["transitions"]), "#{type_def.slug} should have transitions map"
        assert length(workflow["statuses"]) >= 2, "#{type_def.slug} needs at least 2 statuses"
      end
    end
  end
end
