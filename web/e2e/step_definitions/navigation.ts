import { When, Then } from '@badeball/cypress-cucumber-preprocessor';

// Map display text to footer-link cy-id
const footerLinkIds: Record<string, string> = {
  'Contact Us': 'contact',
  'Terms of Service': 'terms',
  'Privacy Policy': 'privacy',
  'Cookie': 'cookie',
};

// --- Footer modals ---

When('I click {string} in the footer', (text: string) => {
  const id = footerLinkIds[text] ?? text.toLowerCase().replace(/\s+/g, '-');
  cy.getByCyId('footer-link', id).click();
});

Then('I should see the contact modal', () => {
  cy.getByCyId('modal', 'contact')
    .should('be.visible')
    .and('contain.text', 'General Inquiries');
});

Then('I should see the terms modal', () => {
  cy.getByCyId('modal', 'terms')
    .should('be.visible')
    .and('contain.text', 'Terms of Service');
});

Then('I should see the privacy modal', () => {
  cy.getByCyId('modal', 'privacy')
    .should('be.visible')
    .and('contain.text', 'Privacy Policy');
});

Then('I should see the cookie modal', () => {
  cy.getByCyId('modal', 'cookie')
    .should('be.visible')
    .and('contain.text', 'Cookie Policy');
});

Then('I should see the email {string}', (email: string) => {
  cy.getByCy('modal').contains(email).should('be.visible');
});

When('I close the footer modal', () => {
  cy.getByCy('modal-close').first().click();
});

Then('the footer modal should be closed', () => {
  cy.getByCy('modal').should('not.exist');
});

When('I click the modal background', () => {
  cy.getByCy('modal-overlay').click({ force: true });
});

// --- Direct page navigation ---

When('I visit the terms page', () => {
  cy.visit('/terms');
});

When('I visit the privacy page', () => {
  cy.visit('/privacy');
});

When('I visit the cookie page', () => {
  cy.visit('/cookie');
});

When('I visit the landing page', () => {
  cy.visit('/');
});

Then('I should see terms of service content', () => {
  cy.contains('Terms of Service').should('be.visible');
  cy.contains('Acceptance of Terms').should('be.visible');
});

Then('I should see privacy policy content', () => {
  cy.contains('Privacy Policy').should('be.visible');
  cy.contains('Information We Collect').should('be.visible');
});

Then('I should see cookie policy content', () => {
  cy.contains('Cookie Policy').should('be.visible');
});

Then('I should see a cookie information table', () => {
  cy.get('table').should('be.visible');
  cy.contains('_boe_session').should('be.visible');
});
