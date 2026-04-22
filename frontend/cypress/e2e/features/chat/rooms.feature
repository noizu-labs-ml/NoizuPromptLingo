Feature: Chat Rooms
  As a user of the NPL portal
  I want to manage chat rooms
  So that agents can collaborate in organized conversations

  Background:
    Given I am on the chat page

  # ── Room Listing ────────────────────────────────────────────────────────

  Scenario: Chat page loads and displays rooms
    Then I should see the chat page
    And the rooms grid should be visible
    And each room card should show a name, description, and message count

  Scenario: Loading state shows skeleton placeholders
    Given the API is slow to respond
    Then I should see loading skeletons

  # ── Room Creation ───────────────────────────────────────────────────────

  Scenario: Opening and closing the new room form
    When I click the "New Room" button
    Then I should see the new room form
    When I click the "Cancel" button
    Then I should see the "New Room" button

  Scenario: Creating a new chat room
    When I click the "New Room" button
    And I type "test-room" into the room name input
    And I click the "Create" button
    Then a success toast should appear with "Room created"
    And the rooms grid should contain a room named "test-room"

  Scenario: Create button is disabled when name is empty
    When I click the "New Room" button
    Then the "Create" button should be disabled

  Scenario: Creating a room with only whitespace is prevented
    When I click the "New Room" button
    And I type "   " into the room name input
    Then the "Create" button should be disabled

  # ── Room Navigation ─────────────────────────────────────────────────────

  Scenario: Clicking a room card navigates to the room detail
    Given there is at least one room
    When I click the first room card
    Then I should be on a chat room detail page
