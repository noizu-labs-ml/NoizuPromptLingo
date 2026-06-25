import { test as setup } from "@playwright/test";
import fs from "node:fs";

const STATE = "e2e/.auth/state.json";

/**
 * Authenticate once and persist storageState for the spec projects.
 *
 * Auth is OIDC (no plain login form — dmitri seq251). The exact flow is locked
 * on FIRST RUN against the live app. Two supported paths:
 *
 *   A) Inject a session token captured from a logged-in browser:
 *        E2E_STORAGE_STATE=/path/to/state.json   (copied straight through), or
 *        E2E_SESSION_COOKIE="name=value; domain=..."  (set as a cookie).
 *
 *   B) Drive the IdP login (TODO once the dev IdP + creds are known):
 *        await page.goto("/login");
 *        ... complete the OIDC flow with E2E_USER / E2E_PASS ...
 *        await page.context().storageState({ path: STATE });
 */
setup("authenticate", async ({ page, context }) => {
  fs.mkdirSync("e2e/.auth", { recursive: true });

  const provided = process.env.E2E_STORAGE_STATE;
  if (provided && fs.existsSync(provided)) {
    fs.copyFileSync(provided, STATE);
    return;
  }

  // TODO(first-run): implement the OIDC login against the live dev IdP, then:
  //   await page.context().storageState({ path: STATE });
  // For now, fail loudly rather than run specs unauthenticated.
  await context.storageState({ path: STATE });
  setup.skip(
    !provided,
    "E2E auth not configured yet — set E2E_STORAGE_STATE (or implement the OIDC flow) once the dev IdP is known.",
  );
});
