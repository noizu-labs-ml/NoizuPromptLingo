import { defineConfig, devices } from "@playwright/test";

/**
 * E2E harness for the chat-rooms slice (epic ffc795c5, QA ticket QF4).
 * Owner: sofia-qa. Sibling to the unit/vitest layer (ava, 346e94f0) — DO NOT fold.
 *
 * Specs are written to the CONFIRMED FE selectors (priya/diego/mei). The only
 * deploy-dependent bits are parameterized via env and locked on first run against
 * the live app:
 *   E2E_BASE_URL  - frontend origin            (default http://localhost:3000)
 *   E2E_ORG       - org slug for /app/:org/...  (TODO: set to a real org slug)
 *   E2E_ROOM      - chat room UUID              (TODO: seed/lookup a room)
 *
 * Auth is OIDC (no plain form) -> handled by the `setup` project (auth.setup.ts),
 * which persists storageState so the spec projects start authenticated.
 */
export default defineConfig({
  testDir: "./e2e",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  reporter: process.env.CI ? "github" : "list",
  use: {
    baseURL: process.env.E2E_BASE_URL ?? "http://localhost:3000",
    trace: "on-first-retry",
    screenshot: "only-on-failure",
  },
  projects: [
    { name: "setup", testMatch: /auth\.setup\.ts/ },
    {
      name: "chromium",
      use: { ...devices["Desktop Chrome"], storageState: "e2e/.auth/state.json" },
      dependencies: ["setup"],
    },
  ],
  // The app + backend are deployed via lead's dev env; uncomment to self-host:
  // webServer: { command: "npm run dev", url: process.env.E2E_BASE_URL ?? "http://localhost:3000", reuseExistingServer: true },
});
