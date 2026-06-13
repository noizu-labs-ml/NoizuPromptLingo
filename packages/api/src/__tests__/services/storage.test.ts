import { describe, test, expect, beforeEach, afterEach } from "vitest";
import { StorageService } from "../../services/storage.ts";

describe("StorageService", () => {
  let storage: StorageService;

  beforeEach(async () => {
    storage = new StorageService(":memory:");
    await storage.initialize();
  });

  afterEach(() => {
    storage.close();
  });

  test("constructor creates instance with default db path", () => {
    const service = new StorageService();
    expect(service).toBeInstanceOf(StorageService);
  });

  test("constructor accepts a custom db path", () => {
    const service = new StorageService("/tmp/test.db");
    expect(service).toBeInstanceOf(StorageService);
  });

  test("initialize resolves without error", async () => {
    const service = new StorageService(":memory:");
    await expect(service.initialize()).resolves.toBeUndefined();
    service.close();
  });

  test("getConversations returns empty array when no data", async () => {
    const result = await storage.getConversations();
    expect(result).toEqual([]);
  });

  test("getConversation returns null for nonexistent id", async () => {
    const result = await storage.getConversation("nonexistent-id");
    expect(result).toBeNull();
  });

  test("upsertConversation + getConversation round-trip", async () => {
    await storage.upsertConversation({
      id: "test-123",
      projectPath: "/Users/test/project",
      startedAt: "2026-05-12T00:00:00Z",
      updatedAt: "2026-05-12T01:00:00Z",
      messageCount: 10,
      title: "Test conversation",
      sourcePath: "/path/to/file.jsonl",
    });

    const result = await storage.getConversation("test-123");
    expect(result).not.toBeNull();
    expect(result!.id).toBe("test-123");
    expect(result!.projectPath).toBe("/Users/test/project");
    expect(result!.title).toBe("Test conversation");
    expect(result!.messageCount).toBe(10);
    expect(result!.status).toBe("active");
    expect(result!.tags).toEqual([]);
  });

  test("upsertConversation updates existing record", async () => {
    await storage.upsertConversation({
      id: "test-123",
      projectPath: "/Users/test/project",
      startedAt: "2026-05-12T00:00:00Z",
      updatedAt: "2026-05-12T01:00:00Z",
      messageCount: 10,
      title: "Original title",
      sourcePath: "/path/to/file.jsonl",
    });

    await storage.upsertConversation({
      id: "test-123",
      projectPath: "/Users/test/project",
      startedAt: "2026-05-12T00:00:00Z",
      updatedAt: "2026-05-12T02:00:00Z",
      messageCount: 20,
      title: "Updated title",
      sourcePath: "/path/to/file.jsonl",
    });

    const result = await storage.getConversation("test-123");
    expect(result!.title).toBe("Updated title");
    expect(result!.messageCount).toBe(20);
  });

  test("getConversations returns sorted results", async () => {
    await storage.upsertConversation({
      id: "older",
      projectPath: "/project",
      startedAt: "2026-05-10T00:00:00Z",
      updatedAt: "2026-05-10T00:00:00Z",
      messageCount: 5,
      title: "Older",
      sourcePath: "/a.jsonl",
    });

    await storage.upsertConversation({
      id: "newer",
      projectPath: "/project",
      startedAt: "2026-05-12T00:00:00Z",
      updatedAt: "2026-05-12T00:00:00Z",
      messageCount: 3,
      title: "Newer",
      sourcePath: "/b.jsonl",
    });

    const byDate = await storage.getConversations({ sort: "updated_at" });
    expect(byDate[0].id).toBe("newer");

    const byCount = await storage.getConversations({ sort: "message_count" });
    expect(byCount[0].id).toBe("older");
  });

  test("getConversations respects limit", async () => {
    for (let i = 0; i < 5; i++) {
      await storage.upsertConversation({
        id: `conv-${i}`,
        projectPath: "/project",
        startedAt: `2026-05-1${i}T00:00:00Z`,
        updatedAt: `2026-05-1${i}T00:00:00Z`,
        messageCount: 1,
        title: `Conv ${i}`,
        sourcePath: `/file-${i}.jsonl`,
      });
    }

    const limited = await storage.getConversations({ limit: 3 });
    expect(limited).toHaveLength(3);
  });

  test("getConversations filters by project", async () => {
    await storage.upsertConversation({
      id: "proj-a",
      projectPath: "/project-a",
      startedAt: "2026-05-12T00:00:00Z",
      updatedAt: "2026-05-12T00:00:00Z",
      messageCount: 1,
      title: "Project A",
      sourcePath: "/a.jsonl",
    });

    await storage.upsertConversation({
      id: "proj-b",
      projectPath: "/project-b",
      startedAt: "2026-05-12T00:00:00Z",
      updatedAt: "2026-05-12T00:00:00Z",
      messageCount: 1,
      title: "Project B",
      sourcePath: "/b.jsonl",
    });

    const filtered = await storage.getConversations({ project: "/project-a" });
    expect(filtered).toHaveLength(1);
    expect(filtered[0].id).toBe("proj-a");
  });

  test("getConversations filters by harness", async () => {
    await storage.upsertConversation({
      id: "claude-1",
      harness: "claude",
      projectPath: "/project",
      startedAt: "2026-05-12T00:00:00Z",
      updatedAt: "2026-05-12T00:00:00Z",
      messageCount: 1,
      title: "Claude",
      sourcePath: "/claude.jsonl",
    });

    await storage.upsertConversation({
      id: "codex-1",
      harness: "codex",
      projectPath: "/project",
      startedAt: "2026-05-12T00:00:00Z",
      updatedAt: "2026-05-12T00:00:00Z",
      messageCount: 1,
      title: "Codex",
      sourcePath: "/codex.jsonl",
    });

    const filtered = await storage.getConversations({ harness: "codex" });
    expect(filtered).toHaveLength(1);
    expect(filtered[0].id).toBe("codex-1");
    expect(filtered[0].harness).toBe("codex");
  });

  test("insertMessages + getMessages round-trip", async () => {
    await storage.upsertConversation({
      id: "conv-1",
      projectPath: "/project",
      startedAt: "2026-05-12T00:00:00Z",
      updatedAt: "2026-05-12T00:00:00Z",
      messageCount: 2,
      title: "Test",
      sourcePath: "/file.jsonl",
    });

    await storage.insertMessages("conv-1", [
      { conversationId: "conv-1", role: "user", content: "Hello", timestamp: "2026-05-12T00:00:00Z" },
      { conversationId: "conv-1", role: "assistant", content: "Hi there!", timestamp: "2026-05-12T00:00:01Z" },
    ]);

    const messages = await storage.getMessages("conv-1");
    expect(messages).toHaveLength(2);
    expect(messages[0].role).toBe("user");
    expect(messages[0].content).toBe("Hello");
    expect(messages[1].role).toBe("assistant");
    expect(messages[1].content).toBe("Hi there!");
  });

  test("insertUniversalMessages + getUniversalMessages round-trip", async () => {
    await storage.upsertConversation({
      id: "universal-1",
      harness: "codex",
      projectPath: "/project",
      startedAt: "2026-05-12T00:00:00Z",
      updatedAt: "2026-05-12T00:00:00Z",
      messageCount: 1,
      title: "Universal",
      sourcePath: "/file.jsonl",
    });

    await storage.insertUniversalMessages("universal-1", [{
      id: "msg-1",
      role: "assistant",
      timestamp: "2026-05-12T00:00:00Z",
      content: [{ type: "thinking", thinking: "private reasoning", providerType: "thinking" }],
      provenance: { harness: "codex", sourcePath: "/file.jsonl", rawIndex: 1 },
    }]);

    const messages = await storage.getUniversalMessages("universal-1");
    expect(messages).toHaveLength(1);
    expect(messages[0].conversationId).toBe("universal-1");
    expect(messages[0].content[0].type).toBe("thinking");
  });

  test("getStats returns correct counts", async () => {
    const empty = await storage.getStats();
    expect(empty.conversationCount).toBe(0);
    expect(empty.projectCount).toBe(0);

    await storage.upsertConversation({
      id: "conv-1",
      projectPath: "/project-a",
      startedAt: "2026-05-12T00:00:00Z",
      updatedAt: "2026-05-12T00:00:00Z",
      messageCount: 1,
      title: "Test",
      sourcePath: "/file.jsonl",
    });

    await storage.upsertConversation({
      id: "conv-2",
      projectPath: "/project-b",
      startedAt: "2026-05-12T00:00:00Z",
      updatedAt: "2026-05-12T00:00:00Z",
      messageCount: 1,
      title: "Test 2",
      sourcePath: "/file2.jsonl",
    });

    const stats = await storage.getStats();
    expect(stats.conversationCount).toBe(2);
    expect(stats.projectCount).toBe(2);
  });

  test("generateId produces consistent hash", () => {
    const id1 = StorageService.generateId("/path/file.jsonl", "2026-05-12T00:00:00Z");
    const id2 = StorageService.generateId("/path/file.jsonl", "2026-05-12T00:00:00Z");
    expect(id1).toBe(id2);
    expect(id1).toHaveLength(16);

    const id3 = StorageService.generateId("/different/file.jsonl", "2026-05-12T00:00:00Z");
    expect(id3).not.toBe(id1);
  });
});
