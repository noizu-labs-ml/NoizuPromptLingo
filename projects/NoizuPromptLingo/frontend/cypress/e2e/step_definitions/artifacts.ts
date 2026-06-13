import { Given, When, Then } from "@badeball/cypress-cucumber-preprocessor";

// ── Background ───────────────────────────────────────────────────────────

Given("I am on the artifacts page", () => {
  cy.intercept("GET", "**/api/artifacts*", { fixture: "artifacts/list.json" }).as(
    "listArtifacts",
  );
  cy.visit("/artifacts");
  cy.getByCy("artifacts-page").should("exist");
});

// ── Filtering ────────────────────────────────────────────────────────────

Given("the artifacts API returns yaml-only results when filtered", () => {
  cy.intercept("GET", "**/api/artifacts*", {
    fixture: "artifacts/list-yaml.json",
  }).as("listArtifactsFiltered");
});

Given("the artifacts API returns empty results when filtered", () => {
  cy.intercept("GET", "**/api/artifacts*", {
    fixture: "artifacts/list-empty.json",
  }).as("listArtifactsEmpty");
});

// ── List ─────────────────────────────────────────────────────────────────

When("I click the first artifact card", () => {
  cy.getByCy("artifact-card").first().click();
});

// ── Detail stub ──────────────────────────────────────────────────────────

Given("the artifact detail API is stubbed", () => {
  cy.intercept("GET", "**/api/artifacts/1*", {
    fixture: "artifacts/detail-1.json",
  }).as("getArtifact");
  cy.intercept("GET", "**/api/artifacts/1/revisions*", {
    body: {
      revisions: [
        {
          id: 1013,
          artifact_id: 1,
          revision: 3,
          notes: null,
          created_by: null,
          created_at: "2026-04-22T12:00:00Z",
        },
      ],
    },
  }).as("listRevisions");
});

// ── Creation ─────────────────────────────────────────────────────────────

Given("the artifact creation API is stubbed", () => {
  cy.intercept("POST", "**/api/artifacts", {
    fixture: "artifacts/created.json",
  }).as("createArtifact");
});

Given("the artifact creation API will fail", () => {
  cy.intercept("POST", "**/api/artifacts", {
    statusCode: 500,
    body: { detail: "Internal server error" },
  }).as("createArtifactFail");
});

When("I click the create artifact button", () => {
  cy.getByCy("create-artifact-btn").click();
});
