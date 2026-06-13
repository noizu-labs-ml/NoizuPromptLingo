// Dead-page crawler. Visits every known route with the console guard armed —
// catches things like missing Provider context, hydration mismatches, or the
// silent "useX must be used within <XProvider>" class of bugs that have no
// visible selector but crash the page.
//
// New routes: just append to ROUTES. Public routes go above the auth block,
// authenticated routes below.

import { seed, loginAs, withFirstOrg } from "../support/seed";

const PUBLIC_ROUTES: string[] = [
  "/",
  "/login",
  "/signup",
];

const ORG_SECTIONS: string[] = [
  "",
  "prompts",
  "rubrics",
  "personas",
  "agents",
  "scripts",
  "runs",
  "review",
  "datasets",
  "otel",
  "webhooks",
  "settings",
];

const ORG_CREATE_PAGES: string[] = [
  "prompts/new",
  "rubrics/new",
  "personas/new",
  "agents/new",
  "scripts/new",
  "scripts/import",
];

describe("dead-page crawler — public", () => {
  PUBLIC_ROUTES.forEach((path) => {
    it(`renders without console errors: ${path}`, () => {
      cy.installConsoleGuard();
      cy.visit(path);
      // Give React time to flush errors from mount + effects.
      cy.wait(500);
      cy.assertNoConsoleErrors();
    });
  });
});

describe("dead-page crawler — authenticated", () => {
  beforeEach(() => {
    loginAs(seed.adminEmail(), seed.adminPassword());
  });

  ORG_SECTIONS.forEach((section) => {
    it(`renders without console errors: /app/<orgId>/${section || "(dashboard)"}`, () => {
      cy.installConsoleGuard({
        // These API 404s are expected when the DB is empty.
        ignore: [/Failed to fetch|NetworkError|404/i],
      });
      withFirstOrg(section, () => {
        cy.wait(800);
        cy.assertNoConsoleErrors();
      });
    });
  });

  ORG_CREATE_PAGES.forEach((section) => {
    it(`renders create/import page: /app/<orgId>/${section}`, () => {
      cy.installConsoleGuard({ ignore: [/Failed to fetch|NetworkError|404/i] });
      withFirstOrg(section, () => {
        cy.wait(600);
        cy.assertNoConsoleErrors();
      });
    });
  });
});
