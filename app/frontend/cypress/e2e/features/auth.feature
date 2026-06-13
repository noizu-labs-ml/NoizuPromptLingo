Feature: Authentication
  Users sign up with an invite token and log in to reach their workspace list.

  Scenario: Landing page renders brand
    Given I am on the landing page
    Then I see "CodeFresh" somewhere on the page
    And the page has no console errors

  Scenario: Login page shows AuthCard
    Given I am on the login page
    Then I see the "auth-card" element
    And I see the "auth-email-input" element
    And I see the "auth-password-input" element
    And the page has no console errors

  Scenario: Signup requires invite token
    Given I am on the signup page
    When I type "nobody@test.local" into the "auth-email-input" field
    And I type "password123" into the "auth-password-input" field
    And I click "auth-submit"
    Then I see the "auth-error" element

  Scenario: Signup with invalid invite token surfaces server error
    Given I am on the signup page
    When I type "invalid-token-xyz" into the "invite-token-input" field
    And I type "newuser@test.local" into the "auth-email-input" field
    And I type "password123" into the "auth-password-input" field
    And I click "auth-submit"
    Then I see the "auth-error" element

  Scenario: Login with wrong password shows error
    Given I am on the login page
    When I type "keith.brings@noizu.com" into the "auth-email-input" field
    And I type "wrong-password-xyz" into the "auth-password-input" field
    And I click "auth-submit"
    Then the "auth-error" element contains "nvalid"
