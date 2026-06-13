// Smoke suite — runs on every PR. Confirms the stack is reachable end-to-end:
// login/signup render, invite-token validation works, happy-path login + org
// list, workspace dashboard section cards.

import { seed, loginAs } from "../support/seed";

describe("smoke — public pages render", () => {
  it("landing page loads at /", () => {
    cy.visit("/");
    cy.contains(/codefresh|codefre\.sh/i, { timeout: 10_000 });
  });

  it("login page renders AuthCard", () => {
    cy.visit("/login");
    cy.getByCy("auth-card").should("be.visible");
    cy.getByCy("auth-email-input").should("be.visible");
    cy.getByCy("auth-password-input").should("be.visible");
  });

  it("signup page renders AuthCard with invite-token field", () => {
    cy.visit("/signup");
    cy.getByCy("auth-card").should("be.visible");
    cy.getByCy("invite-token-input").should("be.visible");
    cy.getByCy("auth-email-input").should("be.visible");
    cy.getByCy("auth-password-input").should("be.visible");
  });

  it("signup without invite token shows error", () => {
    cy.visit("/signup");
    cy.getByCy("auth-email-input").type("nobody@test.local");
    cy.getByCy("auth-password-input").type("password123");
    // leave invite-token blank
    cy.getByCy("auth-submit").click();
    cy.getByCy("auth-error").should("be.visible");
  });

  it("signup with invalid invite token shows server error", () => {
    cy.visit("/signup");
    cy.getByCy("invite-token-input").type("invalid-token-xyz");
    cy.getByCy("auth-email-input").type("newuser@test.local");
    cy.getByCy("auth-password-input").type("password123");
    cy.getByCy("auth-submit").click();
    cy.getByCy("auth-error").should("be.visible");
  });
});

describe("smoke — login happy path", () => {
  it("logs in with seeded credentials and redirects to /", () => {
    loginAs(seed.adminEmail(), seed.adminPassword());
    cy.location("pathname").should("eq", "/");
  });

  it("rejects wrong password", () => {
    cy.visit("/login");
    cy.getByCy("auth-email-input").type(seed.adminEmail());
    cy.getByCy("auth-password-input").type("wrong-password-xyz");
    cy.getByCy("auth-submit").click();
    cy.getByCy("auth-error").should("contain.text", /invalid/i);
  });
});

describe("smoke — org list + workspace dashboard", () => {
  beforeEach(() => {
    loginAs(seed.adminEmail(), seed.adminPassword());
  });

  it("/app shows org list with at least one seeded org", () => {
    cy.visit("/app");
    cy.getByCy("orgs-list", { timeout: 10_000 }).should("be.visible");
    cy.getByCy("org-card").should("have.length.at.least", 1);
    cy.getByCy("org-name").first().should("not.be.empty");
  });

  it("clicking org card navigates to dashboard with 6 section cards", () => {
    cy.visit("/app");
    cy.getByCy("org-card", { timeout: 10_000 }).first().find("[data-cy='org-link']").click();
    cy.getByCy("org-dashboard", { timeout: 10_000 }).should("be.visible");
    cy.getByCy("dashboard-card").should("have.length", 6);
    cy.getByCy("dashboard-title").should("be.visible");
  });
});
