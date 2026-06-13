Feature: Game Interface
  As a logged-in player
  I want to interact with the game world
  So I can play the text RPG

  Background:
    Given I am logged in
    And the API returns my character data
    And I am on the game page

  Scenario: Game page displays character stats
    Then I should see my character name displayed
    And I should see the HP progress bar
    And I should see the energy progress bar
    And I should see the XP progress bar
    And I should see my gold amount
    And I should see my equipped weapon
    And I should see my equipped armor

  Scenario: Game page displays active effects
    Then I should see active effects on my character

  Scenario: Game page displays narrative log
    Then I should see the narrative log
    And I should see my current location

  Scenario: Executing an action
    When I click the "Look around" action button
    Then the action should appear in the narrative log

  Scenario: Typing a command
    When I type "go north" in the command input
    And I submit the command
    Then the command should appear in the narrative log prefixed with ">"

  Scenario: Command history navigation
    When I type "look" in the command input
    And I submit the command
    And I type "inventory" in the command input
    And I submit the command
    And I press the up arrow in the command input
    Then the command input should contain "inventory"
    When I press the up arrow in the command input
    Then the command input should contain "look"

  Scenario: Accessibility skip links
    Then I should see a "Skip to story" skip link
    And I should see a "Skip to command input" skip link

  Scenario: Logout from game
    When I click the logout button
    Then I should be redirected to the home page
    And I should not be logged in
