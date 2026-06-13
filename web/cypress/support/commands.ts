/// <reference types="cypress" />

// Custom commands following docs/testing/cypress-attributes.md

declare global {
  namespace Cypress {
    interface Chainable {
      getByCy(
        name: string,
        options?: Partial<Loggable & Timeoutable>,
      ): Chainable<JQuery<HTMLElement>>;
      getByCyId(
        name: string,
        id: string | number,
      ): Chainable<JQuery<HTMLElement>>;
      getByCyFor(
        name: string,
        forId: string | number,
      ): Chainable<JQuery<HTMLElement>>;
      withinScope(scopeName: string, fn: () => void): Chainable<void>;
      pair(
        name: string,
        id: string | number,
      ): Chainable<{ root: JQuery<HTMLElement>; mate: JQuery<HTMLElement> }>;
    }
  }
}

Cypress.Commands.add('getByCy', (name, options) =>
  cy.get(`[data-cy="${name}"]`, options),
);

Cypress.Commands.add('getByCyId', (name, id) =>
  cy.get(`[data-cy="${name}"][data-cy-id="${id}"]`),
);

Cypress.Commands.add('getByCyFor', (name, forId) =>
  cy.get(`[data-cy="${name}"][data-cy-for="${forId}"]`),
);

Cypress.Commands.add('withinScope', (scopeName, fn) => {
  cy.get(`[data-cy="${scopeName}"][data-cy-scope]`).within(fn);
});

Cypress.Commands.add('pair', (name, id) =>
  cy.wrap(null).then(() => {
    const rootSel = `[data-cy="${name}"][data-cy-id="${id}"]`;
    const mateSel = `[data-cy="${name}-list"][data-cy-for="${id}"]`;
    return cy.get(rootSel).then((root) => {
      return cy.get(mateSel).then((mate) => ({ root, mate }));
    });
  }),
);

export {};
