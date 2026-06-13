@tier1 @regression @crud
Feature: Artifact Creation
  As a user of the NPL portal
  I want to create new artifacts
  So that I can store versioned documents

  Background:
    Given I am on the artifacts page

  # ── Form Toggle ────────────────────────────────────────────────────────

  Scenario: Create form opens and closes
    When I click the "New artifact" button
    Then "artifact-form" should be visible
    When I click the "Cancel" button
    Then "artifact-form" should not exist

  # ── Validation ─────────────────────────────────────────────────────────

  Scenario: Create button disabled when title is empty
    When I click the "New artifact" button
    Then "create-artifact-btn" should be disabled

  # ── Happy Path ─────────────────────────────────────────────────────────

  @smoke
  Scenario: Creating a text artifact
    Given the artifact creation API is stubbed
    When I click the "New artifact" button
    And I type "My New Doc" into the "artifact-title-input" input
    And I type "Hello world" into the "artifact-content-input" input
    And I click the create artifact button
    Then "artifact-form" should not exist

  # ── Error Path ─────────────────────────────────────────────────────────

  @error
  Scenario: Failed artifact creation shows error
    Given the artifact creation API will fail
    When I click the "New artifact" button
    And I type "Fail Doc" into the "artifact-title-input" input
    And I type "some content" into the "artifact-content-input" input
    And I click the create artifact button
    Then "artifact-error" should be visible
