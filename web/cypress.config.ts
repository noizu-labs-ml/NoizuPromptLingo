import { defineConfig } from 'cypress';
import createBundler from '@bahmutov/cypress-esbuild-preprocessor';
import { addCucumberPreprocessorPlugin } from '@badeball/cypress-cucumber-preprocessor';
import { createEsbuildPlugin } from '@badeball/cypress-cucumber-preprocessor/esbuild';

export default defineConfig({
  // allowCypressEnv: false — blocked by @badeball/cypress-cucumber-preprocessor
  // which calls Cypress.env() internally. Revisit when preprocessor updates.
  e2e: {
    baseUrl: 'http://localhost:3000',
    specPattern: 'e2e/features/**/*.feature',
    supportFile: 'cypress/support/e2e.ts',
    async setupNodeEvents(on, config) {
      await addCucumberPreprocessorPlugin(on, config);

      on(
        'file:preprocessor',
        createBundler({ plugins: [createEsbuildPlugin(config)] }),
      );

      return config;
    },
  },
});
