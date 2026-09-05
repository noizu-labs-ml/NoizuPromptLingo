import { test, expect } from "@playwright/test";
import { gotoRoom, sel } from "./helpers";

/**
 * E4 — XSS-inert render (QA flag QF3). Backend stores message content VERBATIM
 * (correct: store raw, sanitize at render), so XSS protection lives entirely in
 * the FE render layer. Today it's inert by construction — message render is
 * `<div className="chat-message__body">{m.content}</div>`, a JSX text child React
 * escapes (priya seq231). This spec is the REGRESSION guard: if anyone ever adds
 * markdown / dangerouslySetInnerHTML to messages, these fail.
 */
test.describe("xss-inert render", () => {
  test("E4a: a <script> payload renders as inert text, never executes", async ({ page }) => {
    const dialogs: string[] = [];
    page.on("dialog", (d) => {
      dialogs.push(d.message());
      d.dismiss();
    });

    await gotoRoom(page);
    // Per-run nonce: the stage room is long-lived and older runs' payloads
    // accumulate — a bare hasText("<script>") resolves to N messages and
    // trips strict mode. The nonce pins the locator to THIS run's message.
    const nonce = Date.now();
    const payload = `<script>window.__xss=1;alert('xss')/*${nonce}*/</script>`;
    await page.locator(sel.composerInput).fill(payload);
    await page.locator(sel.composerSubmit).click();

    const node = page.locator(sel.message).filter({ hasText: `${nonce}` });
    await expect(node).toBeVisible();
    // it must be TEXT, not a live <script> element inside the body
    await expect(node.locator("script")).toHaveCount(0);
    expect(await page.evaluate(() => (window as any).__xss)).toBeUndefined();
    expect(dialogs).toEqual([]);
  });

  test("E4b: an <img onerror> payload does not fire", async ({ page }) => {
    let errored = false;
    page.on("console", (m) => {
      if (m.text().includes("__img_xss")) errored = true;
    });

    await gotoRoom(page);
    const nonce = Date.now();
    const payload = `<img src=x-${nonce} onerror="console.log('__img_xss')">`;
    await page.locator(sel.composerInput).fill(payload);
    await page.locator(sel.composerSubmit).click();

    const node = page.locator(sel.message).filter({ hasText: `x-${nonce}` });
    await expect(node).toBeVisible();
    await expect(node.locator("img")).toHaveCount(0); // rendered as text, no live <img>
    expect(errored).toBe(false);
  });
});
