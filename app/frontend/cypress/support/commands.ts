// Custom commands — docs/cypress-attributes.md §4
// Selectors built on data-cy / data-cy-id / data-cy-for / data-cy-scope

declare global {
  namespace Cypress {
    interface Chainable {
      getByCy(
        name: string,
        options?: Partial<Cypress.Loggable & Cypress.Timeoutable>,
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
    }
  }
}

Cypress.Commands.add("getByCy", (name: string, options) =>
  cy.get(`[data-cy="${name}"]`, options),
);

Cypress.Commands.add("getByCyId", (name: string, id: string | number) =>
  cy.get(`[data-cy="${name}"][data-cy-id="${id}"]`),
);

Cypress.Commands.add("getByCyFor", (name: string, forId: string | number) =>
  cy.get(`[data-cy="${name}"][data-cy-for="${forId}"]`),
);

Cypress.Commands.add("withinScope", (scopeName: string, fn: () => void) => {
  cy.get(`[data-cy="${scopeName}"][data-cy-scope]`).within(fn);
});

export {};
