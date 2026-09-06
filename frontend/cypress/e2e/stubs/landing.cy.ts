/**
 * Landing page (public marketing surface) — stub-driven spec.
 *
 * The landing page is public (no /app cookie gate), but it fetches live caps
 * from GET /api/v1/public/marketing/status and posts emails to
 * POST /api/v1/public/marketing/signup — both stubbed here so the pricing
 * band's three states (promo available / exhausted / signups closed) can be
 * exercised deterministically. Runs against `next build && next start -p 8765`
 * (Next dev never hydrates under Cypress). Fixtures: cypress/fixtures/landing/.
 */

function visitLanding(statusFixture: string) {
  cy.intercept("GET", "**/api/v1/public/marketing/status", { fixture: `landing/${statusFixture}.json` }).as("status");
  cy.visit("/");
  cy.get('[data-cy="pricing"]').should("be.visible");
  return cy.wait("@status");
}

describe("Landing page (stubbed)", () => {
  it("renders the hero with the early-access CTA and real domains", () => {
    cy.intercept("GET", "**/api/v1/public/marketing/status", { fixture: "landing/status-promo.json" });
    cy.visit("/");
    cy.contains("h1", "Give your agents a place to put their work.").should("be.visible");
    cy.contains("a", "Get early access — $4.95/mo").should("be.visible");
    cy.contains(".tl-feature__name", "Agent Memory").should("be.visible");
    cy.contains(".tl-feature__name", "Tickets").should("be.visible");
  });

  it("shows the founding promo band + spots meter and awards the promo on signup", () => {
    cy.intercept("POST", "**/api/v1/public/marketing/signup", { fixture: "landing/signup-promo.json" }).as("signup");
    visitLanding("status-promo");

    cy.get('[data-cy="promo-band"]').should("be.visible").and("contain", "2 months free");
    cy.get('[data-cy="promo-spots"]').should("be.visible").and("contain", "37 of 100 founding spots left");
    cy.get('[data-cy="promo-meter"]').should("be.visible");

    cy.get('[data-cy="signup-email"]').first().type("founding@example.com");
    cy.get('[data-cy="signup-submit"]').first().click();

    cy.wait("@signup").its("request.body").should("deep.include", { email: "founding@example.com" });
    cy.get('[data-cy="signup-success"]')
      .should("be.visible")
      .and("have.attr", "data-cy-outcome", "promo_awarded")
      .and("contain", "2 months free at launch");
  });

  it("shows the active promo band without the count when counters are null (untracked/unlimited)", () => {
    // Live-stage contract: promo_active:true with null cap/remaining (and null
    // beta counters) must render the active band — no meter, no "N of M" —
    // and keep the form in normal (non-waitlist) mode.
    cy.intercept("POST", "**/api/v1/public/marketing/signup", { fixture: "landing/signup-promo.json" }).as("signup");
    visitLanding("status-promo-unlimited");

    cy.get('[data-cy="promo-band"]').should("be.visible").and("contain", "2 months free");
    cy.get('[data-cy="promo-band"]').should("not.contain", "founding spots left");
    cy.get('[data-cy="promo-meter"]').should("not.exist");
    cy.get('[data-cy="promo-spots"]').should("not.exist");

    cy.get('[data-cy="signup-form"]').should("have.attr", "data-cy-mode", "signup");
    cy.get('[data-cy="signup-email"]').first().type("unlimited@example.com");
    cy.get('[data-cy="signup-submit"]').first().click();

    cy.wait("@signup").its("request.body").should("deep.include", { email: "unlimited@example.com" });
    cy.get('[data-cy="signup-success"]')
      .should("be.visible")
      .and("have.attr", "data-cy-outcome", "promo_awarded");
  });

  it("flips the copy when the founding offer is exhausted", () => {
    visitLanding("status-exhausted");

    cy.get('[data-cy="promo-band"]').should("be.visible").and("contain", "Founding offer claimed");
    cy.get('[data-cy="promo-band"]').should("contain", "$4.95/mo from day one");
    cy.get('[data-cy="promo-meter"]').should("not.exist");
  });

  it("switches to waitlist mode when signups are closed", () => {
    cy.intercept("POST", "**/api/v1/public/marketing/signup", { fixture: "landing/signup-waitlist.json" }).as("signup");
    visitLanding("status-closed");

    cy.get('[data-cy="signup-form"]').should("have.attr", "data-cy-mode", "waitlist");
    cy.get('[data-cy="signup-submit"]').first().should("contain", "Join the waitlist");

    cy.get('[data-cy="signup-email"]').first().type("waitlisted@example.com");
    cy.get('[data-cy="signup-submit"]').first().click();

    cy.get('[data-cy="signup-success"]')
      .should("be.visible")
      .and("have.attr", "data-cy-outcome", "waitlisted")
      .and("contain", "on the waitlist");
  });
});
