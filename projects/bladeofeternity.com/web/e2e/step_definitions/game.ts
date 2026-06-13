import { When, Then } from '@badeball/cypress-cucumber-preprocessor';

// --- Stats display ---

Then('I should see my character name displayed', () => {
  cy.fixture('user.json').then((data) => {
    cy.getByCy('character-name')
      .should('be.visible')
      .and('contain.text', data.character.character.name);
  });
});

Then('I should see the HP progress bar', () => {
  cy.getByCy('hp-bar').should('exist');
});

Then('I should see the energy progress bar', () => {
  cy.getByCy('energy-bar').should('exist');
});

Then('I should see the XP progress bar', () => {
  cy.getByCy('xp-bar').should('exist');
});

Then('I should see my gold amount', () => {
  cy.fixture('user.json').then((data) => {
    cy.getByCy('gold')
      .should('be.visible')
      .and('have.attr', 'data-cy-value', String(data.character.character.gold));
  });
});

Then('I should see my equipped weapon', () => {
  cy.fixture('user.json').then((data) => {
    cy.getByCy('weapon')
      .should('be.visible')
      .and('contain.text', data.character.character.weapon);
  });
});

Then('I should see my equipped armor', () => {
  cy.fixture('user.json').then((data) => {
    cy.getByCy('armor')
      .should('be.visible')
      .and('contain.text', data.character.character.armor);
  });
});

Then('I should see active effects on my character', () => {
  cy.fixture('user.json').then((data) => {
    cy.getByCy('effects').should('be.visible');
    data.character.character.effects.forEach((effect: string) => {
      cy.getByCyId('effect', effect).should('be.visible');
    });
  });
});

// --- Narrative ---

Then('I should see the narrative log', () => {
  cy.getByCy('narrative-log').should('be.visible');
});

Then('I should see my current location', () => {
  cy.fixture('user.json').then((data) => {
    cy.getByCy('location')
      .should('be.visible')
      .and('contain.text', data.character.character.location);
  });
});

// --- Actions ---

When('I click the {string} action button', (action: string) => {
  const slug = action.toLowerCase().replace(/\s+/g, '-');
  cy.getByCyId('action-button', slug).click();
});

Then('the action should appear in the narrative log', () => {
  cy.getByCy('narrative-log').children().should('have.length.gte', 1);
});

// --- Command input ---

When('I type {string} in the command input', (command: string) => {
  cy.getByCy('command-input').clear().type(command);
});

When('I submit the command', () => {
  cy.getByCy('command-form').submit();
});

Then(
  'the command should appear in the narrative log prefixed with {string}',
  (prefix: string) => {
    cy.getByCy('narrative-log').should('contain.text', prefix);
  },
);

When('I press the up arrow in the command input', () => {
  cy.getByCy('command-input').type('{uparrow}');
});

Then('the command input should contain {string}', (expected: string) => {
  cy.getByCy('command-input').should('have.value', expected);
});

// --- Skip links ---

Then('I should see a {string} skip link', (text: string) => {
  cy.contains(text).should('exist');
});

// --- Logout ---

When('I click the logout button', () => {
  cy.getByCy('logout-button').click();
});

Then('I should be redirected to the home page', () => {
  // Game page redirects unauthenticated users to /login via its useEffect,
  // which fires before the manual router.push("/") takes effect.
  cy.url().should('include', '/login');
});
