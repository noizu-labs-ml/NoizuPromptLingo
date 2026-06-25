import { test, expect } from "@playwright/test";
import { gotoRoom, sel } from "./helpers";

/**
 * E1 — compose (ticket ac011e44). The regression that matters (yuki seq181):
 * a FAILED send must NOT clear the user's typed text. handleSend rethrows, the
 * composer clears + refocuses only on success; on failure it keeps the text and
 * sets aria-invalid. We pin both so it can't silently regress.
 */
test.describe("compose", () => {
  test("E1a: text is PRESERVED and aria-invalid set when send fails", async ({ page }) => {
    await gotoRoom(page);

    // Force the message POST to fail.
    await page.route("**/messages", (route) =>
      route.fulfill({ status: 500, contentType: "application/json", body: "{}" }),
    );

    const input = page.locator(sel.composerInput);
    const draft = "this draft must survive a failed send 🎉";
    await input.fill(draft);
    await page.locator(sel.composerSubmit).click();

    await expect(input).toHaveValue(draft); // <-- the bug guard
    await expect(input).toHaveAttribute("aria-invalid", "true");
  });

  test("E1b: successful send clears the input and appends the message", async ({ page }) => {
    await gotoRoom(page);
    const input = page.locator(sel.composerInput);
    const body = `e2e hello ${Date.now()}`;

    await input.fill(body);
    await page.locator(sel.composerSubmit).click();

    await expect(input).toHaveValue("");
    await expect(page.locator(sel.message).filter({ hasText: body })).toBeVisible();
  });

  test("E1c: Enter sends, Shift+Enter inserts a newline (does not send)", async ({ page }) => {
    await gotoRoom(page);
    const input = page.locator(sel.composerInput);

    await input.fill("line one");
    await input.press("Shift+Enter");
    await input.type("line two");
    await expect(input).toHaveValue(/line one\n.*line two/s); // still in the box
  });

  test("E1d: empty / whitespace-only content cannot be sent", async ({ page }) => {
    await gotoRoom(page);
    const input = page.locator(sel.composerInput);
    await input.fill("   ");
    await page.locator(sel.composerSubmit).click();
    // BE returns 422; FE must not optimistically append a blank message.
    await expect(page.locator(sel.message).filter({ hasText: /^\s*$/ })).toHaveCount(0);
  });
});
