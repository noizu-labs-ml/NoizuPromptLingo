import { defineConfig } from "cypress";

/**
 * Dedicated config for stub-driven (intercept) specs.
 *
 * The main cypress.config.ts is cucumber-based but the cucumber preprocessor
 * packages are not installed, so it cannot load — plain .cy.ts specs run under
 * this config instead, mirroring the cypress.authentik.config.ts isolation
 * pattern. baseUrl points at the local Next dev server (npx next dev -p 8765).
 */
export default defineConfig({
  e2e: {
    baseUrl: "http://127.0.0.1:8765",
    specPattern: "cypress/e2e/stubs/**/*.cy.{ts,tsx}",
    supportFile: "cypress/support/e2e.ts",
    defaultCommandTimeout: 10000,
    video: false,
    screenshotOnRunFailure: true,
  },
  viewportWidth: 1280,
  viewportHeight: 720,
});
