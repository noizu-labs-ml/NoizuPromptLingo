// Seed helpers — reads credentials from Cypress env vars.
// Set via cypress.config.ts env block or CI environment:
//   CYPRESS_INVITE_TOKEN, CYPRESS_ADMIN_EMAIL, CYPRESS_ADMIN_PASSWORD

export const seed = {
  inviteToken: (): string =>
    Cypress.env("INVITE_TOKEN") ?? "open-dev-invite",

  adminEmail: (): string =>
    Cypress.env("ADMIN_EMAIL") ?? "keith.brings@noizu.com",

  adminPassword: (): string =>
    Cypress.env("ADMIN_PASSWORD") ?? "changeme123$!",
};

/** Login and follow redirect; resolves when /app is reached. */
export function loginAs(email: string, password: string): void {
  cy.visit("/login");
  cy.getByCy("auth-email-input").type(email);
  cy.getByCy("auth-password-input").type(password);
  cy.getByCy("auth-submit").click();
  cy.location("pathname", { timeout: 12_000 }).should("eq", "/");
}

/** Navigate to the first org's section, skipping if no orgs exist. */
export function withFirstOrg(
  section: string,
  cb: (orgId: string) => void,
): void {
  cy.visit("/app");
  cy.getByCy("org-card", { timeout: 10_000 })
    .first()
    .invoke("attr", "data-cy-id")
    .then((slug) => {
      if (!slug) {
        cy.log("No orgs found — skipping test");
        return;
      }
      // The org-link href contains the UUID; extract it.
      cy.getByCy("org-card")
        .first()
        .find("[data-cy='org-link']")
        .invoke("attr", "href")
        .then((href) => {
          const orgId = (href ?? "").split("/app/")[1]?.split("/")[0];
          if (!orgId) {
            cy.log("Could not extract orgId — skipping");
            return;
          }
          cy.visit(`/app/${orgId}/${section}`);
          cb(orgId);
        });
    });
}
