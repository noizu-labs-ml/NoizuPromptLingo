import { describe, test, expect, vi, beforeEach } from "vitest";
import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { MemoryRouter } from "react-router-dom";
import { App } from "../../App.tsx";

const universalPayload = {
  data: {
    id: "conv-1",
    harness: "claude",
    sourcePath: "/Users/test/.claude/projects/example/session-123.jsonl",
    projectPath: "/Users/test/project",
    title: "Debug deployment",
    startedAt: "2026-06-01T10:00:00.000Z",
    updatedAt: "2026-06-01T10:05:00.000Z",
    messages: [
      {
        id: "m1",
        role: "user",
        timestamp: "2026-06-01T10:00:00.000Z",
        content: [{ type: "text", text: "What broke?" }],
      },
      {
        id: "m2",
        role: "assistant",
        timestamp: "2026-06-01T10:01:00.000Z",
        content: [{ type: "text", text: "The deployment failed during rollout." }],
      },
    ],
    rawEvents: [
      {
        id: "raw-1",
        timestamp: "2026-06-01T10:00:00.000Z",
        harness: "claude",
        eventType: "message",
        payload: { type: "user" },
      },
    ],
  },
};

beforeEach(() => {
  vi.restoreAllMocks();
  vi.stubGlobal("fetch", vi.fn((url: string) => {
    if (url.includes("/conversations/conv-1/universal")) {
      return Promise.resolve({
        ok: true,
        json: () => Promise.resolve(universalPayload),
      });
    }
    return Promise.resolve({
      ok: true,
      json: () => Promise.resolve({ data: [], meta: { total: 0, limit: 20 } }),
    });
  }));
  Object.defineProperty(navigator, "clipboard", {
    configurable: true,
    value: { writeText: vi.fn().mockResolvedValue(undefined) },
  });
});

describe("ContinueSession", () => {
  test("renders continuation payload and transfer target states", async () => {
    render(
      <MemoryRouter initialEntries={["/thread/conv-1/continue"]}>
        <App />
      </MemoryRouter>,
    );

    await waitFor(() => {
      expect(screen.getByRole("heading", { name: "Debug deployment" })).toBeInTheDocument();
    });

    expect(screen.getByText("Transfer Target")).toBeInTheDocument();
    expect(screen.getByText("Native resume")).toBeInTheDocument();
    expect(screen.getByText("Gemini")).toBeInTheDocument();
    expect(screen.getAllByText("TODO").length).toBeGreaterThan(0);
    expect(screen.getByText("Continuation Prompt")).toBeInTheDocument();
    expect(screen.getByText(/Continue session: Debug deployment/)).toBeInTheDocument();
  });

  test("switches target harness and raw view", async () => {
    render(
      <MemoryRouter initialEntries={["/thread/conv-1/continue"]}>
        <App />
      </MemoryRouter>,
    );

    await screen.findByRole("heading", { name: "Debug deployment" });

    fireEvent.click(screen.getByRole("button", { name: /Codex/ }));
    expect(screen.getByText("Native resume is not available for this target; use the universal payload or prompt.")).toBeInTheDocument();
    expect(screen.getByText(/Target: codex/)).toBeInTheDocument();

    fireEvent.click(screen.getByRole("button", { name: "Raw" }));
    expect(screen.getByText("Raw Transcript Events")).toBeInTheDocument();
    expect(screen.getByText(/raw-1/)).toBeInTheDocument();
  });
});
