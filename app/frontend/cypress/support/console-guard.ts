// Opt-in console + uncaught-exception guard.
//
// Many specs pass visibly while the page is silently broken (e.g. provider
// context missing, hydration mismatch). Enable this guard inside a `describe`
// or `it` via `installConsoleGuard()`; it fails the test if the page logs an
// `error` or a React error-boundary fires during the test body.
//
// It deliberately does NOT install globally — some flows (auth 401, network
// fallbacks) legitimately log errors. Opt in per spec.

declare global {
  interface Window {
    __cyConsoleErrors?: string[];
  }
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace Cypress {
    interface Chainable {
      installConsoleGuard(options?: {
        ignore?: RegExp[];
      }): Chainable<void>;
      assertNoConsoleErrors(): Chainable<void>;
    }
  }
}

const DEFAULT_IGNORE: RegExp[] = [
  // Next.js dev warnings we don't care about during smoke
  /Download the React DevTools/i,
  /\[Fast Refresh\]/i,
  // HMR websocket noise
  /websocket.*closed/i,
];

Cypress.Commands.add("installConsoleGuard", (options = {}) => {
  const ignore = [...DEFAULT_IGNORE, ...(options.ignore ?? [])];
  cy.on("window:before:load", (win) => {
    win.__cyConsoleErrors = [];
    const origErr = win.console.error.bind(win.console);
    win.console.error = (...args: unknown[]) => {
      const text = args
        .map((a) => (a instanceof Error ? a.message : String(a)))
        .join(" ");
      if (!ignore.some((re) => re.test(text))) {
        win.__cyConsoleErrors!.push(text);
      }
      origErr(...args);
    };
  });
  cy.on("uncaught:exception", (err) => {
    const msg = err.message || String(err);
    if (ignore.some((re) => re.test(msg))) return false;
    // Record, then fail the test by re-throwing.
    throw err;
  });
});

Cypress.Commands.add("assertNoConsoleErrors", () => {
  cy.window().then((win) => {
    const errors = win.__cyConsoleErrors ?? [];
    if (errors.length > 0) {
      throw new Error(
        `Console errors detected (${errors.length}):\n${errors.join("\n---\n")}`,
      );
    }
  });
});

export {};
