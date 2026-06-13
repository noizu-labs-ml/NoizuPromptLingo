import { describe, test, expect, vi, beforeEach } from "vitest";
import { apiFetch } from "../../hooks/useApi.ts";

describe("apiFetch", () => {
  beforeEach(() => {
    vi.restoreAllMocks();
  });

  test("makes GET request to correct URL with /api prefix", async () => {
    const mockFetch = vi.fn().mockResolvedValue({
      ok: true,
      json: () => Promise.resolve({ data: "test" }),
    });
    globalThis.fetch = mockFetch;

    await apiFetch("/health");

    expect(mockFetch).toHaveBeenCalledWith(
      "/api/health",
      expect.objectContaining({
        headers: expect.objectContaining({
          "Content-Type": "application/json",
        }),
      }),
    );
  });

  test("returns parsed JSON on success", async () => {
    const payload = { status: "ok", count: 42 };
    globalThis.fetch = vi.fn().mockResolvedValue({
      ok: true,
      json: () => Promise.resolve(payload),
    });

    const result = await apiFetch("/health");
    expect(result).toEqual(payload);
  });

  test("throws on non-ok response", async () => {
    globalThis.fetch = vi.fn().mockResolvedValue({
      ok: false,
      status: 500,
      statusText: "Internal Server Error",
    });

    await expect(apiFetch("/health")).rejects.toThrow(
      "API error: 500 Internal Server Error",
    );
  });

  test("includes Content-Type header", async () => {
    const mockFetch = vi.fn().mockResolvedValue({
      ok: true,
      json: () => Promise.resolve({}),
    });
    globalThis.fetch = mockFetch;

    await apiFetch("/test");

    const callArgs = mockFetch.mock.calls[0];
    expect(callArgs[1].headers["Content-Type"]).toBe("application/json");
  });
});
