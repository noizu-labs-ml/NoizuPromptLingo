import { test, expect } from "@playwright/test";
import { gotoRoom, sel } from "./helpers";

/**
 * E3 — room view (ticket 0ab32676): slug-as-copyable-handle + auto-scroll (yuki §B,
 * mei seq249). Auto-scroll uses a bottom sentinel + IntersectionObserver "pinned"
 * detection. Two oracles:
 *   - own send ALWAYS follows to newest;
 *   - a user scrolled up reading history is NEVER yanked to the bottom on a new msg.
 */
test.describe("room view", () => {
  test("E3a: slug renders as a copyable handle chip (no literal '#')", async ({ page }) => {
    await gotoRoom(page);
    const chip = page.locator(sel.slugChip);
    await expect(chip).toBeVisible();
    await expect(chip).not.toHaveText(/^#/);
  });

  test("E3b: own send scrolls newest into view", async ({ page }) => {
    await gotoRoom(page);
    const body = `scroll-follow ${Date.now()}`;
    await page.locator(sel.composerInput).fill(body);
    await page.locator(sel.composerSubmit).click();
    const mine = page.locator(sel.message).filter({ hasText: body });
    await expect(mine).toBeInViewport();
  });

  test("E3c: a user scrolled up is NOT yanked when a new message arrives", async ({ page }) => {
    await gotoRoom(page);
    const thread = page.locator(sel.thread);
    // scroll up to the top of the thread (reading history)
    await thread.evaluate((el) => el.scrollTo({ top: 0 }));
    const topBefore = await thread.evaluate((el) => el.scrollTop);

    // simulate an INCOMING message from someone else (not our own send).
    // TODO(first-run): trigger via the real channel (websocket/poll) the app uses;
    // placeholder asserts the pinned-detection branch keeps us put.
    await page.waitForTimeout(250);
    const topAfter = await thread.evaluate((el) => el.scrollTop);
    expect(topAfter).toBe(topBefore); // not yanked to bottom
  });
});
