// Runs flow — golden path smoke coverage.
// The runs page may show empty state, runner-missing state, or actual runs —
// all three are acceptable in a seeded dev environment.

import { loginAs, withFirstOrg } from "../support/seed";

describe("runs flow", () => {
  beforeEach(() => {
    loginAs(
      Cypress.env("ADMIN_EMAIL") ?? "keith.brings@noizu.com",
      Cypress.env("ADMIN_PASSWORD") ?? "changeme123$!",
    );
  });

  it("runs page renders in some valid state", () => {
    withFirstOrg("runs", () => {
      // Accept: page with list/empty OR the runner-missing placeholder
      cy.get(
        "[data-cy='runs-page'], [data-cy='runs-runner-missing']",
        { timeout: 12_000 },
      ).should("exist");
    });
  });

  it("runs page shows trigger button or runner-missing banner", () => {
    withFirstOrg("runs", () => {
      cy.get("body", { timeout: 12_000 }).then(($body) => {
        if ($body.find("[data-cy='runs-runner-missing']").length > 0) {
          cy.getByCy("runs-runner-missing").should("be.visible");
          cy.log("Runner not deployed — acceptable in dev stack");
        } else {
          cy.getByCy("runs-page").should("be.visible");
          cy.getByCy("runs-trigger").should("be.visible");
          // Either a list of runs or the empty state
          cy.get("[data-cy='runs-list'], [data-cy='runs-empty']").should("exist");
        }
      });
    });
  });

  it("runs-error is not visible on initial load when stack is healthy", () => {
    withFirstOrg("runs", () => {
      cy.get("body", { timeout: 12_000 }).then(($body) => {
        if ($body.find("[data-cy='runs-runner-missing']").length > 0) {
          cy.log("Runner missing — skipping error assertion");
          return;
        }
        cy.getByCy("runs-error").should("not.exist");
      });
    });
  });
});
