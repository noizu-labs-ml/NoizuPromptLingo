# CodeFresh frontend test suite

Three layers, in increasing fidelity:

1. **Component isolation** (`cypress/component/*.cy.tsx`) — mount a single primitive, verify props/events/a11y wiring.
2. **Dead-page crawler** (`cypress/e2e/dead-pages.cy.ts`) — visit every route, fail on any `console.error` or uncaught exception. Catches the "silent broken page" class of bug (missing Provider context, hydration mismatch, bad env wiring).
3. **Gherkin features** (`cypress/e2e/features/*.feature`) — human-readable behavioral specs: auth, workspace shell, command palette.

## Run

Install once (dev-deps include Cypress + Cucumber preprocessor):

```bash
cd app/frontend
npm install
```

Then (dev stack must be up at `http://127.0.0.1:8082/` — baseUrl default; override with `CYPRESS_BASE_URL=…` if running against a remote stack):

| Command | What it runs |
|---|---|
| `npm run cypress:open` | Interactive runner (E2E mode) |
| `npm run cypress:run` | All E2E specs headless |
| `npm run cypress:smoke` | Original `smoke.cy.ts` only |
| `npm run cypress:features` | Only `.feature` files |
| `npm run cypress:deadpages` | Dead-page crawler |
| `npm run cypress:component` | Component isolation tests |
| `npm run cypress:component:open` | Interactive component runner |

## Adding a feature

1. Write Gherkin in `cypress/e2e/features/<name>.feature`.
2. Reuse steps in `cypress/support/step_definitions/common.steps.ts` where possible; add new ones there.
3. Every `Then I see "<cy-name>"` step maps to a `data-cy` attribute — follow `docs/cypress-attributes.md` when wiring new attributes.

## Adding a dead-page check

New route? Append its path to `PUBLIC_ROUTES` or `ORG_SECTIONS` in `cypress/e2e/dead-pages.cy.ts`. The crawler visits it, waits for effects to flush, and fails if any `console.error` fires (minus allow-listed dev warnings).

## Console guard

`cy.installConsoleGuard({ ignore: [/regex/] })` captures `console.error` + uncaught exceptions during the test. Pair with `cy.assertNoConsoleErrors()` at the end. Enable per-test — some flows legitimately log (expected 401s, optional telemetry).

## Component testing — why

Dead pages like the `useCommandPalette` provider crash only surface in context. Component tests let us reproduce the same bug (see `cypress/component/CommandPalette.cy.tsx`) in isolation — mount the provider + consumer, verify the hook resolves. This class of regression test is cheap and fast.
