import { Given, When, Then, DataTable } from "@badeball/cypress-cucumber-preprocessor";
import { seed, loginAs } from "../seed";

// ─── Given steps ──────────────────────────────────────────────────────────────

Given("I am on the landing page", () => {
  cy.installConsoleGuard();
  cy.visit("/");
});

Given("I am on the login page", () => {
  cy.installConsoleGuard();
  cy.visit("/login");
});

Given("I am on the signup page", () => {
  cy.installConsoleGuard();
  cy.visit("/signup");
});

Given("I am logged in as the seeded admin", () => {
  loginAs(seed.adminEmail(), seed.adminPassword());
});

Given("I am on the workspace picker", () => {
  cy.installConsoleGuard();
  cy.visit("/app");
});

Given("I open my first workspace", () => {
  cy.visit("/app");
  cy.getByCy("org-card", { timeout: 10_000 })
    .first()
    .find("[data-cy='org-link']")
    .click();
  cy.getByCy("org-dashboard", { timeout: 10_000 }).should("be.visible");
});

Given(/^I navigate to the "([^"]+)" section$/, (section: string) => {
  cy.installConsoleGuard({ ignore: [/Failed to fetch|NetworkError|404/i] });
  cy.location("pathname").then((p) => {
    const orgId = p.split("/app/")[1]?.split("/")[0];
    if (!orgId) throw new Error("Not inside an org; step prerequisite missing");
    cy.visit(`/app/${orgId}/${section}`);
  });
});

// ─── When steps ───────────────────────────────────────────────────────────────

When(/^I type "([^"]*)" into the "([^"]+)" field$/, (value: string, cy_name: string) => {
  cy.getByCy(cy_name).clear().type(value);
});

When(/^I click "([^"]+)"$/, (cy_name: string) => {
  cy.getByCy(cy_name).click();
});

When("I submit the form", () => {
  cy.getByCy("auth-submit").click();
});

When("I press the command-palette shortcut", () => {
  cy.get("body").type("{meta}k");
});

// ─── Then steps ───────────────────────────────────────────────────────────────

Then(/^I see the "([^"]+)" element$/, (cy_name: string) => {
  cy.getByCy(cy_name).should("be.visible");
});

Then(/^I don't see the "([^"]+)" element$/, (cy_name: string) => {
  cy.getByCy(cy_name).should("not.exist");
});

Then(/^the URL is "([^"]+)"$/, (path: string) => {
  cy.location("pathname").should("eq", path);
});

Then(/^the URL matches "([^"]+)"$/, (pattern: string) => {
  cy.location("pathname").should("match", new RegExp(pattern));
});

Then(/^I see "([^"]+)" somewhere on the page$/, (text: string) => {
  cy.contains(text, { timeout: 8_000 }).should("be.visible");
});

Then(/^the page has no console errors$/, () => {
  cy.wait(400);
  cy.assertNoConsoleErrors();
});

Then(/^the "([^"]+)" element contains "([^"]+)"$/, (cy_name: string, text: string) => {
  cy.getByCy(cy_name).should("contain.text", text);
});

Then("I see at least one org card", () => {
  cy.getByCy("org-card", { timeout: 10_000 }).should("have.length.at.least", 1);
});

Then(/^I see the following dashboard cards:$/, (table: DataTable) => {
  const rows = table.raw().flat();
  cy.getByCy("dashboard-card").should("have.length.at.least", rows.length);
  rows.forEach((label) => {
    cy.getByCy("dashboard-card-title").contains(label).should("be.visible");
  });
});
