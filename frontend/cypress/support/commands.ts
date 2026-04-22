declare global {
  namespace Cypress {
    interface Chainable {
      getByCy(selector: string): Chainable<JQuery<HTMLElement>>;
      getByCyId(selector: string, id: string | number): Chainable<JQuery<HTMLElement>>;
      getByCyScope(scope: string): Chainable<JQuery<HTMLElement>>;
    }
  }
}

Cypress.Commands.add("getByCy", (selector: string) => {
  return cy.get(`[data-cy="${selector}"]`);
});

Cypress.Commands.add("getByCyId", (selector: string, id: string | number) => {
  return cy.get(`[data-cy="${selector}"][data-cy-id="${id}"]`);
});

Cypress.Commands.add("getByCyScope", (scope: string) => {
  return cy.get(`[data-cy-scope="${scope}"]`);
});

export {};
