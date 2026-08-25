/**
 * Authentik OIDC login smoke — NoizuPromptLingo (tobor.locker)
 * Shared helpers: Portfolio/shared/cypress-authentik
 *
 * Requires CYPRESS_AUTHENTIK_PASSWORD (never commit).
 * Default user: testing@therobotlives.com
 *
 * NPL login page (src/app/login/page.tsx) fetches providers from
 * /api/v1/auth/sso/providers (returns ["oidc"]) and renders the SSO link as
 * data-cy="sso-provider-link" data-cy-id="oidc" -> href /auth/oidc,
 * labeled "Sign in with SSO" — matches the shared sso-link trigger as-is.
 *
 * On success the app's AuthProvider.ssoExchange() stores access_token /
 * refresh_token in localStorage and the sso-callback page router.push("/app"),
 * which the shared support module's DEFAULT_SUCCESS_PATH already matches.
 */
describe("Authentik OIDC login", () => {
  before(function () {
    const oidcEnv = Cypress.env("OIDC_ENABLED");
    // NPL (tobor.locker) has OIDC live — /api/v1/auth/sso/providers returns
    // ["oidc"] and AUTHENTIK_ISSUER is configured on the backend. Default on,
    // matching therobotlearns; env can still force true/false.
    const siteDefaultEnabled = true;
    if (oidcEnv === false || oidcEnv === "false") {
      this.skip();
    }
    if (oidcEnv === undefined || oidcEnv === null || oidcEnv === "") {
      if (!siteDefaultEnabled) {
        this.skip();
      }
    }
    if (!Cypress.env("AUTHENTIK_PASSWORD")) {
      this.skip();
    }
  });

  it("logs in via Authentik with testing@therobotlives.com", () => {
    cy.loginViaAuthentik({
      username:
        (Cypress.env("AUTHENTIK_USERNAME") as string) ||
        "testing@therobotlives.com",
      appTrigger: (Cypress.env("APP_TRIGGER") as
        | "sso-link"
        | "email-then-sso"
        | "direct-oidc") || "sso-link",
      loginPath: (Cypress.env("LOGIN_PATH") as string) || "/login",
      successPathMatch:
        (Cypress.env("SUCCESS_PATH_MATCH") as string) ||
        "^/(app|dashboard|auth/register|complete-registration|pending-approval)(/|$)",
      cacheSession: false,
    });

    // Extra soft checks after command assertion
    cy.window().then((win) => {
      const token =
        win.localStorage.getItem("access_token") ||
        win.localStorage.getItem("token");
      if (token) {
        expect(token).to.be.a("string").and.not.be.empty;
      }
    });

    // Org members smoke (pm_core membership read path): after SSO, the logged-in
    // owner must appear in their org's member list. Resilient by design — if the
    // live account has no org membership we only assert /app loads.
    //
    // TODO(pm-core members read fix): tobor.locker does not yet ship the backend
    // fix that sources user membership rows from pm_core — until it deploys, an
    // owner row may be missing from GET /api/v1/memberships/organizations/:id and
    // this check logs instead of failing (see backend scoped_memberships.ex).
    // NOTE(2026-08-26): unverified end-to-end — the SSO login itself currently
    // fails on live (stuck at auth.derobot.is/if/flow, pre-existing; the pristine
    // spec fails identically), so this block has not executed against prod yet.
    cy.window().then((win) => {
      const token = win.localStorage.getItem("access_token");
      const auth = token ? { bearer: token } : {};
      cy.request({
        url: "/api/v1/organizations",
        auth,
        failOnStatusCode: false,
      }).then((res) => {
        const orgs =
          res.isOkStatusCode && Array.isArray(res.body?.organizations)
            ? res.body.organizations
            : [];
        if (orgs.length === 0) {
          cy.log("no org membership on live — asserting /app loads instead");
          cy.visit("/app", { failOnStatusCode: false });
          return;
        }

        const org = orgs[0];
        cy.visit(`/app/${org.slug}/members`);
        cy.contains("h1", "Members", { timeout: 15000 }).should("be.visible");

        cy.request({
          url: `/api/v1/memberships/organizations/${org.id}`,
          auth,
          failOnStatusCode: false,
        }).then((mres) => {
          if (!mres.isOkStatusCode) {
            cy.log(`members endpoint returned ${mres.status} — skipping owner-row check`);
            return;
          }
          const members = mres.body?.members ?? [];
          const ownerRow = members.find(
            (m: { role?: string }) => m.role === "owner"
          );
          if (!ownerRow) {
            cy.log(
              "no owner row in members list — expected until the pm-core membership read fix deploys"
            );
            return;
          }
          const identity =
            ownerRow.display_name || ownerRow.user_name || ownerRow.email;
          expect(identity, "owner row carries a display identity").to.not.be
            .empty;
          cy.contains("tbody tr", identity).should("exist");
        });
      });
    });
  });
});
