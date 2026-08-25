/**
 * Members page (pm_core membership read split) — stub-driven spec.
 *
 * The app shell needs an authenticated session + org context before
 * /app/:slug/members renders, so this stubs the whole chain (me →
 * organizations → projects) plus the endpoint under test, GET
 * /api/v1/memberships/organizations/:orgId — the viewer-gated PBAC members
 * list that must source user rows from pm_core and persona rows from the app
 * DB (backend scoped_memberships.ex, pm-core cutover fix). Fixtures:
 * cypress/fixtures/members/{me,orgs,list}.json.
 */

const ORG_SLUG = "acme";
const ORG_ID = "22222222-2222-4222-8222-222222222222";

describe("Members list (stubbed)", () => {
  beforeEach(() => {
    cy.intercept("GET", "**/api/v1/auth/sso/providers", { body: ["oidc"] }).as("ssoProviders");
    cy.intercept("GET", "**/api/v1/auth/me", { fixture: "members/me.json" }).as("me");
    cy.intercept("GET", "**/api/v1/organizations*", { fixture: "members/orgs.json" }).as("listOrgs");
    cy.intercept("GET", "**/api/v1/projects*", { body: { projects: [] } }).as("listProjects");
    cy.intercept("GET", "**/api/v1/memberships/organizations/*", {
      fixture: "members/list.json",
    }).as("listMembers");

    // AuthProvider only loads the user when a token is in localStorage, and the
    // Next proxy (src/proxy.ts) gates /app/* on an access_token COOKIE — prime
    // both from a throwaway page, then load the members route.
    cy.visit("/login");
    cy.window().then((win) => {
      win.localStorage.setItem("access_token", "cypress-stub-token");
      win.document.cookie = "access_token=cypress-stub-token; path=/";
    });
    cy.visit(`/app/${ORG_SLUG}/members`);
    cy.contains("h1", "Members").should("be.visible");
  });

  it("renders the owner row from the memberships endpoint", () => {
    cy.wait("@listMembers");
    cy.contains("tbody tr", "Org Owner").should("be.visible").and("contain", "owner");
    cy.contains("tbody tr", "owner@example.com").should("be.visible");
  });

  it("renders persona members alongside user members", () => {
    cy.wait("@listMembers");
    cy.contains("tbody tr", "Zara").should("be.visible").and("contain", "member");
    cy.contains("tbody tr", "Zara")
      .find('[data-member-type="persona"]')
      .should("contain", "Agent");
    cy.contains("tbody tr", "Zara").should("contain", "zara-agent");
  });

  it("fetches members from the viewer-gated memberships route", () => {
    cy.wait("@listMembers")
      .its("request.url")
      .should("include", `/api/v1/memberships/organizations/${ORG_ID}`);
  });
});
