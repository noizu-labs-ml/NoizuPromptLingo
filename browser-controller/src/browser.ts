/**
 * Playwright wrapper executing the cloud Browser.* actions against a single
 * long-lived chromium page. Every method is defensive: a thrown Playwright
 * error is surfaced to the caller, which turns it into a `command_result`
 * error rather than crashing the controller.
 *
 * Pages are created inside a BrowserContext so video recording can be toggled
 * on/off (Playwright records video per-context). A "normal" context with no
 * recording is the default; `record_start` swaps in a recording context and
 * `record_stop` flushes the .webm, uploads it, and restores a normal context.
 */

import { promises as fs } from "node:fs";
import os from "node:os";
import path from "node:path";

import {
  chromium,
  type Browser,
  type BrowserContext,
  type Page,
} from "playwright";

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
  upload_url?: string;
  key?: string;
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
interface RecordStopParams {
  upload_url: string;
  key: string;
  content_type?: string;
}

export class BrowserDriver {
  private browser: Browser | null = null;
  private context: BrowserContext | null = null;
  private page: Page | null = null;
  private recording = false;
  private recordDir: string | null = null;

  constructor(private readonly headless: boolean) {}

  async start(): Promise<void> {
    this.browser = await chromium.launch({ headless: this.headless });
    this.context = await this.browser.newContext();
    this.page = await this.context.newPage();
  }

  async stop(): Promise<void> {
    await this.context?.close().catch(() => {});
    await this.browser?.close().catch(() => {});
    await this.cleanupRecordDir();
    this.browser = null;
    this.context = null;
    this.page = null;
    this.recording = false;
  }

  private requirePage(): Page {
    if (!this.page) throw new Error("browser page not initialized");
    return this.page;
  }

  private requireBrowser(): Browser {
    if (!this.browser) throw new Error("browser not initialized");
    return this.browser;
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
        case "record_start":
          return await this.recordStart();
        case "record_stop":
          return await this.recordStop(params as RecordStopParams);
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

    const { width, height } = await pngSize(page, buffer);

    // When the cloud minted a presigned PUT URL, stream the bytes straight to
    // object storage instead of round-tripping a multi-MB base64 string.
    if (params.upload_url) {
      await putBytes(params.upload_url, buffer, "image/png");
      return {
        ok: true,
        data: { key: params.key, width, height, uploaded: true },
      };
    }

    return {
      ok: true,
      data: {
        format: "png",
        encoding: "base64",
        image: buffer.toString("base64"),
        width,
        height,
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

  /**
   * Begin recording the session. Playwright records video per-context, so we
   * tear down the current context and recreate the page inside a fresh context
   * launched with `recordVideo`, re-navigating to the current url if any.
   */
  private async recordStart(): Promise<CommandResult> {
    if (this.recording) return { ok: true, data: { recording: true } };
    const browser = this.requireBrowser();

    const currentUrl = this.page?.url();
    const dir = await fs.mkdtemp(path.join(os.tmpdir(), "bc-video-"));

    await this.context?.close().catch(() => {});

    const context = await browser.newContext({ recordVideo: { dir } });
    const page = await context.newPage();
    if (currentUrl && currentUrl !== "about:blank") {
      await page.goto(currentUrl, { waitUntil: "load" }).catch(() => {});
    }

    this.context = context;
    this.page = page;
    this.recordDir = dir;
    this.recording = true;
    return { ok: true, data: { recording: true } };
  }

  /**
   * Stop recording: close the recording page+context so Playwright flushes the
   * .webm, upload its bytes to the presigned URL, then restore a normal
   * (non-recording) context+page so navigate/click/fill keep working.
   */
  private async recordStop(params: RecordStopParams): Promise<CommandResult> {
    if (!params?.upload_url || !params?.key) {
      return { ok: false, error: "upload_url and key are required" };
    }
    if (!this.recording || !this.context) {
      return { ok: false, error: "no active recording" };
    }
    const browser = this.requireBrowser();
    const contentType = params.content_type || "video/webm";
    const currentUrl = this.page?.url();
    const dir = this.recordDir;

    // Capture the video handle/path before close — the file is only finalized
    // once the page and context are closed.
    const videoPath = await this.page?.video()?.path().catch(() => undefined);

    await this.context.close().catch(() => {});
    this.context = null;
    this.page = null;
    this.recording = false;

    try {
      const resolved = videoPath ?? (dir ? await findWebm(dir) : undefined);
      if (!resolved) throw new Error("recorded video file not found");
      const buffer = await fs.readFile(resolved);
      await putBytes(params.upload_url, buffer, contentType);
    } finally {
      // Restore a working non-recording context regardless of upload outcome.
      const context = await browser.newContext();
      const page = await context.newPage();
      if (currentUrl && currentUrl !== "about:blank") {
        await page.goto(currentUrl, { waitUntil: "load" }).catch(() => {});
      }
      this.context = context;
      this.page = page;
      await this.cleanupRecordDir();
    }

    return { ok: true, data: { key: params.key, uploaded: true } };
  }

  private async cleanupRecordDir(): Promise<void> {
    if (!this.recordDir) return;
    await fs.rm(this.recordDir, { recursive: true, force: true }).catch(() => {});
    this.recordDir = null;
  }
}

/** PUT raw bytes to a presigned URL via global fetch (Node 22+). */
async function putBytes(
  url: string,
  body: Buffer,
  contentType: string,
): Promise<void> {
  const res = await fetch(url, {
    method: "PUT",
    headers: { "content-type": contentType },
    body: new Uint8Array(body),
  });
  if (!res.ok) {
    throw new Error(`upload failed: HTTP ${res.status} ${res.statusText}`);
  }
}

/** Read the rendered viewport/element size for the captured PNG. */
async function pngSize(
  page: Page,
  buffer: Buffer,
): Promise<{ width: number; height: number }> {
  const dims = pngDimensions(buffer);
  if (dims) return dims;
  // Fallback to the viewport if the PNG header was unreadable.
  const vp = page.viewportSize();
  return { width: vp?.width ?? 0, height: vp?.height ?? 0 };
}

/** Parse width/height from a PNG IHDR chunk without decoding the image. */
function pngDimensions(buffer: Buffer): { width: number; height: number } | null {
  // PNG signature (8 bytes) + length (4) + "IHDR" (4) then width/height.
  if (buffer.length < 24) return null;
  if (buffer.toString("ascii", 12, 16) !== "IHDR") return null;
  return {
    width: buffer.readUInt32BE(16),
    height: buffer.readUInt32BE(20),
  };
}

/** Find the single .webm Playwright wrote into the recording dir. */
async function findWebm(dir: string): Promise<string | undefined> {
  const entries = await fs.readdir(dir).catch(() => [] as string[]);
  const webm = entries.find((e) => e.endsWith(".webm"));
  return webm ? path.join(dir, webm) : undefined;
}

function errorMessage(err: unknown): string {
  if (err instanceof Error) return err.message;
  return String(err);
}
