import { describe, test, expect, vi, beforeEach } from "vitest";
import React from "react";
import { render } from "ink-testing-library";
import { ShowCommand } from "../../commands/show.tsx";

function waitForFrame(ms = 100): Promise<void> {
  return new Promise((r) => setTimeout(r, ms));
}

beforeEach(() => {
  vi.stubGlobal("fetch", vi.fn((url: string) => {
    if (url.includes("/messages")) {
      return Promise.resolve({
        ok: true,
        json: () => Promise.resolve({ data: [], meta: { total: 0 } }),
      });
    }
    return Promise.resolve({
      ok: true,
      json: () => Promise.resolve({
        data: {
          id: "abc-def-123",
          title: "Test conversation",
          projectPath: "/test",
          messageCount: 0,
          startedAt: "2026-05-12T00:00:00Z",
          updatedAt: "2026-05-12T00:00:00Z",
        },
      }),
    });
  }));
});

describe("ShowCommand", () => {
  test("shows usage message when no id provided", () => {
    const { lastFrame } = render(<ShowCommand />);
    const output = lastFrame() ?? "";
    expect(output).toContain("Usage:");
  });

  test("shows conversation header when id provided", async () => {
    const { lastFrame } = render(<ShowCommand id="abc-def-123" />);
    await waitForFrame();
    const output = lastFrame() ?? "";
    expect(output).toContain("Test conversation");
  });
});
