import { test, expect, type Page } from "@playwright/test";
import { dismissConsent } from "./helpers";

/**
 * E2E for the MCP client setup page (/app/mcp-keys):
 *  1. OAuth install snippets for Claude Code, Claude Desktop, Codex toml,
 *     Cursor, VS Code Copilot, and Grok — URL/OAuth only, no bearer.
 *  2. Nowhere on the page may a script export the legacy bare AUTH_TOKEN name.
 *  3. OAuth Default tab include editor — expand a group, disable one tool,
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
  await dismissConsent(page);
  await expect(page.getByRole("heading", { name: "MCP client setup" })).toBeVisible();
}

test.describe("MCP setup page", () => {
  test("OAuth install snippets cover Claude Code, Desktop, Codex toml, Cursor, VS Code, Grok", async ({ page }) => {
    await gotoMcpKeys(page);

    const oauthSnippet = page.locator("code[data-mcp-oauth-client]");
    await expect(oauthSnippet).toBeVisible();
    await expect(oauthSnippet).toHaveAttribute("data-mcp-oauth-client", "claude-code");
    await expect(oauthSnippet).toContainText("claude mcp add --transport http");
    await expect(oauthSnippet).not.toContainText("Authorization");

    const clients: { label: string; id: string; needle: string | RegExp }[] = [
      { label: "Claude Desktop", id: "claude-desktop", needle: "claude_desktop_config.json" },
      { label: "Claude Desktop", id: "claude-desktop", needle: "mcpServers" },
      { label: "Codex", id: "codex", needle: "[mcp_servers." },
      { label: "Codex", id: "codex", needle: "~/.codex/config.toml" },
      { label: "Cursor", id: "cursor", needle: ".cursor/mcp.json" },
      { label: "VS Code Copilot", id: "vscode", needle: ".vscode/mcp.json" },
      { label: "VS Code Copilot", id: "vscode", needle: '"type": "http"' },
      { label: "Grok", id: "grok", needle: "grok mcp add --transport http" },
    ];

    // Labels are unique on the OAuth picker; click once per client id.
    const seen = new Set<string>();
    for (const row of clients) {
      if (!seen.has(row.id)) {
        await page.getByRole("button", { name: row.label, exact: true }).first().click();
        seen.add(row.id);
      }
      await expect(oauthSnippet).toHaveAttribute("data-mcp-oauth-client", row.id);
      await expect(page.locator("body")).toContainText(row.needle);
      await expect(oauthSnippet).not.toContainText("Bearer");
    }

    await expect(page.getByText("Access is not unlimited.")).toBeVisible();
    await expect(page.locator("body")).not.toContainText("export AUTH_TOKEN=");
    await expect(page.locator("body")).not.toContainText("--bearer-token-env-var AUTH_TOKEN");
  });

  test("legacy-key snippets never use the bare AUTH_TOKEN name", async ({ page }) => {
    await gotoMcpKeys(page);

    const body = page.locator("body");
    await expect(body).not.toContainText("export AUTH_TOKEN=");
    await expect(body).not.toContainText("--bearer-token-env-var AUTH_TOKEN");
    // Org-scoped env var is only in the minted-key panel (state-dependent).
    // The OAuth Codex toml must not fall back to a bearer env var.
    await page.getByRole("button", { name: "Codex", exact: true }).first().click();
    const oauthSnippet = page.locator("code[data-mcp-oauth-client='codex']");
    await expect(oauthSnippet).toContainText("[mcp_servers.");
    await expect(oauthSnippet).not.toContainText(AUTH_ENV_PATTERN);
  });

  test("OAuth Default tab include editor persists a per-tool toggle", async ({ page }) => {
    await gotoMcpKeys(page);

    // Default MCP tab is the default tab of the OAuth panel. After a save the
    // page can render more than one "Included services" block (one per saved
    // endpoint) — pin to the first.
    const editorHeading = page.getByText("Included services", { exact: true }).first();
    await expect(editorHeading).toBeVisible();

    // Expand the first group that has an expand chevron.
    const expandBtn = page.getByRole("button", { name: /^Toggle tools for / }).first();
    await expandBtn.click();

    // First per-tool checkbox inside the expanded list.
    // The include checkbox's <label> wraps the mono tool-name span (the row
    // div carries the title tooltip now — label[title] no longer matches).
    const toolLabel = page.locator("label", { has: page.locator("span.font-mono") }).first();
    const toolCheckbox = toolLabel.locator('input[type="checkbox"]');
    await expect(toolCheckbox).toBeVisible();

    // IDEMPOTENT: flip from whatever state a previous run left behind, verify
    // the flip persisted across reload, then flip back and save — the spec
    // must not permanently mutate the endpoint's catalog.
    const initial = await toolCheckbox.isChecked();

    if (initial) {
      await toolCheckbox.uncheck();
    } else {
      await toolCheckbox.check();
    }

    const saveBtn = page.getByRole("button", { name: /^Save \(\d+\)$/ }).first();
    await saveBtn.click();
    // Toast confirmation or button returning to idle either way signals completion.
    await expect(page.getByText("Included services updated")).toBeVisible({ timeout: 10_000 });

    // Reload and confirm the flipped state persisted.
    await page.reload();
    await expect(editorHeading).toBeVisible();
    const expandBtn2 = page.getByRole("button", { name: /^Toggle tools for / }).first();
    await expandBtn2.click();
    const toolCheckbox2 = page
      .locator("label", { has: page.locator("span.font-mono") })
      .first()
      .locator('input[type="checkbox"]');
    await expect(toolCheckbox2).toBeVisible();
    await expect(toolCheckbox2).toBeChecked({ checked: !initial });

    // Restore the original state so reruns start clean.
    if (initial) {
      await toolCheckbox2.check();
    } else {
      await toolCheckbox2.uncheck();
    }
    await page.getByRole("button", { name: /^Save \(\d+\)$/ }).first().click();
    await expect(page.getByText("Included services updated")).toBeVisible({ timeout: 10_000 });
  });
});
