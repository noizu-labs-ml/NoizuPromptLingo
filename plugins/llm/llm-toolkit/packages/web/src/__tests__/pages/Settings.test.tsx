import { describe, test, expect, vi, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import { MemoryRouter } from "react-router-dom";
import { Settings } from "../../pages/Settings.tsx";

beforeEach(() => {
  vi.stubGlobal("fetch", vi.fn(() =>
    Promise.resolve({
      ok: true,
      json: () => Promise.resolve({
        data: {
          indexPaths: ["~/.claude/projects"],
          embedding: { provider: "local" },
          server: { port: 3100, host: "localhost" },
          status: "idle", lastIndexed: null, conversationCount: 0,
        },
      }),
    }),
  ));
});

describe("Settings", () => {
  test("renders 'Settings' heading", async () => {
    render(<MemoryRouter><Settings /></MemoryRouter>);
    await waitFor(() => {
      expect(screen.getByRole("heading", { name: "Settings" })).toBeInTheDocument();
    });
  });

  test("renders 'Index & Embeddings' section", async () => {
    render(<MemoryRouter><Settings /></MemoryRouter>);
    await waitFor(() => {
      expect(screen.getByText("Index & Embeddings")).toBeInTheDocument();
    });
  });

  test("renders 'Embedding Provider' section", async () => {
    render(<MemoryRouter><Settings /></MemoryRouter>);
    await waitFor(() => {
      expect(screen.getByText("Embedding Provider")).toBeInTheDocument();
    });
  });
});
