/**
 * Playwright wrapper executing the cloud Browser.* actions against a single
 * long-lived chromium page. Every method is defensive: a thrown Playwright
 * error is surfaced to the caller, which turns it into a `command_result`
 * error rather than crashing the controller.
 */

import { chromium, type Browser, type Page } from "playwright";

export interface CommandResult {
  ok: boolean;
  data?: unknown;
  error?: string;
}

interface NavigateParams {
  url: string;
}
interface ScreenshotParams {
  full_page?: boolean;
  selector?: string;
}
interface ClickParams {
  selector: string;
}
interface FillParams {
  selector: string;
  value: string;
}
interface StateParams {
  include_text?: boolean;
}

export class BrowserDriver {
  private browser: Browser | null = null;
  private page: Page | null = null;

  constructor(private readonly headless: boolean) {}

  async start(): Promise<void> {
    this.browser = await chromium.launch({ headless: this.headless });
    this.page = await this.browser.newPage();
  }

  async stop(): Promise<void> {
    await this.browser?.close().catch(() => {});
    this.browser = null;
    this.page = null;
  }

  private requirePage(): Page {
    if (!this.page) throw new Error("browser page not initialized");
    return this.page;
  }

  /**
   * Execute one action. Never throws — always resolves to a CommandResult so
   * the channel can reply with a structured ok/error payload.
   */
  async execute(action: string, params: unknown): Promise<CommandResult> {
    try {
      switch (action) {
        case "navigate":
          return await this.navigate(params as NavigateParams);
        case "screenshot":
          return await this.screenshot((params ?? {}) as ScreenshotParams);
        case "click":
          return await this.click(params as ClickParams);
        case "fill":
          return await this.fill(params as FillParams);
        case "state":
          return await this.state((params ?? {}) as StateParams);
        default:
          return { ok: false, error: `unknown action: ${action}` };
      }
    } catch (err) {
      return { ok: false, error: errorMessage(err) };
    }
  }

  private async navigate(params: NavigateParams): Promise<CommandResult> {
    if (!params?.url) return { ok: false, error: "url is required" };
    const page = this.requirePage();
    await page.goto(params.url, { waitUntil: "load" });
    return { ok: true, data: { url: page.url(), title: await page.title() } };
  }

  private async screenshot(params: ScreenshotParams): Promise<CommandResult> {
    const page = this.requirePage();
    let buffer: Buffer;
    if (params.selector) {
      const el = page.locator(params.selector).first();
      buffer = await el.screenshot({ type: "png" });
    } else {
      buffer = await page.screenshot({
        type: "png",
        fullPage: params.full_page === true,
      });
    }
    return {
      ok: true,
      data: {
        format: "png",
        encoding: "base64",
        image: buffer.toString("base64"),
        url: page.url(),
      },
    };
  }

  private async click(params: ClickParams): Promise<CommandResult> {
    if (!params?.selector) return { ok: false, error: "selector is required" };
    const page = this.requirePage();
    await page.locator(params.selector).first().click();
    return { ok: true, data: { clicked: params.selector, url: page.url() } };
  }

  private async fill(params: FillParams): Promise<CommandResult> {
    if (!params?.selector) return { ok: false, error: "selector is required" };
    const page = this.requirePage();
    await page.locator(params.selector).first().fill(params.value ?? "");
    return { ok: true, data: { filled: params.selector, url: page.url() } };
  }

  private async state(params: StateParams): Promise<CommandResult> {
    const page = this.requirePage();
    const data: Record<string, unknown> = {
      url: page.url(),
      title: await page.title(),
    };
    if (params.include_text === true) {
      data.text = await page.evaluate(() => document.body?.innerText ?? "");
    }
    return { ok: true, data };
  }
}

function errorMessage(err: unknown): string {
  if (err instanceof Error) return err.message;
  return String(err);
}
