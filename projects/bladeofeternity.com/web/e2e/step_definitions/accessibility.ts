import { Then } from '@badeball/cypress-cucumber-preprocessor';

Then('the narrative log should have aria-live {string}', (value: string) => {
  cy.getByCy('narrative-log').should('have.attr', 'aria-live', value);
});

Then('the HP bar should have role {string}', (role: string) => {
  cy.getByCy('hp-bar').should('have.attr', 'role', role);
});

Then('the energy bar should have role {string}', (role: string) => {
  cy.getByCy('energy-bar').should('have.attr', 'role', role);
});

Then('the XP bar should have role {string}', (role: string) => {
  cy.getByCy('xp-bar').should('have.attr', 'role', role);
});

Then('the email input should have autocomplete {string}', (value: string) => {
  cy.getByCy('email-input').should('have.attr', 'autocomplete', value);
});

Then(
  'the password input should have autocomplete {string}',
  (value: string) => {
    cy.getByCy('password-input').should('have.attr', 'autocomplete', value);
  },
);

Then('the honeypot field should be hidden', () => {
  cy.getByCy('honeypot').should('not.be.visible');
});

Then('the error message should have role {string}', (role: string) => {
  cy.getByCy('error-alert').should('have.attr', 'role', role);
});
