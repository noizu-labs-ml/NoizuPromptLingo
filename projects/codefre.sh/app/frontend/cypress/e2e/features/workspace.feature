Feature: Workspace shell
  Once logged in, users land on an org picker, pick a workspace, and see the
  Forge dashboard with 6 section cards and 4 metric tiles.

  Background:
    Given I am logged in as the seeded admin

  Scenario: Workspace picker lists seeded orgs
    Given I am on the workspace picker
    Then I see the "orgs-list" element
    And I see at least one org card
    And the page has no console errors

  Scenario: Dashboard shows section cards and metric tiles
    Given I open my first workspace
    Then I see the "org-dashboard" element
    And I see the "dashboard-metrics" element
    And I see the following dashboard cards:
      | Prompts  |
      | Rubrics  |
      | Personas |
      | Scripts  |
      | Agents   |
      | Runs     |
    And the page has no console errors

  Scenario Outline: Section navigation renders without errors
    Given I open my first workspace
    When I navigate to the "<section>" section
    Then the URL matches "/app/[^/]+/<section>"
    And the page has no console errors

    Examples:
      | section  |
      | prompts  |
      | rubrics  |
      | personas |
      | agents   |
      | scripts  |
      | runs     |
      | review   |
      | datasets |
      | otel     |
      | webhooks |
      | settings |
