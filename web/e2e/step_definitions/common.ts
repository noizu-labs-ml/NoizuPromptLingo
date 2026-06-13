import { Given, Then } from '@badeball/cypress-cucumber-preprocessor';

// --- Auth helpers ---

Given('I am logged in', () => {
  cy.fixture('user.json').then((data) => {
    cy.intercept('GET', '**/api/v1/auth/me', {
      statusCode: 200,
      body: { user: data.authResponse.user },
    }).as('getMe');

    cy.window().then((win) => {
      win.localStorage.setItem(
        'boe_tokens',
        JSON.stringify({
          access_token: data.authResponse.access_token,
          refresh_token: data.authResponse.refresh_token,
        }),
      );
    });
  });
});

Given('the API returns my character data', () => {
  cy.fixture('user.json').then((data) => {
    cy.intercept('GET', '**/api/v1/character', {
      statusCode: 200,
      body: data.character,
    }).as('getCharacter');
  });
});

Given('the API will accept login credentials', () => {
  cy.fixture('user.json').then((data) => {
    cy.intercept('POST', '**/api/v1/auth/login', {
      statusCode: 200,
      body: data.authResponse,
    }).as('loginRequest');
  });
});

Given('the API will reject login credentials', () => {
  cy.intercept('POST', '**/api/v1/auth/login', {
    statusCode: 401,
    body: { error: 'Invalid email or password' },
  }).as('loginRequest');
});

Given('the API will accept registration', () => {
  cy.fixture('user.json').then((data) => {
    cy.intercept('POST', '**/api/v1/auth/register', {
      statusCode: 201,
      body: data.authResponse,
    }).as('registerRequest');
  });
});

Given('I have accepted cookies', () => {
  cy.on('window:before:load', (win) => {
    win.localStorage.setItem('boe_cookies_accepted', 'all');
  });
});

// --- Navigation ---

Given('I am on the landing page', () => {
  cy.visit('/');
});

Given('I am on the login page', () => {
  cy.visit('/login');
});

Given('I am on the signup page', () => {
  cy.visit('/signup');
});

Given('I am on the game page', () => {
  cy.visit('/game');
  // Wait for character data to load before proceeding
  cy.getByCy('game-page', { timeout: 10000 }).should('exist');
});

// --- Header assertions ---

Then('I should see the site header', () => {
  cy.getByCy('header').should('be.visible');
});

Then('I should see the site footer', () => {
  cy.getByCy('footer').should('be.visible');
});

Then('I should see a {string} link in the header', (text: string) => {
  cy.getByCy('header').contains(text).should('be.visible');
});

Then('I should see my username in the header', () => {
  cy.getByCy('username').should('be.visible');
});

Then('I should see a logout button in the header', () => {
  cy.getByCy('logout-button').should('be.visible');
});

Then('I should not be logged in', () => {
  cy.window().then((win) => {
    expect(win.localStorage.getItem('boe_tokens')).to.be.null;
  });
});
