import { When, Then } from '@badeball/cypress-cucumber-preprocessor';

// --- Form input ---

When('I enter {string} in the email field', (value: string) => {
  cy.getByCy('email-input').clear().type(value);
});

When('I enter {string} in the password field', (value: string) => {
  cy.getByCy('password-input').clear().type(value);
});

When('I enter {string} in the confirm password field', (value: string) => {
  cy.getByCy('confirm-input').clear().type(value);
});

When('I fill the honeypot field', () => {
  cy.getByCy('honeypot').type('http://bot.example.com', { force: true });
});

// --- Actions ---

When('I click the sign in button', () => {
  cy.getByCyId('submit-button', 'login').click();
});

When('I click the create account button', () => {
  cy.getByCyId('submit-button', 'signup').click();
});

When('I visit the login page', () => {
  cy.visit('/login');
});

// --- Assertions ---

Then('I should be redirected to the game page', () => {
  cy.url().should('include', '/game');
});

Then('I should be redirected to the character creation page', () => {
  cy.url().should('include', '/create-character');
});

Then('I should still be on the signup page', () => {
  cy.url().should('include', '/signup');
});

Then('I should see a login error message', () => {
  cy.getByCy('error-alert').should('be.visible');
});

Then('I should see a link to create an account', () => {
  cy.getByCy('signup-link').should('be.visible');
});

Then('I should see a password mismatch error', () => {
  cy.getByCy('error-alert')
    .should('be.visible')
    .and('contain.text', 'match');
});

Then('I should see a registration error', () => {
  cy.getByCy('error-alert').should('be.visible');
});

// --- Footer modals (from signup/login pages) ---

When('I click the terms of service link', () => {
  cy.getByCyId('footer-link', 'terms').click();
});

When('I click the privacy policy link', () => {
  cy.getByCyId('footer-link', 'privacy').click();
});

Then('I should see the terms of service modal', () => {
  cy.getByCyId('modal', 'terms')
    .should('be.visible')
    .and('contain.text', 'Terms of Service');
});

Then('I should see the privacy policy modal', () => {
  cy.getByCyId('modal', 'privacy')
    .should('be.visible')
    .and('contain.text', 'Privacy Policy');
});

When('I close the modal', () => {
  cy.getByCy('modal-close').first().click();
});

Then('the modal should be closed', () => {
  cy.getByCy('modal').should('not.exist');
});
