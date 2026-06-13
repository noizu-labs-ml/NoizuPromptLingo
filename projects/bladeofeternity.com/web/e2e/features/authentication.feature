Feature: Authentication
  As a player
  I want to log in and register for an account
  So I can play Blade of Eternity

  Scenario: Successful login
    Given the API will accept login credentials
    And I am on the login page
    When I enter "test@bladeofeternity.com" in the email field
    And I enter "TestPass123!" in the password field
    And I click the sign in button
    Then I should be redirected to the game page

  Scenario: Login with invalid credentials
    Given the API will reject login credentials
    And I am on the login page
    When I enter "wrong@example.com" in the email field
    And I enter "badpassword" in the password field
    And I click the sign in button
    Then I should see a login error message

  Scenario: Login page links to signup
    Given I am on the login page
    Then I should see a link to create an account

  Scenario: Successful registration
    Given the API will accept registration
    And I am on the signup page
    When I enter "new@bladeofeternity.com" in the email field
    And I enter "SecurePass123!" in the password field
    And I enter "SecurePass123!" in the confirm password field
    And I click the create account button
    Then I should be redirected to the character creation page

  Scenario: Registration with mismatched passwords
    Given I am on the signup page
    When I enter "new@bladeofeternity.com" in the email field
    And I enter "SecurePass123!" in the password field
    And I enter "DifferentPass456!" in the confirm password field
    And I click the create account button
    Then I should see a password mismatch error

  Scenario: Registration honeypot rejects bots
    Given the API will accept registration
    And I am on the signup page
    When I fill the honeypot field
    And I enter "bot@example.com" in the email field
    And I enter "BotPass123!" in the password field
    And I enter "BotPass123!" in the confirm password field
    And I click the create account button
    Then I should still be on the signup page

  Scenario: Signup page terms modal
    Given I am on the signup page
    When I click the terms of service link
    Then I should see the terms of service modal
    When I close the modal
    Then the modal should be closed

  Scenario: Signup page privacy modal
    Given I am on the signup page
    When I click the privacy policy link
    Then I should see the privacy policy modal
    When I close the modal
    Then the modal should be closed

  Scenario: Already logged in user is redirected from login
    Given I am logged in
    When I visit the login page
    Then I should be redirected to the game page
