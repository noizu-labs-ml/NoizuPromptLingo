@tier1 @regression
Feature: Artifact List
  As a user of the NPL portal
  I want to browse and filter artifacts
  So that I can find and access versioned documents

  Background:
    Given I am on the artifacts page

  # ── List Display ───────────────────────────────────────────────────────

  @smoke
  Scenario: Artifacts page loads and displays artifacts
    Then "artifacts-page" should be visible
    And "artifacts-list" should be visible
    And I should see 3 "artifact-card" elements

  # ── Filtering ──────────────────────────────────────────────────────────

  Scenario: Filter artifacts by kind
    Given the artifacts API returns yaml-only results when filtered
    When I select "yaml" from the "kind-filter" dropdown
    Then I should see 1 "artifact-card" elements

  Scenario: Empty state when no artifacts match filter
    Given the artifacts API returns empty results when filtered
    When I select "code" from the "kind-filter" dropdown
    Then "artifacts-empty" should be visible
    And the page should contain "No artifacts match the filter"

  # ── Navigation ─────────────────────────────────────────────────────────

  @smoke @navigation
  Scenario: Clicking an artifact navigates to detail
    Given the artifact detail API is stubbed
    When I click the first artifact card
    Then the URL should match "/artifacts/1"
