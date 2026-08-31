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
    tempDir = mkdtempSync(join(tmpdir(), "llm-toolkit-indexer-"));
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
      providerRaw: { type: "input_text", text: "Build the memory harness" },
    });
    expect(universalMessages[0].provenance?.harness).toBe("codex");
    expect(universalMessages[0].providerRaw).toEqual(lines[1]);

    const rawEvents = await storage.getRawTranscriptEvents("codex:codex-session-1");
    expect(rawEvents).toHaveLength(3);
    expect(rawEvents[0].eventType).toBe("session_meta");
  });

  test("scopes Claude universal message ids per source file", async () => {
    const timestamp = "2026-06-01T00:00:00.000Z";
    const sharedUuid = "shared-claude-message-uuid";
    const fileA = join(tempDir, "session-a.jsonl");
    const fileB = join(tempDir, "session-b.jsonl");
    const claudeRecord = (sessionId: string, content: string) => ({
      uuid: sharedUuid,
      parentUuid: null,
      type: "user",
      timestamp,
      sessionId,
      message: {
        role: "user",
        content,
      },
    });

    writeFileSync(fileA, JSON.stringify(claudeRecord("session-a", "Shared history in session A")));
    writeFileSync(fileB, JSON.stringify(claudeRecord("session-b", "Shared history in session B")));

    const indexer = new IndexerService(storage, [{ harness: "claude", path: tempDir, format: "jsonl" }]);
    await indexer.indexFile(fileA);
    await indexer.indexFile(fileB);

    const conversationA = StorageService.generateId(fileA, timestamp);
    const conversationB = StorageService.generateId(fileB, timestamp);
    const messagesA = await storage.getUniversalMessages(conversationA);
    const messagesB = await storage.getUniversalMessages(conversationB);

    expect(messagesA).toHaveLength(1);
    expect(messagesB).toHaveLength(1);
    expect(messagesA[0].providerMessageId).toBe(sharedUuid);
    expect(messagesB[0].providerMessageId).toBe(sharedUuid);
    expect(messagesA[0].id).toMatch(/^claude:/);
    expect(messagesB[0].id).toMatch(/^claude:/);
    expect(messagesA[0].id).not.toBe(messagesB[0].id);
  });

  test("extracts work-item search entries from Claude messages in small LLM batches", async () => {
    const filePath = join(tempDir, "batched-session.jsonl");
    const lines = Array.from({ length: 7 }, (_, index) => ({
      uuid: `message-${index}`,
      parentUuid: index === 0 ? null : `message-${index - 1}`,
      type: "user",
      timestamp: `2026-06-01T00:00:0${index}.000Z`,
      sessionId: "batched-session",
      message: {
        role: "user",
        content: `Implemented indexing task step ${index}`,
      },
    }));
    writeFileSync(filePath, lines.map((line) => JSON.stringify(line)).join("\n"));

    const complete = vi.fn(async (req: { messages: Array<{ content: string }> }) => {
      const userPrompt = req.messages[1].content;
      const secondBatch = typeof userPrompt === "string" && userPrompt.includes("[6] user");
      return {
        content: JSON.stringify({
          items: [{
            kind: "task",
            title: secondBatch ? "Finalize indexing enrichment" : "Implement indexing enrichment",
            description: secondBatch
              ? "Finalized the batched extraction flow for semantic indexing."
              : "Implemented the first pass of batched work-item extraction for semantic indexing.",
            evidence: secondBatch ? "message 6" : "messages 0-5",
            startIndex: secondBatch ? 6 : 0,
            endIndex: secondBatch ? 6 : 5,
            confidence: 0.9,
          }],
        }),
        model: "fake",
        provider: "fake",
        finishReason: "stop",
      };
    });
    const llm = { available: true, complete };
    const embed = vi.fn(async () => new Float32Array(384).fill(0.01));
    const embeddings = { ready: true, embed };

    const indexer = new IndexerService(
      storage,
      [{ harness: "claude", path: tempDir, format: "jsonl" }],
      embeddings as never,
      llm as never,
    );
    await indexer.indexFile(filePath);

    const conversationId = StorageService.generateId(filePath, "2026-06-01T00:00:00.000Z");
    const workItems = await storage.getConversationWorkItems(conversationId);

    expect(complete).toHaveBeenCalledTimes(2);
    expect(workItems).toHaveLength(2);
    expect(workItems[0].title).toBe("Implement indexing enrichment");
    expect(workItems[1].title).toBe("Finalize indexing enrichment");
    if (storage.vecAvailable) expect(embed).toHaveBeenCalledTimes(3);
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
