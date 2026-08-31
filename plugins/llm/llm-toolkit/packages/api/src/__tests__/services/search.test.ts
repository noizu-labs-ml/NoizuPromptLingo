import { describe, test, expect } from "vitest";
import { SearchService } from "../../services/search.ts";
import { StorageService } from "../../services/storage.ts";

describe("SearchService", () => {
  test("search with fts mode returns empty array", async () => {
    const service = new SearchService();
    const results = await service.search({ query: "hello", mode: "fts" });
    expect(results).toEqual([]);
  });

  test("search with semantic mode returns empty array", async () => {
    const service = new SearchService();
    const results = await service.search({ query: "hello", mode: "semantic" });
    expect(results).toEqual([]);
  });

  test("semantic search returns extracted work-item vector matches", async () => {
    const storage = new StorageService(":memory:");
    await storage.initialize();
    try {
      if (!storage.vecAvailable) return;

      await storage.upsertConversation({
        id: "conv-work-items",
        harness: "claude",
        projectPath: "/project",
        startedAt: "2026-06-01T00:00:00.000Z",
        updatedAt: "2026-06-01T00:00:00.000Z",
        messageCount: 1,
        title: "Conversation fallback title",
        sourcePath: "/project/session.jsonl",
      });
      await storage.replaceConversationWorkItems("conv-work-items", [{
        id: "work-item-1",
        conversationId: "conv-work-items",
        kind: "task",
        title: "Fix duplicate indexing",
        description: "Scoped Claude message identifiers so duplicate provider UUIDs can be indexed safely.",
        evidence: "unique constraint failure",
        startIndex: 0,
        endIndex: 3,
        confidence: 0.9,
        createdAt: "2026-06-01T00:00:00.000Z",
      }]);

      const embedding = new Float32Array(384);
      embedding[0] = 1;
      await storage.upsertWorkItemVector("work-item-1", embedding);

      const embeddings = { ready: true, embed: async () => embedding };
      const service = new SearchService(storage, embeddings as never);
      const results = await service.search({ query: "duplicate indexing", mode: "semantic" });

      expect(results).toHaveLength(1);
      expect(results[0].conversation.id).toBe("conv-work-items");
      expect(results[0].snippet).toContain("Fix duplicate indexing");
    } finally {
      storage.close();
    }
  });
});
