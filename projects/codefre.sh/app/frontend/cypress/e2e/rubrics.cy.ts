// Rubrics flow — golden path smoke coverage.

import { loginAs, withFirstOrg } from "../support/seed";

describe("rubrics flow", () => {
  beforeEach(() => {
    loginAs(
      Cypress.env("ADMIN_EMAIL") ?? "keith.brings@noizu.com",
      Cypress.env("ADMIN_PASSWORD") ?? "changeme123$!",
    );
  });

  it("rubrics list renders", () => {
    withFirstOrg("rubrics", () => {
      cy.getByCy("rubrics-page", { timeout: 10_000 }).should("be.visible");
      cy.get("[data-cy='rubrics-list'], [data-cy='rubrics-empty']").should("exist");
    });
  });

  it("creates a rubric and redirects to detail", () => {
    withFirstOrg("rubrics/new", () => {
      cy.getByCy("rubric-new-page", { timeout: 10_000 }).should("be.visible");
      cy.getByCy("rubric-new-name").type("Cypress smoke rubric");
      cy.getByCy("rubric-new-submit").click();
      cy.getByCy("rubric-detail-page", { timeout: 12_000 }).should("be.visible");
      cy.getByCy("rubric-name").should("contain.text", "Cypress smoke rubric");
    });
  });

  it("publishes a version with continuous scale and 1 criterion", () => {
    withFirstOrg("rubrics/new", () => {
      cy.getByCy("rubric-new-name").type("Scale rubric");
      cy.getByCy("rubric-new-submit").click();
      cy.getByCy("rubric-detail-page", { timeout: 12_000 }).should("be.visible");

      // Ensure scale editor is visible and set to continuous
      cy.getByCy("scale-method-select").should("exist").select("continuous");

      // Add a criterion
      cy.getByCy("criterion-add").click();
      cy.getByCy("criterion-name").first().type("Accuracy");

      // Publish
      cy.getByCy("rubric-publish-btn").click();
      cy.getByCy("rubric-published-badge", { timeout: 10_000 }).should("exist");
    });
  });

  it("previews rubric with sample input and response", () => {
    withFirstOrg("rubrics", () => {
      // Navigate to first available rubric that has a published version
      cy.getByCy("rubric-row", { timeout: 10_000 })
        .first()
        .find("[data-cy='rubric-detail-link']")
        .click();

      cy.getByCy("rubric-detail-page", { timeout: 10_000 }).should("be.visible");

      cy.getByCy("rubric-preview-btn").then(($btn) => {
        if ($btn.length === 0) {
          cy.log("No preview button — rubric may be unpublished, skipping preview assertion");
          return;
        }
        cy.getByCy("preview-sample-input").type("What is the capital of France?");
        cy.getByCy("preview-sample-response").type("The capital of France is Paris.");
        cy.getByCy("rubric-preview-btn").click();
        cy.getByCy("rubric-preview-section", { timeout: 15_000 }).should("be.visible");
      });
    });
  });

  it("marketplace page renders", () => {
    withFirstOrg("rubrics/marketplace", () => {
      cy.getByCy("rubrics-marketplace-page", { timeout: 10_000 }).should("be.visible");
      cy.get("[data-cy='marketplace-list'], [data-cy='marketplace-empty']").should("exist");
    });
  });
});
