// Scripts flow — golden path smoke coverage.
// Exercises: list, create, graph editor (add nodes + edge), attempt publish.

import { loginAs, withFirstOrg } from "../support/seed";

describe("scripts flow", () => {
  beforeEach(() => {
    loginAs(
      Cypress.env("ADMIN_EMAIL") ?? "keith.brings@noizu.com",
      Cypress.env("ADMIN_PASSWORD") ?? "changeme123$!",
    );
  });

  it("scripts list renders", () => {
    withFirstOrg("scripts", () => {
      cy.getByCy("scripts-page", { timeout: 10_000 }).should("be.visible");
      cy.get("[data-cy='scripts-list'], [data-cy='scripts-empty']").should("exist");
    });
  });

  it("creates a script via new-script page and opens editor", () => {
    withFirstOrg("scripts/new", () => {
      cy.getByCy("scripts-new-page", { timeout: 10_000 }).should("be.visible");
      cy.getByCy("scripts-new-name").type("Cypress smoke script");
      cy.getByCy("scripts-new-submit").click();
      cy.getByCy("script-editor", { timeout: 12_000 }).should("be.visible");
      cy.getByCy("script-canvas").should("be.visible");
    });
  });

  it("adds a user_turn node, a terminal node, draws an always edge, then attempts publish", () => {
    withFirstOrg("scripts/new", () => {
      cy.getByCy("scripts-new-name").type("Cypress edge script");
      cy.getByCy("scripts-new-submit").click();
      cy.getByCy("script-editor", { timeout: 12_000 }).should("be.visible");

      // Add user_turn node via palette
      cy.getByCy("script-palette").should("be.visible");
      cy.getByCyId("palette-add-node", "user_turn").click();
      cy.getByCy("graph-node").should("have.length.at.least", 1);

      // Add terminal node
      cy.getByCyId("palette-add-node", "terminal").click();
      cy.getByCy("graph-node").should("have.length.at.least", 2);

      // Initiate edge from first node — click source node to start edge mode
      cy.getByCy("graph-node").first().click();
      cy.getByCy("edge-source-hint").should("be.visible");

      // Click second node to complete edge
      cy.getByCy("graph-node").last().click();

      // Edge modal or direct creation — handle modal if it appears
      cy.get("body").then(($body) => {
        if ($body.find("[data-cy='edge-modal']").length > 0) {
          cy.getByCy("edge-match-method").select("always");
          cy.getByCy("edge-modal-submit").click();
        }
      });

      // At least one edge should now exist
      cy.getByCy("graph-edge").should("have.length.at.least", 1);

      // Attempt publish — expect success or specific validation failure
      cy.getByCy("script-publish").click();
      cy.get(
        "[data-cy='script-publish-status'], [data-cy='script-publish-issues'], [data-cy='script-editor-error']",
        { timeout: 10_000 },
      ).should("exist");
    });
  });
});
