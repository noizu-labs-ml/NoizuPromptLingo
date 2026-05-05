@tier1 @regression @crud
Feature: Task Creation
  As a user of the NPL portal
  I want to create new tasks
  So that I can add work items to the queue

  Background:
    Given I am on the tasks page

  # ── Create Form ─────────────────────────────────────────────────────────

  @smoke
  Scenario: Creating a new task
    Given the task creation API is stubbed
    When I click the "New task" button
    And I type "My new task" into the "task-title-input" input
    And I click the create task button
    Then "new-task-form" should not exist
    And "new-task-btn" should be visible

  Scenario: Create form opens and closes
    When I click the "New task" button
    Then "new-task-form" should be visible
    When I click the task form cancel button
    Then "new-task-form" should not exist
    And "new-task-btn" should be visible

  Scenario: Create button disabled when title is empty
    When I click the "New task" button
    Then "create-task-btn" should be disabled

  @error
  Scenario: Failed task creation shows error message
    Given the task creation API will fail
    When I click the "New task" button
    And I type "Fail task" into the "task-title-input" input
    And I click the create task button
    Then "task-error" should be visible
