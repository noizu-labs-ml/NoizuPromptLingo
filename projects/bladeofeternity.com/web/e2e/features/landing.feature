Feature: Landing Page
  As a visitor
  I want to see the Blade of Eternity landing page
  So I can learn about the game and navigate to sign up or log in

  Background:
    Given I am on the landing page

  Scenario: Landing page displays game content
    Then I should see the site header
    And I should see the site footer
    And I should see a hero section

  Scenario: Carousel navigation
    When I click the next carousel button
    Then the carousel should advance to the next slide
    When I click the previous carousel button
    Then the carousel should return to the previous slide

  Scenario: Navigation links for unauthenticated users
    Then I should see a "Login" link in the header
    And I should see a "Create Account" link in the header

  Scenario: Cookie consent banner appears on first visit
    Then I should see the cookie consent banner
    When I click "Accept All" on the cookie banner
    Then the cookie consent banner should disappear
    And localStorage "boe_cookies_accepted" should equal "all"

  Scenario: Cookie consent essential only
    Then I should see the cookie consent banner
    When I click "Essential Only" on the cookie banner
    Then the cookie consent banner should disappear
    And localStorage "boe_cookies_accepted" should equal "essential"
