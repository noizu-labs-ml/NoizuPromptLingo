/**
 * Stage login driver: walks the real Authentik OIDC flow against a deployed
 * environment (default https://tobor-stage.noizu.com) and persists a
 * Playwright storageState the suite can consume (auth.setup.ts path A:
 * E2E_STORAGE_STATE, copied to e2e/.auth/state.json).
 *
 * First-run accounts are registered through the SPA's /auth/register page;
 * the IdP session is cached at e2e/.auth/idp-state.json (gitignored) so
 * re-runs skip the credential dance.
 *
 * Env:
 *   CY_EMAIL / CY_PASS   required — test-account credentials (capture via
 *                        `dc get auto cypress_test_email --reveal --raw`;
 *                        never inline or echo them)
 *   E2E_BASE_URL         default https://tobor-stage.noizu.com
 *   E2E_ORG              org handle to land on after login (default e2e-org;
 *                        must exist and have the account as a member)
 *   OUT                  storageState path (default e2e/.auth/state.json)
 */
import { chromium } from "playwright";
import fs from "node:fs";

const base = process.env.E2E_BASE_URL || "https://tobor-stage.noizu.com";
const org = process.env.E2E_ORG || "e2e-org";
const out = process.env.OUT || "e2e/.auth/state.json";
const idpState = "e2e/.auth/idp-state.json";
if (!process.env.CY_EMAIL || !process.env.CY_PASS) {
  console.error("CY_EMAIL / CY_PASS required (capture from dc, never inline)");
  process.exit(1);
}

const T0 = Date.now();
const log = (...a) => console.log("[login", Math.round((Date.now() - T0) / 1000) + "s]", ...a);

const browser = await chromium.launch();
const ctx = await browser.newContext({
  viewport: { width: 1280, height: 900 },
  storageState: fs.existsSync(idpState) ? idpState : undefined,
});
const page = await ctx.newPage();
page.on("response", r => { if (r.url().includes("/api/v1/auth/sso/")) log("api:", r.status(), r.request().method(), r.url().replace(base, "")); });

await page.goto(base + "/auth/oidc", { waitUntil: "domcontentloaded", timeout: 45000 });
for (let i = 0; i < 10; i++) {
  await page.waitForTimeout(3000);
  if (page.url().startsWith(base)) break; // IdP session cached → straight through
}
log("url now:", page.url().slice(0, 90));

// the cookie-consent modal overlays every SPA page and eats clicks
const acc = page.locator('button:has-text("Accept all")').first();
if (await acc.isVisible().catch(() => false)) {
  await acc.click().catch(() => {});
  log("cookie consent accepted");
}

if (page.url().includes("auth.derobot.is")) {
  await page.waitForTimeout(5000); // let the Lit flow executor wire up
  const user = page.locator('input[name="username"]').first();
  await user.fill(process.env.CY_EMAIL);
  await user.press("Enter");
  await page.waitForTimeout(5000);
  const pw = page.locator('input[name="password"]').first();
  await pw.fill(process.env.CY_PASS);
  await page.waitForTimeout(1000);
  await pw.press("Enter");
  await page.waitForTimeout(2000);
  // belt and braces: Continue click if the stage is still showing
  const cont = page.locator('button:has-text("Continue")').first();
  if (await cont.isVisible().catch(() => false)) {
    log("Continue still visible — clicking");
    await cont.click().catch(() => {});
  }
  log("credentials submitted");
}

// poll for the return to the SPA (60s)
let landed = false;
for (let i = 0; i < 12 && !landed; i++) {
  await page.waitForTimeout(5000);
  if (!page.url().includes("auth.derobot.is")) landed = true;
}
if (!landed) throw new Error("did not return from IdP; url: " + page.url());
log("landed:", page.url().slice(0, 110));

// cache IdP session for future runs
await ctx.storageState({ path: idpState });

if (page.url().includes("/auth/register")) {
  log("first-run registration");
  await page.locator("#first").waitFor({ timeout: 30000 });
  // #first exists in SSR HTML pre-hydration; the readonly #email only fills
  // once React is live and getRegistration(token) resolves. Wait for it.
  await page.waitForFunction(() => {
    const el = document.querySelector("#email");
    return el && el.value && el.value.length > 0;
  }, null, { timeout: 60000 }).catch(() => log("#email never filled — hydrating anyway"));
  await page.locator("#first").fill("Cypress");
  await page.locator("#last").fill("Tester");
  // click, then re-click until it takes (hydration race) or an error shows
  for (let i = 0; i < 12; i++) {
    await page.locator('button[type="submit"]').click().catch(() => {});
    await page.waitForTimeout(5000);
    const err = await page.locator(".sg-error").innerText().catch(() => "");
    if (err) throw new Error(err);
    const tok = await page.evaluate(() => localStorage.getItem("access_token")).catch(() => null);
    if (tok) break;
  }
}

await page.waitForFunction(() => !!localStorage.getItem("access_token"), null, { timeout: 90000 });
log("access_token present");

await page.goto(`${base}/app/${org}`, { waitUntil: "domcontentloaded", timeout: 45000 });
await page.waitForTimeout(3000);

await ctx.storageState({ path: out });
log("storageState written:", out);
await browser.close();
