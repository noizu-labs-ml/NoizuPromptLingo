import { describe, test, expect, vi, afterEach } from "vitest";
import { isApiRunning } from "../api-launcher.ts";

const originalFetch = globalThis.fetch;

afterEach(() => {
  globalThis.fetch = originalFetch;
});

describe("isApiRunning", () => {
  test('returns true when health endpoint responds with { status: "ok" }', async () => {
    globalThis.fetch = vi.fn(() =>
      Promise.resolve(
        new Response(JSON.stringify({ status: "ok" }), { status: 200 }),
      ),
    ) as typeof fetch;

    const result = await isApiRunning(3100);
    expect(result).toBe(true);
  });

  test("returns false when fetch throws (connection refused)", async () => {
    globalThis.fetch = vi.fn(() =>
      Promise.reject(new Error("Connection refused")),
    ) as typeof fetch;

    const result = await isApiRunning(3100);
    expect(result).toBe(false);
  });

  test("returns false when response is not ok status", async () => {
    globalThis.fetch = vi.fn(() =>
      Promise.resolve(
        new Response(JSON.stringify({ error: "not found" }), { status: 404 }),
      ),
    ) as typeof fetch;

    // The function checks body.status === "ok", not HTTP status,
    // so a 404 with a non-"ok" body returns false.
    const result = await isApiRunning(3100);
    expect(result).toBe(false);
  });
});
