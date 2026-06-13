import { afterEach, beforeEach, describe, expect, test, vi } from "vitest";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { IndexerService } from "../../services/indexer.ts";
import { StorageService } from "../../services/storage.ts";

describe("IndexerService", () => {
  let storage: StorageService;
  let tempDir: string;

  beforeEach(async () => {
    storage = new StorageService(":memory:");
    await storage.initialize();
    tempDir = mkdtempSync(join(tmpdir(), "claude-assist-indexer-"));
  });

  afterEach(() => {
    storage.close();
    rmSync(tempDir, { recursive: true, force: true });
  });

  test("indexes Codex JSONL sessions as codex conversations", async () => {
    const filePath = join(tempDir, "session.jsonl");
    const lines = [
      {
        timestamp: "2026-06-01T00:00:00.000Z",
        type: "session_meta",
        payload: { id: "codex-session-1", cwd: "/Users/test/project" },
      },
      {
        timestamp: "2026-06-01T00:00:01.000Z",
        type: "response_item",
        payload: {
          type: "message",
          role: "user",
          content: [{ type: "input_text", text: "Build the memory harness" }],
        },
      },
      {
        timestamp: "2026-06-01T00:00:02.000Z",
        type: "response_item",
        payload: {
          type: "message",
          role: "assistant",
          content: [{ type: "output_text", text: "I will index the session." }],
        },
      },
    ];
    writeFileSync(filePath, lines.map((line) => JSON.stringify(line)).join("\n"));

    const indexer = new IndexerService(storage, [{ harness: "codex", path: tempDir, format: "jsonl" }]);
    await indexer.indexFile(filePath);

    const conversations = await storage.getConversations({ harness: "codex" });
    expect(conversations).toHaveLength(1);
    expect(conversations[0].id).toBe("codex:codex-session-1");
    expect(conversations[0].title).toBe("Build the memory harness");
    expect(conversations[0].projectPath).toBe("/Users/test/project");

    const messages = await storage.getMessages("codex:codex-session-1");
    expect(messages).toHaveLength(2);
    expect(messages[0].role).toBe("user");
    expect(messages[1].role).toBe("assistant");

    const universalMessages = await storage.getUniversalMessages("codex:codex-session-1");
    expect(universalMessages).toHaveLength(2);
    expect(universalMessages[0].content[0]).toEqual({
      type: "text",
      text: "Build the memory harness",
      providerType: "input_text",
    });
    expect(universalMessages[0].provenance?.harness).toBe("codex");

    const rawEvents = await storage.getRawTranscriptEvents("codex:codex-session-1");
    expect(rawEvents).toHaveLength(3);
    expect(rawEvents[0].eventType).toBe("session_meta");
  });

  test("accepts pending harnesses without inventing transcript parsing", async () => {
    const filePath = join(tempDir, "gemini-session.jsonl");
    writeFileSync(filePath, JSON.stringify({ type: "unknown", text: "pending transcript shape" }));

    const warn = vi.spyOn(console, "warn").mockImplementation(() => {});
    const indexer = new IndexerService(storage, [{ harness: "gemini", path: tempDir, format: "jsonl" }]);

    await indexer.indexFile(filePath);

    const conversations = await storage.getConversations({ harness: "gemini" });
    expect(conversations).toHaveLength(0);
    expect(warn).toHaveBeenCalledWith(expect.stringContaining("gemini transcript import is stubbed"));

    warn.mockRestore();
  });
});
