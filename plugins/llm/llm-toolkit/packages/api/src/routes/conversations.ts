import { Hono } from "hono";
import { readFileSync } from "node:fs";
import { parseJsonlFile, isUserMessage, isAssistantMessage } from "@llm-toolkit/shared";
import type { StorageService } from "../services/storage.ts";
import type { AgentHarness, ArtifactType } from "@llm-toolkit/shared";
import { applyOperations, type EditOperation } from "../services/editor.ts";
import { identifyCandidates, convertToArtifact } from "../services/converter.ts";
import { OperationsService } from "../services/operations.ts";
import type { SearchService } from "../services/search.ts";
import { prepareContinuationPayload } from "../services/session-workflow.ts";

// ⟦𓆷𓈾𓊲𓅣⟧ createConversationRoutes :: auto-generated pointer for public function createConversationRoutes
export function createConversationRoutes(storage: StorageService, searchService?: SearchService): Hono {
  const routes = new Hono();

  routes.get("/", async (c) => {
    const sort = c.req.query("sort") ?? "updated_at";
    const limit = Number(c.req.query("limit") ?? 20);
    const offset = Number(c.req.query("offset") ?? 0);
    const groupBy = c.req.query("group_by");
    const project = c.req.query("project");
    const harness = c.req.query("harness") as AgentHarness | undefined;

    const conversations = await storage.getConversations({ sort, limit, offset, groupBy, project, harness });
    const total = await storage.getConversationCount(project, harness);

    return c.json({ data: conversations, meta: { total, limit, offset } });
  });

  routes.get("/by-slug/:slug", async (c) => {
    const slug = c.req.param("slug");
    const conversation = await storage.getConversationBySlug(slug);
    if (!conversation) {
      return c.json({ data: null, error: "not found" }, 404);
    }
    return c.json({ data: conversation });
  });

  routes.get("/:id", async (c) => {
    const id = c.req.param("id");
    const conversation = await storage.getConversation(id);
    if (!conversation) {
      return c.json({ data: null, error: "not found" }, 404);
    }
    return c.json({ data: conversation });
  });

  routes.get("/:id/messages", async (c) => {
    const id = c.req.param("id");
    const messages = await storage.getMessages(id);
    return c.json({ data: messages, meta: { total: messages.length } });
  });

  routes.get("/:id/metadata", async (c) => {
    const id = c.req.param("id");
    const conversation = await storage.getConversation(id);
    if (!conversation) {
      return c.json({ data: null, error: "not found" }, 404);
    }
    return c.json({
      data: {
        title: conversation.title,
        tags: conversation.tags,
        summary: conversation.summary,
        status: conversation.status,
        harness: conversation.harness,
        projectPath: conversation.projectPath,
        messageCount: conversation.messageCount,
      },
    });
  });

  routes.get("/:id/search", async (c) => {
    const id = c.req.param("id");
    const q = c.req.query("q") ?? "";
    if (!q.trim() || !searchService) {
      return c.json({ data: [], meta: { total: 0 } });
    }
    const results = await searchService.searchInConversation(id, q);
    return c.json({ data: results, meta: { total: results.length } });
  });

  routes.get("/:id/thread", async (c) => {
    const id = c.req.param("id");
    const conversation = await storage.getConversation(id);
    if (!conversation) {
      return c.json({ data: null, error: "not found" }, 404);
    }

    if (conversation.harness !== "claude") {
      const messages = await storage.getMessages(id);
      return c.json({
        data: messages.map((message, index) => ({
          type: message.role === "assistant" ? "assistant" : "user",
          uuid: `${id}:${index}`,
          timestamp: message.timestamp,
          message: {
            role: message.role,
            content: message.content,
          },
        })),
        meta: { total: messages.length },
      });
    }

    try {
      const content = readFileSync(conversation.sourcePath, "utf-8");
      const records = [];
      for (const record of parseJsonlFile(content)) {
        if (isUserMessage(record) || isAssistantMessage(record)) {
          records.push(record);
        }
      }
      return c.json({ data: records, meta: { total: records.length } });
    } catch {
      return c.json({ data: null, error: "source file not readable" }, 500);
    }
  });

  routes.get("/:id/universal", async (c) => {
    const id = c.req.param("id");
    const includeRaw = c.req.query("raw") === "true";
    const conversation = await storage.getConversation(id);
    if (!conversation) {
      return c.json({ data: null, error: "not found" }, 404);
    }

    const messages = await storage.getUniversalMessages(id);
    const rawEvents = includeRaw ? await storage.getRawTranscriptEvents(id) : undefined;
    return c.json({
      data: {
        id: conversation.id,
        harness: conversation.harness,
        sourcePath: conversation.sourcePath,
        projectPath: conversation.projectPath,
        title: conversation.title,
        startedAt: conversation.startedAt.toISOString(),
        updatedAt: conversation.updatedAt.toISOString(),
        messages,
        rawEvents,
      },
      meta: { total: messages.length, raw: rawEvents?.length ?? 0 },
    });
  });

  routes.get("/:id/continuation", async (c) => {
    const id = c.req.param("id");
    const targetHarness = c.req.query("target") as AgentHarness | undefined;
    const conversation = await storage.getConversation(id);
    if (!conversation) {
      return c.json({ data: null, error: "not found" }, 404);
    }

    const messages = await storage.getUniversalMessages(id);
    const payload = prepareContinuationPayload({
      sourceHarness: conversation.harness,
      targetHarness,
      title: conversation.title,
      messages,
      intent: targetHarness && targetHarness !== conversation.harness ? "transfer" : "continue",
    });
    return c.json({ data: payload, meta: { total: messages.length } });
  });

  routes.post("/:id/transfer", async (c) => {
    const id = c.req.param("id");
    const body = await c.req.json().catch(() => ({})) as { targetHarness?: AgentHarness };
    if (!body.targetHarness) {
      return c.json({ data: null, error: "targetHarness required" }, 400);
    }

    const conversation = await storage.getConversation(id);
    if (!conversation) {
      return c.json({ data: null, error: "not found" }, 404);
    }

    const messages = await storage.getUniversalMessages(id);
    const payload = prepareContinuationPayload({
      sourceHarness: conversation.harness,
      targetHarness: body.targetHarness,
      title: conversation.title,
      messages,
      intent: "transfer",
    });
    return c.json({ data: payload, meta: { total: messages.length } });
  });

  routes.get("/:id/edits", async (c) => {
    const id = c.req.param("id");
    const edits = await storage.getEdits(id);
    return c.json({ data: edits });
  });

  routes.post("/:id/edits", async (c) => {
    const id = c.req.param("id");
    const conversation = await storage.getConversation(id);
    if (!conversation) {
      return c.json({ data: null, error: "conversation not found" }, 404);
    }

    const body = await c.req.json() as { description: string; operations: EditOperation[] };
    if (!body.description || !body.operations) {
      return c.json({ data: null, error: "description and operations required" }, 400);
    }

    const messages = await storage.getMessages(id);
    const sourceMessages = messages.map((m) => ({ role: m.role, content: m.content }));
    const editedMessages = applyOperations(sourceMessages, body.operations);
    const edit = await storage.createEdit(id, body.description, editedMessages);

    return c.json({ data: edit }, 201);
  });

  routes.get("/:id/draft", async (c) => {
    const id = c.req.param("id");
    const draft = await storage.getDraftEdit(id);
    if (!draft) {
      return c.json({ data: null });
    }
    return c.json({ data: draft });
  });

  routes.post("/:id/draft", async (c) => {
    const id = c.req.param("id");
    const conversation = await storage.getConversation(id);
    if (!conversation) {
      return c.json({ data: null, error: "conversation not found" }, 404);
    }

    const existing = await storage.getDraftEdit(id);
    if (existing) {
      return c.json({ data: existing });
    }

    const body = await c.req.json() as { messages: Array<{ originalIndex?: number; role: string; content: string; injected?: boolean; collapsed?: boolean; template?: string; rawRecord?: unknown; rawEdited?: boolean }> };
    const editedMessages = (body.messages ?? []).map((m, i) => ({
      originalIndex: m.originalIndex ?? i,
      role: m.role as "user" | "assistant" | "system",
      content: m.content,
      injected: m.injected,
      collapsed: m.collapsed,
      template: m.template,
      rawRecord: m.rawRecord,
      rawEdited: m.rawEdited,
    }));
    const draft = await storage.createEdit(id, "Draft edit", editedMessages, "draft");
    return c.json({ data: draft }, 201);
  });

  routes.patch("/:id/draft", async (c) => {
    const id = c.req.param("id");
    const draft = await storage.getDraftEdit(id);
    if (!draft) {
      return c.json({ data: null, error: "no draft found" }, 404);
    }
    const body = await c.req.json() as { messages: Array<{ originalIndex?: number; role: string; content: string; injected?: boolean; collapsed?: boolean; template?: string; rawRecord?: unknown; rawEdited?: boolean }>; description?: string };
    const messages = body.messages.map((m) => ({
      originalIndex: m.originalIndex,
      role: m.role as "user" | "assistant" | "system",
      content: m.content,
      injected: m.injected,
      collapsed: m.collapsed,
      template: m.template,
      rawRecord: m.rawRecord,
      rawEdited: m.rawEdited,
    }));
    await storage.updateEdit(draft.id, messages, body.description);
    return c.json({ success: true });
  });

  routes.post("/:id/draft/finalize", async (c) => {
    const id = c.req.param("id");
    const draft = await storage.getDraftEdit(id);
    if (!draft) {
      return c.json({ data: null, error: "no draft found" }, 404);
    }
    const body = await c.req.json().catch(() => ({})) as { description?: string };
    if (body.description) {
      await storage.updateEdit(draft.id, draft.messages, body.description);
    }
    await storage.finalizeEdit(draft.id);
    return c.json({ success: true, data: { editId: draft.id } });
  });

  routes.delete("/:id/draft", async (c) => {
    const id = c.req.param("id");
    const draft = await storage.getDraftEdit(id);
    if (!draft) {
      return c.json({ success: true });
    }
    await storage.deleteEdit(draft.id);
    return c.json({ success: true });
  });

  routes.get("/:id/candidates", async (c) => {
    const id = c.req.param("id");
    const messages = await storage.getMessages(id);
    const candidates = identifyCandidates(messages.map((m) => ({ role: m.role, content: m.content })));
    return c.json({ data: candidates });
  });

  routes.post("/:id/convert", async (c) => {
    const id = c.req.param("id");
    const body = await c.req.json() as { type: ArtifactType; range: [number, number]; name: string; description: string };
    const messages = await storage.getMessages(id);
    const artifact = convertToArtifact(
      body.type,
      messages.map((m) => ({ role: m.role, content: m.content })),
      body.range,
      { name: body.name, description: body.description, conversationId: id },
    );
    return c.json({ data: artifact });
  });

  const ops = new OperationsService(storage);

  routes.post("/:id/save-edit", async (c) => {
    const id = c.req.param("id");
    const body = await c.req.json() as {
      messages: Array<{ originalIndex?: number; role: string; content: string; injected?: boolean; collapsed?: boolean; template?: string; rawRecord?: unknown; rawEdited?: boolean }>;
      mode: "new" | "overwrite";
      description?: string;
    };
    if (!body.messages?.length || !body.mode) {
      return c.json({ error: "messages and mode required" }, 400);
    }
    try {
      const editMessages = body.messages.map((m) => ({
        originalIndex: m.originalIndex,
        role: m.role as "user" | "assistant" | "system",
        content: m.content,
        injected: m.injected,
        collapsed: m.collapsed,
        template: m.template,
        rawRecord: m.rawRecord,
        rawEdited: m.rawEdited,
      }));
      const result = await ops.saveEdit(id, editMessages, body.mode, body.description);
      return c.json({ data: result });
    } catch (err) {
      return c.json({ error: err instanceof Error ? err.message : "Save failed" }, 500);
    }
  });

  routes.post("/:id/archive", async (c) => {
    const id = c.req.param("id");
    await ops.archive(id);
    return c.json({ success: true });
  });

  routes.post("/:id/tag", async (c) => {
    const id = c.req.param("id");
    const body = await c.req.json() as { tags: string[] };
    await ops.tag(id, body.tags);
    return c.json({ success: true });
  });

  routes.patch("/:id/meta", async (c) => {
    const id = c.req.param("id");
    const conversation = await storage.getConversation(id);
    if (!conversation) {
      return c.json({ data: null, error: "conversation not found" }, 404);
    }

    const body = await c.req.json() as { slug?: string | null; description?: string | null; title?: string };

    if (body.slug !== undefined && body.slug !== null) {
      const slugRe = /^[a-z0-9][a-z0-9-]*[a-z0-9]$|^[a-z0-9]$/;
      if (!slugRe.test(body.slug)) {
        return c.json({ error: "slug must be lowercase alphanumeric with hyphens, no leading/trailing hyphens" }, 400);
      }
      const existing = await storage.getConversationBySlug(body.slug);
      if (existing && existing.id !== id) {
        return c.json({ error: `slug "${body.slug}" is already in use` }, 409);
      }
    }

    await storage.updateConversationMeta(id, body);
    const updated = await storage.getConversation(id);
    return c.json({ data: updated });
  });

  routes.post("/:id/clone", async (c) => {
    const id = c.req.param("id");
    const newId = await ops.clone(id);
    return c.json({ data: { id: newId } }, 201);
  });

  routes.post("/:id/rehome", async (c) => {
    const id = c.req.param("id");
    const body = await c.req.json() as { project: string };
    await ops.rehome(id, body.project);
    return c.json({ success: true });
  });

  routes.post("/bulk", async (c) => {
    return c.json({ data: null, error: "not implemented" }, 501);
  });

  return routes;
}

// Keep backward-compatible named export for tests that import it directly
export const conversationRoutes = new Hono();
conversationRoutes.get("/", async (c) => {
  const limit = Number(c.req.query("limit") ?? 20);
  return c.json({ data: [], meta: { total: 0, limit } });
});
conversationRoutes.get("/:id", async (c) => c.json({ data: null, error: "not implemented" }, 501));
conversationRoutes.get("/:id/messages", async (c) => c.json({ data: [], meta: { total: 0 } }));
conversationRoutes.get("/:id/metadata", async (c) => c.json({ data: null, error: "not implemented" }, 501));
conversationRoutes.get("/:id/edits", async (c) => c.json({ data: [] }));
conversationRoutes.post("/:id/edits", async (c) => c.json({ data: null, error: "not implemented" }, 501));
conversationRoutes.post("/bulk", async (c) => c.json({ data: null, error: "not implemented" }, 501));
