@tier1 @regression
Feature: Task List
  As a user of the NPL portal
  I want to view and manage tasks
  So that I can track work items and their statuses

  Background:
    Given I am on the tasks page

  # ── Task Listing ────────────────────────────────────────────────────────

  @smoke
  Scenario: Tasks page loads and displays tasks
    Then "tasks-page" should be visible
    And "tasks-list" should be visible
    And I should see 3 "task-row" elements

  Scenario: Filter tasks by status
    When I select "in_progress" from the "status-filter" dropdown
    Then I should see at least 1 "task-row" elements

  Scenario: Filter tasks by assignee
    When I type "npl-tdd-coder" into the "assignee-filter" input
    Then I should see at least 1 "task-row" elements

  Scenario: Clear all filters
    When I select "pending" from the "status-filter" dropdown
    And I click the "Clear" button
    Then "status-filter" should have value ""

  Scenario: Inline status update on a task
    Given the task status update API is stubbed
    When I change the status of the first task to "done"
    Then the first task status select should have value "done"

  Scenario: Empty state when no tasks match filters
    Given the tasks API returns no results
    Then "tasks-empty" should be visible
