import { test, expect, type Page } from "@playwright/test";

/**
 * E2E for the MCP client setup page (/app/mcp-keys):
 *  1. Org-scoped AUTH_TOKEN env var — no bare `export AUTH_TOKEN=` anywhere,
 *     and CLI snippets reference an *_AUTH_TOKEN env var name.
 *  2. OAuth Default tab include editor — expand a group, disable one tool,
 *     Save, reload, assert the toggle persisted.
 *
 * Auth is OIDC (see auth.setup.ts): specs only run with E2E_STORAGE_STATE set,
 * otherwise the setup project skips and these never execute authenticated.
 */

const MCP_KEYS_PATH = "/app/mcp-keys";

// Any org-scoped env var name (e.g. NOIZU_LABS_AUTH_TOKEN) or the fallback.
const AUTH_ENV_PATTERN = /[A-Z][A-Z0-9_]*_AUTH_TOKEN/;

async function gotoMcpKeys(page: Page) {
  await page.goto(MCP_KEYS_PATH);
  await expect(page.getByRole("heading", { name: "MCP client setup" })).toBeVisible();
}

test.describe("MCP setup page", () => {
  test("legacy-key snippets use the org-scoped AUTH env var, never bare AUTH_TOKEN", async ({ page }) => {
    await gotoMcpKeys(page);

    // OAuth panel renders CLI snippets (codex note) that must reference the
    // org-scoped env var name.
    const body = page.locator("body");
    await expect(body).toContainText(AUTH_ENV_PATTERN);

    // Nowhere on the page may a script export the legacy bare name.
    await expect(body).not.toContainText("export AUTH_TOKEN=");
    await expect(body).not.toContainText("--bearer-token-env-var AUTH_TOKEN");

    // Full-script assertion (needs a minted token) is backend-state dependent —
    // covered by the unit layer; here we assert the fallback name appears in
    // the codex snippet even when no org slug resolves.
    const codexSnippet = page.locator("code", { hasText: "codex mcp add" }).first();
    await expect(codexSnippet).toContainText(AUTH_ENV_PATTERN);
  });

  test("OAuth Default tab include editor persists a per-tool toggle", async ({ page }) => {
    await gotoMcpKeys(page);

    // Default MCP tab is the default tab of the OAuth panel.
    const editorHeading = page.getByText("Included services", { exact: true });
    await expect(editorHeading).toBeVisible();

    // Expand the first group that has an expand chevron.
    const expandBtn = page.getByRole("button", { name: /^Toggle tools for / }).first();
    await expandBtn.click();

    // First per-tool checkbox inside the expanded list.
    const toolLabel = page.locator("label[title]").filter({ has: page.locator('input[type="checkbox"]') }).first();
    const toolCheckbox = toolLabel.locator('input[type="checkbox"]');
    await expect(toolCheckbox).toBeVisible();
    await expect(toolCheckbox).toBeChecked();

    await toolCheckbox.uncheck();

    const saveBtn = page.getByRole("button", { name: /^Save \(\d+\)$/ });
    await saveBtn.click();
    // Toast confirmation or button returning to idle either way signals completion.
    await expect(page.getByText("Included services updated")).toBeVisible({ timeout: 10_000 });

    // Reload and confirm the tool stayed disabled.
    await page.reload();
    await expect(editorHeading).toBeVisible();
    const expandBtn2 = page.getByRole("button", { name: /^Toggle tools for / }).first();
    await expandBtn2.click();
    const toolCheckbox2 = page
      .locator("label[title]")
      .filter({ has: page.locator('input[type="checkbox"]') })
      .first()
      .locator('input[type="checkbox"]');
    await expect(toolCheckbox2).toBeVisible();
    await expect(toolCheckbox2).not.toBeChecked();
  });
});
