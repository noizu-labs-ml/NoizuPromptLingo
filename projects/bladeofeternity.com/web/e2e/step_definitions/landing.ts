import { When, Then } from '@badeball/cypress-cucumber-preprocessor';

Then('I should see a hero section', () => {
  cy.getByCy('landing').should('be.visible');
});

// --- Carousel ---

When('I click the next carousel button', () => {
  cy.getByCy('carousel-next').click();
});

When('I click the previous carousel button', () => {
  cy.getByCy('carousel-prev').click();
});

Then('the carousel should advance to the next slide', () => {
  cy.getByCy('carousel-slide')
    .should('have.attr', 'data-cy-value')
    .and('not.equal', '0');
});

Then('the carousel should return to the previous slide', () => {
  cy.getByCy('carousel-slide').should('have.attr', 'data-cy-value', '0');
});

// --- Cookie consent ---

Then('I should see the cookie consent banner', () => {
  cy.getByCy('cookie-banner').should('be.visible');
});

When('I click {string} on the cookie banner', (buttonText: string) => {
  if (/accept all/i.test(buttonText)) {
    cy.getByCy('cookie-accept-all').click();
  } else {
    cy.getByCy('cookie-essential').click();
  }
});

Then('the cookie consent banner should disappear', () => {
  cy.getByCy('cookie-banner').should('not.exist');
});

Then(
  'localStorage {string} should equal {string}',
  (key: string, value: string) => {
    cy.window().then((win) => {
      expect(win.localStorage.getItem(key)).to.equal(value);
    });
  },
);
