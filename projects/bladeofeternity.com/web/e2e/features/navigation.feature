Feature: Site Navigation
  As a visitor
  I want to navigate between pages
  So I can find information about the game

  Background:
    Given I have accepted cookies
    And I am on the landing page

  Scenario: Footer opens contact modal
    When I click "Contact Us" in the footer
    Then I should see the contact modal
    And I should see the email "support@bladeofeternity.com"

  Scenario: Footer opens terms modal
    When I click "Terms of Service" in the footer
    Then I should see the terms modal

  Scenario: Footer opens privacy modal
    When I click "Privacy Policy" in the footer
    Then I should see the privacy modal

  Scenario: Footer opens cookie modal
    When I click "Cookie" in the footer
    Then I should see the cookie modal

  Scenario: Footer modal closes on X button
    When I click "Contact Us" in the footer
    Then I should see the contact modal
    When I close the footer modal
    Then the footer modal should be closed

  Scenario: Footer modal closes on background click
    When I click "Contact Us" in the footer
    Then I should see the contact modal
    When I click the modal background
    Then the footer modal should be closed

  Scenario: Direct navigation to legal pages
    When I visit the terms page
    Then I should see terms of service content
    When I visit the privacy page
    Then I should see privacy policy content
    When I visit the cookie page
    Then I should see cookie policy content
    And I should see a cookie information table

  Scenario: Authenticated header shows play link
    Given I am logged in
    When I visit the landing page
    Then I should see a "Play" link in the header
    And I should see my username in the header
    And I should see a logout button in the header
