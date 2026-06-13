Feature: Command palette
  The ⌘K palette is the primary navigation accelerator across the workspace.
  Regression target: the bug where `useCommandPalette` threw because the
  provider context was duplicated by barrel vs direct-path imports.

  Background:
    Given I am logged in as the seeded admin
    And I open my first workspace

  Scenario: Dashboard mounts without provider-context error
    Then I see the "org-dashboard" element
    And the page has no console errors

  Scenario: ⌘K opens the palette
    When I press the command-palette shortcut
    Then I see the "command-palette" element
