// Component-testing support. Loaded by every `cypress/component/*.cy.tsx` spec.
//
// Imports Next's global stylesheet so primitives render with Forge tokens,
// registers the `data-cy` custom commands, and exposes `cy.mount`.

import { mount } from "cypress/react18";
import "../../src/app/globals.css";
import "./commands";

declare global {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace Cypress {
    interface Chainable {
      mount: typeof mount;
    }
  }
}

Cypress.Commands.add("mount", mount);

// Force dark mode (Forge is dark-only).
before(() => {
  document.documentElement.classList.add("dark");
});
