import { describe, test, expect, vi, beforeEach } from "vitest";
import React from "react";
import { render } from "ink-testing-library";
import { SearchCommand } from "../../commands/search.tsx";

function waitForFrame(ms = 100): Promise<void> {
  return new Promise((r) => setTimeout(r, ms));
}

beforeEach(() => {
  vi.stubGlobal("fetch", vi.fn(() =>
    Promise.resolve({
      ok: true,
      json: () => Promise.resolve({ data: [], meta: { total: 0, query: "", mode: "fts" } }),
    }),
  ));
});

describe("SearchCommand", () => {
  test("shows 'No results' when results are empty", async () => {
    const { lastFrame } = render(<SearchCommand query="nonexistent" />);
    await waitForFrame();
    const output = lastFrame() ?? "";
    expect(output).toContain("No results");
  });

  test("displays the query text in the output", async () => {
    const { lastFrame } = render(<SearchCommand query="my search term" />);
    await waitForFrame();
    const output = lastFrame() ?? "";
    expect(output).toContain("my search term");
  });
});
