# E2E suite (Playwright)

Browser tests for the SPA. `playwright.config.ts` runs two projects: `setup`
(`auth.setup.ts` — materializes `e2e/.auth/state.json`, gitignored) and
`chromium` (all `e2e/*.spec.ts`, which reuse that storageState and are skipped
if it is missing).

## Local stage lane

Run the whole suite against a deployed environment (stage by default) with a
real OIDC login:

```sh
cd frontend
CY_EMAIL=$(dc get auto cypress_test_email --reveal --raw) \
CY_PASS=$(dc get auto cypress_test_password --reveal --raw) \
E2E_BASE_URL=https://tobor-stage.noizu.com \
E2E_ORG=e2e-org \
E2E_ROOM=<room-uuid> \
  npm run e2e:stage
```

`e2e:stage` = `e2e/scripts/stage-login.mjs` (walks Authentik, handles
first-run registration, writes `e2e/.auth/state.json`, caches the IdP session
at `e2e/.auth/idp-state.json` for faster re-runs) followed by
`E2E_STORAGE_STATE=... playwright test`. Re-run just the suite with
`E2E_STORAGE_STATE="$PWD/e2e/.auth/state.json" npx playwright test` while the
state is fresh.

Stage prerequisites (seeded via the admin API with SOAK_ADMIN_JWT):

- org `e2e-org` with a chat room; pass the room uuid as `E2E_ROOM`
  (`helpers.ts` builds `/app/${org}/chat/${room}` URLs from `E2E_ORG`/`E2E_ROOM`)
- the test account is an org member (it self-registers on first login)

## Known spec drift (as of 2026-09-03)

All three current failures are test-side, not app bugs:

1. `compose.spec.ts` E1d — the app now disables Send for whitespace-only
   input; the spec still tries to click the disabled button. Fix: assert
   `toBeDisabled()` instead of clicking.
2. `mcp-setup.spec.ts` OAuth editor — `getByText('Included services')` now
   matches two panels (per-endpoint editor + OAuth Default tab editor). Fix:
   scope the locator to the "Connect MCP clients (OAuth)" region.
3. `reactions.spec.ts` E2d — the reaction picker closes after the first
   selection, so `Promise.all([click, click])` can never fire twice. The
   in-flight guard needs an intercept-delay or re-open-and-click harness.

## CI

Not wired yet: a CI lane needs stage credentials as repo secrets plus a
decision on whether CI may mutate stage data. Local lane above is the
supported path today.
