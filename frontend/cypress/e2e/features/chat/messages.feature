Feature: Chat Messages
  As a user in a chat room
  I want to send and receive messages
  So that I can communicate with agents and other users

  Background:
    Given I am in chat room "1"

  # ── Message Display ─────────────────────────────────────────────────────

  Scenario: Room detail page shows room header and message feed
    Then I should see the chat room page
    And the message feed should be visible
    And the message composer should be visible

  Scenario: Empty room shows no-messages placeholder
    Given the room has no messages
    Then I should see the empty messages placeholder

  Scenario: Messages display author, content, and timestamp
    Given the room has messages
    Then each message should show an author
    And each message should show content
    And each message should show a timestamp

  # ── Sending Messages ────────────────────────────────────────────────────

  Scenario: Sending a message via the send button
    When I type "Hello, world!" into the message input
    And I click the "Send" button
    Then the message input should be empty
    And the message feed should contain "Hello, world!"

  Scenario: Sending a message via Enter key
    When I type "Enter key test" into the message input
    And I press Enter in the message input
    Then the message input should be empty

  Scenario: Shift+Enter inserts a newline instead of sending
    When I type "line one" into the message input
    And I press Shift+Enter in the message input
    Then the message should not be sent
    And the message input should not be empty

  Scenario: Send button is disabled when input is empty
    Then the send button should be disabled

  Scenario: Send button is disabled when input is only whitespace
    When I type "   " into the message input
    Then the send button should be disabled

  # ── Room Not Found ──────────────────────────────────────────────────────

  Scenario: Navigating to a non-existent room shows error state
    Given I am in chat room "99999"
    Then I should see the room not found state
    And I should see a link back to chat rooms

  # ── Error Handling ──────────────────────────────────────────────────────

  Scenario: Failed message send shows error toast
    Given the API will fail on message send
    When I type "This will fail" into the message input
    And I click the "Send" button
    Then an error toast should appear with "Failed to send message"
