// Personas flow — golden path smoke coverage.

import { loginAs, withFirstOrg } from "../support/seed";

describe("personas flow", () => {
  beforeEach(() => {
    loginAs(
      Cypress.env("ADMIN_EMAIL") ?? "keith.brings@noizu.com",
      Cypress.env("ADMIN_PASSWORD") ?? "changeme123$!",
    );
  });

  it("personas list renders", () => {
    withFirstOrg("personas", () => {
      cy.getByCy("personas-page", { timeout: 10_000 }).should("be.visible");
      cy.get("[data-cy='personas-list'], [data-cy='personas-empty']").should("exist");
    });
  });

  it("imports hostile starter persona and verifies it appears in list", () => {
    withFirstOrg("personas", () => {
      cy.getByCy("personas-page", { timeout: 10_000 }).should("be.visible");

      // Capture initial persona count
      cy.getByCy("persona-row").then(($rows) => {
        const initialCount = $rows.length;

        // Open starter modal
        cy.getByCy("personas-import-starter").click();
        cy.getByCy("starter-library-modal", { timeout: 8_000 }).should("be.visible");

        // Wait for starters to load
        cy.getByCy("starters-loading").should("not.exist");

        // Find and import the hostile starter (fall back to first available)
        cy.get("[data-cy='starter-row']").then(($starters) => {
          if ($starters.length === 0) {
            cy.getByCy("starters-empty").should("exist");
            cy.log("No starters available — skipping import assertion");
            cy.getByCy("starter-modal-close").click();
            return;
          }

          const hostileRow = $starters.filter("[data-cy-id='hostile']");
          const targetRow = hostileRow.length > 0 ? cy.getByCyId("starter-row", "hostile") : cy.getByCy("starter-row").first();

          targetRow.find("[data-cy='starter-import']").click();

          // Modal should close and persona should appear in list
          cy.getByCy("starter-library-modal").should("not.exist");
          cy.getByCy("persona-row", { timeout: 10_000 }).should(
            "have.length.at.least",
            initialCount + 1,
          );
          cy.getByCy("persona-name").should("be.visible");
        });
      });
    });
  });

  it("creates a new blank persona", () => {
    withFirstOrg("personas", () => {
      cy.getByCy("personas-page", { timeout: 10_000 }).should("be.visible");
      cy.getByCy("personas-create").click();
      cy.getByCy("personas-create-form").should("be.visible");
      cy.getByCy("personas-name-input").type("Cypress persona");
      cy.getByCy("personas-create-submit").click();
      cy.getByCy("persona-row", { timeout: 10_000 })
        .filter(":contains('Cypress persona')")
        .should("exist");
    });
  });
});
