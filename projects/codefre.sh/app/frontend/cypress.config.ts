import { defineConfig } from "cypress";
import createBundler from "@bahmutov/cypress-esbuild-preprocessor";
import { addCucumberPreprocessorPlugin } from "@badeball/cypress-cucumber-preprocessor";
import { createEsbuildPlugin } from "@badeball/cypress-cucumber-preprocessor/esbuild";

async function setupCucumber(on: Cypress.PluginEvents, config: Cypress.PluginConfigOptions) {
  await addCucumberPreprocessorPlugin(on, config);
  on(
    "file:preprocessor",
    createBundler({
      plugins: [createEsbuildPlugin(config) as unknown as never],
    }),
  );
  return config;
}

export default defineConfig({
  e2e: {
    baseUrl: process.env.CYPRESS_BASE_URL || "http://127.0.0.1:8082",
    specPattern: [
      "cypress/e2e/**/*.cy.ts",
      "cypress/e2e/features/**/*.feature",
    ],
    supportFile: "cypress/support/e2e.ts",
    fixturesFolder: "cypress/fixtures",
    screenshotsFolder: "cypress/screenshots",
    videosFolder: "cypress/videos",
    video: false,
    viewportWidth: 1280,
    viewportHeight: 800,
    defaultCommandTimeout: 8000,
    retries: { runMode: 1, openMode: 0 },
    async setupNodeEvents(on, config) {
      return setupCucumber(on, config);
    },
  },
  component: {
    specPattern: "cypress/component/**/*.cy.{ts,tsx}",
    supportFile: "cypress/support/component.ts",
    indexHtmlFile: "cypress/support/component-index.html",
    devServer: {
      framework: "next",
      bundler: "webpack",
    },
    viewportWidth: 1000,
    viewportHeight: 700,
  },
});
