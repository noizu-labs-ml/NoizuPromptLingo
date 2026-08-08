defmodule NoizuPromptLingua.Domains.Tickets.Seed do
  @moduledoc """
  Seeds the default **global** field and type definitions (organization_id and
  project_id NULL). Every organization and project inherits these and may
  override, extend, or disable them at a more-specific scope. Run once: `run/0`.
  """
  alias NoizuPromptLingua.Domains.Tickets.Definitions

  def run do
    seed_fields()
    seed_types()
    :ok
  end

  defp seed_fields do
    fields()
    |> Enum.each(fn attrs -> Definitions.upsert_field(attrs) end)
  end

  defp seed_types do
    types()
    |> Enum.each(fn {type_attrs, field_specs} ->
      {:ok, type_def} = Definitions.upsert_type(type_attrs)

      field_specs
      |> Enum.with_index()
      |> Enum.each(fn {{slug, required}, idx} ->
        case Definitions.get_field_in_scope(nil, nil, slug) do
          nil ->
            :ok

          field ->
            Definitions.add_field_to_type(type_def.id, field.id,
              required: required,
              position: idx
            )
        end
      end)
    end)
  end

  defp fields do
    [
      %{
        slug: "priority",
        label: "Priority",
        field_type: "select",
        options: %{
          "values" => [
            %{"value" => "low", "label" => "Low"},
            %{"value" => "medium", "label" => "Medium"},
            %{"value" => "high", "label" => "High"},
            %{"value" => "critical", "label" => "Critical"}
          ]
        }
      },
      %{
        slug: "severity",
        label: "Severity",
        field_type: "select",
        options: %{
          "values" => [
            %{"value" => "cosmetic", "label" => "Cosmetic"},
            %{"value" => "minor", "label" => "Minor"},
            %{"value" => "major", "label" => "Major"},
            %{"value" => "critical", "label" => "Critical"},
            %{"value" => "blocker", "label" => "Blocker"}
          ]
        }
      },
      %{slug: "story_points", label: "Story Points", field_type: "number"},
      %{slug: "acceptance_criteria", label: "Acceptance Criteria", field_type: "markdown"},
      %{slug: "steps_to_reproduce", label: "Steps to Reproduce", field_type: "markdown"},
      %{slug: "expected_behavior", label: "Expected Behavior", field_type: "markdown"},
      %{slug: "actual_behavior", label: "Actual Behavior", field_type: "markdown"},
      %{slug: "environment", label: "Environment", field_type: "text"},
      %{slug: "component", label: "Component", field_type: "text"},
      %{slug: "labels", label: "Labels", field_type: "multi_select", options: %{"values" => []}},
      %{slug: "due_date", label: "Due Date", field_type: "date"},
      %{slug: "estimate", label: "Estimate", field_type: "text"},
      %{slug: "research_question", label: "Research Question", field_type: "markdown"},
      %{slug: "hypothesis", label: "Hypothesis", field_type: "markdown"},
      %{slug: "findings", label: "Findings", field_type: "rich_text"},
      %{
        slug: "doc_type",
        label: "Documentation Type",
        field_type: "select",
        options: %{
          "values" => [
            %{"value" => "api", "label" => "API"},
            %{"value" => "guide", "label" => "Guide"},
            %{"value" => "runbook", "label" => "Runbook"},
            %{"value" => "adr", "label" => "ADR"},
            %{"value" => "changelog", "label" => "Changelog"}
          ]
        }
      },
      %{
        slug: "target_audience",
        label: "Target Audience",
        field_type: "select",
        options: %{
          "values" => [
            %{"value" => "internal", "label" => "Internal"},
            %{"value" => "external", "label" => "External"},
            %{"value" => "developer", "label" => "Developer"},
            %{"value" => "end_user", "label" => "End User"}
          ]
        }
      },
      %{slug: "prd_link", label: "PRD Link", field_type: "url"},
      # ── Product-management (user story / PRD) fields ──
      %{slug: "persona", label: "Persona", field_type: "persona"},
      %{
        slug: "user_story_status",
        label: "Status",
        field_type: "select",
        options: %{
          "values" => [
            %{"value" => "draft", "label" => "Draft"},
            %{"value" => "in_progress", "label" => "In Progress"},
            %{"value" => "documented", "label" => "Documented"},
            %{"value" => "implemented", "label" => "Implemented"},
            %{"value" => "tested", "label" => "Tested"}
          ]
        }
      },
      %{slug: "prd_refs", label: "PRD References", field_type: "text"},
      %{slug: "related_stories", label: "Related Stories", field_type: "text"},
      %{
        slug: "prd_status",
        label: "Status",
        field_type: "select",
        options: %{
          "values" => [
            %{"value" => "draft", "label" => "Draft"},
            %{"value" => "review", "label" => "Review"},
            %{"value" => "approved", "label" => "Approved"},
            %{"value" => "done", "label" => "Done"},
            %{"value" => "closed", "label" => "Closed"}
          ]
        }
      },
      %{slug: "version", label: "Version", field_type: "text"},
      %{
        slug: "functional_requirements",
        label: "Functional Requirements",
        field_type: "markdown"
      },
      %{slug: "acceptance_tests", label: "Acceptance Tests", field_type: "markdown"}
    ]
  end

  defp workflow(statuses, transitions) do
    %{"statuses" => statuses, "transitions" => transitions}
  end

  defp types do
    [
      {%{
         slug: "epic",
         name: "Epic",
         description: "Large body of work that can be broken into user stories",
         status_workflow:
           workflow(
             ["open", "in_progress", "done", "closed"],
             %{
               "open" => ["in_progress", "closed"],
               "in_progress" => ["done", "closed"],
               "done" => ["closed", "open"]
             }
           )
       },
       [
         {"priority", true},
         {"labels", false},
         {"due_date", false},
         {"acceptance_criteria", false}
       ]},
      {%{
         slug: "user_story",
         name: "User Story",
         description: "A feature or requirement from the user's perspective",
         status_workflow:
           workflow(
             ["open", "in_progress", "in_review", "done", "closed"],
             %{
               "open" => ["in_progress", "closed"],
               "in_progress" => ["in_review", "closed"],
               "in_review" => ["done", "in_progress"],
               "done" => ["closed", "open"]
             }
           )
       },
       [
         {"persona", false},
         {"priority", true},
         {"user_story_status", false},
         {"acceptance_criteria", true},
         {"prd_refs", false},
         {"related_stories", false},
         {"story_points", false},
         {"labels", false},
         {"estimate", false}
       ]},
      {%{
         slug: "prd",
         name: "PRD",
         description: "Product Requirements Document",
         status_workflow:
           workflow(
             ["draft", "review", "approved", "done", "closed"],
             %{
               "draft" => ["review", "closed"],
               "review" => ["approved", "draft"],
               "approved" => ["done", "closed"],
               "done" => ["closed"]
             }
           )
       },
       [
         {"priority", true},
         {"prd_status", false},
         {"version", false},
         {"functional_requirements", false},
         {"acceptance_tests", false},
         {"prd_link", false},
         {"target_audience", false},
         {"acceptance_criteria", false}
       ]},
      {%{
         slug: "bug",
         name: "Bug",
         description: "A defect or unexpected behavior",
         status_workflow:
           workflow(
             ["open", "triaged", "in_progress", "in_review", "done", "closed", "wont_fix"],
             %{
               "open" => ["triaged", "closed", "wont_fix"],
               "triaged" => ["in_progress", "closed", "wont_fix"],
               "in_progress" => ["in_review", "closed"],
               "in_review" => ["done", "in_progress"],
               "done" => ["closed", "open"]
             }
           )
       },
       [
         {"priority", true},
         {"severity", true},
         {"steps_to_reproduce", true},
         {"expected_behavior", false},
         {"actual_behavior", false},
         {"environment", false},
         {"component", false},
         {"labels", false}
       ]},
      {%{
         slug: "task",
         name: "Task",
         description: "A unit of work to be completed",
         status_workflow:
           workflow(
             ["open", "in_progress", "done", "closed"],
             %{
               "open" => ["in_progress", "closed"],
               "in_progress" => ["done", "closed"],
               "done" => ["closed", "open"]
             }
           )
       }, [{"priority", true}, {"estimate", false}, {"labels", false}, {"component", false}]},
      {%{
         slug: "documentation",
         name: "Documentation",
         description: "Documentation authoring or update task",
         status_workflow:
           workflow(
             ["draft", "review", "published", "closed"],
             %{
               "draft" => ["review", "closed"],
               "review" => ["published", "draft"],
               "published" => ["closed", "draft"]
             }
           )
       },
       [{"priority", true}, {"doc_type", true}, {"target_audience", false}, {"labels", false}]},
      {%{
         slug: "research",
         name: "R&D",
         description: "Research and development investigation",
         status_workflow:
           workflow(
             ["open", "in_progress", "analysis", "done", "closed"],
             %{
               "open" => ["in_progress", "closed"],
               "in_progress" => ["analysis", "closed"],
               "analysis" => ["done", "in_progress"],
               "done" => ["closed", "open"]
             }
           )
       },
       [
         {"priority", true},
         {"research_question", true},
         {"hypothesis", false},
         {"findings", false},
         {"labels", false}
       ]},
      {%{
         slug: "subtask",
         name: "Sub-Task",
         description: "A smaller unit of work within a parent ticket",
         status_workflow:
           workflow(
             ["open", "in_progress", "done", "closed"],
             %{
               "open" => ["in_progress", "closed"],
               "in_progress" => ["done", "closed"],
               "done" => ["closed", "open"]
             }
           )
       }, [{"priority", true}, {"estimate", false}]}
    ]
  end
end
