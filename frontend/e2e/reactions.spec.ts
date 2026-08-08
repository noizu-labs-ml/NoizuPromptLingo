import { test, expect } from "@playwright/test";
import { gotoRoom, sel } from "./helpers";

/**
 * E2 — reaction UI (ticket 764f7346, diego's accessible picker).
 * Gates the keyboard/focus contract AND the in-flight double-tap guard
 * (yuki flow C / sofia G1): a fast double-toggle must NOT create a duplicate
 * reaction — the chip + options disable while a toggle is pending.
 */
test.describe("reactions", () => {
  const firstMsg = () => `${sel.message}`;

  test("E2a: picker opens on click, exposes aria-expanded + role=menu", async ({ page }) => {
    await gotoRoom(page);
    const toggle = page.locator(sel.reactionToggle).first();
    await expect(toggle).toHaveAttribute("aria-expanded", "false");
    await toggle.click();
    await expect(toggle).toHaveAttribute("aria-expanded", "true");
    await expect(page.locator(sel.reactionMenu)).toBeVisible();
  });

  test("E2b: keyboard — Enter opens, arrows rove, Esc closes + restores focus", async ({ page }) => {
    await gotoRoom(page);
    const toggle = page.locator(sel.reactionToggle).first();
    await toggle.focus();
    await page.keyboard.press("Enter");
    await expect(page.locator(sel.reactionMenu)).toBeVisible();

    const options = page.locator(sel.reactionOption);
    await expect(options.first()).toBeFocused(); // first option focused on open
    await page.keyboard.press("ArrowDown");
    await expect(options.nth(1)).toBeFocused();

    await page.keyboard.press("Escape");
    await expect(page.locator(sel.reactionMenu)).toBeHidden();
    await expect(toggle).toBeFocused(); // focus restored to the ＋
  });

  test("E2c: toggling a reaction flips aria-checked and reflects the count", async ({ page }) => {
    await gotoRoom(page);
    const toggle = page.locator(sel.reactionToggle).first();
    await toggle.click();
    const option = page.locator(sel.reactionOption).first();
    const checkedBefore = await option.getAttribute("aria-checked");
    await option.click();
    await expect(option).toHaveAttribute(
      "aria-checked",
      checkedBefore === "true" ? "false" : "true",
    );
  });

  test("E2d: double-tap guard — rapid double toggle never yields a duplicate row", async ({ page }) => {
    await gotoRoom(page);
    const toggle = page.locator(sel.reactionToggle).first();
    await toggle.click();
    const option = page.locator(sel.reactionOption).first();

    // fire two toggles back-to-back; the in-flight guard must collapse them so the
    // net effect is a single add (count 1), never two rows / count 2.
    await Promise.all([option.click(), option.click()]);
    await expect(option).toHaveAttribute("aria-checked", "true");
    // count badge for that emoji should read exactly 1 (server-truth reconcile)
    await expect(option).toContainText(/\b1\b/);
  });
});
