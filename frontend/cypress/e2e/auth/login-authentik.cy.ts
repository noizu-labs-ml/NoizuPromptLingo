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
  });
});
