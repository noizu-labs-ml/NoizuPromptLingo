Feature: Accessibility
  As a blind or screen reader user
  I want the game to be fully accessible
  So I can play without barriers

  Scenario: Game page has proper ARIA live regions
    Given I am logged in
    And the API returns my character data
    And I am on the game page
    Then the narrative log should have aria-live "polite"
    And the HP bar should have role "progressbar"
    And the energy bar should have role "progressbar"
    And the XP bar should have role "progressbar"

  Scenario: Login form has proper labels and autocomplete
    Given I am on the login page
    Then the email input should have autocomplete "email"
    And the password input should have autocomplete "current-password"

  Scenario: Signup form has proper labels and autocomplete
    Given I am on the signup page
    Then the email input should have autocomplete "email"
    And the password input should have autocomplete "new-password"
    And the honeypot field should be hidden

  Scenario: Error messages use role alert
    Given the API will reject login credentials
    And I am on the login page
    When I enter "bad@example.com" in the email field
    And I enter "wrong" in the password field
    And I click the sign in button
    Then the error message should have role "alert"
