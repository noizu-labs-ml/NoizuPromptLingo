Cypress.Commands.add("twLogin", () => {
  const email = Cypress.env("TW_EMAIL");
  const password = Cypress.env("TW_PASSWORD");

  if (!email || !password) {
    throw new Error("TW_EMAIL and TW_PASSWORD must be set. Use cypress.env.json or CYPRESS_TW_EMAIL / CYPRESS_TW_PASSWORD env vars.");
  }

  cy.session(
    "tailwind-plus",
    () => {
      cy.visit("/plus/login");
      cy.get('input[type="email"], input[name="email"]').type(email);
      cy.get('input[type="password"], input[name="password"]').type(password, { log: false });
      cy.get('button[type="submit"]').click();
      cy.url().should("not.include", "/login");
    },
    {
      validate() {
        cy.visit("/plus/ui-blocks");
        cy.url().should("include", "/plus");
      },
    }
  );
});

declare global {
  namespace Cypress {
    interface Chainable {
      twLogin(): Chainable<void>;
    }
  }
}
