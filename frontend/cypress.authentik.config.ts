import { defineConfig } from "cypress";

/**
 * Dedicated config for Authentik OIDC specs.
 * Isolates chromeWebSecurity:false and .cy.ts pattern from any cucumber-only configs.
 * Ported from therobotlives.com/app/frontend/cypress.authentik.config.ts.
 */
export default defineConfig({
  e2e: {
    baseUrl: process.env.CYPRESS_BASE_URL || "https://tobor.locker",
    specPattern: "cypress/e2e/auth/**/*.cy.{ts,tsx}",
    supportFile: "cypress/support/e2e.ts",
    chromeWebSecurity: false,
    defaultCommandTimeout: 20000,
    pageLoadTimeout: 60000,
    video: false,
    screenshotOnRunFailure: true,
    env: {
      AUTHENTIK_USERNAME: process.env.CYPRESS_AUTHENTIK_USERNAME || process.env.CYPRESS_TEST_EMAIL || "testing@therobotlives.com",
      // Password only via env — never hardcode
      AUTHENTIK_PASSWORD: process.env.CYPRESS_AUTHENTIK_PASSWORD || process.env.CYPRESS_TEST_PASSWORD || "",
      AUTHENTIK_ORIGIN: process.env.CYPRESS_AUTHENTIK_ORIGIN || "https://auth.derobot.is",
      OIDC_ENABLED: process.env.CYPRESS_OIDC_ENABLED ?? process.env.OIDC_ENABLED,
    },
  },
});
