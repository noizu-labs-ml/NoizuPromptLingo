// Prompts flow — golden path smoke coverage.
// Assumes seeded dev stack with one org.

import { loginAs, withFirstOrg } from "../support/seed";

describe("prompts flow", () => {
  beforeEach(() => {
    loginAs(
      Cypress.env("ADMIN_EMAIL") ?? "keith.brings@noizu.com",
      Cypress.env("ADMIN_PASSWORD") ?? "changeme123$!",
    );
  });

  it("navigates to prompts library", () => {
    withFirstOrg("prompts", () => {
      cy.getByCy("prompts-page", { timeout: 10_000 }).should("be.visible");
      // Either shows list or empty state — both are valid
      cy.get("[data-cy='prompts-list'], [data-cy='prompts-empty']").should("exist");
    });
  });

  it("creates a new prompt and redirects to detail", () => {
    withFirstOrg("prompts/new", (orgId) => {
      cy.getByCy("new-prompt-page", { timeout: 10_000 }).should("be.visible");
      cy.getByCy("new-prompt-name").type("Cypress smoke prompt");
      cy.getByCy("new-prompt-submit").click();
      cy.getByCy("prompt-detail-page", { timeout: 12_000 }).should("be.visible");
      cy.getByCy("prompt-detail-name").should("contain.text", "Cypress smoke prompt");
    });
  });

  it("publishes a version with body and template_vars, then renders in sandbox", () => {
    withFirstOrg("prompts/new", () => {
      cy.getByCy("new-prompt-name").type("Sandbox test prompt");
      cy.getByCy("new-prompt-submit").click();
      cy.getByCy("prompt-detail-page", { timeout: 12_000 }).should("be.visible");

      // Open editor
      cy.getByCy("prompt-edit-toggle").click();
      cy.getByCy("prompt-editor").should("be.visible");

      // Set body with template variable
      cy.getByCy("prompt-body-input").clear().type("hello {{name}}");

      // Set template_vars JSON
      cy.getByCy("prompt-template-vars-input").clear().type('{"name": {"type": "string"}}', {
        parseSpecialCharSequences: false,
      });

      // Publish
      cy.getByCy("prompt-publish-btn").click();
      cy.getByCy("prompt-current-version", { timeout: 10_000 }).should("be.visible");
      cy.getByCy("prompt-version-number").should("contain.text", "v1");

      // Switch to sandbox tab
      cy.getByCy("prompt-tab-sandbox").click();
      cy.getByCy("prompt-tab-sandbox-panel").should("be.visible");

      // Set binding name=world
      cy.getByCy("sandbox-binding-key").eq(0).clear().type("name");
      cy.getByCy("sandbox-binding-value").eq(0).clear().type("world");

      // Render
      cy.getByCy("sandbox-render-btn").click();
      cy.getByCy("sandbox-rendered", { timeout: 10_000 }).should("contain.text", "hello world");
    });
  });
});
