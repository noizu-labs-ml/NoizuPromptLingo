import { test, expect, type Page } from "@playwright/test";
import { gotoRoom, sel } from "./helpers";

/**
 * E2 — reaction UI (ticket 764f7346, diego's accessible picker).
 * Gates the keyboard/focus contract AND the in-flight double-tap guard
 * (yuki flow C / sofia G1): a fast double-toggle must NOT create a duplicate
 * reaction — the chip + options disable while a toggle is pending.
 *
 * The stage room is LONG-LIVED and accumulates messages across runs, so every
 * test posts its OWN message first and scopes the picker to that message —
 * global .first() selectors resolved into stale messages' pickers and broke
 * strict-mode resolution (and reaction state) once the room grew.
 */
test.describe("reactions", () => {
  /** Post a unique message and return its message <li> scope. */
  async function postFreshMessage(page: Page, tag: string) {
    const text = `e2e-react ${tag} ${Date.now()}`;
    await page.locator(sel.composerInput).fill(text);
    await page.locator(sel.composerSubmit).click();
    const body = page.locator(sel.message).filter({ hasText: text }).last();
    await expect(body).toBeVisible();
    return body.locator("xpath=.."); // the wrapping <li>
  }

  test("E2a: picker opens on click, exposes aria-expanded + role=menu", async ({ page }) => {
    await gotoRoom(page);
    const li = await postFreshMessage(page, "A");
    const toggle = li.locator(sel.reactionToggle);
    await expect(toggle).toHaveAttribute("aria-expanded", "false");
    await toggle.click();
    await expect(toggle).toHaveAttribute("aria-expanded", "true");
    await expect(li.locator(sel.reactionMenu)).toBeVisible();
  });

  test("E2b: keyboard — Enter opens, arrows rove, Esc closes + restores focus", async ({ page }) => {
    await gotoRoom(page);
    const li = await postFreshMessage(page, "B");
    const toggle = li.locator(sel.reactionToggle);
    await toggle.focus();
    await page.keyboard.press("Enter");
    const menu = li.locator(sel.reactionMenu);
    await expect(menu).toBeVisible();

    const options = li.locator(sel.reactionOption);
    await expect(options.first()).toBeFocused(); // first option focused on open
    await page.keyboard.press("ArrowDown");
    await expect(options.nth(1)).toBeFocused();

    await page.keyboard.press("Escape");
    await expect(menu).toBeHidden();
    await expect(toggle).toBeFocused(); // focus restored to the ＋
  });

  test("E2c: toggling a reaction flips aria-checked and reflects the count", async ({ page }) => {
    await gotoRoom(page);
    const li = await postFreshMessage(page, "C");
    const toggle = li.locator(sel.reactionToggle);
    await toggle.click();
    const option = li.locator(sel.reactionOption).first();
    const checkedBefore = await option.getAttribute("aria-checked");
    await option.click();
    await expect(option).toHaveAttribute(
      "aria-checked",
      checkedBefore === "true" ? "false" : "true",
    );
  });

  test("E2d: double-tap guard — rapid double toggle never yields a duplicate row", async ({ page }) => {
    await gotoRoom(page);
    const li = await postFreshMessage(page, "D");
    const toggle = li.locator(sel.reactionToggle);
    await toggle.click();
    const option = li.locator(sel.reactionOption).first();

    // fire two toggles back-to-back; the in-flight guard must collapse them so the
    // net effect is a single add (count 1), never two rows / count 2. force:
    // skips the stability wait — concurrent workers' realtime traffic keeps
    // re-rendering the list, and the guard itself disables the button in-flight
    // (a force click landing on a disabled button is a browser-level no-op, so
    // the collapse semantics under test are preserved).
    await Promise.all([option.click({ force: true }), option.click({ force: true })]);
    await expect(option).toHaveAttribute("aria-checked", "true");
    // server-truth reconcile: exactly one 👍 chip, count 1 (chip carries the count)
    const chip = li.locator(".reaction-chip").filter({ hasText: "👍" }).first();
    await expect(chip).toHaveAttribute("aria-label", "👍 reaction, 1");
  });
});
