import { describe, test, expect, vi, beforeEach } from "vitest";
import React from "react";
import { render } from "ink-testing-library";
import { App } from "../app.tsx";

function waitForFrame(ms = 100): Promise<void> {
  return new Promise((r) => setTimeout(r, ms));
}

beforeEach(() => {
  vi.stubGlobal("fetch", vi.fn((url: string) => {
    if (url.includes("/messages")) {
      return Promise.resolve({ ok: true, json: () => Promise.resolve({ data: [], meta: { total: 0 } }) });
    }
    if (url.includes("/conversations/")) {
      return Promise.resolve({
        ok: true,
        json: () => Promise.resolve({
          data: { id: "abc123", title: "Test", projectPath: "/test", messageCount: 0, startedAt: "2026-05-12", updatedAt: "2026-05-12" },
        }),
      });
    }
    if (url.includes("/conversations")) {
      return Promise.resolve({ ok: true, json: () => Promise.resolve({ data: [], meta: { total: 0, limit: 20 } }) });
    }
    if (url.includes("/search")) {
      return Promise.resolve({ ok: true, json: () => Promise.resolve({ data: [], meta: { total: 0, query: "", mode: "fts" } }) });
    }
    return Promise.resolve({ ok: true, json: () => Promise.resolve({}) });
  }));
});

describe("App", () => {
  test("renders interactive TUI for 'interactive' command", () => {
    const { lastFrame } = render(<App command="interactive" args={[]} />);
    const output = lastFrame() ?? "";
    expect(output).toContain("claude-assist");
  });

  test("renders error for unknown command", () => {
    const { lastFrame } = render(<App command="bogus" args={[]} />);
    const output = lastFrame() ?? "";
    expect(output).toContain("Unknown command");
    expect(output).toContain("bogus");
  });

  test("renders search component for 'search' command", () => {
    const { lastFrame } = render(<App command="search" args={["test query"]} />);
    const output = lastFrame() ?? "";
    expect(output).toContain("test query");
  });

  test("renders list component for 'list' command", async () => {
    const { lastFrame } = render(<App command="list" args={[]} />);
    await waitForFrame();
    const output = lastFrame() ?? "";
    expect(output).toContain("No conversations indexed");
  });

  test("renders show component for 'show' command", async () => {
    const { lastFrame } = render(<App command="show" args={["abc123"]} />);
    await waitForFrame();
    const output = lastFrame() ?? "";
    expect(output).toContain("Test");
  });

  test("renders serve info for 'serve' command", () => {
    const { lastFrame } = render(<App command="serve" args={[]} />);
    const output = lastFrame() ?? "";
    expect(output).toContain("localhost");
  });
});
