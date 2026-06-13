import { describe, test, expect, vi, beforeEach } from "vitest";
import React from "react";
import { render } from "ink-testing-library";
import { ListCommand } from "../../commands/list.tsx";

function waitForFrame(ms = 100): Promise<void> {
  return new Promise((r) => setTimeout(r, ms));
}

beforeEach(() => {
  vi.stubGlobal("fetch", vi.fn(() =>
    Promise.resolve({
      ok: true,
      json: () => Promise.resolve({ data: [], meta: { total: 0, limit: 20 } }),
    }),
  ));
});

describe("ListCommand", () => {
  test("shows 'No conversations indexed' when empty", async () => {
    const { lastFrame } = render(<ListCommand args={[]} />);
    await waitForFrame();
    const output = lastFrame() ?? "";
    expect(output).toContain("No conversations indexed");
  });

  test("suggests running 'claude-assist index'", async () => {
    const { lastFrame } = render(<ListCommand args={[]} />);
    await waitForFrame();
    const output = lastFrame() ?? "";
    expect(output).toContain("claude-assist index");
  });
});
